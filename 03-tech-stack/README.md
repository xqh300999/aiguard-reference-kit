# AIguard 技术栈文档

本目录包含 AIguard 智能家居安全项目完整的技术栈参考文档，涵盖硬件平台、后端、前端、智能家居、AI 和 DevOps 六大模块。

## 目录结构

```
03-tech-stack/
├── README.md                          # 本文件（技术栈总览）
│
├── hardware-platform/                 # 硬件平台
│   ├── README.md
│   ├── raspberry-pi-5.md              # 树莓派5规格/安装/配置
│   ├── waveshare-esp32.md             # 微雪ESP32-S3/P4开发
│   └── official-links.md              # 硬件官方链接
│
├── backend/                           # 后端技术栈
│   ├── README.md
│   ├── java-17.md                     # Java 17新特性/核心概念
│   ├── spring-boot-3.md               # Spring Boot 3快速入门
│   ├── opengauss.md                   # openGauss数据库
│   ├── mqtt.md                        # MQTT协议/主题设计/集成
│   ├── websocket.md                   # WebSocket实时通信
│   └── official-links.md              # 后端官方链接
│
├── frontend/                          # 前端技术栈
│   ├── README.md
│   ├── vue3-vite-ts.md                # Vue3+Vite+TypeScript
│   ├── harmonyos-next.md              # HarmonyOS NEXT/ArkTS/ArkUI
│   └── official-links.md              # 前端官方链接
│
├── smart-home/                        # 智能家居平台
│   ├── README.md
│   ├── home-assistant.md              # Home Assistant安装/集成/自动化
│   ├── xiaozhi-esp32.md               # 小智ESP32语音助手/OTA/MCP
│   └── official-links.md              # 智能家居官方链接
│
├── ai/                                # AI技术栈
│   ├── README.md
│   ├── qwen-api.md                    # 通义千问API使用
│   ├── mcp.md                         # Model Context Protocol
│   └── official-links.md              # AI官方链接
│
└── devops/                            # DevOps工具链
    ├── README.md
    ├── docker.md                      # Docker/Docker Compose
    ├── git.md                         # Git版本控制
    └── official-links.md              # DevOps官方链接
```

## 整体技术架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                        前端层 (Frontend)                            │
│  Vue 3 + Vite + TypeScript (Web管理后台)  │  HarmonyOS NEXT (移动端) │
└────────────────────────────┬────────────────────────────────────────┘
                             │ HTTP / WebSocket / REST API
┌────────────────────────────▼────────────────────────────────────────┐
│                       后端服务层 (Backend)                           │
│  Spring Boot 3 + Java 17                                            │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────────┐    │
│  │ REST API │  │ WebSocket│  │  MQTT     │  │  AI Service      │    │
│  │  Controller│  │ 推送服务 │  │  Broker   │  │  Qwen + MCP      │    │
│  └────┬─────┘  └──────────┘  └─────┬─────┘  └────────┬─────────┘    │
│       │                             │                 │              │
└───────┼─────────────────────────────┼─────────────────┼──────────────┘
        │                             │                 │
┌───────▼─────────────────────────────▼─────────────────▼──────────────┐
│                      数据/消息/AI层                                   │
│  openGauss/PostgreSQL    MQTT Broker       通义千问API / MCP Tools   │
│  (数据持久化)          (设备消息路由)        (大模型+工具调用)        │
└────────────────────────────┬────────────────────────────────────────┘
                             │ MQTT
┌────────────────────────────▼────────────────────────────────────────┐
│                       硬件/设备层 (Hardware)                         │
│  ┌─────────────────┐  ┌──────────────────────────────────────────┐  │
│  │  Raspberry Pi 5 │  │     微雪 ESP32-S3 / ESP32-P4             │  │
│  │  (本地网关)      │  │  ┌────────────┐  ┌─────────────────┐     │  │
│  │  - Docker       │  │  │ 小智固件    │  │ 传感器/执行器    │     │  │
│  │  - Home Assistant│  │  │ 语音对话    │  │ 语音/屏幕/控制  │     │  │
│  │  - Mosquitto    │  │  └────────────┘  └─────────────────┘     │  │
│  └─────────────────┘  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## 技术选型总览

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| **硬件平台** | Raspberry Pi 5 | - | 本地网关，4GB/8GB 内存版本 |
| | 微雪 ESP32-S3 / P4 | - | 智能语音终端 |
| **后端** | Java | 17 LTS | 主要开发语言 |
| | Spring Boot | 3.x | 应用框架 |
| | openGauss | 5.x / 3.x | 关系型数据库（开发阶段可用PostgreSQL替代）|
| | MQTT (Mosquitto) | 3.1.1/5.0 | 设备通信协议 |
| | WebSocket | RFC 6455 | 前端实时推送 |
| **前端** | Vue | 3.4+ | Web UI 框架 |
| | Vite | 5.x | 构建工具 |
| | TypeScript | 5.x | 类型安全 |
| | Element Plus | - | UI 组件库 |
| | HarmonyOS NEXT | 5.0+ | 移动端原生应用 |
| | ArkTS + ArkUI | - | 鸿蒙开发语言/UI框架 |
| **智能家居** | Home Assistant | 最新稳定版 | 智能家居中枢 |
| | 小智 ESP32 | v2.2.x | 开源语音助手固件 |
| **AI** | 通义千问 (Qwen) | qwen-plus/turbo | 阿里云大语言模型 |
| | MCP | 2024-11-05 规范 | 模型上下文协议（工具调用）|
| **DevOps** | Docker | 24+ | 容器化 |
| | Docker Compose | v2 | 多容器编排 |
| | Git | - | 版本控制 |

