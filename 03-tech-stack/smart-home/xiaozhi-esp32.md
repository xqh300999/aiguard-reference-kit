# 小智 ESP32

小智 AI 对话助手（xiaozhi-esp32）是开源的 ESP32 智能语音助手项目，支持 MQTT、大模型对话、OTA 升级、MCP 工具调用。

## 快速参考

### 小智 ESP32 概述

| 特性 | 说明 |
|------|------|
| 项目地址 | https://github.com/78/xiaozhi-esp32 |
| 开源协议 | MIT |
| 开发框架 | ESP-IDF v5.x |
| 支持开发板 | 微雪 ESP32-S3-Touch-AMOLED-2.06、ESP32-P4-WIFI6-Touch-LCD-7B 等 |
| AI 对话 | 支持通义千问、DeepSeek、ChatGLM、本地 LLM 等 |
| 通信方式 | Wi-Fi + MQTT（WebSocket 备选）|
| 固件升级 | OTA 空中升级 |
| 工具扩展 | MCP（Model Context Protocol）|
| 语音唤醒 | 支持离线唤醒词 |
| 屏幕显示 | 支持多种 LCD/OLED 屏幕 |

**支持的开发板：**
- 微雪 ESP32-S3-Touch-AMOLED-2.06（小智官方推荐，2.06寸AMOLED触控屏）
- 微雪 ESP32-P4-WIFI6-Touch-LCD-7B（7寸大屏，WiFi6）
- 其他 ESP32-S3 开发板（需自行适配驱动）

**固件文件（参考）：**
```
v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip     # S3 AMOLED 版本
v2.2.4_waveshare-esp32-p4-wifi6-touch-lcd-7b.zip    # P4 WiFi6 7寸版本
```

### 固件烧录（web 方式，推荐新手）

1. 浏览器访问小智官方烧录工具（需 Chrome/Edge）
2. 连接 ESP32 开发板到电脑 USB
3. 选择对应开发板的固件包（zip 文件）
4. 点击「连接」选择正确的串口
5. 点击「烧录固件」等待完成
6. 烧录完成后重启设备，按屏幕提示配网

### 固件烧录（命令行方式）

```bash
# 安装 esptool
pip install esptool

# 解压固件包
unzip v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip
cd firmware

# 擦除 Flash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash

# 烧录固件（注意波特率需与固件匹配）
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
  write_flash -z 0x0 xiaozhi.bin
# 不同固件包烧录地址可能不同，查看 release 说明
```

### 首次配网

1. 烧录完成后按 RST 键重启设备
2. 屏幕显示 Wi-Fi 配网二维码或热点名称
3. 使用手机连接设备热点或扫描二维码配网
4. 输入 Wi-Fi 密码，设备连接网络
5. 输入 MQTT 服务器地址或使用小智官方服务器
6. 设备激活后即可语音对话

### OTA 升级

小智固件支持 OTA 空中升级，无需重新烧录：

1. 设备连接网络后，若检测到新版本固件会提示升级
2. 在设备屏幕上确认升级（或后台自动升级）
3. 等待固件下载并安装（不要断电）
4. 升级完成后设备自动重启

**自托管 OTA 服务器（可选）：**
若需管理私有固件版本，可部署 OTA 服务，固件检查 HTTP 接口返回最新版本信息和下载 URL。

### MQTT 主题设计

小智与服务器通信的 MQTT 主题：

```
# 设备→服务器
xiaozhi/<device_id>/hello         # 上线打招呼/心跳
xiaozhi/<device_id>/audio         # 音频数据（opus编码）
xiaozhi/<device_id>/message       # 文本消息/指令
xiaozhi/<device_id>/status        # 状态上报
xiaozhi/<device_id>/ota           # OTA 请求

# 服务器→设备
xiaozhi/<device_id>/command       # 控制指令
xiaozhi/<device_id>/tts           # TTS 语音数据
xiaozhi/<device_id>/config        # 配置下发
xiaozhi/<device_id>/ota_update    # OTA 升级通知
```

**消息格式示例：**
```json
// 语音识别结果
{
  "type": "listen",
  "text": "打开客厅灯",
  "session_id": "abc123"
}

// 服务器返回对话
{
  "type": "tts",
  "text": "好的，已为你打开客厅灯",
  "audio": "<base64编码音频>",
  "should_listen": false
}

// 设备状态上报
{
  "type": "status",
  "state": "idle",
  "battery": 100,
  "wifi_rssi": -45
}
```

### MCP（Model Context Protocol）集成

MCP 是模型上下文协议，允许大模型调用外部工具。小智通过 MCP 可控制智能家居设备。

**AIguard MCP 工具集成示例：**

```json
// MCP 工具定义
{
  "tools": [
    {
      "name": "control_device",
      "description": "控制智能家居设备",
      "parameters": {
        "type": "object",
        "properties": {
          "device_id": { "type": "string", "description": "设备ID" },
          "action": { "type": "string", "enum": ["turn_on", "turn_off", "set_brightness"], "description": "操作" },
          "value": { "type": "number", "description": "参数值" }
        },
        "required": ["device_id", "action"]
      }
    },
    {
      "name": "get_weather",
      "description": "查询天气",
      "parameters": {
        "type": "object",
        "properties": {
          "city": { "type": "string", "description": "城市名称" }
        },
        "required": ["city"]
      }
    },
    {
      "name": "query_device_status",
      "description": "查询设备状态",
      "parameters": {
        "type": "object",
        "properties": {
          "device_id": { "type": "string", "description": "设备ID" }
        },
        "required": ["device_id"]
      }
    }
  ]
}
```

