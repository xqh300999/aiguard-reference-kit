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
