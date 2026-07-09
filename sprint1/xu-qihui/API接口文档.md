# AiGuard 智慧养老管理系统 — API 接口文档

> **基础路径：** `http://<服务器地址>:8080`
> **移动端接口前缀：** `/api/v1`（如 `/api/v1/auth/login`）
> **网页端接口前缀：** `/api/web/v1`（如 `/api/web/v1/auth/register`）
> **认证方式：** 所有接口（除登录/注册外）请求头需携带 `Authorization: Bearer <token>`
> **统一返回格式：** `{ code: int, message: string, data: object, ts: string }`
> **成功码：** `code: 0`（不是 200）
> **时间戳：** ISO 8601 格式，如 `"2026-07-05T10:00:00Z"`
> **分页参数：** `?page=1&size=20`，响应为 `{ records: [], total: int, page: int, size: int }`

---

## 目录

- [1. 认证相关](#1-认证相关)
  - [1.1 用户登录](#11-用户登录)
  - [1.2 Token 刷新](#12-token-刷新)
  - [1.3 用户注册](#13-用户注册)
  - [1.4 用户绑定老人](#14-用户绑定老人)
  - [1.5 按姓名电话绑定老人](#15-按姓名电话绑定老人)
- [2. 用户管理](#2-用户管理)
- [3. 社区管理](#3-社区管理)
- [4. 老人档案](#4-老人档案)
  - [4.1 创建老人档案](#41-创建老人档案)
  - [4.2 老人列表](#42-老人列表)
  - [4.3 家人端注册老人](#43-家人端注册老人)
  - [4.4 搜索老人（用于绑定）](#44-搜索老人用于绑定)
  - [4.5 老人详情](#45-老人详情)
  - [4.6 更新老人档案](#46-更新老人档案)
  - [4.7 删除老人档案](#47-删除老人档案)
  - [4.8 老人告警历史](#48-老人告警历史)
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
    "realName": "管理员",
    "elderlyId": null
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
| elderlyId | Long | 绑定老人 ID，未绑定则为 null |

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

> **⚠️ 尚未实现** — Token 刷新功能待开发，当前 Token 有效期 24 小时。

### 1.3 用户注册

#### 移动端注册（仅限家属）

```
POST /api/v1/auth/register
```

**说明：** 移动端只允许注册 `FAMILY` 角色。

**Request Body：**
```json
{
  "username": "family2",
  "password": "123456",
  "realName": "张三",
  "phone": "13800000005",
  "role": "FAMILY",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | String | 是 | 账号，唯一 |
| password | String | 是 | 密码 |
| realName | String | 是 | 真实姓名 |
| phone | String | 否 | 手机号 |
| role | String | 是 | **仅限 `FAMILY`**，传其他角色返回 400 |
| communityId | Long | 是 | 所属社区 ID |

**Response 200：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 5,
    "username": "family2",
    "realName": "张三",
    "phone": "13800000005",
    "role": "FAMILY",
    "communityId": 1,
    "elderlyId": null,
    "status": "ENABLED"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

**Response 400：** 用户名已存在 / 角色不合法
```json
{
  "code": 400,
  "message": "用户名已存在",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

#### 网页端注册（支持家属 + 社区工作人员）

```
POST /api/web/v1/auth/register
```

**说明：** 网页端允许注册 `FAMILY` 或 `COMMUNITY_WORKER` 角色（不可注册 ADMIN）。

**Request Body：**
```json
{
  "username": "worker3",
  "password": "123456",
  "realName": "李四",
  "phone": "13800000006",
  "role": "COMMUNITY_WORKER",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | String | 是 | 账号，唯一 |
| password | String | 是 | 密码 |
| realName | String | 是 | 真实姓名 |
| phone | String | 否 | 手机号 |
| role | String | 是 | `FAMILY` 或 `COMMUNITY_WORKER`（不可注册 ADMIN） |
| communityId | Long | 是 | 所属社区 ID |

**Response 200／400：** 格式同移动端。

> **接口设计说明：** 移动端和网页端使用不同的注册接口，移动端 `/api/v1/auth/register` 限制仅可注册家属，网页端 `/api/web/v1/auth/register` 允许注册家属和社区工作人员，实现接口层面的职责分离。

---

## 1.4 用户绑定老人（管理端）

```
PUT /api/v1/users/{userId}/bind
```

**说明：** 适用于管理后台（ADMIN 角色），已知老人 ID 时直接绑定。

**请求头：** `Authorization: Bearer <token>`

**Request Body：**
```json
{
  "elderlyId": 1
}
```

**Response 200：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 4,
    "username": "family1",
    "role": "FAMILY",
    "realName": "王五",
    "elderlyId": 1,
    "communityId": 1,
    "status": "ENABLED"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

## 1.5 按姓名电话绑定老人（家人端）

```
PUT /api/v1/users/{userId}/bind-by-contact
```

**说明：** 家人端专用。通过老人姓名 + 电话匹配并绑定，无需知道数据库 ID。
适合流程：注册家属账号 → 注册老人信息 → 按姓名电话绑定。

**请求头：** `Authorization: Bearer <token>`

**Request Body：**
```json
{
  "name": "测试老人",
  "phone": "13800000999"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 老人姓名，精确匹配 |
| phone | String | 是 | 老人电话，精确匹配 |

**Response 200：** 返回用户信息（含 elderlyId）
```json
{
  "code": 0,
  "data": {
    "id": 4,
    "username": "family1",
    "role": "FAMILY",
    "realName": "王五",
    "elderlyId": 5,
    "communityId": 1,
    "status": "ENABLED"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

**Response 400：** 未找到匹配的老人
```json
{
  "code": 400,
  "message": "未找到匹配的老人，请检查姓名和电话",
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

### 4.3 家人端注册老人

```
POST /api/v1/elderly/register
```

**说明：** 家人端（FAMILY 角色）注册老人信息，创建老人档案。与 4.1 创建老人档案功能相同，但权限上 FAMILY 角色可调用。

**Request Body：**
```json
{
  "name": "测试老人",
  "age": 80,
  "gender": "MALE",
  "address": "测试地址",
  "phone": "13800000999",
  "emergencyContact": "13800000100",
  "healthNotes": "高血压，需定期服药",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 老人姓名 |
| age | Integer | 否 | 年龄 |
| gender | String | 是 | MALE / FEMALE |
| address | String | 否 | 住址 |
| phone | String | 否 | 电话号码（用于绑定） |
| emergencyContact | String | 否 | 紧急联系人 |
| healthNotes | String | 否 | 健康备注 |
| communityId | Long | 是 | 所属社区 |

**Response 200：**
```json
{
  "code": 0,
  "data": {
    "id": 5,
    "name": "测试老人",
    "age": 80,
    "gender": "MALE",
    "communityId": 1,
    "phone": "13800000999",
    "status": "NORMAL"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

### 4.4 搜索老人（用于绑定）

```
GET /api/v1/elderly/search?keyword=王
```

| 参数 | 类型 | 说明 |
|------|------|------|
| keyword | String | 姓名关键词，模糊搜索 |

**Response：**
```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "name": "王大爷",
      "age": 78,
      "gender": "MALE",
      "communityId": 1,
      "phone": "010-88886666"
    }
  ],
  "ts": "2026-07-05T10:00:00Z"
}
```

### 4.5 老人详情

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

### 4.6 更新老人档案

#### 管理端 / 网页端 — 按 ID 更新

```
PUT /api/v1/elderly
```

**说明：** ADMIN 和 FAMILY 可调用。通过 body 中的 `id` 字段指定要更新的老人。

**请求头：** `Authorization: Bearer <token>`

**Request Body：**
```json
{
  "id": 5,
  "address": "阳光花园小区3栋2单元501室",
  "name": "测试老人",
  "age": 80,
  "gender": "MALE",
  "phone": "13800000999",
  "emergencyContact": "13800000100",
  "healthNotes": "高血压，需定期服药",
  "communityId": 1
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | Long | 是 | 老人 ID，指定要更新的记录 |
| name | String | 否 | 老人姓名 |
| age | Integer | 否 | 年龄 |
| gender | String | 否 | MALE / FEMALE |
| address | String | 否 | 详细住址（建议填到门牌号） |
| phone | String | 否 | 电话号码 |
| emergencyContact | String | 否 | 紧急联系人 |
| healthNotes | String | 否 | 健康备注 |
| communityId | Long | 否 | 所属社区 |

**Response 200：**
```json
{
  "code": 0,
  "message": "success",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

#### 家人端 — 按姓名电话更新

```
PUT /api/v1/elderly/update-by-contact
```

**说明：** ADMIN 和 FAMILY 可调用。通过老人姓名 + 电话匹配记录并更新，无需知道数据库 ID。
`address` 字段建议填写详细地址到门牌号（如 "阳光花园小区3栋2单元501室"）。

**请求头：** `Authorization: Bearer <token>`

**Request Body：**
```json
{
  "name": "测试老人",
  "phone": "13800000999",
  "address": "阳光花园小区3栋2单元501室",
  "healthNotes": "高血压，需定期服药"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 老人姓名，用于匹配 |
| phone | String | 是 | 老人电话，用于匹配 |
| address | String | 否 | 详细住址（建议填到门牌号） |
| age | Integer | 否 | 年龄 |
| gender | String | 否 | MALE / FEMALE |
| emergencyContact | String | 否 | 紧急联系人 |
| healthNotes | String | 否 | 健康备注 |
| communityId | Long | 否 | 所属社区 |

**Response 200：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 5,
    "name": "测试老人",
    "age": 80,
    "gender": "MALE",
    "address": "阳光花园小区3栋2单元501室",
    "phone": "13800000999",
    "healthNotes": "高血压，需定期服药",
    "communityId": 1,
    "status": "NORMAL"
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

**Response 400 未找到：**
```json
{
  "code": 400,
  "message": "未找到匹配的老人，请检查姓名和电话",
  "data": null,
  "ts": "2026-07-05T10:00:00Z"
}
```

### 4.7 删除老人档案

```
DELETE /api/v1/elderly/{id}
```

**说明：** 仅 ADMIN 和 FAMILY 可调用。COMMUNITY_WORKER 无删除权限。

> 删除后关联设备的 `elderlyId` 自动清空，关联告警保留但标记。

### 4.8 老人告警历史

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
GET /api/v1/stats/overview/{communityId}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| communityId | Long | 是 | 社区 ID（路径参数） |

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

| 字段 | 类型 | 说明 |
|------|------|------|
| totalElderly | Long | 老人总数 |
| todayAlerts | Long | 今日告警数（happened_at >= 今日 00:00） |
| onlineDevices | Long | 在线设备数（status = 'ONLINE'） |
| pendingAlerts | Long | 待处理告警数（status = 'PENDING'） |

### 10.2 告警统计趋势

```
GET /api/v1/stats/alerts/{communityId}?period=weekly
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| communityId | Long | 是 | 社区 ID（路径参数） |
| period | String | 否 | 统计周期：daily(按天，近7天) / weekly(按周，近4周，默认) / monthly(按月，近6个月) |

**Response：**
```json
{
  "code": 0,
  "data": {
    "period": "weekly",
    "records": [
      {
        "label": "2026-W28",
        "total": 2,
        "details": [
          { "type": "SOS", "count": 1 },
          { "type": "INACTIVITY", "count": 1 }
        ]
      },
      {
        "label": "2026-W27",
        "total": 4,
        "details": [
          { "type": "FALL", "count": 1 },
          { "type": "LOW_BATTERY", "count": 1 },
          { "type": "ABNORMAL", "count": 1 },
          { "type": "SOS", "count": 1 }
        ]
      }
    ]
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| period | String | 统计周期 |
| records | Array | 趋势记录列表，按时间正序 |
| records[].label | String | 时间标签（daily: `2026-07-05` / weekly: `2026-W28` / monthly: `2026-07`） |
| records[].total | Long | 该时间段告警总数 |
| records[].details | Array | 按告警类型分类的明细 |
| records[].details[].type | String | 告警类型：SOS / FALL / INACTIVITY / LOW_BATTERY / DEVICE_OFFLINE / ABNORMAL |
| records[].details[].count | Long | 该类型告警数量 |

### 10.3 关怀统计

```
GET /api/v1/stats/care/{communityId}?period=weekly
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| communityId | Long | 是 | 社区 ID（路径参数） |
| period | String | 否 | 统计周期：daily(按天，近7天) / weekly(按周，近4周，默认) / monthly(按月，近6个月) |

**Response：**
```json
{
  "code": 0,
  "data": {
    "period": "weekly",
    "records": [
      {
        "label": "2026-W28",
        "total": 3,
        "details": [
          { "type": "PHONE", "count": 1 },
          { "type": "VISIT", "count": 1 },
          { "type": "MEDICINE", "count": 1 }
        ]
      },
      {
        "label": "2026-W27",
        "total": 2,
        "details": [
          { "type": "PHONE", "count": 2 }
        ]
      }
    ]
  },
  "ts": "2026-07-05T10:00:00Z"
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| period | String | 统计周期 |
| records | Array | 趋势记录列表，按时间正序 |
| records[].label | String | 时间标签（daily: `2026-07-05` / weekly: `2026-W28` / monthly: `2026-07`） |
| records[].total | Long | 该时间段关怀记录总数 |
| records[].details | Array | 按关怀类型分类的明细 |
| records[].details[].type | String | 关怀类型：PHONE(电话) / VISIT(走访) / MEDICINE(用药提醒) / OTHER(其他) |
| records[].details[].count | Long | 该类型关怀数量 |

### 10.4 导出 Excel

```
GET /api/v1/stats/export?communityId=1
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| communityId | Long | 否 | 社区 ID，不传则导出全部社区 |

**Response：** 直接返回 Excel 文件流（`Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`），浏览器自动下载 `统计报表.xlsx`。

Excel 包含 3 个 Sheet：

| Sheet | 名称 | 列 |
|-------|------|-----|
| 1 | 老人列表 | ID / 姓名 / 年龄 / 性别 / 社区 / 电话 / 紧急联系人 / 健康备注 / 状态 |
| 2 | 告警统计 | ID / 类型 / 老人姓名 / 社区 / 状态 / 优先级 / 发生时间 |
| 3 | 关怀统计 | ID / 类型 / 老人姓名 / 护工 / 老人状态 / 备注 / 记录时间 |

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

*文档版本：v2.4 | 最后更新：2026-07-09*

### 接口分离说明

| 端 | 接口前缀 | 注册限制 |
|----|---------|---------|
| **移动端 (HarmonyOS)** | `/api/v1/...` | 仅 `FAMILY` |
| **网页端 (Vue Admin)** | `/api/web/v1/...` | `FAMILY` + `COMMUNITY_WORKER` |

> 网页端通过 Vite 代理将 `/api` 路径自动映射到 `/api/v1`（共享接口）或 `/api/web`（网页专用接口）。移动端直接请求完整路径。
