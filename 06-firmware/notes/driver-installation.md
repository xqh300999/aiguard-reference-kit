# USB 驱动安装指南

## 概述

ESP32开发板通过USB连接电脑时，可能需要安装对应的USB转串口驱动才能被电脑识别。不同开发板使用不同的USB转换芯片，需要安装对应驱动。

## 常见USB芯片

| 芯片 | 常见开发板 | 驱动 |
|------|------------|------|
| CP210x (CP2102/CP2104) | 很多NodeMCU、ESP32 DevKit | Silicon Labs CP210x驱动 |
| CH340/CH343 | 低价开发板、Waveshare部分板 | 沁恒CH34x驱动 |
| 内置USB JTAG (ESP32-S3/C3/P4) | ESP32-S3/C3直连USB | 无需额外驱动（Win10+/macOS/Linux） |

## AIguard参考套件所用芯片

| 硬件 | USB接口 | 芯片 | 驱动需求 |
|------|---------|------|----------|
| ESP32-S3-Touch-AMOLED-2.06 | Type-C | ESP32-S3内置USB+CH343? | 通常免驱，无法识别时装CH343驱动 |
| ESP32-P4-WIFI6-Touch-LCD-7B | USB TO UART口 | CH343（参考微雪Wiki） | 安装CH343驱动 |
| ESP32-P4-WIFI6-Touch-LCD-7B | USB直连口 | ESP32-P4内置USB | Win10+免驱 |

> 注：具体芯片型号以微雪官方Wiki和板上丝印为准。如果系统能自动识别出串口，可直接使用。

## Windows 驱动安装

### 1. 自动识别（推荐先试）

Windows 10/11 通常能自动识别以下设备：
- ESP32-S3/C3/H2/P4 内置USB JTAG/CDC
- 部分CP210x设备

连接设备后等待几分钟，打开设备管理器查看「端口(COM和LPT)」。

### 2. 手动安装 CH343 驱动

适用于：Waveshare ESP32-P4 USB TO UART 端口，及部分使用CH343的设备。

1. 访问沁恒官网下载CH343驱动：
   - http://www.wch-ic.com/downloads/CH343SER_EXE.html
   - 或搜索「CH343SER 驱动下载」
2. 下载后运行安装程序
3. 按照提示完成安装
4. 重新插拔USB设备
5. 打开设备管理器确认出现新的COM端口

### 3. 手动安装 CP210x 驱动

适用于：使用CP2102/CP2104的开发板。

1. 访问Silicon Labs官网：
   - https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers
2. 下载对应Windows版本的VCP驱动
3. 解压并运行安装程序
4. 重新插拔USB设备

### 验证安装

1. 右键「此电脑」→「管理」→「设备管理器」
2. 展开「端口(COM和LPT)」
3. 插入ESP32设备后，应出现新的COM端口，如：
   - `USB Serial Device (COM3)` - 内置USB CDC
   - `Silicon Labs CP210x USB to UART Bridge (COM4)` - CP210x
   - `USB-SERIAL CH340 (COM5)` 或 `CH343 (COMx)` - CH340/CH343
4. 如果出现带黄色感叹号的「未知设备」，说明驱动未正确安装

## macOS 驱动安装

macOS 10.13+ 对CP210x和CH34x的支持情况：

### 内置USB CDC（ESP32-S3/C3/P4直连）
- macOS 10.14+ 通常免驱
- 设备会出现在 `/dev/cu.usbmodem*`

### CH340/CH343 驱动
macOS上有时需要手动安装CH34x驱动：

1. 下载CH34x驱动（WCH官网）：
   - http://www.wch-ic.com/downloads/CH341SER_MAC_ZIP.html
   - 或搜索 CH34x macOS 驱动
2. 注意：macOS 10.13+ 运行内核扩展需在「系统设置 → 隐私与安全性」中允许加载
3. 安装后重启
4. 设备会出现在 `/dev/cu.wchusbserial*` 或 `/dev/cu.usbserial*`

### CP210x 驱动
- 从Silicon Labs官网下载macOS版VCP驱动
- 安装后重启
- 设备出现在 `/dev/cu.SLAB_USBtoUART`

### 验证安装
打开终端，执行：
```bash
ls /dev/cu.*
```
插入设备前后对比，新出现的即为设备串口。

### macOS 常见问题
- **设备已连接但 /dev 中不出现**：检查「系统设置 → 隐私与安全性」是否有驱动加载提示，允许后重启
- **提示「来自身份不明的开发者」**：右键安装包 → 打开；或在隐私设置中允许
- **M1/M2/M3 Mac注意**：驱动需支持Apple Silicon，安装后可能需要在恢复模式启用扩展

## Linux 驱动安装

### 内置USB CDC
- Linux内核自带驱动，无需安装
- 设备通常为 `/dev/ttyACM0`

### CP210x / CH340 / CH343
- Linux内核3.x+已内置CP210x和CH340/CH343驱动
- 通常无需额外安装
- 设备通常为 `/dev/ttyUSB0`

### 权限问题
如果无法访问串口（Permission denied），需将用户加入dialout组：
```bash
sudo usermod -a -G dialout $USER
# 或对于ttyACM*
sudo usermod -a -G plugdev $USER
```

注销重新登录后生效。

也可以临时添加udev规则：
```bash
echo 'SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", MODE="0666"' | sudo tee /etc/udev/rules.d/99-esp32.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

验证：
```bash
ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null
```

## 通用排查步骤

### 设备无法识别（任何系统）
1. **换USB线**：很多USB线仅支持充电，不支持数据传输。使用手机原装或已知支持数据的线。
2. **换USB口**：尝试电脑后置端口或直接端口，避免USB Hub。
3. **检查设备是否上电**：部分开发板需要按电源键，或板载LED应亮起。
4. **进入下载模式**：有些设备在正常模式下可能不枚举USB，按住BOOT键插入USB试试。
5. **查看设备管理器/dmesg**：
   - Windows：设备管理器
   - macOS：系统信息 → USB
   - Linux：`dmesg | tail`
6. **驱动重装**：在设备管理器中卸载旧驱动，重新安装。

### Windows中设备出现又消失
- 可能是驱动冲突，卸载重复的驱动
- 尝试在「设备和打印机」中删除旧设备重新连接
- 检查USB口供电是否足够（用双USB头的线或外接供电Hub）

### 能识别但刷写工具连不上
- 确认串口没有被其他程序占用（关闭串口监视器、Arduino IDE、Python脚本等）
- 关闭蓝牙串口监控软件
- 确认串口号正确

## 驱动下载链接汇总

| 驱动 | 下载地址 |
|------|----------|
| CP210x VCP | https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers |
| CH340/CH343 (WCH) | http://www.wch-ic.com/downloads/category/30.html |
| FTDI (罕见) | https://ftdichip.com/drivers/vcp-drivers/ |
| ESP32内置USB | 系统自带，无需驱动（Win10+/macOS 10.14+/Linux 3.x+） |
