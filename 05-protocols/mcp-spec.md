# MCP (Model Context Protocol) 工具调用规范

> **注意**：本文档为**参考约定，可根据实际项目需求调整**。

## 概述

MCP（Model Context Protocol）是用于大语言模型（LLM）与外部工具/数据源交互的开放协议。在AIguard中，MCP用于：
- 让AI助手能够查询设备状态、传感器数据
- 让AI能够触发告警、控制设备
- 标准化AI与硬件功能的交互接口
- 支持将AIguard能力暴露给支持MCP的LLM客户端

本文档基于MCP规范，定义AIguard的MCP工具接口。

> 参考：MCP官方规范 https://modelcontextprotocol.io/

## 架构

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────┐
│  LLM Client     │◄────►│  MCP Server      │◄────►│ AIguard     │
│ (Claude/等)     │ MCP  │ (AIguard提供)    │ MQTT │ 设备/网关   │
└─────────────────┘      └──────────────────┘      └─────────────┘
```

MCP Server可运行在：
1. ESP32-P4面板本地（资源充足时）
2. 家庭服务器/树莓派/HA插件
3. 云端服务（远程访问场景）

## 传输层

MCP支持多种传输方式，AIguard推荐：

| 传输 | 适用场景 | 说明 |
|------|----------|------|
| stdio | 本地进程调用 | MCP Server作为子进程运行 |
| SSE (Server-Sent Events) | HTTP服务 | Server推事件，Client POST发请求 |
| WebSocket | 浏览器/长连接 | 双向实时通信 |
| 自定义(MQTT桥接) | IoT设备 | 通过MQTT Broker转发 |

## 工具（Tools）定义

AIguard提供以下MCP工具供LLM调用：

### 1. 设备查询类

#### `list_devices`
列出所有已注册的AIguard设备。

**参数：** 无

**返回：**
```json
{
  "devices": [
    {
      "id": "a1b2c3d4e5f6",
      "type": "watch",
      "name": "爷爷的手表",
      "online": true,
      "battery": 85,
      "last_seen": "2024-06-27T10:00:00Z"
    }
  ]
}
```

#### `get_device_status`
获取指定设备的详细状态。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {
      "type": "string",
      "description": "设备ID"
    }
  },
  "required": ["device_id"]
}
```

### 2. 传感器类

#### `get_sensor_data`
获取传感器最新数据。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string", "description": "设备ID"},
    "sensor_type": {
      "type": "string",
      "enum": ["battery", "imu", "environment", "hr_spo2"],
      "description": "传感器类型"
    }
  },
  "required": ["device_id"]
}
```

#### `get_sensor_history`
查询传感器历史数据。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "sensor_type": {"type": "string"},
    "start_time": {"type": "string", "description": "ISO 8601时间"},
    "end_time": {"type": "string"},
    "limit": {"type": "integer", "default": 50, "maximum": 500}
  },
  "required": ["device_id", "sensor_type", "start_time", "end_time"]
}
```

#### `get_fall_detection_status`
获取跌倒检测状态/最近跌倒记录。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "recent_hours": {"type": "integer", "default": 24, "description": "查询最近多少小时"}
  },
  "required": ["device_id"]
}
```

### 3. 告警类

#### `list_alerts`
查询告警记录。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "status": {
      "type": "string",
      "enum": ["active", "acknowledged", "cancelled", "resolved", "all"],
      "default": "active"
    },
    "alert_type": {
      "type": "string",
      "enum": ["fall", "sos", "battery_low", "door", "smoke"]
    },
    "limit": {"type": "integer", "default": 20}
  }
}
```

#### `acknowledge_alert`
确认/处理告警。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "alert_id": {"type": "string", "description": "告警ID"},
    "note": {"type": "string", "description": "处理备注"}
  },
  "required": ["alert_id"]
}
```

#### `cancel_alert`
取消告警。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "alert_id": {"type": "string"},
    "reason": {"type": "string", "description": "取消原因，如误报"}
  },
  "required": ["alert_id"]
}
```

