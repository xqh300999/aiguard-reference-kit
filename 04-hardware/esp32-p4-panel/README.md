# Waveshare ESP32-P4-WIFI6-Touch-LCD-7B 规格说明

## 产品概述

ESP32-P4-WIFI6-Touch-LCD-7B 是微雪电子推出的基于 ESP32-P4 芯片的高性能开发板。采用双核加单核 RISC-V 架构设计，内置 7 寸 1024×600 分辨率 IPS 触控显示屏。支持丰富的人机交互接口，包括集成 ISP 的 MIPI-CSI、高速 USB OTG 2.0 HS 接口。集成数字签名外设和专用密钥管理单元，适用于智能家居中控屏、工业控制面板、售货机等场景。

## 核心规格

### 处理器

| 项目 | 参数 |
|------|------|
| HP 核心 | RISC-V 32-bit 双核，主频最高 360MHz，支持 DSP 指令集扩展及 FPU |
| LP 核心 | RISC-V 32-bit 单核，主频最高 40MHz |
| 无线协处理器 | ESP32-C6-MINI-1，通过 SDIO 扩展 Wi-Fi 6 / Bluetooth 5 (LE) |

### 存储

| 项目 | 参数 |
|------|------|
| HP ROM | 128KB |
| LP ROM | 16KB |
| HP L2MEM | 768KB |
| LP SRAM | 32KB |
| TCM | 8KB |
| PSRAM | 片上堆叠 32MB |
| Flash | QSPI 外接 32MB Nor Flash |

### 屏幕规格

| 项目 | 参数 |
|------|------|
| 屏幕尺寸 | 7 英寸 |
| 分辨率 | 1024×600 |
| 显示类型 | IPS LCD |
| 接口 | MIPI-DSI |
| 触控 | 电容式多点触控 |
| 图形加速 | 像素处理加速器 (PPA)、2D 图形加速控制器 (2D DMA)、JPEG 解码 (1080P@30fps) |

### 多媒体

| 模块 | 芯片/接口 | 功能 |
|------|-----------|------|
| 音频编解码 | ES8311 | 音频编码/解码 |
| 回声消除 | ES7210 | 回声消除，提升音频采集精度 |
| 麦克风 | SMD 麦克风矩阵 | 音频输入 + 回声消除 |
| 扬声器接口 | PH2.0 | 外接扬声器（无极性要求） |
| 摄像头接口 | MIPI-CSI (2-lane) | 支持 1080P@30fps H.264/JPEG 编码，集成 ISP |

### 工业接口

| 接口 | 端子类型 | 说明 |
|------|----------|------|
| RS485 | PH2.0 4PIN | RS485 总线控制 |
| CAN | PH2.0 4PIN | CAN 总线控制 |
| I2C | PH2.0 4PIN | I2C 设备扩展 |
| UART | PH2.0 4PIN | UART 设备扩展 |
| GPIO扩展 | PH2.0 12PIN | 17个可自定义GPIO + 常用电源 |

### 其他接口

| 接口 | 说明 |
|------|------|
| Type-C (USB1.1 FS) | 供电、刷写、调试（直连ESP32-P4） |
| Type-C (USB TO UART) | 供电、刷写、调试（UART转换） |
| Type-A (USB OTG 2.0 HS) | USB 2.0 高速 OTG |
| TF卡 | SDIO 3.0 接口 |
| 电池接口 | MX1.25 正向电池接口 |
| RTC电池座 | 1220尺寸，仅支持 3V~3.3V 可充电电池 |

### 按键与指示

| 项目 | 说明 |
|------|------|
| PWR 按键 | 电源按键 |
| RESET 按键 | 复位按键 |
| BOOT 按键 | 上电/复位时按住进入下载模式 |
| LED 状态指示灯 | 系统状态指示 |

### 视频编码
- H.264 & JPEG 视频编码
- 支持 1080P@30fps

## 开发支持

| 开发框架 | 版本要求 |
|----------|----------|
| ESP-IDF | ≥ v5.3.1（推荐） |
| Arduino IDE | 需 ESP32 板包支持 ESP32-P4 |
| Espressif-IDE | ≥ v5.3.1 |

## 板载接口位置说明

参考官方Wiki硬件描述章节，主要区域包括：
1. ESP32-P4 核心模组
2. ESP32-C6-MINI-1 无线模组
3. ESP32-C6 UART 刷写端子
4. ES8311 音频编解码芯片
5. ES7210 回声消除芯片
6. MIPI-DSI 显示屏接口
7. 触控接口
8. MIPI-CSI 摄像头接口
9. MX1.25 电池接口
10. PH2.0 扬声器接口
11. RTC 电池座
12. 电源按键
13. LED 状态指示灯
14. Type-A USB OTG 接口
15. Type-C USB 直连接口
16. Type-C USB TO UART 接口
17. RESET 按键
18. BOOT 按键
19-22. PH2.0 扩展端子 (I2C/UART/CAN/RS485)
23. 麦克风矩阵
24. PH2.0 GPIO 扩展端子
25. TF卡插槽
26. 电池预留区

## 参考链接

- 官方Wiki：https://www.waveshare.com/wiki/ESP32-P4-WIFI6-Touch-LCD-7B
- ESP32-P4 技术参考手册：https://www.espressif.com/sites/default/files/documentation/esp32-p4_technical_reference_manual_en.pdf

## 固件版本历史

