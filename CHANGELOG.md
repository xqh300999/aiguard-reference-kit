# 更新日志

本文档记录 AiGuard 参考资料包的所有版本变更。

## [1.2.0] - 2026-07-04

### 新增
- 新增 `09-course-operation/` 小学期课程运行规则目录：
  - Git 分支、提交、PR/MR 与 Issue 关联规则
  - Issue 技术求助、Bug 报告、教师介入和关闭规范
  - Sprint 0-3 与终期验收清单
  - 课程考核与过程证据说明
  - 教师运行建议
  - 技术求助、Bug、每日站会、Sprint 评审模板

### 变更
- 更新根 `README.md`，增加“小学期课程协作入口”和 `09-course-operation/` 知识地图。
- 更新 `skills/aiguard-knowledge/SKILL.md`，将课程协作规则纳入知识地图，并说明 Skill 依赖完整 `00-09` 资料包。

## [1.1.1] - 2026-06-29

### 新增
- README.md 新增「致谢与开源项目引用」章节，明确列出所有依赖的开源项目地址
  - 核心依赖：小智ESP32、小智服务端、ESP-IDF、Home Assistant、Spring Boot、openGauss、Vue3、HarmonyOS、Mosquitto、Caddy、Docker
  - 硬件与板级支持：Waveshare BSP、LVGL
  - 参考资源：小智Releases/Wiki/Issues、ESP-IDF文档、HA文档、Spring Boot文档、鸿蒙开发文档、Vue3文档

### 变更
- **Skill目录迁移**：从 `.trae/skills/aiguard-knowledge/` 迁移到 `skills/aiguard-knowledge/`（仓库根目录）
  - `.trae/skills/` 是 Trae 专用路径，Claude Code / Codex / Cursor 等平台不识别
  - `skills/` 是社区主流做法（如 garden-skills 仓库），兼容所有 Agent 平台
  - 更新所有文档中的路径引用和相对路径（`../../../` → `../../`）

## [1.1.0] - 2026-06-29

### 新增
- 添加 ESP32-P4 中控屏 V0.5（纯Dashboard固件）和 V1.0（接入小智语音）完整开发经验文档
- 新增 04-hardware/esp32-p4-panel/firmware-versions.md 固件版本对比文档
- 更新故障排查文档，添加 P4 已知问题（启动crash、触摸错位、中文不显示等8个问题）
- 更新 P4 刷写指南，添加 V0.5/V1.0 版本选择和配网流程

### 变更
- **固件分发方式变更**：固件二进制文件从仓库中移除，改为通过 Gitee Release 下载
- **Skill 标准化**：更新 manifest.json，添加安装说明，支持多平台标准安装
- 更新 .gitignore，忽略固件二进制文件
- 更新根 README.md，完善知识地图和 Skill 安装说明
- 更新固件目录文档，所有固件改为下载链接方式

### 修复
- 修正 P4 适配状态：从"待适配"改为"已适配"
- 修正 ESP-IDF 版本要求：明确为 v5.5.2

## [1.0.0] - 2026-06-27

### 新增
- 初始版本发布
- 提供 AiGuard 项目完整参考资料包结构
- 包含入门指南、敏捷开发实践、项目概览等核心文档
- 提供分角色学习路径指引
- 提供 Sprint 规划、站会、回顾等模板
- 明确功能目标与非功能需求，不限制实现方式

---

版本格式遵循 [Semantic Versioning](https://semver.org/) 规范：主版本号.次版本号.修订号
