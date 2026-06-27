# AI-Guard 知识地图（机读索引）

本文件是aiguard-knowledge Skill的内部知识索引，用于快速定位问题对应的文档。

## 问题类型到文档的映射

### 入门与环境
| 问题关键词 | 文档路径 |
|-----------|----------|
| 环境搭建、安装依赖、JDK/Node/Python/Docker版本 | 00-getting-started/prerequisites.md |
| 如何开始、学习路径、角色分工 | 00-getting-started/learning-path.md |
| Git命令、Docker操作、screen使用 | 00-getting-started/dev-basics.md |

### 敏捷开发与项目管理
| 问题关键词 | 文档路径 |
|-----------|----------|
| Scrum、Sprint、敏捷流程 | 01-agile-development/scrum-basics.md |
| Sprint计划、任务拆分 | 01-agile-development/sprint-templates/sprint-planning-template.md |
| 每日站会、同步进度 | 01-agile-development/sprint-templates/daily-standup-template.md |
| Sprint回顾、总结改进 | 01-agile-development/sprint-templates/sprint-retrospective-template.md |
| 敏捷书籍、学习资源 | 01-agile-development/resources.md |

### 项目概述与需求
| 问题关键词 | 文档路径 |
|-----------|----------|
| 项目要做什么、功能需求 | 02-project-overview/functional-requirements.md |
| 架构设计、参考架构 | 02-project-overview/system-architecture.md |
| 性能要求、安全要求 | 02-project-overview/non-functional-requirements.md |

### 硬件平台
| 问题关键词 | 文档路径 |
|-----------|----------|
| Raspberry Pi 5、树莓派、主控 | 03-tech-stack/hardware-platform/raspberry-pi-5.md |
| ESP32、ESP32-S3、ESP32-P4、微雪 | 03-tech-stack/hardware-platform/waveshare-esp32.md |
| 硬件平台官方链接 | 03-tech-stack/hardware-platform/official-links.md |

### 后端技术栈
| 问题关键词 | 文档路径 |
|-----------|----------|
| Java、Java 17、JDK | 03-tech-stack/backend/java-17.md |
| Spring Boot、Spring、REST API、后端框架 | 03-tech-stack/backend/spring-boot-3.md |
| openGauss、数据库、SQL、JDBC | 03-tech-stack/backend/opengauss.md |
| MQTT、消息队列、发布订阅 | 03-tech-stack/backend/mqtt.md |
| WebSocket、实时通信、长连接 | 03-tech-stack/backend/websocket.md |
| 后端官方文档链接 | 03-tech-stack/backend/official-links.md |

### 前端技术栈
| 问题关键词 | 文档路径 |
|-----------|----------|
| Vue3、Vue、Vite、TypeScript、大屏 | 03-tech-stack/frontend/vue3-vite-ts.md |
| HarmonyOS、鸿蒙、ArkTS、ArkUI、DevEco Studio、家属端 | 03-tech-stack/frontend/harmonyos-next.md |
| 前端官方文档链接 | 03-tech-stack/frontend/official-links.md |

### 智能家居
| 问题关键词 | 文档路径 |
|-----------|----------|
| Home Assistant、HA、智能家居平台 | 03-tech-stack/smart-home/home-assistant.md |
| 小智、xiaozhi、ESP32语音助手、语音交互 | 03-tech-stack/smart-home/xiaozhi-esp32.md |
| 智能家居官方链接 | 03-tech-stack/smart-home/official-links.md |

### AI相关
| 问题关键词 | 文档路径 |
|-----------|----------|
| 通义千问、Qwen、大模型、AI对话 | 03-tech-stack/ai/qwen-api.md |
| MCP、Model Context Protocol、工具调用 | 03-tech-stack/ai/mcp.md |
| AI官方文档链接 | 03-tech-stack/ai/official-links.md |

### DevOps
| 问题关键词 | 文档路径 |
|-----------|----------|
| Docker、Docker Compose、容器 | 03-tech-stack/devops/docker.md |
| Git、版本控制、代码提交 | 03-tech-stack/devops/git.md |
| DevOps官方链接 | 03-tech-stack/devops/official-links.md |

### 硬件规格
| 问题关键词 | 文档路径 |
|-----------|----------|
| ESP32-S3手表、手板、AMOLED、智能手表 | 04-hardware/esp32-s3-watch/README.md |
| 手表引脚、GPIO定义 | 04-hardware/esp32-s3-watch/pinout.md |
| ESP32-P4中控屏、触摸屏、7寸屏 | 04-hardware/esp32-p4-panel/README.md |
| 中控屏引脚、GPIO定义 | 04-hardware/esp32-p4-panel/pinout.md |
| QMI8658、IMU、六轴、跌倒检测、加速度计、陀螺仪 | 04-hardware/sensors/qmi8658.md |
| 门磁、温湿度、烟雾、传感器选型 | 04-hardware/sensors/other-sensors.md |
| HA兼容设备、传感器推荐 | 04-hardware/home-assistant/supported-devices.md |

### 通信协议
| 问题关键词 | 文档路径 |
|-----------|----------|
| MQTT主题、topic命名 | 05-protocols/mqtt-topics.md |
| REST API、接口设计、API规范 | 05-protocols/rest-api-guidelines.md |
| 小智协议、OTA、WebSocket协议 | 05-protocols/xiaozhi-protocol.md |
| MCP协议、工具调用规范 | 05-protocols/mcp-spec.md |

### 固件相关
| 问题关键词 | 文档路径 |
|-----------|----------|
| 固件下载、固件版本、v2.2.4 | 06-firmware/xiaozhi/README.md |
| 浏览器刷固件、ESP Web Tools | 06-firmware/flashing-tools/esp-web-tools.md |
| esptool.py、命令行刷写 | 06-firmware/flashing-tools/esptool.md |
| USB驱动、驱动安装 | 06-firmware/notes/driver-installation.md |
| 固件升级、固件回退、降级 | 06-firmware/notes/firmware-update-tips.md |
| 固件校验、SHA256 | 06-firmware/checksums.txt |

### 故障排查
| 问题关键词 | 文档路径 |
|-----------|----------|
| 环境问题、依赖安装失败、版本不对 | 07-troubleshooting/environment.md |
| 网络问题、端口被占、连不上、防火墙 | 07-troubleshooting/network.md |
| 后端启动失败、数据库连不上、HA连接失败 | 07-troubleshooting/backend.md |
| 前端构建失败、跨域、接口404、鸿蒙编译失败 | 07-troubleshooting/frontend.md |
| 设备连不上、刷固件失败、传感器没数据 | 07-troubleshooting/hardware.md |
| 常见问题、FAQ | 07-troubleshooting/faq.md |

### 额外资源
| 问题关键词 | 文档路径 |
|-----------|----------|
| 开发工具、IDE、插件推荐 | 08-additional-resources/useful-tools.md |
| 教程、学习资料 | 08-additional-resources/tutorials.md |
| 社区、论坛、求助 | 08-additional-resources/community-links.md |
| 案例参考、项目案例 | 08-additional-resources/case-studies.md |

## 排查层级顺序

故障排查按以下顺序进行：
1. 环境层 (environment.md)
2. 网络层 (network.md)
3. 后端层 (backend.md)
4. 前端层 (frontend.md)
5. 硬件层 (hardware.md)
