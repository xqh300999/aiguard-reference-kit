# AiGuard 参考资料包

> **版本**：v1.1.1 ｜ **协议**：MIT ｜ **用途**：本文档是 AiGuard 参考资料包的入口说明，介绍资料包定位、内容结构、知识地图与使用方式。

## 资料包定位

AiGuard 参考资料包是一套面向智能家居养老看护系统开发的学习与实践指南。本资料包：

- ✅ 提供功能目标与需求说明
- ✅ 提供参考架构与最佳实践
- ✅ 提供开发流程与敏捷实践模板
- ❌ 不限制具体技术实现方式
- ❌ 不强制使用特定框架或工具
- 💡 鼓励创新与探索更优方案

## 知识地图

```
aiguard-reference-kit/
├── 00-getting-started/          # 入门指南
│   ├── prerequisites.md         # 开发环境依赖
│   ├── learning-path.md         # 分角色学习路径
│   └── dev-basics.md            # 开发基础工具
├── 01-agile-development/        # 敏捷开发实践
│   ├── scrum-basics.md          # Scrum 基础
│   ├── sprint-templates/        # Sprint 模板集合（规划/站会/回顾）
│   └── resources.md             # 学习资源
├── 02-project-overview/         # 项目概览
│   ├── functional-requirements.md   # 功能需求
│   ├── system-architecture.md       # 参考架构
│   └── non-functional-requirements.md # 非功能需求
├── 03-tech-stack/               # 技术栈快速参考与官方文档
│   ├── ai/                      # AI（MCP、通义千问API、官方链接）
│   ├── backend/                 # 后端（Java17、Spring Boot 3、MQTT、WebSocket、openGauss）
│   ├── devops/                  # DevOps（Docker、Git）
│   ├── frontend/                # 前端（Vue3+Vite+TS、鸿蒙Next）
│   ├── hardware-platform/       # 硬件平台（树莓派5、ESP32 系列）
│   └── smart-home/              # 智能家居（Home Assistant、小智ESP32）
├── 04-hardware/                 # 硬件规格、引脚定义、刷写指南
│   ├── esp32-s3-watch/          # ESP32-S3 手表（规格、引脚、刷写）
│   ├── esp32-p4-panel/          # ESP32-P4 中控屏（规格、引脚、刷写、固件版本对比）
│   ├── home-assistant/          # Home Assistant 支持设备
│   └── sensors/                 # 传感器（QMI8658 等）
├── 05-protocols/                # 通信协议与接口规范
│   ├── mqtt-topics.md           # MQTT 主题定义
│   ├── rest-api-guidelines.md   # REST API 规范
│   ├── xiaozhi-protocol.md      # 小智协议
│   └── mcp-spec.md              # MCP 规范
├── 06-firmware/                 # 固件与刷写工具
│   ├── xiaozhi/                 # 小智固件（下载链接方式）
│   ├── flashing-tools/          # 刷写工具（esptool、ESP Web Tools）
│   ├── notes/                   # 驱动安装、刷写提示
│   └── checksums.txt            # 固件 SHA-256 校验值
├── 07-troubleshooting/          # 分层故障排查指南
│   ├── environment.md           # 环境层排查
│   ├── network.md               # 网络层排查
│   ├── backend.md               # 后端层排查
│   ├── frontend.md              # 前端层排查
│   ├── hardware.md              # 硬件层排查
│   └── faq.md                   # 常见问题 FAQ
└── 08-additional-resources/     # 附加资源
    ├── useful-tools.md          # 推荐工具
    ├── tutorials.md             # 教程链接
    ├── community-links.md       # 社区链接
    └── case-studies.md          # 案例研究
```

## 阅读建议

### 按角色阅读

