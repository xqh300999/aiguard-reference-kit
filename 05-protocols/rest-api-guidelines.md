# REST API 设计规范

> **注意**：本文档为**参考约定，可根据实际项目需求调整**。

## 概述

本文档定义 AIguard 服务端 REST API 的设计规范，主要用于：
- Web管理面板与后端交互
- 第三方服务集成
- 配置管理、历史数据查询
- 设备管理接口

API 主要由面板端（ESP32-P4）或外接服务器/网关提供，手表端通常不直接提供REST API（资源受限，主要使用MQTT）。

## 基础规范

### URL 结构

```
https://{host}:{port}/api/{version}/{resource}/{id}/{sub-resource}
```

- 版本号放在URL中：`/api/v1/...`
- 资源名使用复数名词：`/api/v1/devices`, `/api/v1/alerts`
- 使用小写字母和连字符（kebab-case）
- ID使用路径参数：`/api/v1/devices/a1b2c3d4e5f6`

### HTTP 方法

| 方法 | 用途 | 幂等 | 示例 |
|------|------|------|------|
| GET | 查询资源 | 是 | `GET /api/v1/devices` 获取设备列表 |
| GET | 查询单个资源 | 是 | `GET /api/v1/devices/{id}` 获取设备详情 |
| POST | 创建资源/执行动作 | 否 | `POST /api/v1/alerts` 创建告警 |
| PUT | 全量更新资源 | 是 | `PUT /api/v1/devices/{id}/config` 更新配置 |
| PATCH | 部分更新资源 | 否 | `PATCH /api/v1/devices/{id}` 部分更新 |
| DELETE | 删除资源 | 是 | `DELETE /api/v1/devices/{id}` 删除设备 |

### 状态码

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| 200 OK | 请求成功 | GET/PUT/PATCH成功 |
| 201 Created | 创建成功 | POST创建资源成功 |
| 202 Accepted | 已接受，处理中 | 异步操作（如OTA触发） |
| 204 No Content | 成功无返回 | DELETE成功 |
| 400 Bad Request | 请求参数错误 | 参数校验失败 |
| 401 Unauthorized | 未认证 | 缺少/无效Token |
| 403 Forbidden | 无权限 | 权限不足 |
| 404 Not Found | 资源不存在 | 设备/记录不存在 |
| 409 Conflict | 资源冲突 | 重复创建、状态冲突 |
| 422 Unprocessable Entity | 语义错误 | 参数格式正确但业务逻辑错误 |
| 429 Too Many Requests | 请求频率超限 | 限流 |
| 500 Internal Server Error | 服务器错误 | 内部异常 |

### 请求/响应格式

- 统一使用 JSON 格式
- Content-Type: `application/json; charset=utf-8`
- 时间格式：ISO 8601（`2024-06-27T10:00:00Z`）或Unix时间戳
- 字符编码：UTF-8

### 统一响应格式

**成功响应：**
```json
{
  "code": 0,
  "message": "success",
  "data": { ... },
  "ts": 1719000000
}
```

**错误响应：**
```json
{
  "code": 40001,
  "message": "device not found",
  "details": "device id 'a1b2c3d4e5f6' does not exist",
  "ts": 1719000000
}
```

**分页响应：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [ ... ],
    "total": 100,
    "page": 1,
    "page_size": 20,
    "total_pages": 5
  },
  "ts": 1719000000
}
```

### 分页参数
- `page`: 页码，从1开始，默认1
- `page_size`: 每页数量，默认20，最大100
- `sort`: 排序字段，如 `created_at`
- `order`: 排序方向，`asc` / `desc`，默认 `desc`

## 认证

推荐使用 Bearer Token (JWT)：

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

可选：API Key 方式用于服务端集成：
```
X-API-Key: your-api-key-here
```

## API 端点示例

### 设备管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/devices` | 获取设备列表 |
| GET | `/api/v1/devices/{id}` | 获取设备详情 |
| PUT | `/api/v1/devices/{id}/config` | 更新设备配置 |
| GET | `/api/v1/devices/{id}/status` | 获取设备当前状态 |
| POST | `/api/v1/devices/{id}/cmd` | 发送指令到设备 |
| DELETE | `/api/v1/devices/{id}` | 删除设备 |

