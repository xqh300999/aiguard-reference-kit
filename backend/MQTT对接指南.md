# MQTT 对接指南

## 1. 架构概览

```
硬件设备(按钮/手表)
      ↓ MQTT publish
树莓派5 (HA Mosquitto Broker, 端口1883)
      ↓ MQTT broker 转发
后端 Spring Integration (MqttConfig.java)
      ↓ topic 匹配分流
  ┌──────┬──────────┬────────────┐
  SOS    心跳      上线/离线
handler handler    handler
  ↓        ↓          ↓
alert表  device表   device表
```

## 2. 后端连接配置

`application-local.yml` 中 MQTT 配置：

```yaml
mqtt:
  broker-url: tcp://树莓派IP:1883        # Mosquitto 所在机器的局域网 IP
  client-id: aiguard-backend-local       # 后端在 Broker 上的标识
  username: 你的HA用户名                  # HA 账号或专用用户
  password: 你的HA密码
  keep-alive: 60                         # 心跳间隔(秒)
  connection-timeout: 30                 # 连接超时(秒)
  completion-timeout: 5000               # 适配器启停超时(毫秒)
```

**切换 Broker 只需改 `broker-url`、`username`、`password` 三个值，代码不用改。**

| 场景 | broker-url |
|------|-----------|
| 本地开发 | `tcp://localhost:1883` |
| 树莓派 HA | `tcp://树莓派IP:1883` |

## 3. Topic 命名规范

### 3.1 格式

```
aiguard/v1/{设备类型}/{设备ID}/{领域}/{动作}
```

| 变量 | 说明 | 示例值 |
|------|------|--------|
| 设备类型 | 设备分类 | watch(手表)、panel(大屏)、gateway(网关) |
| 设备ID | 设备唯一标识 | 手表 IMEI 或 MAC 地址（无分隔符小写） |
| 领域 | 业务领域 | alert、health、system |
| 动作 | 操作类型 | sos、heartbeat、sensor、command |

### 3.2 后端订阅的 Topic

| Topic | QoS | 用途 |
|-------|-----|------|
| `aiguard/v1/+/+/alert/sos` | 2 | SOS 告警 |
| `aiguard/v1/+/+/health/heartbeat` | 1 | 心跳上报 |
| `aiguard/v1/+/+/system/online` | 1 | 设备上线 |
| `aiguard/v1/+/+/system/offline` | 1 | 设备离线 |

> `+` 是 MQTT 通配符，匹配任意一级。

### 3.3 完整 Topic 列表（文档定义）

| Topic | 方向 | 说明 | QoS |
|-------|------|------|-----|
| `aiguard/v1/watch/{id}/alert/sos` | 设备→服务器 | SOS 告警 | 2 |
| `aiguard/v1/watch/{id}/alert/fall` | 设备→服务器 | 跌倒检测告警 | 1 |
| `aiguard/v1/watch/{id}/alert/low_battery` | 设备→服务器 | 低电量告警 | 1 |
| `aiguard/v1/watch/{id}/health/heartbeat` | 设备→服务器 | 设备心跳 | 1 |
| `aiguard/v1/watch/{id}/health/sensor` | 设备→服务器 | 传感器数据上报 | 1 |
| `aiguard/v1/panel/{id}/display/command` | 服务器→设备 | 大屏显示指令 | 1 |
| `aiguard/v1/gateway/{id}/system/ota` | 服务器→设备 | OTA 升级指令 | 0 |

## 4. Payload 格式（JSON）

### 4.1 SOS 告警上报（QoS 2）

```json
{
  "type": "sos",
  "deviceId": "watch_a1b2c3d4e5f6",
  "timestamp": "2026-07-05T10:30:00Z",
  "data": {
    "elderlyId": 1,
    "lat": 30.5728,
    "lng": 104.0668
  }
}
```

### 4.2 心跳上报（QoS 1）

```json
{
  "type": "heartbeat",
  "deviceId": "watch_a1b2c3d4e5f6",
  "timestamp": "2026-07-05T10:30:00Z",
  "data": {
    "battery": 85,
    "rssi": -65
  }
}
```

### 4.3 跌倒检测上报（QoS 1）

```json
{
  "type": "fall",
  "deviceId": "watch_a1b2c3d4e5f6",
  "timestamp": "2026-07-05T10:30:00Z",
  "data": {
    "elderlyId": 1,
    "impact": 9.8,
    "angle": 75.3
  }
}
```

## 5. 设备注册要求

- **设备 MAC 必须先在 `device` 表注册**，否则后端会打印"设备未注册"并丢弃消息
- topic 中的设备ID必须是无分隔符小写 MAC（如 `a1b2c3d4e5f6`），后端自动转成 `A1:B2:C3:D4:E5:F6` 查表
- 数据库中已注册设备示例：