| 角色 | 推荐阅读顺序 |
|------|-------------|
| 后端开发 | 00 → 01 → 02 → 03/backend → 05 → 07 |
| 前端开发 | 00 → 01 → 02 → 03/frontend → 05 → 07 |
| 嵌入式开发 | 00 → 01 → 02 → 03/hardware-platform → 04 → 06 → 07 |
| AI/应用开发 | 00 → 01 → 02 → 03/ai → 03/smart-home → 05 → 07 |
| 全栈开发 | 00 → 01 → 02 → 按需选择各模块深入 |
| 项目经理/Scrum Master | 00 → 01 → 02 → 重点关注敏捷实践部分 |

### 阅读阶段

1. **第一阶段（1-2天）**：通读 00-getting-started，搭建开发环境，了解学习路径
2. **第二阶段（2-3天）**：学习 01-agile-development，理解敏捷流程与 Sprint 节奏
3. **第三阶段（3-5天）**：深入 02-project-overview，理解功能需求与架构目标
4. **第四阶段（持续）**：根据所选角色进入具体技术实现阶段：
   - 查技术细节与官方文档 → `03-tech-stack/`（按 backend/frontend/ai/devops/hardware-platform/smart-home 分类）
   - 硬件接线、引脚、刷写 → `04-hardware/`（含 ESP32-S3 手表、ESP32-P4 中控屏 V0.5/V1.0 固件版本对比）
   - 通信协议与接口设计 → `05-protocols/`（MQTT 主题、REST 规范、小智协议、MCP）
   - 刷固件、固件版本问题 → `06-firmware/`（固件通过 Gitee Release 下载，见下方「固件获取」）
   - 遇到错误需要排查 → `07-troubleshooting/`（按 环境/网络/后端/前端/硬件 分层排查 + FAQ）
   - 找工具、教程、社区 → `08-additional-resources/`

## Skill 安装说明

本资料包包含 `aiguard-knowledge` 知识助手 Skill，可安装在支持 Skill 机制的 AI 编程助手中（如 TRAE、Claude Code、Cursor 等）。

### 方式一：通过仓库地址安装（推荐）

在 AI 编程助手中提供本仓库地址即可：
```
https://github.com/Catherine618/aiguard-reference-kit
```
助手会自动 clone 整个仓库并识别 `skills/aiguard-knowledge/` 中的 Skill。

### 方式二：本地导入

1. `git clone` 整个资料包仓库到本地
2. 在助手的 Skill 管理界面选择「从本地目录安装」
3. 选择 `skills/aiguard-knowledge/` 目录

### 重要说明