**对话流程：**
1. 用户说「打开客厅灯」
2. 语音识别发送文本到后端
3. 大模型识别需要调用 `control_device` 工具
4. 后端执行工具调用（通过 MQTT/HA API 控制设备）
5. 返回结果给大模型，生成自然语言回复
6. TTS 播放回复语音

### 对接 AIguard 后端

后端服务需实现以下 MQTT 消息处理逻辑：

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class XiaozhiMqttService {

    private final MqttClient mqttClient;
    private final QwenService qwenService;
    private final DeviceControlService deviceService;
    private final ObjectMapper objectMapper;

    @MqttMessageListener(topic = "xiaozhi/+/hello")
    public void onHello(String topic, String payload) {
        String deviceId = extractDeviceId(topic);
        log.info("小智设备上线: {}", deviceId);
        // 回复 welcome 消息
        publish(deviceId, "welcome", Map.of(
            "type", "welcome",
            "server_time", System.currentTimeMillis()
        ));
    }

    @MqttMessageListener(topic = "xiaozhi/+/message")
    public void onMessage(String topic, String payload) throws Exception {
        String deviceId = extractDeviceId(topic);
        JsonNode msg = objectMapper.readTree(payload);
        String type = msg.get("type").asText();

        if ("listen".equals(type)) {
            String text = msg.get("text").asText();
            String sessionId = msg.get("session_id").asText();

            // 调用通义千问 + MCP 处理
            String response = qwenService.chatWithTools(deviceId, text, sessionId);

            // 返回 TTS 消息
            publish(deviceId, "tts", Map.of(
                "type", "tts",
                "text", response,
                "session_id", sessionId,
                "should_listen", false
            ));
        }
    }

    @MqttMessageListener(topic = "xiaozhi/+/ota")
    public void onOtaRequest(String topic, String payload) {
        String deviceId = extractDeviceId(topic);
        // 检查是否有新版本，返回OTA信息
        // ...
    }

    private void publish(String deviceId, String action, Object data) {
        try {
            String topic = "xiaozhi/" + deviceId + "/" + action;
            mqttClient.publish(topic, objectMapper.writeValueAsString(data).getBytes(), 1, false);
        } catch (Exception e) {
            log.error("发布消息失败", e);
        }
    }

    private String extractDeviceId(String topic) {
        // xiaozhi/device-xxx/message -> device-xxx
        String[] parts = topic.split("/");
        return parts[1];
    }
}
```

### 源码编译（自定义开发）

```bash
# 克隆仓库
git clone https://github.com/78/xiaozhi-esp32.git
cd xiaozhi-esp32
git submodule update --init --recursive

# 设置 ESP-IDF 环境
# 需安装 ESP-IDF v5.2+
. ~/esp/esp-idf/export.sh

# 配置目标板型
idf.py set-target esp32s3
# 或 idf.py set-target esp32p4

# menuconfig 配置
idf.py menuconfig
# 配置：Xiaozhi Assistant → Board Config → 选择对应开发板
# 配置：Wi-Fi 默认参数、MQTT 服务器地址（也可配网后设置）

# 编译烧录
idf.py -p /dev/ttyUSB0 build flash monitor
```

## 常见坑点

1. **固件与开发板不匹配**
   - 烧录前确认开发板型号，不同屏幕驱动 IC 不同
   - 微雪 ESP32-S3 AMOLED 2.06 和 P4 WiFi6 7B 固件不能互刷
   - 刷错固件现象：屏幕白屏/花屏、触摸无反应、麦克风不工作

2. **烧录失败/无法识别串口**
   - USB 驱动：确保安装 CH340/CP2102 驱动
   - Linux/macOS：确认用户有串口权限
   - 按住 BOOT 键再插 USB/按 RST 进入下载模式
   - 降低烧录波特率：`-b 115200`

3. **MQTT 连接失败**
   - 检查 Wi-Fi 是否正常连接
   - MQTT Broker 地址是否正确（不要用 localhost，需用局域网IP）
   - 用户名密码是否正确
   - Broker 是否开放 1883 端口、防火墙是否放行

4. **麦克风/唤醒问题**
   - 远离噪音源，避免回音
   - 确认开发板麦克风引脚配置正确（官方固件已适配微雪板）
   - 唤醒词为「小智小智」

5. **OTA 升级断电变砖**
   - OTA 升级过程中（屏幕显示升级进度）严禁断电
   - 若升级失败变砖，需重新通过 USB 烧录固件
   - 可在固件中实现双分区回退机制

6. **MCP 工具调用超时**
   - MCP 工具调用需控制响应时间，建议 3 秒内返回结果
   - 复杂操作应异步处理，先回复「正在为你操作」再后台执行
   - 控制设备后需查询确认状态

7. **PSRAM 配置错误**
   - 编译时 menuconfig 必须选择正确的 PSRAM 类型（Octal/Quad）
   - 微雪 ESP32-S3 AMOLED 2.06 使用 Octal PSRAM
   - PSRAM 配置错误会导致启动崩溃或重启循环

8. **音频流传输延迟**
   - 音频使用 opus 编码压缩以减少带宽
   - MQTT QoS 建议使用 0 或 1（QoS 2 延迟过高不适合实时音频）
   - 网络环境差时可能出现卡顿，建议使用 5GHz Wi-Fi

## 官方链接

详见 [official-links.md](official-links.md)。

- 小智 ESP32 GitHub：https://github.com/78/xiaozhi-esp32
- 小智固件发布页：https://github.com/78/xiaozhi-esp32/releases
- 小智 Web 烧录工具：https://xiaozhi.me/
- 小智文档（Wiki）：https://github.com/78/xiaozhi-esp32/wiki
- 小智配置服务器：https://api.tenclass.net/xiaozhi/
