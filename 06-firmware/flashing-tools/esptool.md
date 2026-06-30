# esptool.py 命令行刷写指南

## 概述

esptool.py 是乐鑫官方提供的Python编写的开源命令行工具，用于与ESP8266/ESP32系列芯片的ROM引导程序通信，实现固件刷写、Flash读写、内存操作等功能。适合高级用户、批量刷写和自动化场景。

## 安装

### 前置要求
- Python 3.7 或更高版本
- pip 包管理器

### 安装命令

```bash
pip install esptool
```

或使用pipx（推荐，避免依赖冲突）：
```bash
pipx install esptool
```

验证安装：
```bash
esptool.py version
```

更新到最新版：
```bash
pip install --upgrade esptool
```

> ESP32-P4支持需要 esptool.py v4.7 或更高版本。

## 固件下载

> **重要**：固件二进制文件不再存放在本仓库中，使用 esptool 刷写前，请先从 Gitee Release 下载所需固件到本地。

### 下载地址

固件通过 Gitee Release 发布，下载地址格式为：

```
https://gitee.com/<owner>/aiguard-reference-kit/releases/download/v<版本>/<下载文件>
```

> ⚠️ `<owner>` 与 `<Gitee仓库地址>` 为占位符，**请替换为实际 Gitee 仓库地址**。

### 各固件下载链接（占位）

| 固件 | 版本 | 下载文件 | 下载地址（占位） |
|------|------|----------|------------------|
| ESP32-S3 手表 | v2.2.4 | v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip | `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v2.2.4/v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip` |
| ESP32-P4 中控屏 V0.5 | v0.5 | aiguard_p4_panel_v0.5.bin | `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v0.5/aiguard_p4_panel_v0.5.bin` |
| ESP32-P4 中控屏 V1.0 | v1.0 | xiaozhi_p4_panel_v1.0_merged.bin | `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v1.0/xiaozhi_p4_panel_v1.0_merged.bin` |

Release 总览页：`https://<Gitee仓库地址>/aiguard-reference-kit/releases`

### 下载与校验步骤

```bash
# 1. 创建一个本地目录存放固件（示例）
mkdir -p ~/aiguard-firmware && cd ~/aiguard-firmware

# 2. 下载固件（以 ESP32-S3 手表固件为例，请替换 <Gitee仓库地址>）
curl -L -O https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v2.2.4/v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip

# 3. （若是 zip 包）解压
unzip v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip

# 4. 校验 SHA-256（推荐，校验值以 Release 附件页公布的为准）
shasum -a 256 v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip
```

> P4 固件为单文件 `.bin`，无需解压，下载后可直接刷写。

下载完成后，即可使用下文的 esptool 命令刷写到设备。

## 基本命令

### 1. 查看串口/确认连接

```bash
# 列出可用串口
esptool.py chip_id
```

或直接指定端口查看芯片信息：
```bash
esptool.py --port /dev/ttyACM0 chip_id
```

macOS串口通常为 `/dev/cu.usbmodem*` 或 `/dev/cu.SLAB_USBtoUART*`
Linux串口通常为 `/dev/ttyACM0` 或 `/dev/ttyUSB0`
Windows串口为 `COM3`、`COM4` 等

### 2. 擦除Flash

**首次刷写或刷写遇到问题时建议先擦除：**

```bash
esptool.py --chip esp32s3 --port PORT erase_flash
```

示例：
```bash
# ESP32-S3 (macOS)
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 erase_flash

# ESP32-P4
esptool.py --chip esp32p4 --port /dev/ttyUSB0 erase_flash
```

擦除整个Flash会清除所有数据（包括Wi-Fi配置、NVS等），设备恢复到出厂状态。

### 3. 刷写固件

#### 方法A：刷写合并固件（单文件，推荐新手）

如果固件包提供了合并后的 `factory.bin` 或 `merged-firmware.bin` 文件，直接刷写到0x0地址：

```bash
esptool.py --chip esp32s3 --port PORT write_flash -z 0x0 firmware-factory.bin
```

示例：
```bash
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 write_flash -z 0x0 xiaozhi-v2.2.4-esp32s3-watch-factory.bin
```

参数说明：
- `--chip esp32s3`：指定芯片类型（esp32s3/esp32p4）
- `--port PORT`：指定串口号
- `-z`：启用压缩传输，加快刷写速度
- `0x0`：刷写起始地址
- 最后一个参数：固件文件路径

#### 方法B：刷写多文件分区固件

如果是多个bin文件（bootloader、分区表、app等），需指定各自地址：

```bash
esptool.py --chip esp32s3 --port PORT write_flash -z \
  0x0 bootloader.bin \
  0x8000 partition-table.bin \
  0xD000 ota_data_initial.bin \
  0x10000 firmware.bin
```

如有SPIFFS分区，加上：
```bash
  0x110000 spiffs.bin
```

> ⚠️ 注意：具体地址以固件发布说明为准，不同分区方案地址不同！

### 4. 常用选项

