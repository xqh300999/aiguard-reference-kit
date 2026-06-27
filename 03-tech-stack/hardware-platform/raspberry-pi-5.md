# Raspberry Pi 5

Raspberry Pi 5 是 AIguard 项目的本地网关核心硬件。

## 快速参考

### 硬件规格

| 规格 | 参数 |
|------|------|
| 处理器 | Broadcom BCM2712，四核 Cortex-A76 @ 2.4GHz |
| 内存 | 4GB / 8GB LPDDR4X-4267 |
| 视频 | VideoCore VII GPU，支持 H.265/HEVC 4Kp60 解码 |
| 存储 | microSD 卡插槽，支持 PCIe 2.0 x1 (需转接板) |
| 网络 | 千兆以太网，双频 802.11ac Wi-Fi，蓝牙 5.0/BLE |
| USB | 2×USB 3.0，2×USB 2.0 |
| GPIO | 40-pin 标准 GPIO 排针 |
| 电源 | 5V/5A USB-C，支持 Power Delivery |
| 尺寸 | 85mm × 56mm |

### OS 安装

1. **下载镜像**
   - Raspberry Pi OS (64-bit) 推荐：https://www.raspberrypi.com/software/operating-systems/
   - 也可选择 Ubuntu Server 22.04/24.04 LTS for Raspberry Pi

2. **使用 Raspberry Pi Imager 烧录**
   - 下载工具：https://www.raspberrypi.com/software/
   - 选择镜像 → 选择SD卡 → 点击齿轮图标高级设置
   - 配置：主机名、SSH启用、用户名密码、Wi-Fi、时区

3. **首次启动**
   ```bash
   # SSH连接（替换为你的IP）
   ssh pi@raspberrypi.local

   # 系统更新
   sudo apt update && sudo apt full-upgrade -y

   # 查看系统信息
   uname -a
   cat /proc/cpuinfo
   ```

### 基础配置

```bash
# raspi-config 配置工具
sudo raspi-config
# 常用选项：
# - Interface Options: 启用 SSH/VNC/SPI/I2C/Serial
# - Performance Options: 配置 GPU Memory
# - Localisation Options: 设置时区/语言/键盘
# - Advanced Options: 扩展文件系统

# 查看温度和频率
vcgencmd measure_temp
vcgencmd measure_clock arm

# 查看内存
free -h
```

### 软件源配置（国内加速）

```bash
# 编辑 sources.list
sudo nano /etc/apt/sources.list
# 替换为清华源（以 Debian Bookworm 为例）
deb https://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ bookworm main contrib non-free rpi
deb-src https://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ bookworm main contrib non-free rpi

# 编辑 raspi.list
sudo nano /etc/apt/sources.list.d/raspi.list
deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ bookworm main
```

## 常见坑点

1. **电源问题**
   - 现象：闪电图标出现在右上角、随机重启、USB设备不稳定
   - 解决：必须使用 5V/5A 官方电源或满足PD规格的电源
   - 检查：`vcgencmd get_throttled`，返回 0x0 表示正常

2. **SD卡启动失败**
   - 现象：无法引导、ACT灯不亮或异常闪烁
   - 解决：使用官方 Imager 烧录，选择正确的镜像版本，使用高质量SD卡
   - 建议：使用 UHS-I Class 10/A2 等级的SD卡，容量 32GB+

3. **PCIe 接口使用**
   - 默认禁用，需在 `/boot/firmware/config.txt` 末尾添加：
     ```
     dtparam=pciex1
     # 如需Gen2速度：
     dtparam=pciex1_gen=2
     ```
   - 需要专用的PCIe FPC排线和转接板

4. **64位系统兼容性**
   - 部分旧软件仅提供32位armhf版本
   - 安装32位运行时：`sudo apt install libc6:armhf`
   - Java/OpenGauss/Docker等官方均提供64位aarch64版本

5. **Wi-Fi 国家码问题**
   - 现象：5GHz Wi-Fi不可用或信号弱
   - 解决：raspi-config 中设置正确的国家码（CN）

## 官方链接

详见 [official-links.md](official-links.md)。

- Raspberry Pi 官网：https://www.raspberrypi.com/
- Raspberry Pi 5 文档：https://www.raspberrypi.com/documentation/computers/raspberry-pi-5.html
- Raspberry Pi OS 下载：https://www.raspberrypi.com/software/operating-systems/
- 硬件原理图：https://www.raspberrypi.com/documentation/computers/raspberry-pi-5.html#schematics
