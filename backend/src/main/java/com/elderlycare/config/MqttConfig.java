package com.elderlycare.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.elderlycare.mapper.AlertMapper;
import com.elderlycare.mapper.DeviceMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.entity.Alert;
import com.elderlycare.entity.Device;
import com.elderlycare.entity.Elderly;
import com.elderlycare.websocket.AlertWebSocketHandler;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * MQTT 消费配置 — Spring Integration
 * <p>
 * 监听 topic（按团队 MQTT 协议规范 mqtt-topics.md）：
 * <ul>
 *   <li>SOS 告警：aiguard/v1/{type}/{id}/alert/sos — QoS 2（恰好一次）</li>
 *   <li>设备心跳：aiguard/v1/{type}/{id}/health/heartbeat — QoS 1（至少一次）</li>
 *   <li>设备上线：aiguard/v1/{type}/{id}/system/online — QoS 1（Retain，LWT）</li>
 *   <li>设备离线：aiguard/v1/{type}/{id}/system/offline — QoS 1（Retain，LWT）</li>
 * </ul>
 * 断线自动重连：MqttConnectOptions.setAutomaticReconnect(true)
 */
@Configuration
public class MqttConfig {

    private static final Logger log = LoggerFactory.getLogger(MqttConfig.class);

    @Autowired
    private DeviceMapper deviceMapper;

    @Autowired
    private AlertMapper alertMapper;

    @Autowired
    private ElderlyMapper elderlyMapper;

    @Autowired
    private AlertWebSocketHandler alertWebSocketHandler;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("${mqtt.broker-url}")
    private String brokerUrl;

    @Value("${mqtt.client-id}")
    private String clientId;

    @Value("${mqtt.username:}")
    private String username;

    @Value("${mqtt.password:}")
    private String password;

    @Value("${mqtt.keep-alive:60}")
    private int keepAliveInterval;

    @Value("${mqtt.connection-timeout:30}")
    private int connectionTimeout;

    @Value("${mqtt.completion-timeout:5000}")
    private long completionTimeout;

