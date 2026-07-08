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

## Mock 账号

```text
管理员：admin / admin123
社区工作人员：worker / worker123
```

## 说明

- 默认 `.env` 中 `VITE_USE_MOCK=true`，可直接使用 Mock 数据演示。
- 联调真实后端时，将 `VITE_USE_MOCK=false`，并确保后端接口按 `/api/v1`、`code:0` 返回。
- 提交 Gitee 时不要提交 `node_modules/` 和 `dist/`，依赖通过 `package-lock.json` 还原。
