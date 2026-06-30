# 小智 AI 对话固件说明

## 固件概述

小智（Xiaozhi）是一个开源的AI语音对话固件项目，基于ESP32系列芯片，实现语音唤醒、语音识别、AI对话、TTS语音播报等功能。AIguard参考套件使用小智固件作为语音交互基础，并在此之上增加跌倒检测、告警、MQTT对接等AIguard专属功能。

> **重要说明**：固件二进制文件**不再直接存放在本仓库中**。所有固件包均通过 **Gitee Release** 统一发布。本目录仅保留说明文档，不再包含任何 `.zip`/`.bin` 固件文件。

## 固件下载

### 下载方式

固件通过 Gitee Release 发布，下载地址格式为：

```
https://gitee.com/<owner>/aiguard-reference-kit/releases/download/v<版本>/<下载文件>
```

> ⚠️ **占位符说明**：`<owner>` 与 `<Gitee仓库地址>` 为占位符，**请替换为实际 Gitee 仓库地址**。Gitee 仓库创建完成后，请将本文档中的占位符统一替换为真实地址。

### 各固件下载链接（占位）

#### 1. ESP32-S3 手表固件 v2.2.4

- 下载文件：`v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip`
- 下载地址：
  ```
  https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v2.2.4/v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip
  ```

#### 2. ESP32-P4 中控屏固件 V0.5（纯 Dashboard）

- 下载文件：`aiguard_p4_panel_v0.5.bin`
- 下载地址：
  ```
  https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v0.5/aiguard_p4_panel_v0.5.bin
  ```

#### 3. ESP32-P4 中控屏固件 V1.0（接入小智）

- 下载文件：`xiaozhi_p4_panel_v1.0_merged.bin`
- 下载地址：
  ```
  https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v1.0/xiaozhi_p4_panel_v1.0_merged.bin
  ```

### Release 总览页

如需浏览所有历史版本，请访问：

```
https://<Gitee仓库地址>/aiguard-reference-kit/releases
```

### 下载后校验

下载完成后，建议校验文件 SHA-256：

```bash
shasum -a 256 <下载的固件文件名>
```

校验值参考格式见 [../checksums.txt](../checksums.txt)，实际校验值以 Release 附件页公布的为准。

## 版本信息

### ESP32-S3 手表固件

| 项目 | 信息 |
|------|------|
| 固件版本 | v2.2.4 |
| 基础项目 | 小智 ESP32 开源固件 |
| 发布日期 | 2024年（参考） |
| 许可证 | 遵循原项目开源许可证 |

### ESP32-P4 中控屏固件

| 项目 | V0.5 | V1.0 |
|------|------|------|
| 固件版本 | v0.5 | v1.0 |
| 基础项目 | AI-Guard 原生（纯 Dashboard） | 小智 v2.2.4 + overlay 注入 |
| 形态 | 纯 Dashboard 中控屏 | 接入小智语音的中控屏 |
| 下载文件 | `aiguard_p4_panel_v0.5.bin` | `xiaozhi_p4_panel_v1.0_merged.bin` |

## 适用硬件

### 推荐/已验证硬件

| 硬件平台 | 适配状态 | 固件文件名 | 备注 |
|----------|----------|------------|------|
| Waveshare ESP32-S3-Touch-AMOLED-2.06 | ✅ 适配 | v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip | 手表形态，板载QMI8658 IMU、AMOLED屏 |
| Waveshare ESP32-P4-WIFI6-Touch-LCD-7B | ✅ 已适配（V0.5纯Dashboard / V1.0接入小智） | aiguard_p4_panel_v0.5.bin / xiaozhi_p4_panel_v1.0_merged.bin | 7寸 MIPI-DSI 屏，P4 双版本固件可选 |

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

### AIguard 扩展功能（基于v2.2.4，手表固件）
- **IMU数据采集**：读取QMI8658六轴传感器数据
- **跌倒检测算法**：基于加速度峰值+姿态变化+撞击后静止多条件判断
- **SOS紧急呼叫**：长按侧键触发SOS告警
- **MQTT集成**：设备状态/告警上报至MQTT Broker
- **Home Assistant兼容**：支持MQTT Discovery自动发现
- **震动反馈**：告警时手表震动提醒
- **屏幕告警界面**：AMOLED屏幕显示告警信息和确认选项

