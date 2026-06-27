# ESP32-P4-WIFI6-Touch-LCD-7B 固件刷写指南

## 准备工作

### 硬件准备
1. ESP32-P4-WIFI6-Touch-LCD-7B 开发板
2. USB 数据线（Type-A 转 Type-C，支持数据传输）
3. 电脑（Windows / Linux / macOS）

### USB 端口选择
开发板有两个 Type-C 接口，刷写固件时注意选择：

| Type-C 接口 | 用途 | 说明 |
|-------------|------|------|
| USB TO UART（标注 CH343/类似字样） | 固件刷写、串口调试 | 常规刷写使用此口 |
| USB 1.1 FS 直连 | USB 直连、USB OTG功能调试 | 通过 USB-OTA 刷写时使用 |

### 软件准备
- **ESP-IDF v5.3.1 或更高版本**（推荐，官方主要支持此框架）
- **esptool.py**：命令行工具
- **ESP Web Tools**：浏览器刷写（如支持）

## 刷写前注意事项

1. 使用支持数据传输的 USB 数据线
2. 确认使用正确的 Type-C 端口（USB TO UART 端口用于常规刷写）
3. 如无法识别串口，请先安装 USB 驱动（参见 [06-firmware/notes/driver-installation.md](../../06-firmware/notes/driver-installation.md)）
4. ESP32-P4 是较新芯片，确保刷写工具版本支持 P4 芯片
5. 刷写过程中请勿断开 USB 连接
6. 注意：板载 ESP32-C6 协处理器有独立的刷写端子，刷写 P4 固件时无需操作 C6

## 进入下载模式

### 自动下载模式（推荐）
ESP-IDF 和新版本 esptool.py 支持 ESP32-P4 的自动下载，通过串口控制 RTS/DTR 信号自动进入下载模式，无需手动按键。

### 手动进入下载模式（自动模式失败时）
1. 按住 BOOT 按键
2. 按一下 RESET 按键
3. 松开 RESET 按键
4. 松开 BOOT 按键
5. 此时开发板进入固件下载模式

## 刷写方法

### 方法一：ESP-IDF（官方推荐）

1. 配置 ESP-IDF 环境，确保版本 ≥ v5.3.1
2. 设置目标芯片：
   ```bash
   idf.py set-target esp32p4
   ```
3. 配置项目（menuconfig）：
   - 根据屏幕参数配置 MIPI-DSI
   - 配置 Flash 大小为 32MB
4. 编译：
   ```bash
   idf.py build
   ```
5. 设置串口并刷写：
   ```bash
   idf.py -p PORT flash
   ```
6. 监视串口输出：
   ```bash
   idf.py -p PORT monitor
   ```

### 方法二：esptool.py 命令行刷写

参见 [06-firmware/flashing-tools/esptool.md](../../06-firmware/flashing-tools/esptool.md)

基本命令示例：
```bash
esptool.py --chip esp32p4 --port PORT write_flash -z 0x0 firmware.bin
```

注意：esptool.py 版本需支持 ESP32-P4（v4.7 或更高版本）。

### 方法三：ESP32-C6 协处理器刷写

板载 ESP32-C6 模组有独立的刷写端子：
1. 使用 USB 转串口模块连接 C6 UART 端子
2. C6 刷写方法与普通 ESP32-C6 开发板相同
3. 通常情况下无需单独刷写 C6 固件，出厂已预烧录

## 屏幕唤醒注意事项

ESP32-P4 的 MIPI-DSI 屏幕在复位后需要初始化序列才能正常显示。首次刷写自定义固件时，需注意：

1. 参考微雪官方 Demo 中的屏幕初始化代码
2. 确保在 app_main 中正确调用屏幕唤醒序列
3. 屏幕背光控制引脚 (GPIO23) 需正确配置
4. 如刷写后屏幕不亮，先检查背光是否开启，再检查屏幕初始化序列

## 出厂固件恢复

1. 从微雪官方Wiki资源页面下载出厂固件
2. 使用 esptool.py 擦除 Flash：
   ```bash
   esptool.py --chip esp32p4 --port PORT erase_flash
   ```
3. 按照官方提供的刷写地址写入固件（出厂固件通常是多个分区文件）

## 常见问题

### 无法识别串口
- 确认使用 USB TO UART 端口而非 USB 直连端口
- 安装 CH343/CP2102 等 USB 转串口驱动
- 更换 USB 数据线或 USB 端口
- 检查设备管理器中是否有未识别设备

### 刷写失败
- 确认 esptool.py 版本支持 ESP32-P4
- 尝试手动进入下载模式
- 降低刷写波特率（115200 或更低）
- 检查是否有其他程序占用串口

### 刷写后屏幕黑屏
- 检查屏幕背光是否使能（GPIO23）
- 确认屏幕初始化序列是否正确执行
- 通过串口日志确认系统是否正常启动
- 参考官方 Demo 检查 MIPI-DSI 配置参数

### 刷写后系统反复重启
- 检查 Flash 大小配置是否为 32MB
- 确认分区表配置与实际 Flash 大小匹配
- 检查电源供应是否稳定
- 检查是否有看门狗超时导致的复位
