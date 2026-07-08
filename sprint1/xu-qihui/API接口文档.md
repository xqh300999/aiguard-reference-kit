# AiGuard 智慧养老管理系统 — API 接口文档

> **基础路径：** `http://<服务器地址>:8080`
> **接口前缀：** 所有接口路径以 `/api/v1` 开头（如 `/api/v1/auth/login`）
> **认证方式：** 所有接口（除登录外）请求头需携带 `Authorization: Bearer <token>`
> **统一返回格式：** `{ code: int, message: string, data: object, ts: string }`
> **成功码：** `code: 0`（不是 200）
> **时间戳：** ISO 8601 格式，如 `"2026-07-05T10:00:00Z"`
> **分页参数：** `?page=1&size=20`，响应为 `{ records: [], total: int, page: int, size: int }`

---

## 目录

- [1. 认证相关](#1-认证相关)
- [2. 用户管理](#2-用户管理)
- [3. 社区管理](#3-社区管理)
- [4. 老人档案](#4-老人档案)
- [5. 设备管理](#5-设备管理)
- [6. 告警管理](#6-告警管理)
- [7. 派单管理](#7-派单管理)
- [8. 关怀计划](#8-关怀计划)
- [9. 关怀记录](#9-关怀记录)
- [10. 统计报表](#10-统计报表)
- [11. AI 功能](#11-ai-功能)
- [12. 通知](#12-通知)
- [13. WebSocket](#13-websocket)

---

## 1. 认证相关

### 1.1 用户登录

```
POST /api/v1/auth/login
```

**Request Body：**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response 200 成功：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "userId": 1,
    "role": "ADMIN",
    "realName": "管理员"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| token | String | JWT Token，有效期 24 小时 |
| userId | Long | 用户 ID |
| role | String | 角色：ADMIN / WORKER / FAMILY / ELDERLY |
| realName | String | 真实姓名 |

**Response 401 用户名或密码错误：**
```json
{
  "code": 401,
  "message": "用户名或密码错误",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 1.2 Token 刷新

```
POST /api/v1/auth/refresh
```

**Request Header：** `Authorization: Bearer <即将过期的token>`

**Request Body：** 无

**Response 200：**
```json
{
  "code": 0,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "expiresIn": 86400
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

**Response 401 Token 过期/无效：**
```json
{
  "code": 401,
  "message": "Token 已过期，请重新登录",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

---

## 2. 用户管理

### 2.1 创建用户

```
POST /api/v1/users
```

**Request Body：**
```json
{
  "username": "zhangsan",
  "password": "pass123",
  "realName": "张三",
  "phone": "13800138000",
  "role": "WORKER",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | String | 是 | 登录账号，唯一 |
| password | String | 是 | 密码，≥6 位 |
| realName | String | 是 | 真实姓名 |
| phone | String | 否 | 手机号 |
| role | String | 是 | ADMIN / WORKER / FAMILY / ELDERLY |
| communityId | Long | 否 | ADMIN 角色可不填，其他角色必填 |

### 2.2 用户列表

```
GET /api/v1/users?page=1&size=20&communityId=1&role=WORKER
```

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码，从 1 开始 |
| size | int | 每页条数 |
| communityId | Long | 按社区筛选 |
| role | String | 按角色筛选 |

**Response：**
```json
{
  "code": 0,
  "data": {
    "records": [
      {
        "id": 1,
        "username": "zhangsan",
        "realName": "张三",
        "role": "WORKER",
        "phone": "13800138000",
        "communityId": 1,
        "status": "ACTIVE"
      }
    ],
    "total": 10,
    "page": 1,
    "size": 20
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 2.3 用户详情

```
GET /api/v1/users/{id}
```

**Response 200：**
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "username": "zhangsan",
    "realName": "张三",
    "role": "WORKER",
    "phone": "13800138000",
    "communityId": 1,
    "communityName": "幸福社区",
    "status": "ACTIVE",
    "createdAt": "2026-07-01T08:00:00Z"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

**Response 404 用户不存在：**
```json
{
  "code": 404,
  "message": "用户不存在",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 2.4 更新用户

```
PUT /api/v1/users/{id}
```

**Request Body：**
```json
{
  "realName": "张三丰",
  "phone": "13900139000",
  "role": "WORKER",
  "communityId": 2
}
```

> 不传 `password` 则不修改密码。如需改密码：`{"password": "newpass123"}`

### 2.5 删除用户

```
DELETE /api/v1/users/{id}
```

**Response 200：**
```json
{ "code": 0, "message": "删除成功", "data": null, "ts": "2026-07-05T10:00:00Z" }
```

**Response 500 服务端错误：**
```json
{ "code": 500, "message": "服务器内部错误", "data": null, "ts": "2026-07-05T10:00:00Z" }
```

---

## 3. 社区管理

### 3.1 创建社区

```
POST /api/v1/communities
```

**Request Body：**
```json
{
  "name": "幸福社区",
  "address": "北京市海淀区中关村大街1号",
  "area": "海淀区"
}
```

### 3.2 社区列表

```
GET /api/v1/communities
```

**Response：**
```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "name": "幸福社区",
      "address": "北京市海淀区中关村大街1号",
      "area": "海淀区",
      "elderlyCount": 15,
      "deviceCount": 8,
      "createdAt": "2026-07-01T08:00:00Z"
    }
  ],
  "ts": "2026-07-05T10:00:00Z"
}
```

### 3.3 社区详情

```
GET /api/v1/communities/{id}
```

### 3.4 更新社区

```
PUT /api/v1/communities/{id}
```

**Request Body：**
```json
{
  "name": "幸福家园社区",
  "address": "北京市海淀区中关村大街2号",
  "area": "海淀区"
}
```

### 3.5 删除社区

```
DELETE /api/v1/communities/{id}
```

> 社区下存在老人或用户时无法删除，返回 400。

**Response 400：**
```json
{
  "code": 400,
  "message": "该社区下还有 5 位老人，无法删除",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

---

## 4. 老人档案

### 4.1 创建老人档案

```
POST /api/v1/elderly
```

**Request Body：**
```json
{
  "name": "王大爷",
  "age": 78,
  "gender": "MALE",
  "address": "幸福社区3号楼101",
  "phone": "010-88886666",
  "emergencyContact": "13800138001",
  "healthNotes": "高血压，每天服药",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| communityId | Long | 是 | 所属社区，不存在返回 400 |

**Response 400 参数错误：**
```json
{
  "code": 400,
  "message": "communityId 不存在",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 4.2 老人列表

```
GET /api/v1/elderly?page=1&size=20&communityId=1&status=ACTIVE&name=王
```

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 |
| size | int | 每页条数 |
| communityId | Long | 按社区筛选 |
| status | String | ACTIVE / INACTIVE |
| name | String | 姓名模糊搜索 |

### 4.3 老人详情

```
GET /api/v1/elderly/{id}
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "name": "王大爷",
    "age": 78,
    "gender": "MALE",
    "address": "幸福社区3号楼101",
    "phone": "010-88886666",
    "emergencyContact": "13800138001",
    "healthNotes": "高血压，每天服药",
    "communityId": 1,
    "communityName": "幸福社区",
    "device": {
      "id": 1,
      "name": "王大爷的手表",
      "type": "WATCH",
      "status": "ONLINE",
      "lastHeartbeat": "2026-07-05T09:59:00Z",
      "battery": 85
    },
    "status": "ACTIVE",
    "createdAt": "2026-07-01T08:00:00Z"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 4.4 更新老人档案

```
PUT /api/v1/elderly/{id}
```

**Request Body：** 同 4.1，可只传需要修改的字段

### 4.5 删除老人档案

```
DELETE /api/v1/elderly/{id}
```

> 删除后关联设备的 `elderlyId` 自动清空，关联告警保留但标记。

### 4.6 老人告警历史

```
GET /api/v1/elderly/{id}/alerts?page=1&size=20&status=PENDING
```

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 |
| size | int | 每页条数 |
| status | String | 筛选状态 |

**Response：**
```json
{
  "code": 0,
  "data": {
    "records": [
      {
        "id": 1,
        "type": "SOS",
        "typeName": "紧急求助",
        "status": "PENDING",
        "statusName": "待处理",
        "cause": null,
        "details": null,
        "happenedAt": "2026-07-05T10:30:00Z",
        "resolvedAt": null,
        "handlerName": null
      }
    ],
    "total": 3,
    "page": 1,
    "size": 20
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

---

## 5. 设备管理

### 5.1 创建设备

```
POST /api/v1/devices
```

**Request Body：**
```json
{
  "name": "王大爷的手表",
  "type": "WATCH",
  "mac": "A1:B2:C3:D4:E5:F6",
  "communityId": 1
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| type | String | WATCH(手表) / PANEL(大屏) / GATEWAY(网关) |

### 5.2 设备列表

```
GET /api/v1/devices?communityId=1&elderlyId=1&status=ONLINE&page=1&size=20
```

| 参数 | 类型 | 说明 |
|------|------|------|
| communityId | Long | 按社区筛选 |
| elderlyId | Long | 按老人筛选 |
| status | String | ONLINE / OFFLINE |

### 5.3 设备详情

```
GET /api/v1/devices/{id}
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "name": "王大爷的手表",
    "type": "WATCH",
    "mac": "A1:B2:C3:D4:E5:F6",
    "communityId": 1,
    "elderlyId": 1,
    "elderlyName": "王大爷",
    "status": "ONLINE",
    "battery": 85,
    "lastHeartbeat": "2026-07-05T09:59:00Z",
    "createdAt": "2026-07-01T08:00:00Z"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 5.4 更新设备

```
PUT /api/v1/devices/{id}
```

**Request Body：**
```json
{
  "name": "王大爷的手表-v2",
  "type": "WATCH"
}
```

### 5.5 删除设备

```
DELETE /api/v1/devices/{id}
```

### 5.6 绑定老人

```
POST /api/v1/devices/{id}/bind
```

**Request Body：**
```json
{
  "elderlyId": 1
}
```

> 校验：elderly 必须存在、该 elderly 未绑定其他设备。绑定成功后同步更新 `elderly.deviceMac`。

**Response 400：**
```json
{
  "code": 400,
  "message": "该老人已绑定设备",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 5.7 解绑老人

```
POST /api/v1/devices/{id}/unbind
```

> 解绑后同步清空 `device.elderlyId` 和 `elderly.deviceMac`。

---

## 6. 告警管理

### 6.1 创建告警（从 App 或 MQTT 触发）

```
POST /api/v1/alerts
```

**Request Body：**
```json
{
  "type": "SOS",
  "elderlyId": 1,
  "source": "APP",
  "lat": 30.5728,
  "lng": 104.0668
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| type | String | SOS / FALL / INACTIVITY / LOW_BATTERY / DEVICE_OFFLINE / ABNORMAL |
| source | String | APP(老人端App触发) / WATCH(手表SOS) / RULE(规则引擎) / SYSTEM |
| lat/lng | Double | 选填，GPS 坐标 |

> SOS 类型优先级为 HIGH，其余类型默认 MEDIUM。

### 6.2 告警列表

```
GET /api/v1/alerts?communityId=1&status=PENDING&type=SOS&page=1&size=20
```

| 参数 | 类型 | 说明 |
|------|------|------|
| communityId | Long | 按社区筛选 |
| status | String | PENDING(待处理) / PROCESSING(处理中) / RESOLVED(已解决) / NEED_HOSPITAL(需送医) |
| type | String | SOS / FALL / INACTIVITY / LOW_BATTERY / DEVICE_OFFLINE / ABNORMAL |
| page | int | 页码 |
| size | int | 每页条数 |

**Response：**
```json
{
  "code": 0,
  "data": {
    "records": [
      {
        "id": 1,
        "type": "SOS",
        "typeName": "紧急求助",
        "elderlyId": 1,
        "elderlyName": "王大爷",
        "communityId": 1,
        "communityName": "幸福社区",
        "status": "PENDING",
        "statusName": "待处理",
        "priority": "HIGH",
        "handlerId": null,
        "handlerName": null,
        "happenedAt": "2026-07-05T10:30:00Z",
        "resolvedAt": null
      }
    ],
    "total": 5,
    "page": 1,
    "size": 20
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 6.3 告警详情

```
GET /api/v1/alerts/{id}
```

**Response：** 同 6.2 records 内单条 + cause/details/dispatch

### 6.4 更新告警（状态流转）

```
PATCH /api/v1/alerts/{id}
```

**Request Body：**
```json
{
  "status": "PROCESSING",
  "cause": "老人误触SOS按钮",
  "details": "到达现场检查无异常"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | String | 是 | PENDING→PROCESSING→RESOLVED 单向流转，不能回退 |
| cause | String | 否 | 告警原因 |
| details | String | 否 | 处理详情 |

**Response 400 状态回退：**
```json
{
  "code": 400,
  "message": "告警已解决，不能回退到处理中",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

---

## 7. 派单管理

### 7.1 创建派单

```
POST /api/v1/dispatches
```

**Request Body：**
```json
{
  "alertId": 1,
  "handlerId": 2
}
```

> 创建后自动将 alert 状态改为 PROCESSING。

**Response 400：**
```json
{
  "code": 400,
  "message": "该告警已被接单",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 7.2 派单详情

```
GET /api/v1/dispatches/{id}
```

### 7.3 按告警查派单

```
GET /api/v1/dispatches/alert/{alertId}
```

### 7.4 按处理人查派单

```
GET /api/v1/dispatches/handler/{handlerId}?page=1&size=20
```

### 7.5 更新派单（填写处理结果）

```
PATCH /api/v1/dispatches/{id}
```

**Request Body：**
```json
{
  "description": "到达现场发现老人摔倒在地，已扶起检查无大碍",
  "result": "RESOLVED"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| description | String | 处理描述 |
| result | String | RESOLVED(已解决) / NEED_HOSPITAL(需送医) / NEED_FOLLOW_UP(需跟进) |

> 填写后自动：dispatch 状态变为 COMPLETED + 根据 result 更新 alert 对应状态。

---

## 8. 关怀计划

### 8.1 创建关怀计划

```
POST /api/v1/care-plans
```

**Request Body：**
```json
{
  "elderlyId": 1,
  "workerId": 2,
  "planType": "PHONE_CALL",
  "frequency": "WEEKLY",
  "startDate": "2026-07-01",
  "endDate": "2026-09-30",
  "notes": "每周电话了解老人身体状况"
}
```

| 字段 | 说明 |
|------|------|
| planType | PHONE_CALL(电话) / VISIT(走访) / MEDICINE_REMIND(用药提醒) / OTHER(其他) |
| frequency | DAILY(每天) / EVERY_2_DAYS(每2天) / WEEKLY(每周) / MONTHLY(每月) |

### 8.2 关怀计划列表

```
GET /api/v1/care-plans?workerId=2&elderlyId=1&status=ACTIVE
```

| 参数 | 说明 |
|------|------|
| status | ACTIVE / COMPLETED / CANCELLED |

### 8.3 关怀计划详情

```
GET /api/v1/care-plans/{id}
```

### 8.4 更新关怀计划

```
PUT /api/v1/care-plans/{id}
```

### 8.5 删除关怀计划

```
DELETE /api/v1/care-plans/{id}
```

> 有已执行记录时，标记为 CANCELLED，不物理删除。

---

## 9. 关怀记录

### 9.1 创建关怀记录

```
POST /api/v1/care-logs
```

**Request Body：**
```json
{
  "planId": 1,
  "workerId": 2,
  "type": "PHONE",
  "elderlyStatus": "GOOD",
  "notes": "老人精神状态良好，血压正常"
}
```

| 字段 | 说明 |
|------|------|
| type | PHONE(电话) / VISIT(走访) / MEDICINE(用药提醒) / OTHER(其他) |
| elderlyStatus | GOOD(良好) / FAIR(一般) / POOR(较差) / EMERGENCY(紧急) |

### 9.2 关怀记录列表

```
GET /api/v1/care-logs?planId=1&workerId=2&page=1&size=20
```

### 9.3 关怀记录详情

```
GET /api/v1/care-logs/{id}
```

---

## 10. 统计报表

### 10.1 仪表盘总览

```
GET /api/v1/stats/overview?communityId=1
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "totalElderly": 50,
    "todayAlerts": 3,
    "onlineDevices": 12,
    "pendingAlerts": 5
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 10.2 告警统计趋势

```
GET /api/v1/stats/alerts/{communityId}?period=weekly
```

| 参数 | 说明 |
|------|------|
| period | daily(按天) / weekly(按周) / monthly(按月) |

### 10.3 关怀统计

```
GET /api/v1/stats/care/{communityId}?period=weekly
```

### 10.4 导出 Excel

```
GET /api/v1/stats/export?communityId=1
```

> 下载一个包含 3 个 Sheet 的 Excel：老人列表、告警统计、关怀统计。

---

## 11. AI 功能

### 11.1 健康评分

```
GET /api/v1/elderly/{id}/health-score
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "score": 85,
    "breakdown": {
      "activity": 35,
      "alerts": 25,
      "care": 18,
      "online": 7
    },
    "evaluateAt": "2026-07-05T10:00:00Z"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

> 评分算法：活动量(40%) + 告警频率(30%) + 关怀覆盖率(20%) + 设备在线(10%)。

### 11.2 AI 健康报告

```
GET /api/v1/elderly/{id}/ai-report
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "report": "王大爷今日活动量偏低（较昨日减少60%），建议家属关注其活动情况。近7天无异常告警。当前健康评分85分（良好）。建议：安排社区人员明日走访。",
    "generatedAt": "2026-07-05T10:00:00Z"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

> 由通义千问生成自然语言报告。AI 服务不可用时返回 503。

### 11.3 触发 AI 日报生成

```
POST /api/v1/ai/generate-daily-report
```

**Request Body：**
```json
{
  "elderlyId": 1
}
```

---

## 12. 通知

### 12.1 通知列表

```
GET /api/v1/notifications?userId=1&page=1&size=20
```

### 12.2 标记已读

```
PATCH /api/v1/notifications/{id}/read
```

### 12.3 未读数

```
GET /api/v1/notifications/unread-count?userId=1
```

**Response：**
```json
{
  "code": 0,
  "data": {
    "unreadCount": 3
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

---

## 13. WebSocket

### 13.1 连接地址

```
WS /ws/alerts?token=<JWT_TOKEN>
```

### 13.2 推送消息格式

```json
{
  "type": "NEW_ALERT",
  "data": {
    "alertId": 1,
    "type": "SOS",
    "elderlyName": "王大爷",
    "communityId": 1,
    "happenedAt": "2026-07-05T10:30:00Z"
  }
}
```

| type | 说明 |
|------|------|
| NEW_ALERT | 新告警产生 |
| ALERT_UPDATE | 告警状态变更 |
| DEVICE_STATUS | 设备在线状态变化 |

---

## 附录：状态码速查

| code | 含义 | 处理方式 |
|------|------|---------|
| 0 | 成功 | 正常解析 data |
| 400 | 参数错误 | 弹窗显示 message |
| 401 | Token 无效 / 未认证 | 跳转登录页 |
| 403 | 无权限 | 提示无权限访问 |
| 404 | 资源不存在 | 提示未找到 |
| 500 | 服务端错误 | 弹窗显示 message |
| 503 | 服务暂不可用 | AI 等外部服务不可用时 |

---

*文档版本：v2.0 | 最后更新：2026-07-05*
