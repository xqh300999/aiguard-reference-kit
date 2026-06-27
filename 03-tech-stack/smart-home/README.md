# 智能家居平台

AIguard 集成 Home Assistant 作为智能家居中枢，配合小智 ESP32 语音助手实现全屋智能控制。

## 目录

- [Home Assistant](home-assistant.md) - 开源智能家居平台安装与配置
- [小智 ESP32](xiaozhi-esp32.md) - 开源语音助手固件、OTA、MCP 集成
- [官方链接](official-links.md) - HA/小智官方文档链接

## 平台概览

| 组件 | 技术 | 用途 |
|------|------|------|
| 智能家居中枢 | Home Assistant | 设备管理、自动化、统一控制 |
| 语音终端 | 小智 ESP32-S3/P4 | 远场语音交互、设备控制 |
| 消息总线 | MQTT | 设备与平台通信 |
| AI 能力 | 通义千问 + MCP | 自然语言理解、工具调用 |

## 快速参考

```bash
# Docker 启动 Home Assistant（或使用 HAOS）
docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=Asia/Shanghai \
  -v ~/homeassistant:/config \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable

# 访问 Web UI
# http://<树莓派IP>:8123
```

## 常见坑点

1. Home Assistant 推荐使用 Home Assistant OS 部署（全功能），Docker 容器版缺少 Supervisor 和 Add-on 商店
2. 小智 ESP32 固件需匹配对应开发板硬件型号，刷错固件会导致屏幕/麦克风不工作
3. MQTT 集成需正确配置 Broker 地址和账号密码，注意 QoS 和 retained 消息设置
4. MCP 工具集成需 AI 服务端支持，本地 LLM 能力有限，建议使用云端 API

## 官方链接

详见 [official-links.md](official-links.md)。
