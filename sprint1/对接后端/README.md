# AiGuard 管理后台与社区工作台

本项目为 Vue3 + Vite + TypeScript + Element Plus 前端项目，包含徐齐晖负责的管理后台和李凯辉负责的社区工作台。

## 运行

```powershell
npm.cmd install
npm.cmd run dev
```

启动后打开终端显示的本地地址，例如：

```text
http://127.0.0.1:5173/
```

## 构建检查

```powershell
npm.cmd run build
```

## 账号

```text
真实后端账号：以后端数据库实际初始化账号为准
Mock 管理员：admin / admin123
Mock 社区工作人员：worker / worker123
```

## 说明

- 当前 `.env` 中 `VITE_USE_MOCK=false`，默认通过 Vite 代理联调 `http://192.168.3.22:8080/api/v1`。
- 如需更换真实后端地址，修改 `.env` 中的 `VITE_API_PROXY_TARGET`。
- 数据总览页已接入统计报表接口：`/stats/alerts/{communityId}`、`/stats/care/{communityId}`、`/stats/export`。
- 如需脱离后端演示，将 `VITE_USE_MOCK=true` 即可切回 Mock 数据。
- 提交 Gitee 时不要提交 `node_modules/` 和 `dist/`，依赖通过 `package-lock.json` 还原。
