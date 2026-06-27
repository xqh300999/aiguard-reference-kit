# Waveshare ESP32-S3-Touch-AMOLED-2.06 规格说明

## 产品概述

ESP32-S3-Touch-AMOLED-2.06 是微雪电子推出的高性能可穿戴手表形态开发板。基于 ESP32-S3R8 微控制器，集成 2.06 寸电容触控高清 AMOLED 屏幕、六轴传感器、RTC、音频编解码芯片及电源管理等功能模块。配合定制外壳，外观与智能手表一致，适用于可穿戴应用的原型设计和功能验证。

## 核心规格

| 项目 | 参数 |
|------|------|
| 主控芯片 | ESP32-S3R8 (Xtensa 32-bit LX7 双核) |
| 主频 | 最高 240MHz |
| SRAM | 内置 512KB |
| ROM | 内置 384KB |
| PSRAM | 板载 8MB (Octal) |
| Flash | 板载 32MB |
| Wi-Fi | 2.4GHz 802.11 b/g/n |
| 蓝牙 | Bluetooth 5 (BLE) |
| 天线 | 板载天线 |
| USB | Type-C 接口 |

## 屏幕规格

| 项目 | 参数 |
|------|------|
| 屏幕尺寸 | 2.06 英寸 |
| 分辨率 | 410×502 |
| 色彩 | 16.7M 色 |
| 显示类型 | AMOLED |
| 显示驱动 | CO5300 (QSPI 接口) |
| 触控类型 | 电容式触控 |
| 触控芯片 | FT3168 (I2C 接口) |

## 板载外设

| 模块 | 芯片 | 接口 | 功能 |
|------|------|------|------|
| 六轴IMU | QMI8658 | I2C | 3轴加速度计 + 3轴陀螺仪，支持运动姿态检测、计步等 |
| RTC | PCF85063 | I2C | 实时时钟，通过 AXP2101 接电池实现不间断供电 |
| 音频编解码 | ES8311 | I2S | 音频输入输出 |
| 电源管理 | AXP2101 | I2C | 高效电源管理，支持多输出电压、充电管理、电池电量监测 |
| TF卡 | — | SPI | 扩展存储 |
| 按键 | — | GPIO | PWR 侧键 + BOOT 侧键 |
| 电池接口 | MX1.25 | — | 3.7V 锂电池充放电接口 |

## 扩展接口

板载引出接口：
- 1× I2C 接口
- 1× UART 接口
- 1× USB 焊盘

## 开发支持

| 开发框架 | 版本要求 |
|----------|----------|
| Arduino IDE | ESP32 板包 ≥ 3.2.0 |
| ESP-IDF | ESP-IDF v5.x |

### Arduino 依赖库
- Arduino_DriveBus (CST816 触控驱动)
- GFX_Library_for_Arduino v1.6.0 (CO5300 图形库)
- lvgl v9.3.0 (推荐离线安装)
- SensorLib v0.3.1 (PCF85063/QMI8658 传感器驱动)
- XPowersLib v0.2.6 (AXP2101 电源管理)

## 参考链接

- 官方Wiki：https://www.waveshare.com/wiki/ESP32-S3-Touch-AMOLED-2.06
- ESP32-S3 技术参考手册：https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_cn.pdf