## 快速开始

### 1. 硬件准备
- 参考 [hardware-platform/raspberry-pi-5.md](hardware-platform/raspberry-pi-5.md) 安装树莓派操作系统
- 参考 [hardware-platform/waveshare-esp32.md](hardware-platform/waveshare-esp32.md) 烧录小智固件

### 2. 基础服务部署
```bash
# 克隆项目
git clone <repo-url>
cd aiguard

# 使用 Docker Compose 启动基础服务（MQTT、数据库、HA）
docker compose up -d mosquitto database homeassistant
```

### 3. 后端开发
参考 [backend/spring-boot-3.md](backend/spring-boot-3.md) 搭建开发环境，配置：
- JDK 17
- Maven
- IDE（IntelliJ IDEA 推荐）

### 4. 前端开发
参考 [frontend/vue3-vite-ts.md](frontend/vue3-vite-ts.md)：
```bash
cd aiguard-admin
npm install
npm run dev
```

### 5. AI 能力配置
参考 [ai/qwen-api.md](ai/qwen-api.md)：
- 申请阿里云百炼 API Key
- 配置通义千问模型和工具调用（MCP）

## 文档规范

每个技术文档均包含三部分：
1. **快速参考**：核心概念、常用命令、代码示例
2. **常见坑点**：实际开发中容易遇到的问题及解决方案
3. **官方链接**：官方文档和资源链接

所有文档使用中文编写，保持客观中立，提供的代码示例均可直接参考使用。

## 关键设计决策

1. **Java 17 + Spring Boot 3**：LTS版本，性能优秀，生态成熟，强制使用Jakarta EE命名空间
2. **openGauss 数据库**：华为开源国产数据库，支持ARM64，PostgreSQL协议兼容，开发阶段可用PostgreSQL
3. **MQTT 作为设备通信协议**：轻量级、适合IoT场景、支持QoS、设备与平台解耦
4. **Vue 3 + TypeScript**：组合式API开发体验好，类型安全，生态丰富
5. **HarmonyOS NEXT 原生**：适配国产鸿蒙系统，ArkTS声明式UI开发效率高
6. **Home Assistant 集成**：成熟开源智能家居平台，支持2500+设备集成
7. **通义千问 MCP 工具调用**：利用大模型自然语言理解能力，通过MCP标准化工具接口
8. **Docker 容器化部署**：一致的开发/生产环境，简化树莓派部署

## 常见坑点速查

| 问题 | 参考文档 |
|------|----------|
| 树莓派5电源不足导致降频 | [hardware-platform/raspberry-pi-5.md](hardware-platform/raspberry-pi-5.md) |
| ESP32 PSRAM配置错误崩溃 | [hardware-platform/waveshare-esp32.md](hardware-platform/waveshare-esp32.md) |
| Spring Boot 3 要求JDK17/jakarta包迁移 | [backend/spring-boot-3.md](backend/spring-boot-3.md) |
| openGauss ARM64镜像问题 | [backend/opengauss.md](backend/opengauss.md) |
| MQTT retained消息导致设备状态异常 | [backend/mqtt.md](backend/mqtt.md) |
| WebSocket跨域/Nginx代理配置 | [backend/websocket.md](backend/websocket.md) |
| Vue3 ref忘记.value | [frontend/vue3-vite-ts.md](frontend/vue3-vite-ts.md) |
| HarmonyOS NEXT不支持APK | [frontend/harmonyos-next.md](frontend/harmonyos-next.md) |
| HA Docker版无Add-on商店 | [smart-home/home-assistant.md](smart-home/home-assistant.md) |
| 小智固件刷错型号白屏 | [smart-home/xiaozhi-esp32.md](smart-home/xiaozhi-esp32.md) |
| 通义千问API Key安全 | [ai/qwen-api.md](ai/qwen-api.md) |
| MCP工具描述质量影响效果 | [ai/mcp.md](ai/mcp.md) |
| 树莓派Docker ARM64镜像兼容 | [devops/docker.md](devops/docker.md) |
| Git提交敏感信息 | [devops/git.md](devops/git.md) |

## 鸿蒙官方文档

华为鸿蒙 HarmonyOS NEXT 官方应用开发指南：
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide
