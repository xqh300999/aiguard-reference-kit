package com.elderlycare.controller;

import com.elderlycare.common.Result;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.time.Instant;

/**
 * MQTT 测试接口 — 模拟设备发布 SOS / 心跳 / 上下线消息
 * <p>用于本地开发测试，硬件设备就绪后可移除
 * <p>payload 格式按团队 MQTT 协议规范 mqtt-topics.md
 */
@RestController
@RequestMapping("/api/v1/test/mqtt")
public class MqttTestController {

    private static final Logger log = LoggerFactory.getLogger(MqttTestController.class);

    @Value("${mqtt.broker-url}")
    private String brokerUrl;

    /**
     * 模拟发布 SOS 告警（QoS 2）
     * <p>topic: aiguard/v1/{type}/{id}/alert/sos
     * <p>payload: {"type":"sos","deviceId":"...","timestamp":"...","data":{"elderlyId":1,"lat":30.57,"lng":104.07}}
     *
     * @param deviceType 设备类型，默认 watch
     * @param deviceId   设备ID（MAC无分隔符小写），默认 a1b2c3d4e5f6（对应王大爷的手表）
     * @param elderlyId  老人ID，默认 1
     * @param lat        纬度，默认 30.5728
     * @param lng        经度，默认 104.0668
     */
    @PostMapping("/sos")
    public Result<String> publishSos(
            @RequestParam(defaultValue = "watch") String deviceType,
            @RequestParam(defaultValue = "a1b2c3d4e5f6") String deviceId,
            @RequestParam(defaultValue = "1") long elderlyId,
            @RequestParam(defaultValue = "30.5728") String lat,
            @RequestParam(defaultValue = "104.0668") String lng) {

        String topic = "aiguard/v1/" + deviceType + "/" + deviceId + "/alert/sos";
        String timestamp = Instant.now().toString();
        String payload = String.format(
                "{\"type\":\"sos\",\"deviceId\":\"%s_%s\",\"timestamp\":\"%s\",\"data\":{\"elderlyId\":%d,\"lat\":%s,\"lng\":%s}}",
                deviceType, deviceId, timestamp, elderlyId, lat, lng);

        publishMqtt(topic, payload, 2);
        return Result.success("SOS 消息已发布 (QoS2): " + topic);
    }

    /**
     * 模拟发布心跳（QoS 1）
     * <p>topic: aiguard/v1/{type}/{id}/health/heartbeat
     * <p>payload: {"type":"heartbeat","deviceId":"...","timestamp":"...","data":{"battery":85,"rssi":-65}}
     *
     * @param deviceType 设备类型，默认 watch
     * @param deviceId   设备ID（MAC无分隔符小写），默认 a1b2c3d4e5f6（对应王大爷的手表）
     * @param battery    电量，默认 85
     * @param rssi       信号强度，默认 -65
     */
    @PostMapping("/heartbeat")
    public Result<String> publishHeartbeat(
            @RequestParam(defaultValue = "watch") String deviceType,
            @RequestParam(defaultValue = "a1b2c3d4e5f6") String deviceId,
            @RequestParam(defaultValue = "85") int battery,
            @RequestParam(defaultValue = "-65") int rssi) {

        String topic = "aiguard/v1/" + deviceType + "/" + deviceId + "/health/heartbeat";
        String timestamp = Instant.now().toString();
        String payload = String.format(
                "{\"type\":\"heartbeat\",\"deviceId\":\"%s_%s\",\"timestamp\":\"%s\",\"data\":{\"battery\":%d,\"rssi\":%d}}",
                deviceType, deviceId, timestamp, battery, rssi);

        publishMqtt(topic, payload, 1);
        return Result.success("心跳消息已发布 (QoS1): " + topic);
    }

    /**
     * 模拟设备上线（LWT online，QoS 1）
     * <p>topic: aiguard/v1/{type}/{id}/system/online
     */
    @PostMapping("/online")
    public Result<String> publishOnline(
            @RequestParam(defaultValue = "watch") String deviceType,
            @RequestParam(defaultValue = "a1b2c3d4e5f6") String deviceId) {

        String topic = "aiguard/v1/" + deviceType + "/" + deviceId + "/system/online";
        String timestamp = Instant.now().toString();
        String payload = String.format(
                "{\"type\":\"online\",\"deviceId\":\"%s_%s\",\"timestamp\":\"%s\",\"data\":{}}",
                deviceType, deviceId, timestamp);

        publishMqtt(topic, payload, 1);
        return Result.success("设备上线消息已发布 (QoS1): " + topic);
    }

    /**
     * 模拟设备离线（LWT offline，QoS 1）
     * <p>topic: aiguard/v1/{type}/{id}/system/offline
     */
    @PostMapping("/offline")
    public Result<String> publishOffline(
            @RequestParam(defaultValue = "watch") String deviceType,
            @RequestParam(defaultValue = "a1b2c3d4e5f6") String deviceId) {

        String topic = "aiguard/v1/" + deviceType + "/" + deviceId + "/system/offline";
        String timestamp = Instant.now().toString();
        String payload = String.format(
                "{\"type\":\"offline\",\"deviceId\":\"%s_%s\",\"timestamp\":\"%s\",\"data\":{}}",
                deviceType, deviceId, timestamp);

        publishMqtt(topic, payload, 1);
        return Result.success("设备离线消息已发布 (QoS1): " + topic);
    }

    /**
     * 发布 MQTT 消息（每次创建临时连接）
     */
    private void publishMqtt(String topic, String payload, int qos) {
        MqttClient client = null;
        try {
            client = new MqttClient(brokerUrl, "test-pub-" + System.currentTimeMillis(),
                    new MemoryPersistence());
            client.connect();
            MqttMessage message = new MqttMessage(payload.getBytes(StandardCharsets.UTF_8));
            message.setQos(qos);
            client.publish(topic, message);
            client.disconnect();
            log.info("[MQTT-Test] 发布成功 | topic={} | qos={} | payload={}", topic, qos, payload);
        } catch (MqttException e) {
            log.error("[MQTT-Test] 发布失败 | topic={} | error={}", topic, e.getMessage());
            throw new RuntimeException("MQTT 发布失败: " + e.getMessage(), e);
        } finally {
            if (client != null) {
                try { client.close(); } catch (MqttException ignored) { }
            }
        }
    }
}