| MAC | 名称 | 类型 |
|-----|------|------|
| A1:B2:C3:D4:E5:F6 | 王大爷的手表 | WATCH |
| A1:B2:C3:D4:E5:F7 | 李奶奶的手表 | WATCH |
| A1:B2:C3:D4:E5:F8 | 刘奶奶的手表 | WATCH |

## 6. 测试方法

### 6.1 HTTP 接口测试（模拟设备）

```bash
# 模拟 SOS 告警
curl -X POST http://localhost:8080/api/v1/test/mqtt/sos

# 模拟心跳
curl -X POST http://localhost:8080/api/v1/test/mqtt/heartbeat

# 模拟设备上线
curl -X POST http://localhost:8080/api/v1/test/mqtt/online

# 模拟设备离线
curl -X POST http://localhost:8080/api/v1/test/mqtt/offline

# 带参数
curl -X POST "http://localhost:8080/api/v1/test/mqtt/sos?deviceId=a1b2c3d4e5f7&battery=20"
```

> 消息流程：curl(HTTP) → 后端 → MQTT publish → 树莓派 HA → 后端订阅 → 入库

### 6.2 mosquitto_pub 命令行测试

```bash
# SOS（QoS 2）
mosquitto_pub -h 树莓派IP -p 1883 -t "aiguard/v1/watch/a1b2c3d4e5f6/alert/sos" -q 2 -m "{\"type\":\"sos\",\"deviceId\":\"watch_a1b2c3d4e5f6\",\"timestamp\":\"2026-07-09T10:30:00Z\",\"data\":{\"elderlyId\":1,\"lat\":30.5728,\"lng\":104.0668}}"

# 心跳（QoS 1）
mosquitto_pub -h 树莓派IP -p 1883 -t "aiguard/v1/watch/a1b2c3d4e5f6/health/heartbeat" -q 1 -m "{\"type\":\"heartbeat\",\"deviceId\":\"watch_a1b2c3d4e5f6\",\"timestamp\":\"2026-07-09T10:30:00Z\",\"data\":{\"battery\":85,\"rssi\":-65}}"
```

### 6.3 验证结果

- 后端日志打印 `[MQTT-SOS]` / `[MQTT-Heartbeat]` 消息
- SOS 发布后，`alert` 表新增 `type=SOS, status=PENDING, priority=HIGH` 记录
- 心跳发布后，`device` 表 `status=ONLINE`，`last_heartbeat` 和 `battery` 更新

## 7. 树莓派 HA Mosquitto 配置

### 7.1 Docker 部署

```bash
docker run -d -p 1883:1883 --name mosquitto eclipse-mosquitto
```

### 7.2 配置文件

`/mosquitto/config/mosquitto.conf`：

```
listener 1883 0.0.0.0
allow_anonymous false
password_file /mosquitto/config/passwd
```

### 7.3 开放防火墙

```bash
sudo ufw allow 1883
```

### 7.4 确认端口映射

```bash
docker ps
# 确保有 0.0.0.0:1883->1883/tcp 的映射
```

## 8. 排查：按钮消息收不到

### 8.1 抓取真实消息

在树莓派终端执行：

```bash
mosquitto_sub -h localhost -p 1883 -t "#" -v
```

按一下按钮，查看终端打印的 topic 和 payload。

### 8.2 常见问题

| 问题 | 原因 | 解决方法 |
|------|------|---------|
| `Connection timed out` | 电脑连不上树莓派 1883 端口 | 检查同一局域网、防火墙、Docker 端口映射 |
| 后端无响应 | 涂鸦 topic 格式不是 `aiguard/v1/...` | 在树莓派加 topic 转发（HA 自动化或 Node-RED） |
| `设备未注册` | topic 中的设备ID在 device 表查不到 | 在 device 表插入对应 MAC 的设备记录 |
| payload 解析失败 | 涂鸦 payload 格式与文档不一致 | 在转发层转换 payload 格式 |

### 8.3 涂鸦平台对接

涂鸦平台发的 topic 和 payload 格式与后端期望的不一样，需要在树莓派上加一层转换：

**方式1 — HA 自动化（推荐）**
- 触发条件：MQTT 收到涂鸦的 topic
- 动作：重新发布到 `aiguard/v1/watch/{设备MAC}/alert/sos`，payload 转成文档格式

**方式2 — Node-RED**
在树莓派上跑 Node-RED，做 topic 和 payload 的映射转发。

## 9. 后续硬件接入

硬件接入后，`MqttTestController` 不再必需，可以：
- **保留**：不影响生产环境，可用于对比测试
- **删除**：确认硬件完全就绪后删除 `MqttTestController.java` 即可

后端代码不需要任何修改，只需确保：
1. 硬件设备连到同一个 Mosquitto Broker
2. topic 格式符合 `aiguard/v1/{type}/{id}/{领域}/{动作}`
3. payload 格式符合文档定义的 JSON 结构
4. 设备 MAC 已在 device 表注册

