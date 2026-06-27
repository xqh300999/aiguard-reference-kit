# 固件刷写工具总览

本文档目录介绍用于刷写AIguard固件的各类工具。

## 可用工具

| 工具 | 适用场景 | 难度 | 文档 |
|------|----------|------|------|
| ESP Web Tools | 新手推荐，浏览器直接刷写 | ★☆☆ | [esp-web-tools.md](esp-web-tools.md) |
| esptool.py | 命令行，高级用户/批量刷写 | ★★☆ | [esptool.md](esptool.md) |
| ESP-IDF (idf.py) | 开发编译+刷写 | ★★★ | ESP-IDF官方文档 |
| Arduino IDE | Arduino框架开发 | ★★☆ | Arduino IDE官方文档 |
| Flash Download Tool | 乐鑫官方GUI工具（Windows） | ★★☆ | 乐鑫官网下载 |

## 工具选择建议

| 场景 | 推荐工具 |
|------|----------|
| 首次刷写，普通用户 | ESP Web Tools |
| 批量刷写多台设备 | esptool.py 脚本 |
| 从源码编译后刷写 | ESP-IDF / Arduino IDE |
| Windows GUI偏好 | Flash Download Tool |
| 自动化/CI/CD | esptool.py |

## 刷写前通用准备

### 1. 安装USB驱动
参见 [../notes/driver-installation.md](../notes/driver-installation.md)

### 2. 确认串口
- Windows：设备管理器 → 端口(COM和LPT)
- macOS/Linux：`ls /dev/tty.*` 或 `ls /dev/cu.*`
- ESP32-S3直连接口通常显示为 USB JTAG/CDC 或 CH340/CP210x 设备

### 3. 进入下载模式
参见对应硬件的刷写指南：
- [ESP32-S3-Watch 刷写指南](../../04-hardware/esp32-s3-watch/flashing-guide.md)
- [ESP32-P4-Panel 刷写指南](../../04-hardware/esp32-p4-panel/flashing-guide.md)

## 刷写地址参考

ESP32系列常见分区刷写地址：

| 文件 | 地址 | 说明 |
|------|------|------|
| merged-firmware.bin | 0x0 | 合并固件单文件 |
| bootloader.bin | 0x0 | 引导程序 |
| partition-table.bin | 0x8000 | 分区表 |
| ota_data_initial.bin | 0xD000 | OTA初始数据 |
| application.bin | 0x10000 | 应用固件 |
| spiffs.bin | 见分区表 | SPIFFS文件系统 |

> ⚠️ 注意：不同固件、不同Flash大小的分区地址可能不同，以固件发布说明提供的地址为准。合并固件（merged/factory bin）通常刷写到 0x0 即可。

## 刷写后验证

1. 复位设备（按RESET键或重新上电）
2. 观察屏幕是否正常点亮
3. 通过串口监视器查看启动日志（波特率通常为115200）
4. 确认设备进入配网模式或正常运行
5. 测试基本功能（屏幕显示、按键、Wi-Fi连接等）