#### `trigger_alert`
主动触发测试告警（用于测试）。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "alert_type": {
      "type": "string",
      "enum": ["fall", "sos"]
    },
    "test": {"type": "boolean", "default": true}
  },
  "required": ["device_id", "alert_type"]
}
```

### 4. 设备控制类

#### `send_device_message`
向设备发送消息/语音播报。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "message": {"type": "string", "description": "要播报的文本内容"},
    "priority": {
      "type": "string",
      "enum": ["normal", "high", "emergency"],
      "default": "normal"
    },
    "volume": {"type": "integer", "minimum": 0, "maximum": 100}
  },
  "required": ["device_id", "message"]
}
```

#### `trigger_device_action`
触发设备动作（震动、屏幕显示等）。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "action": {
      "type": "string",
      "enum": ["vibrate", "display_alert", "reboot", "play_sound"]
    },
    "params": {"type": "object"}
  },
  "required": ["device_id", "action"]
}
```

### 5. 健康统计类

#### `get_daily_summary`
获取每日活动/健康摘要。

**参数：**
```json
{
  "type": "object",
  "properties": {
    "device_id": {"type": "string"},
    "date": {"type": "string", "description": "日期 YYYY-MM-DD，默认今天"}
  },
  "required": ["device_id"]
}
```

**返回示例：**
```json
{
  "date": "2024-06-27",
  "steps": 3420,
  "activity_minutes": 45,
  "fall_count": 0,
  "sos_count": 0,
  "avg_battery": 78,
  "wear_duration_hours": 12.5
}
```

## 资源（Resources）定义

MCP Resources用于暴露结构化数据源，客户端可订阅更新：

| Resource URI | 说明 |
|-------------|------|
| `aiguard://devices/{id}/status` | 设备实时状态 |
| `aiguard://alerts/active` | 当前活动告警 |
| `aiguard://devices/{id}/sensor/imu` | 实时IMU数据流 |

## 提示词模板（Prompts）

MCP Prompts提供预定义的提示词模板：

| Prompt名称 | 用途 |
|-----------|------|
| `fall_alert_response` | 跌倒告警响应流程指引 |
| `daily_checkin` | 每日健康状态检查对话 |
| `device_setup_guide` | 设备配网/设置向导 |

### `fall_alert_response` 示例
```
检测到用户可能发生跌倒，请按以下步骤处理：
1. 首先确认用户状态，尝试通过语音/消息联系
2. 查询最近传感器数据确认
3. 如无回应，通知紧急联系人
4. 记录处理过程
```

## MCP 消息格式示例

### 工具调用（Request）
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "get_device_status",
    "arguments": {
      "device_id": "a1b2c3d4e5f6"
    }
  }
}
```

### 工具响应（Response）
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "手表「爷爷的手表」当前在线，电量85%，Wi-Fi信号良好，未检测到告警。"
      },
      {
        "type": "json",
        "data": {
          "id": "a1b2c3d4e5f6",
          "online": true,
          "battery": 85,
          "rssi": -55
        }
      }
    ]
  }
}
```

### 工具列表（List Tools）
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list",
  "result": {
    "tools": [
      {
        "name": "list_devices",
        "description": "列出所有已注册的AIguard设备",
        "inputSchema": { "type": "object", "properties": {} }
      }
    ]
  }
}
```

## 安全考虑

1. **认证**：MCP Server应要求认证，防止未授权访问
2. **权限控制**：告警触发、设备控制等高风险操作需额外确认
3. **审计日志**：记录所有工具调用，特别是控制类操作
4. **敏感数据**：不暴露Wi-Fi密码、API Key等敏感信息
5. **速率限制**：防止LLM异常循环调用

## 与Home Assistant MCP集成

如果已有Home Assistant，AIguard MCP可：
- 复用HA MCP Server的设备控制能力
- 在AIguard MCP中调用HA的服务
- 或者通过HA实体统一暴露，不单独运行AIguard MCP Server
