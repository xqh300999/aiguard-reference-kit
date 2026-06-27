# ESP32-S3-Touch-AMOLED-2.06 固件刷写指南

## 准备工作

### 硬件准备
1. ESP32-S3-Touch-AMOLED-2.06 开发板
2. USB 数据线（Type-A 转 Type-C，支持数据传输）
3. 电脑（Windows / Linux / macOS）

### 软件准备（三选一）
- **ESP Web Tools**（推荐新手）：浏览器直接刷写，无需安装额外工具
- **esptool.py**：命令行工具，适合批量操作和高级用户
- **ESP-IDF / Arduino IDE**：开发调试环境

## 刷写前注意事项

1. 确保使用的 USB 数据线支持数据传输（非仅充电线）
2. 连接后确认电脑能识别到串口设备
3. 如无法识别串口，请先安装 USB 驱动（参见 [06-firmware/notes/driver-installation.md](../../06-firmware/notes/driver-installation.md)）
4. 刷写过程中请勿断开 USB 连接

## 进入下载模式

开发板在以下情况下进入固件下载模式：

1. **自动下载模式**：大多数刷写工具（esptool.py、ESP Web Tools、ESP-IDF）支持自动进入下载模式，无需手动操作
2. **手动进入下载模式**（自动模式失败时使用）：
   - 按住 BOOT 按键（GPIO0）不放
   - 按一下 RESET/PWR 按键（或重新插拔USB）
   - 松开 BOOT 按键
   - 此时开发板已进入下载模式

## 刷写方法

### 方法一：ESP Web Tools（浏览器刷写）

参见 [06-firmware/flashing-tools/esp-web-tools.md](../../06-firmware/flashing-tools/esp-web-tools.md)

### 方法二：esptool.py 命令行刷写

参见 [06-firmware/flashing-tools/esptool.md](../../06-firmware/flashing-tools/esptool.md)

基本命令示例：
```bash
esptool.py --chip esp32s3 --port /dev/ttyACM0 write_flash -z 0x0 firmware.bin
```

### 方法三：Arduino IDE

1. 在 Arduino IDE 中选择开发板：`ESP32S3 Dev Module`
2. 配置参数：
   - USB CDC On Boot: Enabled
   - CPU Frequency: 240MHz (WiFi/BT)
   - Flash Size: 32MB
   - PSRAM: OPI PSRAM
   - Partition Scheme: Default 4MB with spiffs
3. 选择正确的串口
4. 点击上传按钮

### 方法四：ESP-IDF

1. 使用 VSCode + ESP-IDF 插件打开项目
2. 选择目标芯片：esp32s3
3. 设置正确的串口
4. 点击「Flash」按钮或执行 `idf.py flash`

## 出厂固件恢复

如需恢复出厂固件：
1. 从微雪官方Wiki下载出厂固件包
2. 使用 esptool.py 擦除整个Flash：
   ```bash
   esptool.py --chip esp32s3 --port PORT erase_flash
   ```
3. 按刷写指南重新写入出厂固件

## 常见问题

### 刷写失败
- 检查USB数据线是否支持数据传输
- 尝试手动进入下载模式
- 检查串口是否被其他程序占用
- 降低刷写波特率（如使用 115200 代替 921600）

### 刷写后屏幕无显示
- 确认固件是否匹配 ESP32-S3 平台
- 检查屏幕初始化参数是否正确
- 确认是否正确处理了 QSPI 屏的复位时序

### 刷写后无法进入系统
- 尝试按 RESET 键复位
- 重新进入下载模式，擦除Flash后重新刷写
