# 微雪 ESP32 系列

微雪电子（Waveshare）提供的 ESP32-S3 和 ESP32-P4 开发板是 AIguard 项目的智能终端节点。

## 快速参考

### ESP32-S3 概述

| 特性 | 参数 |
|------|------|
| 核心 | Xtensa® 双核 LX7 @ 240MHz |
| Wi-Fi | 802.11 b/g/n，2.4GHz |
| 蓝牙 | Bluetooth 5 (LE)，支持 Mesh |
| AI 加速 | 向量指令集，支持神经网络计算 |
| 外设 | SPI/I2S/I2C/UART/ADC/DAC/USB OTG |
| 安全 | 安全启动、Flash 加密、硬件加密加速器 |
| 低功耗 | 深度睡眠电流可低至 10μA 以下 |

**微雪常见 ESP32-S3 模块：**
- ESP32-S3-Touch-AMOLED-2.06：2.06英寸AMOLED触控屏开发板（小智固件推荐）
- ESP32-S3-Pico：微型开发板
- ESP32-S3-Zero：紧凑型开发板
- ESP32-S3-LCD-1.69：1.69英寸LCD开发板

### ESP32-P4 概述

| 特性 | 参数 |
|------|------|
| 核心 | Xtensa® 双核 LX7 @ 400MHz |
| Wi-Fi | 需外接芯片（如 ESP32-C6 搭配） |
| 蓝牙 | 需外接芯片 |
| 特色 | 支持双屏显示、MIPI-CSI/DSI、硬件PID |
| 内存 | 集成高容量 PSRAM 支持 |
| 外设 | USB 2.0 OTG、Ethernet MAC、CAN 2.0 |

**微雪常见 ESP32-P4 模块：**
- ESP32-P4-WIFI6-Touch-LCD-7B：7英寸触控屏+WiFi6开发板（小智固件推荐）

### 开发框架选择

| 框架 | 适用场景 | 优点 | 缺点 |
|------|----------|------|------|
| **ESP-IDF** | 专业开发、量产项目 | 官方原生支持、功能完整、性能最优 | 学习曲线较陡、配置复杂 |
| **Arduino Core** | 快速原型、简单项目 | 生态丰富、简单易用、大量示例 | 部分高级功能受限 |
| **ESPHome** | Home Assistant集成 | YAML配置、快速接入HA | 灵活性较差 |
| **MicroPython** | 教学、快速验证 | Python语法、交互开发 | 性能较低、资源占用大 |

**推荐：** 本项目小智固件使用 ESP-IDF 开发，自定义功能建议使用 ESP-IDF v5.0+。

### ESP-IDF 快速开始

```bash
# 1. 安装 ESP-IDF（Linux/macOS）
mkdir -p ~/esp
cd ~/esp
git clone -b v5.2.1 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh
source export.sh

# 2. 创建项目
idf.py create-project my-project
cd my-project

# 3. 配置芯片目标
idf.py set-target esp32s3  # 或 esp32p4

# 4. 项目配置
idf.py menuconfig

# 5. 编译烧录监控
idf.py -p /dev/ttyUSB0 build flash monitor
# Windows 端口示例：COM3
# macOS 端口示例：/dev/cu.usbmodem*
```

### 常用 GPIO 注意事项

- GPIO6-11：连接 SPI Flash/PSRAM，不可用作他用
- Strapping 引脚：GPIO0/GPIO3/GPIO45/GPIO46 上电时决定启动模式
- 部分开发板 GPIO 已连接板载外设（屏幕、按键、LED等），使用前请查阅原理图

## 常见坑点

1. **USB 驱动问题**
   - ESP32-S3/P4 通常使用 CH340/CP2102/CH9102 USB转串口芯片
   - macOS 10.14+、Windows 10+ 通常自带驱动，否则需手动安装
   - Linux：需将用户加入 dialout 组：`sudo usermod -aG dialout $USER`

2. **烧录失败**
   - 检查：端口是否正确、是否被其他程序占用、开发板是否进入下载模式
   - 手动进入下载模式：按住 BOOT 键 → 按一下 RST 键 → 松开 BOOT 键
   - 降低烧录波特率：`idf.py -b 115200 flash`

3. **PSRAM 配置问题**
   - 部分 ESP32-S3 模块带有 Octal PSRAM，部分为 Quad PSRAM
   - menuconfig 中必须正确选择 PSRAM 类型，否则会崩溃或无法启动
   - 微雪开发板购买页面会注明 PSRAM 配置，购买时需留意

4. **ESP32-P4 无原生无线**
   - ESP32-P4 本身不带 Wi-Fi/蓝牙，需要外接 ESP32-C6 等无线协处理器
   - 使用微雪 P4+WiFi6 模块时，无线部分通过 ESP-Hosted 方案通信

5. **屏幕驱动差异**
   - 不同微雪开发板使用不同的 LCD 驱动 IC（如 ST7789/GC9A01/ILI9341 等）
   - 小智固件已针对微雪特定开发板适配，自行移植需确认驱动兼容性

6. **电源供电**
   - 屏幕亮屏时电流较大（200mA+），USB供电不足会导致重启
   - 若使用电池供电，需选用输出能力足够的LDO或DC-DC

## 官方链接

详见 [official-links.md](official-links.md)。

- 乐鑫 ESP-IDF 编程指南：https://docs.espressif.com/projects/esp-idf/zh_CN/latest/
- ESP32-S3 技术参考手册：https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_cn.pdf
- 微雪电子官网：https://www.waveshare.net/