    // ======================== 连接工厂 ========================

    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();
        // Broker 地址（adapter 启动时不传 URI，必须设在 options 里）
        options.setServerURIs(new String[]{brokerUrl});
        // 断线自动重连（Paho 客户端级别）
        options.setAutomaticReconnect(true);
        options.setCleanSession(true);
        options.setKeepAliveInterval(keepAliveInterval);
        options.setConnectionTimeout(connectionTimeout);
        if (!username.isEmpty()) {
            options.setUserName(username);
        }
        if (!password.isEmpty()) {
            options.setPassword(password.toCharArray());
        }
        factory.setConnectionOptions(options);
        return factory;
    }

    // ======================== 消息通道（topic 分流） ========================

    @Bean
    public MessageChannel sosChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageChannel heartbeatChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageChannel deviceStatusChannel() {
        return new DirectChannel();
    }

    // ======================== SOS 入站适配器 — QoS 2 ========================

    @Bean
    public MessageProducer sosMqttAdapter(MqttPahoClientFactory mqttClientFactory) {
        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        clientId + "-sos", mqttClientFactory,
                        "aiguard/v1/+/+/alert/sos");
        adapter.setCompletionTimeout(completionTimeout);
        adapter.setQos(2);
        adapter.setOutputChannel(sosChannel());
        return adapter;
    }

    // ======================== 心跳入站适配器 — QoS 1 ========================

    @Bean
    public MessageProducer heartbeatMqttAdapter(MqttPahoClientFactory mqttClientFactory) {
        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        clientId + "-heartbeat", mqttClientFactory,
                        "aiguard/v1/+/+/health/heartbeat");
        adapter.setCompletionTimeout(completionTimeout);
        adapter.setQos(1);
        adapter.setOutputChannel(heartbeatChannel());
        return adapter;
    }

    // ======================== 设备上线/离线入站适配器（LWT） — QoS 1 ========================

    @Bean
    public MessageProducer deviceStatusMqttAdapter(MqttPahoClientFactory mqttClientFactory) {
        MqttPahoMessageDrivenChannelAdapter adapter =
                new MqttPahoMessageDrivenChannelAdapter(
                        clientId + "-status", mqttClientFactory,
                        "aiguard/v1/+/+/system/online",
                        "aiguard/v1/+/+/system/offline");
        adapter.setCompletionTimeout(completionTimeout);
        adapter.setQos(1);
        adapter.setOutputChannel(deviceStatusChannel());
        return adapter;
    }

    // ======================== 消息处理器（topic 分流 → 业务逻辑） ========================

    /**
     * SOS 告警处理：解析 payload → 查 device → 创建 alert 记录（type=SOS, priority=HIGH）
     */
    @Bean
    @ServiceActivator(inputChannel = "sosChannel")
    public MessageHandler sosMessageHandler() {
        return message -> {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = (String) message.getPayload();
            log.warn("[MQTT-SOS] 收到SOS告警 | topic={} | payload={}", topic, payload);

            try {
                // 从 topic 提取设备ID：aiguard/v1/{type}/{deviceId}/alert/sos
                String[] parts = topic.split("/");
                String rawDeviceId = parts[3];
                String mac = formatMac(rawDeviceId);

                // 查设备
                Device device = deviceMapper.selectOne(
                        new LambdaQueryWrapper<Device>().eq(Device::getMac, mac));
                if (device == null) {
                    log.warn("[MQTT-SOS] 设备未注册，mac={}，topic={}", mac, topic);
                    return;
                }

                // 解析 payload（文档格式：{"type":"sos","deviceId":"...","timestamp":"...","data":{"elderlyId":1,"lat":30.57,"lng":104.06}}）
                JsonNode node = objectMapper.readTree(payload);
                JsonNode data = node.path("data");

                // 创建告警记录
                Alert alert = new Alert();
                alert.setType("SOS");
                // elderlyId 优先用 payload 中的，其次用 device 关联的
                if (data.has("elderlyId") && data.get("elderlyId").canConvertToInt()) {
                    alert.setElderlyId(data.get("elderlyId").asLong());
                } else {
                    alert.setElderlyId(device.getElderlyId());
                }
                alert.setCommunityId(device.getCommunityId());
                alert.setDeviceId(device.getId());
                alert.setSource(device.getType());
                alert.setStatus("PENDING");
                alert.setPriority("HIGH");
                alert.setHappenedAt(LocalDateTime.now());
                // 经纬度
                if (data.has("lat")) {
                    alert.setLat(new BigDecimal(data.get("lat").asText()));
                }
                if (data.has("lng")) {
                    alert.setLng(new BigDecimal(data.get("lng").asText()));
                }
                alertMapper.insert(alert);

                // WebSocket 实时推送 NEW_ALERT
                broadcastAlert("NEW_ALERT", alert, device.getElderlyId(), device.getCommunityId());

                log.warn("[MQTT-SOS] 告警已入库 | alertId={} | elderlyId={} | deviceId={}",
                        alert.getId(), device.getElderlyId(), device.getId());
            } catch (Exception e) {
                log.error("[MQTT-SOS] 处理失败 | topic={} | payload={}", topic, payload, e);
            }
        };
    }

    /**
     * 心跳处理：解析 payload → 查 device → 更新 last_heartbeat / battery / status=ONLINE
     */
    @Bean
    @ServiceActivator(inputChannel = "heartbeatChannel")
    public MessageHandler heartbeatMessageHandler() {
        return message -> {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = (String) message.getPayload();
            log.info("[MQTT-Heartbeat] 收到心跳 | topic={} | payload={}", topic, payload);

            try {
                // 从 topic 提取设备ID：aiguard/v1/{type}/{deviceId}/health/heartbeat
                String[] parts = topic.split("/");
                String rawDeviceId = parts[3];
                String mac = formatMac(rawDeviceId);

                // 查设备
                Device device = deviceMapper.selectOne(
                        new LambdaQueryWrapper<Device>().eq(Device::getMac, mac));
                if (device == null) {
                    log.warn("[MQTT-Heartbeat] 设备未注册，mac={}，topic={}", mac, topic);
                    return;
                }

                // 解析 payload（文档格式：{"type":"heartbeat","deviceId":"...","timestamp":"...","data":{"battery":85,"rssi":-65}}）
                JsonNode node = objectMapper.readTree(payload);
                JsonNode data = node.path("data");
                int battery = data.has("battery") ? data.get("battery").asInt() : -1;

                // 更新设备状态
                Device update = new Device();
                update.setId(device.getId());
                update.setStatus("ONLINE");
                update.setLastHeartbeat(LocalDateTime.now());
                if (battery >= 0) {
                    update.setBattery(battery);
                }
                deviceMapper.updateById(update);

                log.info("[MQTT-Heartbeat] 设备已更新 | deviceId={} | mac={} | battery={}",
                        device.getId(), mac, battery >= 0 ? battery : "N/A");
            } catch (Exception e) {
                log.error("[MQTT-Heartbeat] 处理失败 | topic={} | payload={}", topic, payload, e);
            }
        };
    }

    /**
     * 设备上线/离线处理（LWT）：解析 topic → 查 device → 更新 status + 同步 device_type
     */
    @Bean
    @ServiceActivator(inputChannel = "deviceStatusChannel")
    public MessageHandler deviceStatusHandler() {
        return message -> {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = (String) message.getPayload();
            log.info("[MQTT-Status] 收到设备状态 | topic={} | payload={}", topic, payload);

            try {
                // 从 topic 提取：aiguard/v1/{type}/{deviceId}/system/{online|offline}
                String[] parts = topic.split("/");
                String topicType = parts[2];
                String rawDeviceId = parts[3];
                String isOnline = parts[5]; // online 或 offline
                String mac = formatMac(rawDeviceId);
                String deviceType = mapDeviceType(topicType);

                // 查设备
                Device device = deviceMapper.selectOne(
                        new LambdaQueryWrapper<Device>().eq(Device::getMac, mac));
                if (device == null) {
                    log.warn("[MQTT-Status] 设备未注册，mac={}，topic={}", mac, topic);
                    return;
                }

                // 更新设备状态
                Device update = new Device();
                update.setId(device.getId());
                update.setStatus("ONLINE".equals(isOnline) ? "ONLINE" : "OFFLINE");
                if ("ONLINE".equals(isOnline)) {
                    update.setLastHeartbeat(LocalDateTime.now());
                }
                // 同步设备类型（topic 中的 type 映射到后端）
                if (deviceType != null && !deviceType.equals(device.getType())) {
                    update.setType(deviceType);
                }
                deviceMapper.updateById(update);

                log.info("[MQTT-Status] 设备状态已更新 | deviceId={} | mac={} | status={} | type={}",
                        device.getId(), mac, update.getStatus(), deviceType);
            } catch (Exception e) {
                log.error("[MQTT-Status] 处理失败 | topic={} | payload={}", topic, payload, e);
            }
        };
    }

    // ======================== 工具方法 ========================

    /**
     * 构建并广播告警 WebSocket 消息（对应文档 §13 推送格式）
     */
    private void broadcastAlert(String msgType, Alert alert, Long elderlyId, Long communityId) {
        try {
            String elderlyName = null;
            if (elderlyId != null) {
                Elderly elderly = elderlyMapper.selectById(elderlyId);
                if (elderly != null) {
                    elderlyName = elderly.getName();
                }
            }
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("alertId", alert.getId());
            data.put("type", alert.getType());
            data.put("elderlyName", elderlyName);
            data.put("communityId", communityId);
            data.put("happenedAt", alert.getHappenedAt());

            Map<String, Object> message = new LinkedHashMap<>();
            message.put("type", msgType);
            message.put("data", data);

            alertWebSocketHandler.broadcast(objectMapper.writeValueAsString(message));
        } catch (Exception e) {
            log.warn("[WS] 广播告警消息失败", e);
        }
    }

    /**
     * 将无分隔符的 MAC 转为带冒号格式
     * 例：a1b2c3d4e5f6 → A1:B2:C3:D4:E5:F6
     */
    private String formatMac(String rawId) {
        String upper = rawId.toUpperCase();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < upper.length(); i += 2) {
            if (i > 0) sb.append(":");
            sb.append(upper, i, Math.min(i + 2, upper.length()));
        }
        return sb.toString();
    }

    /**
     * 将 topic 中的 device_type 映射为后端设备类型
     * 例：watch → WATCH，panel → PANEL，sensor → SENSOR，gateway → GATEWAY
     */
    private String mapDeviceType(String topicType) {
        if (topicType == null) return null;
        return topicType.toUpperCase();
    }
}
