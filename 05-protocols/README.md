# AIguard 协议文档

> **注意**：本文档中的协议规范为**参考约定，可根据实际项目需求调整**。

本文档目录包含 AIguard 参考套件所涉及的通信协议规范文档。

## 目录结构

```
05-protocols/
├── README.md              # 本文档
├── mqtt-topics.md         # MQTT主题命名约定
├── rest-api-guidelines.md # REST API设计规范
├── xiaozhi-protocol.md    # 小智OTA/WebSocket协议
└── mcp-spec.md            # MCP工具调用规范
```

## 协议概览

| 协议 | 用途 | 适用场景 |
|------|------|----------|
| MQTT | 设备与云端/HA的消息通信 | 传感器数据上报、状态同步、指令下发 |
| REST API | 服务端HTTP接口 | 配置管理、数据查询、Web面板交互 |
| WebSocket (小智) | 设备与小智服务器实时通信 | 语音对话、OTA升级、长连接交互 |
| MCP (Model Context Protocol) | AI工具调用标准化 | LLM调用设备功能、技能扩展 |

## 设计原则

1. **简洁性**：协议设计尽量简单，便于嵌入式设备实现
2. **可扩展**：预留扩展字段，便于后续功能增加
3. **安全**：支持认证、加密，保护用户隐私
4. **兼容性**：遵循主流标准，便于与Home Assistant等系统集成
5. **低功耗**：减少不必要的数据传输，适应电池供电设备