```bash
# 指定波特率（默认460800，越高越快但可能不稳定）
--baud 921600
--baud 115200  # 不稳定时降低到115200

# 刷写前不自动进入下载模式（需要手动按BOOT时使用）
--before no_reset

# 刷写后不重启（刷完手动复位）
--after no_reset

# 完整示例：高波特率刷写合并固件
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 --baud 921600 write_flash -z --flash_mode dio --flash_freq 80m --flash_size 32MB 0x0 firmware.bin
```

### 5. 读取/验证Flash

```bash
# 读取Flash内容（备份）
esptool.py --chip esp32s3 --port PORT read_flash 0x0 0x200000 flash-backup.bin

# 验证固件（刷写后校验）
esptool.py --chip esp32s3 --port PORT verify_flash 0x0 firmware.bin
```

## AIguard 固件刷写示例

> 前置条件：已按上文「固件下载」一节，将固件下载并解压（如需）到本地目录（示例使用 `~/aiguard-firmware`）。

### ESP32-S3-Watch v2.2.4（合并固件）

```bash
# 1. 进入本地固件目录（已从 Gitee Release 下载并解压 zip 包）
cd ~/aiguard-firmware

# 2. 擦除Flash（可选，首次推荐）
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 erase_flash

# 3. 刷写固件（使用 zip 包内的合并固件 factory/merged 文件）
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 --baud 921600 write_flash -z 0x0 xiaozhi-v2.2.4-esp32s3-watch-factory.bin

# 4. 复位设备（或按RESET键）
esptool.py --chip esp32s3 --port /dev/cu.usbmodem101 run
```

### ESP32-P4 中控屏 V0.5（纯 Dashboard）

```bash
# 1. 进入本地固件目录（已从 Gitee Release 下载 aiguard_p4_panel_v0.5.bin）
cd ~/aiguard-firmware

# 2. 擦除Flash（可选，首次推荐）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 erase_flash

# 3. 刷写固件（单文件，直接刷到 0x0）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 --baud 921600 write_flash -z 0x0 aiguard_p4_panel_v0.5.bin

# 4. 复位设备（或按RESET键）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 run
```

### ESP32-P4 中控屏 V1.0（接入小智）

```bash
# 1. 进入本地固件目录（已从 Gitee Release 下载 xiaozhi_p4_panel_v1.0_merged.bin）
cd ~/aiguard-firmware

# 2. 擦除Flash（可选，首次推荐）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 erase_flash

# 3. 刷写固件（合并固件，直接刷到 0x0）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 --baud 921600 write_flash -z 0x0 xiaozhi_p4_panel_v1.0_merged.bin

# 4. 复位设备（或按RESET键）
esptool.py --chip esp32p4 --port /dev/cu.usbmodem101 run
```

### 批量刷写脚本示例

```bash
#!/bin/bash
# 批量刷写脚本 - 刷写完等待换设备
FIRMWARE="xiaozhi-v2.2.4-esp32s3-watch-factory.bin"

while true; do
    echo "等待设备连接..."
    # 自动检测端口（macOS示例）
    PORT=$(ls /dev/cu.usbmodem* 2>/dev/null | head -1)
    if [ -z "$PORT" ]; then
        sleep 2
        continue
    fi
    
    echo "检测到设备: $PORT"
    echo "开始刷写..."
    
    esptool.py --chip esp32s3 --port "$PORT" --baud 921600 write_flash -z 0x0 "$FIRMWARE"
    
    if [ $? -eq 0 ]; then
        echo "刷写成功！请更换设备..."
        esptool.py --chip esp32s3 --port "$PORT" run
    else
        echo "刷写失败！"
    fi
    
    sleep 5
done
```

## 查看串口日志

刷写后可用任意串口工具查看日志：

```bash
# 使用esptool自带的串口监视器
esptool.py --port PORT monitor

# 或使用screen（macOS/Linux）
screen /dev/cu.usbmodem101 115200

# 或使用minicom/picocom等
minicom -D /dev/ttyACM0 -b 115200
```

退出screen：`Ctrl+A` 然后按 `\`

## 常见问题

### 无法连接/无法进入下载模式
- 确认USB驱动已正确安装
- 尝试手动进入下载模式：按住BOOT，按RESET，松开RESET，再松开BOOT
- 降低波特率：`--baud 115200`
- 更换USB线或USB端口
- 检查是否有其他程序占用串口（如已打开的串口监视器、Arduino IDE等）

### 刷写时出现MD5校验错误
- 降低波特率重试
- 更换USB线（短线更好）
- 擦除Flash后重试
- 电脑USB口供电不足，尝试使用带供电的USB Hub

### 刷写后反复重启
- 确认固件对应正确的芯片（esp32s3 vs esp32p4）
- 确认Flash大小参数正确（32MB）
- 尝试擦除Flash后重新刷写
- 检查是否刷写了正确的分区表

### 找不到esptool.py命令
- 确认Python的bin目录在PATH中
- macOS/Linux：`~/Library/Python/3.x/bin` 或 `~/.local/bin`
- 或使用 `python -m esptool` 代替 `esptool.py`

## 更多信息

- esptool.py 官方文档：https://docs.espressif.com/projects/esptool/
- GitHub仓库：https://github.com/espressif/esptool
