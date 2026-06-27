# 小智 AI 对话固件 v2.2.4 说明

## 固件概述

小智（Xiaozhi）是一个开源的AI语音对话固件项目，基于ESP32系列芯片，实现语音唤醒、语音识别、AI对话、TTS语音播报等功能。AIguard参考套件使用小智固件作为语音交互基础，并在此之上增加跌倒检测、告警、MQTT对接等AIguard专属功能。

## 版本信息

| 项目 | 信息 |
|------|------|
| 固件版本 | v2.2.4 |
| 基础项目 | 小智 ESP32 开源固件 |
| 发布日期 | 2024年（参考） |
| 许可证 | 遵循原项目开源许可证 |

## 适用硬件

### 推荐/已验证硬件

| 硬件平台 | 适配状态 | 固件文件名 | 备注 |
|----------|----------|------------|------|
| Waveshare ESP32-S3-Touch-AMOLED-2.06 | ✅ 适配 | xiaozhi-v2.2.4-esp32s3-watch.zip | 手表形态，板载QMI8658 IMU、AMOLED屏 |
| Waveshare ESP32-P4-WIFI6-Touch-LCD-7B | ⚠️ 待适配 | — | 需适配MIPI-DSI屏幕（P4支持需确认） |

### 小智固件通用支持硬件（参考）

小智固件社区还支持多种ESP32开发板，包括但不限于：
- ESP32-S3-EYE
- ESP32-S3-Korvo-1/2
- 原子Muse-UI
- 各种带屏幕/麦克风的ESP32-S3开发板

> 注：AIguard功能（跌倒检测等）依赖特定板载硬件（QMI8658 IMU等），在通用开发板上仅基础AI对话功能可用。

## 功能特性

### 小智基础功能
- **语音唤醒**：支持自定义唤醒词（默认"你好小智"）
- **语音识别(ASR)**：支持中文语音转文字
- **AI对话(LLM)**：接入大语言模型进行对话
- **语音合成(TTS)**：将AI回复转为语音播放
- **Wi-Fi配网**：支持SmartConfig/网页配网/AP配网
- **OTA升级**：支持无线固件升级
- **多TTS/LLM后端**：可配置不同的AI服务提供商

### AIguard 扩展功能（基于v2.2.4）
- **IMU数据采集**：读取QMI8658六轴传感器数据
- **跌倒检测算法**：基于加速度峰值+姿态变化+撞击后静止多条件判断
- **SOS紧急呼叫**：长按侧键触发SOS告警
- **MQTT集成**：设备状态/告警上报至MQTT Broker
- **Home Assistant兼容**：支持MQTT Discovery自动发现
- **震动反馈**：告警时手表震动提醒
- **屏幕告警界面**：AMOLED屏幕显示告警信息和确认选项

## 硬件资源使用（ESP32-S3-Watch）

| 资源 | 配置 |
|------|------|
| Flash | 32MB（使用工厂固件含分区表） |
| PSRAM | 8MB OPI PSRAM |
| 分区方案 | 参考小智默认分区方案 |

## 固件包内容

固件zip包通常包含：
- `bootloader.bin` - 引导加载程序
- `partition-table.bin` - 分区表
- `ota_data_initial.bin` - OTA数据初始分区
- `xiaozhi.bin` / `firmware.bin` - 应用固件
- `spiffs.bin`（如提供）- SPIFFS文件系统镜像
- `merged-firmware.bin`（如提供）- 合并后的单文件固件，适合直接刷写到0x0地址

## 编译信息（参考）

如自行编译AIguard定制版：
- 推荐ESP-IDF版本：v5.1 或 v5.2（以小智要求为准）
- 编译目标：esp32s3
- 配置：启用PSRAM (OPI)，Flash 32MB，USB CDC等
- 板级配置：选择对应开发板的pin配置

## 固件配置项

首次运行或重置后需配置：
1. **Wi-Fi配置**：通过配网模式连接家庭Wi-Fi
2. **服务器配置**：小智服务器地址（或自建服务器）
3. **MQTT配置**（AIguard功能需要）：
   - Broker地址/端口
   - 用户名/密码
   - 是否启用Home Assistant Discovery
4. **跌倒检测灵敏度**：高/中/低
5. **紧急联系人**：告警时通知的联系人

## 已知限制

- ESP32-S3版本资源有限，同时运行AI对话+传感器+MQTT时注意内存使用
- 跌倒检测算法为阈值法，存在误报和漏报可能，仅供参考，不可替代专业医疗/安防设备
- TTS/LLM功能依赖网络连接和后端服务可用性
- 锂电池续航受使用频率影响，频繁语音对话会显著缩短续航

## 参考

- 小智开源项目：GitHub搜索 "xiaozhi-esp32"
- ESP32-S3技术规格：参见 [04-hardware/esp32-s3-watch/README.md](../../04-hardware/esp32-s3-watch/README.md)
- 刷写指南：参见 [../flashing-tools/README.md](../flashing-tools/README.md)