**发送指令示例：**
```http
POST /api/v1/devices/a1b2c3d4e5f6/cmd
Content-Type: application/json

{
  "type": "audio_play",
  "params": {
    "text": "请注意，检测到异常",
    "volume": 80
  }
}
```

### 告警管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/alerts` | 查询告警列表（支持过滤） |
| GET | `/api/v1/alerts/{id}` | 获取告警详情 |
| POST | `/api/v1/alerts/{id}/ack` | 确认告警 |
| POST | `/api/v1/alerts/{id}/cancel` | 取消告警 |
| GET | `/api/v1/alerts/statistics` | 告警统计 |

**查询参数：**
- `device_id`: 按设备过滤
- `type`: 按告警类型过滤（fall/sos/battery_low/door/smoke）
- `status`: 按状态过滤（active/acknowledged/cancelled/resolved）
- `start_time` / `end_time`: 时间范围
- `page` / `page_size`: 分页

### 传感器数据

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/devices/{id}/sensors/history` | 查询传感器历史数据 |
| GET | `/api/v1/devices/{id}/sensors/latest` | 获取最新传感器数据 |

**历史数据查询参数：**
- `type`: 传感器类型（imu/battery/environment）
- `start_time` / `end_time`: 时间范围
- `interval`: 采样间隔聚合（如 1m/5m/1h）
- `limit`: 返回条数限制

### 固件/OTA

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/firmware` | 获取可用固件版本列表 |
| GET | `/api/v1/firmware/{version}` | 获取固件详情 |
| POST | `/api/v1/devices/{id}/ota` | 触发设备OTA升级 |
| GET | `/api/v1/devices/{id}/ota/status` | 查询OTA状态 |

**触发OTA示例：**
```http
POST /api/v1/devices/a1b2c3d4e5f6/ota
Content-Type: application/json

{
  "version": "2.2.4",
  "force": false,
  "md5": "d41d8cd98f00b204e9800998ecf8427e",
  "url": "https://example.com/firmware/xiaozhi-v2.2.4.bin"
}
```

### 用户/紧急联系人

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/contacts` | 获取紧急联系人列表 |
| POST | `/api/v1/contacts` | 添加紧急联系人 |
| PUT | `/api/v1/contacts/{id}` | 更新联系人 |
| DELETE | `/api/v1/contacts/{id}` | 删除联系人 |

### 系统配置

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/system/config` | 获取系统配置 |
| PUT | `/api/v1/system/config` | 更新系统配置 |
| GET | `/api/v1/system/health` | 健康检查 |
| GET | `/api/v1/system/info` | 系统信息 |

## WebSocket 实时推送（可选）

除REST API外，可提供WebSocket接口用于实时数据推送：

```
wss://{host}:{port}/api/v1/ws
```

订阅频道：
- `device.status.{id}`: 设备状态变化
- `alerts.new`: 新告警
- `sensor.data.{id}`: 实时传感器数据

## API 版本策略

- URL中包含主版本号：`/api/v1/...`, `/api/v2/...`
- 主版本变更表示不兼容的API改动
- 次版本功能增加保持URL不变，通过字段扩展实现
- 旧版本API保留至少一个版本周期的兼容期

## 速率限制

- 建议默认限制：每分钟100次请求
- 批量查询、历史数据接口：每分钟30次
- 认证接口：每分钟10次
- 响应头返回限流信息：
  - `X-RateLimit-Limit`: 总限额
  - `X-RateLimit-Remaining`: 剩余次数
  - `X-RateLimit-Reset`: 重置时间戳
