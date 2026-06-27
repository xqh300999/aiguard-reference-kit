# 小智（Xiaozhi）OTA/WebSocket 协议说明

> **注意**：本文档为**参考约定，可根据实际项目需求调整**。

本文档描述小智AI对话固件所使用的通信协议，包括OTA升级流程和WebSocket实时通信协议。小智固件可作为AIguard的语音交互基础。

> 注：小智协议是社区开源项目，具体协议以官方项目为准。本文档基于现有小智开源实现整理，供AIguard集成参考。

## 协议概述

小智设备与服务器之间主要使用两类通信：
1. **HTTP/HTTPS**：用于OTA固件检查、固件下载
2. **WebSocket (WSS)**：用于实时语音对话、长连接交互

### 连接流程

```
设备上电
  ↓
连接Wi-Fi
  ↓
HTTP请求检查OTA更新（如有则升级）
  ↓
建立WebSocket连接到服务器
  ↓
认证/握手
  ↓
双向数据交互（音频流+JSON控制消息）
  ↓
（连接中断后自动重连）
```

## OTA 升级协议

### 版本检查

**请求：**
```http
GET /xiaozhi/ota/check HTTP/1.1
Host: your-server.com
Content-Type: application/json

{
  "device_id": "a1b2c3d4e5f6",
  "mac": "AA:BB:CC:DD:EE:FF",
  "chip_model": "esp32s3",
  "firmware_version": "2.2.3",
  "board_type": "esp32-s3-amoled"
}
```

**响应（有新版本）：**
```json
{
  "has_update": true,
  "version": "2.2.4",
  "firmware_url": "https://example.com/firmware/xiaozhi-v2.2.4-esp32s3.bin",
  "firmware_md5": "d41d8cd98f00b204e9800998ecf8427e",
  "firmware_size": 1572864,
  "spiffs_url": "https://example.com/firmware/spiffs-v2.2.4.bin",
  "spiffs_md5": "abcdef1234567890",
  "spiffs_size": 1048576,
  "release_notes": "1. 优化语音唤醒\n2. 修复MQTT重连问题",
  "force_update": false
}
```

**响应（无新版本）：**
```json
{
  "has_update": false,
  "version": "2.2.3",
  "server_time": 1719000000
}
```

### 固件下载
- 使用HTTP GET直接下载固件bin文件
- 支持断点续传（Range头部）
- 下载完成后校验MD5
- 写入Flash后验证校验和
- 重启切换到新固件

## WebSocket 通信协议

### 连接建立

**WebSocket URL：**
```
wss://your-server.com/xiaozhi/ws
```

**连接参数（URL Query）：**
```
wss://your-server.com/xiaozhi/ws?device_id=xxx&token=xxx&version=2.2.4
```

### 消息格式

WebSocket使用二进制帧和文本帧混合：
- **文本帧**：JSON格式的控制消息
- **二进制帧**：音频数据（Opus编码）或其他二进制载荷

### 消息类型约定

通过JSON消息中的 `type` 字段区分消息类型，音频帧无额外包装。

---

### 1. 客户端 → 服务端

#### 1.1 握手/Hello

连接建立后客户端发送的第一条消息：

```json
{
  "type": "hello",
  "version": 1,
  "device_id": "a1b2c3d4e5f6",
  "mac": "AA:BB:CC:DD:EE:FF",
  "chip_model": "esp32s3",
  "firmware_version": "2.2.4",
  "board_type": "esp32-s3-amOLED",
  "capabilities": {
    "audio": {
      "input": true,
      "output": true,
      "sample_rate": 16000,
      "channels": 1,
      "codec": "opus",
      "frame_duration": 20
    },
    "display": {
      "available": true,
      "width": 410,
      "height": 502,
      "type": "amoled"
    },
    "imu": true,
    "touch": true
  }
}
```

#### 1.2 音频数据

