# MQTT

MQTT（Message Queuing Telemetry Transport）是轻量级物联网消息协议，适合设备与服务器之间的低带宽、不稳定网络通信。

## 快速参考

### MQTT 协议基础

| 特性 | MQTT 3.1.1 | MQTT 5.0 |
|------|------------|----------|
| 发布年份 | 2014 | 2019 |
| 消息大小 | 最大 256MB | 无限制 |
| 共享订阅 | 不支持 | 支持 |
| 消息过期 | 不支持 | 支持 |
| 主题别名 | 不支持 | 支持 |
| 错误码 | 有限 | 更丰富 |

**推荐：** 新项目优先使用 MQTT 5.0，兼容旧设备可用 3.1.1。

### QoS 等级

| QoS | 名称 | 说明 | 适用场景 |
|-----|------|------|----------|
| 0 | At most once（至多一次） | 消息只发一次，不保证到达 | 传感器数据（丢一两个没关系） |
| 1 | At least once（至少一次） | 确保消息到达，但可能重复 | 指令下发、状态通知（需去重） |
| 2 | Exactly once（恰好一次） | 保证消息只到达一次 | 支付、重要控制指令（开销大） |

### 主题设计规范

MQTT 主题以 `/` 分隔，支持多层级和通配符。

**AIguard 主题设计：**
```
# 格式
aiguard/{domain}/{device_id}/{action}

# 示例
aiguard/device/esp32-s3-001/status       # 设备上线/离线状态
aiguard/device/esp32-s3-001/sensor       # 传感器数据上报
aiguard/device/esp32-s3-001/event        # 事件上报（如唤醒、告警）
aiguard/device/esp32-s3-001/command      # 下发指令
aiguard/device/esp32-s3-001/response     # 指令响应

aiguard/homeassistant/status             # HA 状态
aiguard/audio/esp32-s3-001/stream        # 音频流

# 系统级
aiguard/system/broadcast                 # 系统广播
aiguard/ota/device/+                     # OTA 升级（通配符）
```

**通配符：**
- `+`：匹配单一层级，如 `aiguard/device/+/status`
- `#`：匹配多层级（必须在末尾），如 `aiguard/device/#`

**设计原则：**
- 主题开头不要使用 `/`（会产生空层级）
- 主题中不要使用空格和特殊字符
- 使用 `_` 或 `-` 分隔单词
- 设备 ID 放在主题前部便于 ACL 控制
- 不要在主题中放置消息内容（使用 payload）

### Broker 部署（Mosquitto）

```bash
# 安装 Eclipse Mosquitto
sudo apt install -y mosquitto mosquitto-clients

# 配置
sudo nano /etc/mosquitto/mosquitto.conf
```

**mosquitto.conf 基础配置：**
```conf
listener 1883 0.0.0.0
protocol mqtt

# 启用认证
allow_anonymous false
password_file /etc/mosquitto/passwd

# 持久化
persistence true
persistence_location /var/lib/mosquitto/

# 日志
log_dest file /var/log/mosquitto/mosquitto.log
```

```bash
# 创建用户
sudo mosquitto_passwd -c /etc/mosquitto/passwd mqtt_user
# 后续添加用户去掉 -c
sudo mosquitto_passwd /etc/mosquitto/passwd device_user

# 重启服务
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto
```

**命令行测试：**
```bash
# 订阅
mosquitto_sub -h localhost -u mqtt_user -P your_password -t "aiguard/#" -v

# 发布
mosquitto_pub -h localhost -u mqtt_user -P your_password \
  -t "aiguard/device/esp32-s3-001/status" \
  -m '{"online": true, "ip": "192.168.1.100"}'
```

### Spring Boot 集成 MQTT

**Maven 依赖：**
```xml
<dependency>
    <groupId>org.springframework.integration</groupId>
    <artifactId>spring-integration-mqtt</artifactId>
</dependency>
```

**配置类：**
```java
@Configuration
public class MqttConfig {

    @Value("${spring.mqtt.broker-url}")
    private String brokerUrl;

    @Value("${spring.mqtt.client-id}")
    private String clientId;

    @Value("${spring.mqtt.username}")
    private String username;

    @Value("${spring.mqtt.password}")
    private String password;

    @Bean
    public MqttConnectOptions mqttConnectOptions() {
        MqttConnectOptions options = new MqttConnectOptions();
        options.setServerURIs(new String[]{brokerUrl});
        options.setUserName(username);
        options.setPassword(password.toCharArray());
        options.setCleanSession(true);
        options.setAutomaticReconnect(true);
        options.setConnectionTimeout(10);
        options.setKeepAliveInterval(60);
        return options;
    }

    @Bean
    public MqttClient mqttClient() throws MqttException {
        MqttClient client = new MqttClient(brokerUrl, clientId + "-pub");
        client.connect(mqttConnectOptions());
        return client;
    }
}
```

**消息发布服务：**
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class MqttPublishService {

    private final MqttClient mqttClient;

    public void publish(String topic, String payload, int qos) {
        try {
            MqttMessage message = new MqttMessage(payload.getBytes(StandardCharsets.UTF_8));
            message.setQos(qos);
            message.setRetained(false);
            mqttClient.publish(topic, message);
        } catch (MqttException e) {
            log.error("MQTT 发布失败: topic={}, error={}", topic, e.getMessage());
        }
    }
}
```

## 常见坑点

1. **Clean Session 与持久会话**
   - `cleanSession=true`：客户端断开后订阅关系清除，离线消息丢失
   - `cleanSession=false`（MQTT 3.1.1）/ `cleanStart=0`（MQTT 5.0）：保留订阅和离线消息
   - 设备端通常使用 clean session，服务端订阅可使用持久会话接收离线消息

2. **Retained 消息陷阱**
   - Retained 消息会被 Broker 保留，新订阅者立即收到最后一条 retained 消息
   - 传感器数据不要使用 retained（新订阅者会收到过时数据）
   - 设备状态（在线/离线）可使用 retained，便于新上线的服务端获知当前状态
   - 发送空 payload（0字节）可清除 retained 消息

3. **客户端 ID 冲突**
   - 同一 Broker 上 clientId 必须唯一
   - 后连接的客户端会把先连接的"踢下线"
   - 建议使用 `clientId-随机后缀` 或 `clientId-UUID`

4. **QoS 1/2 消息重复**
   - QoS 1 保证至少到达一次，消费者必须实现幂等处理
   - 方案：使用消息 ID 去重、数据库唯一约束、乐观锁

5. **Payload 大小限制**
   - MQTT 3.1.1 最大 payload 256MB，但实际受 Broker 配置限制
   - Mosquitto 默认 `max_packet_size` 通常设置为 1MB 左右
   - 音频、视频等大文件不建议直接通过 MQTT 传输，可传递下载 URL

6. **心跳 Keep Alive 设置**
   - 建议设置 30-60 秒，过短浪费流量，过长无法及时检测断线
   - 在网络不稳定环境（Wi-Fi切换、移动网络）应适当缩短

7. **SSL/TLS 连接**
   - 生产环境必须使用 TLS 加密（端口 8883）
   - 自签名证书客户端需配置 truststore，否则连接失败

## 官方链接

详见 [official-links.md](official-links.md)。

- MQTT 5.0 规范（OASIS）：https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html
- Eclipse Mosquitto：https://mosquitto.org/
- Eclipse Paho Java Client：https://github.com/eclipse/paho.mqtt.java
- Spring Integration MQTT：https://docs.spring.io/spring-integration/reference/html/mqtt.html
- MQTT 中文社区：https://mcxiaoke.gitbook.io/mqtt/