## 10. 实际测试问题分析

### 10.1 问题描述

使用树莓派 HA 作为 Broker，后端成功连接。通过树莓派手动发布消息到 `aiguard/v1/watch/Allen_9/alert/sos`，后端收到了消息但入库失败。

### 10.2 后端日志

```
[MQTT-SOS] 收到SOS告警 | topic=aiguard/v1/watch/Allen_9/alert/sos | payload={
  "name":"allen"
  "TIME":12:12
}

==>  Preparing: SELECT ... FROM device WHERE (mac = ?)
==> Parameters: AL:LE:N_:9(String)
<==      Total: 0

[MQTT-SOS] 设备未注册，mac=AL:LE:N_:9，topic=aiguard/v1/watch/Allen_9/alert/sos
```

### 10.3 问题分析

#### 问题1：设备ID不是MAC地址

- **现象**：topic 中的设备ID是 `Allen_9`，后端 `formatMac()` 把它当 MAC 地址处理，转成了 `AL:LE:N_:9`
- **原因**：后端 `formatMac()` 方法假设设备ID是 12 位十六进制 MAC 地址（如 `a1b2c3d4e5f6`），会每两位插入冒号转成 `A1:B2:C3:D4:E5:F6`。但 `Allen_9` 不是 MAC 格式，转换后得到 `AL:LE:N_:9`，查 device 表自然查不到
- **正确做法**：topic 中的设备ID应该使用设备真实的 MAC 地址（无分隔符小写），例如 `a1b2c3d4e5f6`

#### 问题2：payload 格式不符合文档规范

- **收到的 payload**：
  ```json
  {"name":"allen","TIME":12:12}
  ```
  以及：
  ```json
  {"msg":"Allen_9","the_most_handsome_man_in_SZPU":"Allen_9"}
  ```
- **期望的 payload**（文档定义）：
  ```json
  {
    "type": "sos",
    "deviceId": "watch_a1b2c3d4e5f6",
    "timestamp": "2026-07-05T10:30:00Z",
    "data": {
      "elderlyId": 1,
      "lat": 30.5728,
      "lng": 104.0668
    }
  }
  ```
- **原因**：树莓派上手动发布的测试消息没有遵循文档定义的 payload 格式
- **影响**：即使设备能查到，payload 中的 `data.elderlyId`、`data.lat`、`data.lng` 等字段也解析不出来，无法完整入库

### 10.4 解决方案

#### 方案A：修改树莓派发布的消息（推荐）

确保树莓派发布的消息同时满足：
1. **topic 格式**：设备ID使用真实 MAC 地址
   ```
   aiguard/v1/watch/a1b2c3d4e5f6/alert/sos
   ```
2. **payload 格式**：按文档定义的 JSON 结构
   ```json
   {
     "type": "sos",
     "deviceId": "watch_a1b2c3d4e5f6",
     "timestamp": "2026-07-10T08:56:00Z",
     "data": {
       "elderlyId": 1,
       "lat": 30.5728,
       "lng": 104.0668
     }
   }
   ```

#### 方案B：在 device 表注册对应设备

如果确实要用 `Allen_9` 作为设备ID，需要在 device 表插入一条记录：
```sql
INSERT INTO device (name, type, mac, community_id, elderly_id, status)
VALUES ('Allen的设备', 'WATCH', 'AL:LE:N_:9', 1, 1, 'ONLINE');
```
> 注意：这不推荐，因为 `AL:LE:N_:9` 不是合法 MAC 格式，后续对接真实硬件会有问题。

### 10.5 正确的测试命令

```bash
# 在树莓派上执行，使用正确的 topic 和 payload
mosquitto_pub -h localhost -p 1883 \
  -t "aiguard/v1/watch/a1b2c3d4e5f6/alert/sos" \
  -q 2 \
  -m '{"type":"sos","deviceId":"watch_a1b2c3d4e5f6","timestamp":"2026-07-10T08:56:00Z","data":{"elderlyId":1,"lat":30.5728,"lng":104.0668}}'
```

### 10.6 验证成功的标志

后端日志应该出现：
```
[MQTT-SOS] 收到SOS告警 | topic=aiguard/v1/watch/a1b2c3d4e5f6/alert/sos | payload={"type":"sos",...}
==>  Preparing: SELECT ... FROM device WHERE (mac = ?)
==> Parameters: A1:B2:C3:D4:E5:F6(String)
<==        Row: 1, 王大爷的手表, WATCH, A1:B2:C3:D4:E5:F6, ...
<==      Total: 1
==>  Preparing: INSERT INTO alert (type, elderly_id, community_id, ...) VALUES (...)
<==    Updates: 1
[MQTT-SOS] 告警已入库 | alertId=xx | elderlyId=1 | deviceId=1
```