- 二进制帧直接发送Opus编码的音频帧
- 每帧20ms @ 16kHz（对应640字节PCM，Opus压缩后约几十字节）
- 无需额外JSON包装

#### 1.3 唤醒/打断

```json
{
  "type": "listen",
  "state": "start",
  "source": "wakeword",
  "wakeword": "你好小智"
}
```

`state` 取值：
- `start`: 开始说话/唤醒
- `stop`: 结束说话（VAD检测到静音）
- `detect`: 检测到唤醒词（仅唤醒词通知）
- `pause`: 暂停监听

#### 1.4 状态同步

```json
{
  "type": "status",
  "battery": {
    "level": 85,
    "charging": false,
    "voltage": 3.92
  },
  "wifi": {
    "rssi": -55,
    "ssid": "MyWiFi"
  },
  "uptime": 3600
}
```

#### 1.5 告警/事件上报

```json
{
  "type": "event",
  "event": "fall_detected",
  "data": {
    "confidence": 0.92,
    "ts": 1719000000123
  }
}
```

---

### 2. 服务端 → 客户端

#### 2.1 握手响应

```json
{
  "type": "hello",
  "session_id": "sess-abc123",
  "server_version": "1.0.0",
  "tts": {
    "provider": "minimax",
    "voice": "female-1",
    "codec": "opus",
    "sample_rate": 16000
  },
  "config": {
    "wakeword_enabled": true,
    "vad_sensitivity": "medium"
  }
}
```

#### 2.2 TTS音频数据

- 二进制帧：Opus编码的TTS音频流
- 与上行音频格式一致

#### 2.3 控制指令

```json
{
  "type": "tts",
  "state": "start",
  "text": "你好，我是小智"
}
```

```json
{
  "type": "tts",
  "state": "stop"
}
```

```json
{
  "type": "tts",
  "state": "sentence_start",
  "text": "今天天气不错"
}
```

#### 2.4 对话状态

```json
{
  "type": "stt",
  "text": "今天天气怎么样"
}
```

```json
{
  "type": "llm",
  "text": "今天北京天气晴朗，气温25度...",
  "emotion": "happy"
}
```

#### 2.5 设备控制（AIguard扩展）

在小智基础协议上扩展告警相关控制：

```json
{
  "type": "aiguard",
  "action": "alert",
  "alert_type": "fall",
  "message": "检测到跌倒事件，是否确认？",
  "require_confirm": true
}
```

```json
{
  "type": "aiguard",
  "action": "display",
  "screen": "alert_confirmation",
  "data": {
    "title": "跌倒告警",
    "buttons": ["我没事", "需要帮助"]
  }
}
```

```json
{
  "type": "aiguard",
  "action": "vibrate",
  "pattern": "sos",
  "duration": 2000
}
```

### 连接保活

- 客户端每30秒发送Ping帧
- 服务端回复Pong帧
- 90秒无响应则判定连接断开，自动重连
- 重连时采用退避策略（1s→2s→4s→...最大60s）

### 音频格式约定

| 参数 | 上行（麦克风） | 下行（TTS） |
|------|----------------|-------------|
| 编码 | Opus | Opus |
| 采样率 | 16000 Hz | 16000 Hz |
| 声道 | 单声道 | 单声道 |
| 位深 | 16-bit PCM输入后编码 | — |
| 帧长 | 20ms | 20ms |
| 比特率 | — | 可变，约16-32kbps |

## AIguard 与小智协议集成建议

1. **独立运行**：小智语音连接与AIguard MQTT连接可同时独立保持
2. **事件桥接**：跌倒/SOS告警通过小智语音通道播报，语音确认结果回传MQTT
3. **资源优先级**：告警发生时，暂停语音对话，优先处理告警播报和确认
4. **OTA兼容**：AIguard固件可沿用小智的OTA流程，在board_type中区分硬件型号

## 参考

小智开源项目地址（社区项目，具体实现以官方为准）：
- 主要仓库在 GitHub 搜索 "xiaozhi-esp32"
