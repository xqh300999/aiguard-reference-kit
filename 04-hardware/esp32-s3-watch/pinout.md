# ESP32-S3-Touch-AMOLED-2.06 引脚定义

## 板载外设引脚映射

### AMOLED 显示屏 (CO5300 via QSPI)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO47 | QSPI CS | 片选 |
| GPIO48 | QSPI CLK | 时钟 |
| GPIO45 | QSPI D0 | 数据位0 |
| GPIO46 | QSPI D1 | 数据位1 |
| GPIO42 | QSPI D2 | 数据位2 |
| GPIO41 | QSPI D3 | 数据位3 |
| GPIO38 | RST | 显示屏复位 |
| GPIO39 | TE | 撕裂效果信号 |

### 电容触控 (FT3168 via I2C)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO14 | I2C SDA | I2C 数据线 |
| GPIO15 | I2C SCL | I2C 时钟线 |
| GPIO16 | INT | 触控中断 |
| GPIO17 | RST | 触控复位 |

### 六轴IMU (QMI8658 via I2C)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO14 | I2C SDA | 与触控共用I2C总线 |
| GPIO15 | I2C SCL | 与触控共用I2C总线 |
| GPIO12 | INT1 | IMU中断1 |

### RTC (PCF85063 via I2C)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO14 | I2C SDA | 共用I2C总线 |
| GPIO15 | I2C SCL | 共用I2C总线 |
| GPIO13 | INT | RTC中断 |

### 音频编解码 (ES8311 via I2S)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO4 | I2S BCLK | 位时钟 |
| GPIO5 | I2S LRCK | 左右声道时钟 |
| GPIO6 | I2S DOUT | 数据输出 (ES8311 → ESP32) |
| GPIO7 | I2S DIN | 数据输入 (ESP32 → ES8311) |
| GPIO18 | I2C SDA | ES8311 I2C数据线 |
| GPIO10 | I2C SCL | ES8311 I2C时钟线 |

### 电源管理 (AXP2101 via I2C)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO18 | I2C SDA | 与ES8311共用I2C总线 |
| GPIO10 | I2C SCL | 与ES8311共用I2C总线 |
| GPIO11 | IRQ | 电源中断 |

### TF卡 (SPI)

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO36 | CS | 片选 |
| GPIO35 | MOSI | 主出从入 |
| GPIO37 | MISO | 主入从出 |
| GPIO34 | SCK | 时钟 |

### 按键

| ESP32-S3 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO21 | PWR KEY | 电源按键 |
| GPIO0 | BOOT KEY | 下载/启动按键 (Strapping引脚) |

## 引出扩展接口

### I2C 接口焊盘

| 焊盘 | ESP32-S3 引脚 | 说明 |
|------|---------------|------|
| SDA | GPIO14 | 与板载外设共用I2C，使用时需注意地址冲突 |
| SCL | GPIO15 | 同上 |
| 3V3 | — | 3.3V 电源 |
| GND | — | 接地 |

### UART 接口焊盘

| 焊盘 | ESP32-S3 引脚 | 说明 |
|------|---------------|------|
| TX | GPIO43 | UART发送 |
| RX | GPIO44 | UART接收 |
| 3V3 | — | 3.3V 电源 |
| GND | — | 接地 |

> 注：详细引脚图请参考微雪官方Wiki的原理图部分。
> 文档链接：https://www.waveshare.com/wiki/ESP32-S3-Touch-AMOLED-2.06#Pinout_Definition
