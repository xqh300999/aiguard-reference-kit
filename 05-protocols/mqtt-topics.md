# MQTT 主题命名约定

> **注意**：本文档为**参考约定，可根据实际项目需求调整**。

## 基础命名规范

### 主题层级结构

```
aiguard/{版本}/{设备类型}/{设备ID}/{功能域}/{动作}
```

| 层级 | 说明 | 示例值 |
|------|------|--------|
| aiguard | 根命名空间，固定 | aiguard |
| 版本 | 协议版本号 | v1 |
| 设备类型 | 设备类型标识 | watch / panel / sensor / gateway |
| 设备ID | 设备唯一标识，建议使用MAC地址后缀或UUID | a1b2c3d4e5f6 |
| 功能域 | 功能模块分类 | status / sensor / alert / config / event |
| 动作 | 具体数据/操作 | report / set / get / response / heartbeat |

### 命名规则
- 使用小写字母、数字、连字符（-）和下划线（_）
- 不使用空格和特殊字符
- 层级之间用 `/` 分隔
- 避免开头或结尾的 `/`
- 通配符：`+` 匹配单层，`#` 匹配多层（仅限订阅端）

## 设备端上报主题（Publish）

### 1. 设备状态

| 主题 | QoS | Retain | 说明 | Payload示例 |
|------|-----|--------|------|-------------|
| `aiguard/v1/{type}/{id}/status/online` | 1 | true | 上线通知 | `{"status":"online","ip":"192.168.1.100","fw_version":"2.2.4"}` |
| `aiguard/v1/{type}/{id}/status/offline` | 1 | true | 离线通知（LWT） | `{"status":"offline","reason":"disconnect"}` |
| `aiguard/v1/{type}/{id}/status/heartbeat` | 0 | false | 心跳包 | `{"ts":1719000000,"battery":85,"rssi":-55}` |

### 2. 传感器数据

| 主题 | QoS | Retain | 说明 |
|------|-----|--------|------|
| `aiguard/v1/{type}/{id}/sensor/imu` | 0 | false | IMU数据（加速度+陀螺仪） |
| `aiguard/v1/{type}/{id}/sensor/battery` | 1 | true | 电池状态 |
| `aiguard/v1/{type}/{id}/sensor/environment` | 0 | false | 环境数据（温湿度等） |
| `aiguard/v1/{type}/{id}/sensor/hr_spo2` | 0 | false | 心率血氧数据（如有） |

**IMU数据Payload示例：**
```json
{
  "ts": 1719000000123,
  "acc": {"x": 0.12, "y": -0.05, "z": 0.98},
  "gyro": {"x": 1.2, "y": -0.3, "z": 0.1},
  "activity": "walking"
}
```

**电池数据Payload示例：**
```json
{
  "ts": 1719000000,
  "level": 85,
  "voltage": 3.92,
  "charging": false,
  "temperature": 28.5
}
```

### 3. 告警事件

| 主题 | QoS | Retain | 说明 |
|------|-----|--------|------|
| `aiguard/v1/{type}/{id}/alert/fall` | 2 | false | 跌倒检测告警 |
| `aiguard/v1/{type}/{id}/alert/sos` | 2 | false | SOS紧急按钮 |
| `aiguard/v1/{type}/{id}/alert/battery_low` | 1 | true | 低电量告警 |
| `aiguard/v1/{type}/{id}/alert/door` | 1 | false | 门磁告警（面板） |
| `aiguard/v1/{type}/{id}/alert/smoke` | 2 | false | 烟雾告警（面板） |
| `aiguard/v1/{type}/{id}/alert/cancel` | 1 | false | 取消告警 |

**跌倒告警Payload示例：**
```json
{
  "ts": 1719000000123,
  "type": "fall_detected",
  "confidence": 0.92,
  "acc_peak": 4.2,
  "location": {"x": 0, "y": 0, "z": 0},
  "need_help": true
}
```

**SOS告警Payload示例：**
```json
{
  "ts": 1719000000123,
  "type": "sos_button",
  "trigger": "long_press_3s",
  "battery": 15
}
```

### 4. 事件通知

| 主题 | QoS | Retain | 说明 |
|------|-----|--------|------|
| `aiguard/v1/{type}/{id}/event/button` | 1 | false | 按键事件 |
| `aiguard/v1/{type}/{id}/event/touch` | 0 | false | 触摸事件（面板） |
| `aiguard/v1/{type}/{id}/event/voice` | 1 | false | 语音唤醒/指令 |