### P4 中控屏 V0.5 功能（纯 Dashboard）
- **状态总览 Dashboard**：温湿度/安全/消息汇总展示
- **快捷操作**：SOS 告警、夜灯开关、呼叫家人、小智入口
- **本地告警**：本地告警音 + 屏幕告警覆盖层
- **MQTT 集成**：与 AI-Guard 后端联动
- **小智 UI 预留**：保留小智入口但不接入语音

### P4 中控屏 V1.0 功能（接入小智）
- **包含 V0.5 全部 Dashboard 功能**
- **小智语音对话**：点击小智按钮触发对话/唤醒词触发
- **BottomDock 双区布局**：上方 Dashboard + 下方小智表情/对话文字
- **告警音改走小智音频通道**：通过 `Application::PlaySound` + OGG 资源播放
- **LVGL 双缓冲**：防撕裂
- **全双工打断**（需服务器端支持 barge-in）

## 硬件资源使用（ESP32-S3-Watch）

| 资源 | 配置 |
|------|------|
| Flash | 32MB（使用工厂固件含分区表） |
| PSRAM | 8MB OPI PSRAM |
| 分区方案 | 参考小智默认分区方案 |

## 固件包内容

### ESP32-S3 手表固件 zip 包内容

固件zip包通常包含：
- `bootloader.bin` - 引导加载程序
- `partition-table.bin` - 分区表
- `ota_data_initial.bin` - OTA数据初始分区
- `xiaozhi.bin` / `firmware.bin` - 应用固件
- `spiffs.bin`（如提供）- SPIFFS文件系统镜像
- `merged-firmware.bin`（如提供）- 合并后的单文件固件，适合直接刷写到0x0地址

### ESP32-P4 中控屏固件

- **V0.5**：单文件 `aiguard_p4_panel_v0.5.bin`，可直接刷写到 0x0 地址
- **V1.0**：合并固件 `xiaozhi_p4_panel_v1.0_merged.bin`，可直接刷写到 0x0 地址（包含 bootloader + 分区表 + 应用固件）

## 编译信息（参考）

### ESP32-S3 手表固件

如自行编译AIguard定制版：
- 推荐ESP-IDF版本：v5.1 或 v5.2（以小智要求为准）
- 编译目标：esp32s3
- 配置：启用PSRAM (OPI)，Flash 32MB，USB CDC等
- 板级配置：选择对应开发板的pin配置

### ESP32-P4 中控屏固件 V1.0

如自行编译接入小智的版本：
- ESP-IDF版本：v5.5.2
- 编译目标：esp32p4
- 板级变体：`esp32-p4-wifi6-touch-lcd-7b`
- 小智源码版本：v2.2.4（commit e77dedb）
- esp_hosted版本：2.0.17
- 构建方式：小智源码树 + AIguard overlay 注入（参考 `aiguard/firmware/esp32-p4-panel-xiaozhi/apply-overlay.sh`）

## 固件配置项

首次运行或重置后需配置：
1. **Wi-Fi配置**：通过配网模式连接家庭Wi-Fi
2. **服务器配置**：小智服务器地址（或自建服务器）
3. **MQTT配置**（AIguard功能需要）：
   - Broker地址/端口
   - 用户名/密码
   - 是否启用Home Assistant Discovery
4. **跌倒检测灵敏度**（手表固件）：高/中/低
5. **紧急联系人**：告警时通知的联系人

## 已知限制

- ESP32-S3版本资源有限，同时运行AI对话+传感器+MQTT时注意内存使用
- 跌倒检测算法为阈值法，存在误报和漏报可能，仅供参考，不可替代专业医疗/安防设备
- TTS/LLM功能依赖网络连接和后端服务可用性
- 锂电池续航受使用频率影响，频繁语音对话会显著缩短续航
- P4 V1.0 全双工打断需服务器端支持 realtime barge-in/VAD 检测，固件层无法单独解决

## 参考

- 小智开源项目：GitHub搜索 "xiaozhi-esp32"
- ESP32-S3技术规格：参见 [../../04-hardware/esp32-s3-watch/README.md](../../04-hardware/esp32-s3-watch/README.md)
- ESP32-P4技术规格：参见 [../../04-hardware/esp32-p4-panel/README.md](../../04-hardware/esp32-p4-panel/README.md)
- 刷写指南：参见 [../flashing-tools/README.md](../flashing-tools/README.md)
- 固件总览：参见 [../README.md](../README.md)
- 校验值参考：参见 [../checksums.txt](../checksums.txt)