- **必须获取完整仓库**：Skill 通过相对路径引用资料包中的文档，只复制 Skill 目录会导致文档引用失效
- **固件单独下载**：固件二进制文件不包含在仓库中，请从 [Gitee Release](https://gitee.com/<owner>/aiguard-reference-kit/releases) 页面下载
- **支持多平台**：Skill 兼容 trae / claude-code / cursor / codex-cli 等 Agent 平台

## 固件获取

固件二进制文件不纳入 Git 版本控制，通过 Gitee Release 分发：

| 固件 | 版本 | 适用硬件 | 说明 |
|------|------|----------|------|
| 小智手表固件 | v2.2.4 | ESP32-S3-Touch-AMOLED-2.06 | AI对话+跌倒检测 |
| P4中控屏V0.5 | v0.5 | ESP32-P4-WIFI6-Touch-LCD-7B | 纯Dashboard固件 |
| P4中控屏V1.0 | v1.0 | ESP32-P4-WIFI6-Touch-LCD-7B | 接入小智语音 |

下载地址：`https://gitee.com/<owner>/aiguard-reference-kit/releases`

下载后请使用 SHA-256 校验文件完整性，校验值见 [06-firmware/checksums.txt](06-firmware/checksums.txt)。

## 致谢与开源项目引用

本项目基于以下优秀开源项目构建，在此向所有贡献者致以诚挚感谢：

### 核心依赖项目

| 项目 | 仓库地址 | 说明 | 使用方式 |
|------|----------|------|----------|
| **小智 ESP32** | [github.com/78/xiaozhi-esp32](https://github.com/78/xiaozhi-esp32) ｜ [gitee.com/xiaozhi-esp32](https://gitee.com/xiaozhi-esp32/xiaozhi-esp32) | ESP32 语音助手固件 | S3手表、P4中控屏V1.0的语音交互基础，通过overlay注入定制 |
| **小智服务端** | [github.com/78/xiaozhi-server](https://github.com/78/xiaozhi-server) | 小智后端服务（ASR/LLM/TTS/MCP） | 独立部署，承载语音链路和MCP工具调用 |
| **ESP-IDF** | [github.com/espressif/esp-idf](https://github.com/espressif/esp-idf) (v5.5.2) | ESP32 开发框架 | P4中控屏V0.5原生项目、V1.0小智构建的基础框架 |
| **Home Assistant** | [github.com/home-assistant/core](https://github.com/home-assistant/core) | 开源智能家居平台 | 居家环境监测与设备集成 |
| **Spring Boot** | [github.com/spring-projects/spring-boot](https://github.com/spring-projects/spring-boot) (v3.3.6) | Java 应用框架 | AI-Guard后端业务服务 |
| **openGauss** | [gitee.com/opengauss/openGauss](https://gitee.com/opengauss/openGauss) | 开源关系型数据库 | 后端数据存储 |
| **Vue 3** | [github.com/vuejs/core](https://github.com/vuejs/core) | 渐进式前端框架 | 社区应急大屏Web前端 |
| **HarmonyOS** | [developer.huawei.com](https://developer.huawei.com/consumer/cn/) | 华为鸿蒙操作系统 | 家属端移动应用 |
| **Eclipse Mosquitto** | [github.com/eclipse/mosquitto](https://github.com/eclipse/mosquitto) | MQTT 消息代理 | 设备通信消息中间件 |
| **Caddy** | [github.com/caddyserver/caddy](https://github.com/caddyserver/caddy) | Web服务器/反向代理 | API网关和小智OTA服务 |
| **Docker** | [github.com/moby/moby](https://github.com/moby/moby) | 容器化平台 | 服务编排与部署 |

### 硬件与板级支持

| 项目 | 仓库地址 | 说明 |
|------|----------|------|
| **Waveshare ESP32 BSP** | [github.com/waveshareteam](https://github.com/waveshareteam) | 微雪ESP32开发板BSP支持 |
| **LVGL** | [github.com/lvgl/lvgl](https://github.com/lvgl/lvgl) (v9.x) | 嵌入式图形库，P4中控屏UI框架 |

### 参考资源

| 资源 | 地址 | 说明 |
|------|------|------|
| 小智固件发布 | [github.com/78/xiaozhi-esp32/releases](https://github.com/78/xiaozhi-esp32/releases) | 官方预编译固件下载 |
| 小智文档 | [github.com/78/xiaozhi-esp32/wiki](https://github.com/78/xiaozhi-esp32/wiki) | 官方Wiki文档 |
| 小智问题反馈 | [github.com/78/xiaozhi-esp32/issues](https://github.com/78/xiaozhi-esp32/issues) | 社区Issue跟踪 |
| ESP-IDF 文档 | [docs.espressif.com/projects/esp-idf](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.5.2/esp32p4/get-started/) | 官方开发文档 |
| Home Assistant 文档 | [www.home-assistant.io/docs](https://www.home-assistant.io/docs/) | 官方安装与集成文档 |
| Spring Boot 文档 | [spring.io/projects/spring-boot](https://spring.io/projects/spring-boot) | 官方参考文档 |
| HarmonyOS 开发文档 | [developer.huawei.com/consumer/cn/doc/harmonyos-guides](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide) | 华为鸿蒙开发指南 |
| Vue 3 文档 | [vuejs.org](https://vuejs.org/) | 官方API与教程 |

## 开源协议

本资料包基于 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。
