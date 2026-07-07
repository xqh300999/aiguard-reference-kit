package com.elderlycare.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

/**
 * MQTT 消费配置 — Spring Integration
 * <p>
 * 监听 topic（按团队 MQTT 协议规范 §6.2）：
 * <ul>
 *   <li>SOS 告警：aiguard/v1/+/+/alert/sos — QoS 2（恰好一次）</li>
 *   <li>设备心跳：aiguard/v1/+/+/health/heartbeat — QoS 1</li>
 * </ul>
 * 断线自动重连：MqttConnectOptions.setAutomaticReconnect(true)
 */
@Configuration
public class MqttConfig {

    private static final Logger log = LoggerFactory.getLogger(MqttConfig.class);

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

    // ======================== 消息通道 ========================

    @Bean
    public MessageChannel sosChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageChannel heartbeatChannel() {
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

    // ======================== 消息处理器（topic 分流） ========================

    @Bean
    @ServiceActivator(inputChannel = "sosChannel")
    public MessageHandler sosMessageHandler() {
        return message -> {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = (String) message.getPayload();
            log.warn("[MQTT-SOS] 收到SOS告警 | topic={} | payload={}", topic, payload);
            // TODO: 解析 payload，创建 alert 记录（type=SOS, priority=HIGH），调用 AlertService
        };
    }

    @Bean
    @ServiceActivator(inputChannel = "heartbeatChannel")
    public MessageHandler heartbeatMessageHandler() {
        return message -> {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = (String) message.getPayload();
            log.info("[MQTT-Heartbeat] 收到心跳 | topic={} | payload={}", topic, payload);
            // TODO: 解析 payload，更新 device 的 last_heartbeat / battery / status
        };
    }
}