本节记录 ESP32-P4 中控屏在 AI-Guard 项目中的固件演进，包含两个里程碑版本。详细的开发经验、调试记录与升级路径请参考 [firmware-versions.md](./firmware-versions.md)。

### V0.5 — 纯原生 Dashboard 固件

- **发布日期**：2026-06-26
- **Git标签**：`v0.5.0-panel-dashboard`
- **定位**：不含小智语音助手的纯 Dashboard 固件，面向嵌入式 GUI 教学
- **功能范围**：
  - 1024×600 深色玻璃质感 Dashboard（顶栏 + 快捷动作区 + 状态网格 + 告警覆盖层）
  - HTTP 轮询后端 API（5 秒间隔）获取温湿度 / 烟感 / 气感 / 门磁数据
  - SOS 紧急呼叫（30 秒倒计时）+ 夜灯控制
  - 告警评估纯函数（优先级：SOS > 烟感 > 气感 > 门磁超时）
  - ES8311 扬声器告警音（1200Hz 正弦波）
  - LVGL 9.x 玻璃卡片布局，Lucide SVG 图标 + Source Han Sans SC 字体子集
- **技术栈**：ESP-IDF v5.5.2 + LVGL 9.5 + Waveshare BSP + esp_hosted 1.4.7
- **WiFi 配网**：menuconfig 编译时硬编码（不支持运行时配网）
- **验证状态**：✅ 已验证（真机 ESP32-P4 rev v1.3，WiFi 连接稳定，无 WDT / crash）
- **已知限制**：无语音交互、无 OTA、WiFi 不能运行时配置

### V1.0 — 接入小智语音助手

- **发布日期**：2026-06-29
- **基线**：小智 xiaozhi-esp32 v2.2.4 (commit `e77dedb`)
- **定位**：在保留小智完整语音链路基础上，注入 AI-Guard Dashboard 作为前景 UI
- **新增功能（相比 V0.5）**：
  - 小智完整语音交互（唤醒、聆听、TTS、AEC 回声消除）
  - 小智 Dock 下区（Twemoji 拟人表情图标 + 状态小字 + 对话正文横向滚动）
  - 点击"小智"按钮触发 `ToggleChatState` + `OGG_SUCCESS` 提示音
  - 15 秒静音自动回待机
  - AP 配网模式（`Xiaozhi-XXXX` 热点 + 浏览器 `192.168.4.1`）
  - 长按 10 秒进入 WiFi 重配网模式
  - 小智原生 OTA 升级支持
  - 告警音改为 OPUS 编码 OGG（嘟嘟嘟 4 音，3 秒间隔重复）
- **技术架构变更**：
  - 采用 Overlay 注入方案（非 Fork）：保留小智源码树原样，通过 `apply-overlay.sh` 注入 AI-Guard 代码
  - esp_hosted 升级到 2.0.17（小智默认）
  - ES8311 单 owner 原则：小智 `BoxAudioCodec` 独占，告警音走 `Application::PlaySound`
  - HTTP 客户端改用小智 `Board::GetInstance().GetNetwork()->CreateHttp()`
  - LVGL 线程安全：`Application::Schedule()` 投递到主任务 + `lvgl_port_lock(30000)` 公共 C API
  - 中文字体：文本标签用 `nullptr` 继承 screen 主题字体（小智 `Assets::Apply()` mmap 完整 CJK 字体）
  - UI 刷新：1Hz 定期刷新 + 告警状态变化立即刷新（action queue 仍 100ms 轮询）
- **验证状态**：✅ 已验证（51 个契约测试通过，真机启动稳定，配网 + 语音交互正常）
- **已知限制**：
  - OPUS 解码器无 PLC 补包，网络抖动时可能破音
  - 全双工打断需服务器端 VAD 支持（固件已支持 realtime 模式）
  - app 分区仅剩 13%（~540KB）
  - OTA URL 编译时硬编码
  - 摄像头 OV5647 硬件存在但未启用

### V0.5 vs V1.0 核心区别对比表

| 维度 | V0.5（纯 Dashboard） | V1.0（接入小智） |
|------|---------------------|-------------------|
| 构建方式 | 原生 ESP-IDF 项目 | 小智源码树 + overlay 注入 |
| esp_hosted | 1.4.7 | 2.0.17 |
| WiFi 配网 | menuconfig 编译时硬编码 | AP 配网 + 长按 10s 重配网 |
| 音频系统 | 独立 ES8311 句柄 | ES8311 单 owner（小智独占） |
| HTTP 客户端 | `esp_http_client` | 小智 `Network::CreateHttp()` |
| LVGL 线程安全 | `bsp_display_lock(200)` | `Schedule()` + `lvgl_port_lock(30000)` |
| UI 刷新 | 100ms 每 tick 更新 | 1Hz 定期 + 告警变化立即刷新 |
| 中文字体 | Source Han Sans 子集（20/24px） | `nullptr` 继承主题字体（mmap 完整 CJK） |
| BottomDock | 空文本条（预留） | Twemoji 表情 + 状态 + 对话滚动 |
| 告警音 | 1200Hz 正弦波 | OPUS OGG 嘟嘟嘟 4 音 |
| OTA | 未实现 | 小智原生 OTA |
| bin 大小 | ~1.6MB（app free 80%） | ~3.42MB（app free 13%） |
| 契约测试 | 4 个 | 51 个 |
