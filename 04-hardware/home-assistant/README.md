# Home Assistant 集成说明

## 概述

AIguard 参考套件设计为可与 Home Assistant（HA）智能家居平台集成，实现：
- 手表/面板状态在 HA 中展示
- 传感器数据上报至 HA
- HA 自动化规则可触发 AIguard 告警
- 可通过 HA 接入各类智能家居设备

## 集成方式

AIguard 设备与 HA 的通信可通过以下方式：

| 方式 | 协议 | 适用场景 |
|------|------|----------|
| MQTT | MQTT Broker | 推荐，低功耗、实时性好、HA原生支持 |
| REST API | HTTP | 面板端可直接调用HA REST API |
| WebSocket | WebSocket | 双向实时通信 |
| Zigbee/Z-Wave/蓝牙 | 对应协议 | 通过HA协调器接入其他设备 |

推荐架构：
```
AIguard Watch ←→ MQTT Broker ←→ Home Assistant
AIguard Panel ←→ MQTT Broker ←→ Home Assistant
```

## MQTT 集成配置

### HA 端配置
1. 在 HA 中配置 MQTT Broker（可使用内置 Mosquitto 或外部Broker）
2. 配置 MQTT 自动发现（MQTT Discovery）
3. 订阅 AIguard 设备发布的主题
4. 配置 Lovelace 面板展示数据

### AIguard 端配置
- 设备通过 Wi-Fi 连接到家庭网络
- 配置 MQTT Broker 地址、端口、用户名、密码
- 按照约定的主题格式发布数据（参见 [05-protocols/mqtt-topics.md](../../05-protocols/mqtt-topics.md)）

## 功能映射

### 传感器实体
| HA 实体类型 | 对应数据 |
|-------------|----------|
| binary_sensor | 跌倒告警、SOS按钮、门磁状态 |
| sensor | 加速度数据、电池电量、心率、温湿度 |
| device_tracker | 手表位置（如配合定位功能） |
| button | 远程触发告警/取消告警 |

### 服务调用
AIguard 设备可订阅 HA 服务调用：
- 告警通知推送到手表/面板
- 自动化规则触发语音播报
- 调用 TTS 服务在面板播报信息

## 推荐组件

- **Mosquitto Broker**：HA官方MQTT插件
- **MQTT Integration**：HA内置MQTT集成
- **HACS**（Home Assistant Community Store）：可安装更多社区插件
- **Frigate**：如需摄像头+AI目标检测
- **Node-RED**：可视化自动化流程编辑
