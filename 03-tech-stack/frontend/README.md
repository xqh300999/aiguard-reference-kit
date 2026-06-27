# 前端技术栈

AIguard 前端包含 Web 管理后台（Vue 3 + Vite + TypeScript）和鸿蒙移动端（HarmonyOS NEXT + ArkTS）。

## 目录

- [Vue 3 + Vite + TypeScript](vue3-vite-ts.md) - Web 管理后台开发
- [HarmonyOS NEXT](harmonyos-next.md) - 鸿蒙原生应用开发
- [官方链接](official-links.md) - Vue/Vite/鸿蒙官方文档链接

## 技术栈概览

| 平台 | 技术 | 版本 | 用途 |
|------|------|------|------|
| Web 管理后台 | Vue 3 | 3.4+ | 响应式 UI 框架 |
| | Vite | 5.x | 构建工具 |
| | TypeScript | 5.x | 类型安全 |
| | Element Plus / Naive UI | - | UI 组件库 |
| | Pinia | 2.x | 状态管理 |
| | Vue Router | 4.x | 路由管理 |
| | ECharts | 5.x | 数据可视化 |
| 鸿蒙移动端 | HarmonyOS NEXT | 5.0+ | 操作系统 |
| | ArkTS | - | 开发语言 |
| | ArkUI | - | 声明式 UI 框架 |
| | DevEco Studio | 5.0+ | IDE |

## 快速参考

```bash
# 创建 Vue 3 + Vite + TS 项目
npm create vue@latest aiguard-admin
# 选择：TypeScript, Vue Router, Pinia, ESLint

# 启动开发服务器
cd aiguard-admin
npm install
npm run dev

# 构建生产版本
npm run build
```

## 常见坑点

1. Vite 使用 ES Module，部分 CommonJS 模块需特殊处理
2. Vue 3 组合式 API 中 `ref` 和 `reactive` 使用场景需区分
3. TypeScript 严格模式下第三方库可能缺少类型定义
4. HarmonyOS NEXT 不支持 Android 应用兼容，必须使用 ArkTS 开发原生应用
5. 鸿蒙应用发布需申请华为开发者账号和证书

## 官方链接

详见 [official-links.md](official-links.md)。
