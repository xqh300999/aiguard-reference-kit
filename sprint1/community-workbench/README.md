# AiGuard 社区工作台 Mock 版

这是李凯辉负责的社区工作台 Web 前端，当前采用 Mock 数据优先开发，不依赖后端即可演示完整 MVP 流程。

## 启动

```bash
npm.cmd install
npm.cmd run dev
```

默认地址：

```text
http://127.0.0.1:5173/
```

## Mock 账号

```text
账号：worker
密码：worker123
```

## 已实现功能

- 登录与路由守卫
- 工作台首页：最新 5 条待处理告警
- 告警列表：全部、待处理、处理中、已解决 Tab 和分页
- 告警详情：老人信息、告警信息、时间线
- 接单：`POST /api/v1/dispatches`
- 处理完成：`PATCH /api/v1/dispatches/{id}`
- 老人详情兜底：`GET /api/v1/elderly/{id}`

## 验收路径

团队规范路径：

```text
/worker
/worker/alerts
/worker/alerts/1001
```

任务清单验收路径也可直接访问：

```text
/
/alerts
/alerts/1001
```

未登录访问以上路径都会跳转到 `/login`。

## 当前 Mock 接口

```text
POST /api/v1/auth/login
GET /api/v1/alerts
GET /api/v1/alerts/{id}
GET /api/v1/elderly/{id}
POST /api/v1/dispatches
GET /api/v1/dispatches/alert/{alertId}
PATCH /api/v1/dispatches/{id}
```

## 切换真实后端

当前默认启用 Mock。后端完成后，新增 `.env.local`：

```env
VITE_USE_MOCK=false
VITE_API_BASE_URL=http://后端服务器地址:8080/api/v1
```

页面代码不用改，继续通过 `src/api/*.ts` 调接口。

## 自测

```bash
npm.cmd run lint
npm.cmd run build
```