## 服务端下发主题（Subscribe）

设备订阅以下主题接收指令：

### 1. 配置管理

| 主题 | QoS | 说明 |
|------|-----|------|
| `aiguard/v1/{type}/{id}/config/set` | 1 | 设置配置 |
| `aiguard/v1/{type}/{id}/config/get` | 1 | 请求配置（设备回复到config/response） |

**设置配置Payload示例：**
```json
{
  "msg_id": "uuid-1234",
  "config": {
    "fall_sensitivity": "medium",
    "heartbeat_interval": 60,
    "alert_contacts": ["138xxxxxxx", "139xxxxxxx"],
    "mqtt_broker": "mqtt://192.168.1.10:1883"
  }
}
```

### 2. 告警控制

| 主题 | QoS | 说明 |
|------|-----|------|
| `aiguard/v1/{type}/{id}/alert/ack` | 1 | 告警确认/已处理 |
| `aiguard/v1/{type}/{id}/alert/cancel_cmd` | 1 | 远程取消告警 |

### 3. 设备控制

| 主题 | QoS | 说明 |
|------|-----|------|
| `aiguard/v1/{type}/{id}/cmd/reboot` | 1 | 重启设备 |
| `aiguard/v1/{type}/{id}/cmd/vibrate` | 0 | 震动提示（手表） |
| `aiguard/v1/{type}/{id}/cmd/display` | 1 | 屏幕显示内容（面板/手表） |
| `aiguard/v1/{type}/{id}/cmd/audio` | 1 | 播放音频/语音播报（面板） |
| `aiguard/v1/{type}/{id}/cmd/ota` | 1 | OTA升级指令 |

**音频播报Payload示例：**
```json
{
  "msg_id": "uuid-5678",
  "type": "tts",
  "text": "检测到跌倒，正在联系紧急联系人",
  "volume": 80,
  "priority": "high"
}
```

### 4. OTA升级

| 主题 | QoS | 说明 |
|------|-----|------|
| `aiguard/v1/{type}/{id}/ota/available` | 1 | 通知有新版本可用 |
| `aiguard/v1/{type}/{id}/ota/progress` | 0 | 设备上报升级进度 |

## Home Assistant 发现主题（MQTT Discovery）

为兼容 Home Assistant MQTT Discovery，额外支持HA标准发现主题：

- 配置主题：`homeassistant/{component}/{node_id}/{object_id}/config`
- 状态主题：使用上述 aiguard 主题，HA配置中引用

**HA二进制传感器发现Payload示例：**
```json
{
  "name": "Fall Alert",
  "device_class": "safety",
  "state_topic": "aiguard/v1/watch/a1b2c3d4e5f6/alert/fall",
  "value_template": "{{ value_json.need_help }}",
  "payload_on": true,
  "payload_off": false,
  "unique_id": "aiguard_fall_a1b2c3d4e5f6",
  "device": {
    "identifiers": ["aiguard_a1b2c3d4e5f6"],
    "name": "AIguard Watch",
    "model": "ESP32-S3-AMOLED",
    "manufacturer": "AIguard"
  }
}
```

## 特殊约定

### 设备ID生成
- 建议使用芯片MAC地址（无分隔符，小写）作为设备ID
- 示例：MAC为 `AA:BB:CC:DD:EE:FF`，设备ID为 `aabbccddeeff`

### 时间戳
- 统一使用 Unix 时间戳（毫秒或秒）
- Payload中建议使用UTC时间，设备本地时区显示时再转换

### QoS建议
- 告警类：QoS 2（确保送达）
- 配置/指令：QoS 1（至少送达一次）
- 传感器高频数据：QoS 0（最多一次，减少开销）
- Retain：仅当前状态类消息使用Retain

### 消息保留
- `status/online`/`status/offline`：Retain = true
- 传感器即时数据：Retain = false
- 告警事件：Retain = false
- 配置状态：Retain = true

### LWT (Last Will and Testament)
- 每个设备连接时设置LWT消息到 `aiguard/v1/{type}/{id}/status/offline`
- QoS=1, Retain=true
- Payload: `{"status":"offline","reason":"lwt"}`
