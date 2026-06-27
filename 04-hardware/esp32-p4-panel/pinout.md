# ESP32-P4-WIFI6-Touch-LCD-7B 引脚定义

## 板载外设引脚映射

### MIPI-DSI 显示屏

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| — | MIPI DSI CLK_P/N | MIPI DSI 时钟差分对 |
| — | MIPI DSI D0_P/N | MIPI DSI 数据通道0 |
| — | MIPI DSI D1_P/N | MIPI DSI 数据通道1 |
| GPIO_NUM_20 | LCD RST | 显示屏复位 |
| GPIO_NUM_23 | LCD BL | 背光控制 |

> MIPI-DSI 引脚为专用引脚，连接至板载 FPC 接口，具体引脚号请参考官方原理图。

### MIPI-CSI 摄像头接口

| 引脚 | 功能 | 说明 |
|------|------|------|
| — | MIPI CSI CLK_P/N | MIPI CSI 时钟差分对 |
| — | MIPI CSI D0_P/N | MIPI CSI 数据通道0 |
| — | MIPI CSI D1_P/N | MIPI CSI 数据通道1 |
| GPIO_NUM_27 | CAM RST | 摄像头复位 |
| GPIO_NUM_26 | CAM PWDN | 摄像头掉电控制 |

### 电容触控

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO_NUM_8 | I2C SDA | 触控芯片I2C数据线 |
| GPIO_NUM_9 | I2C SCL | 触控芯片I2C时钟线 |
| GPIO_NUM_10 | INT | 触控中断 |
| GPIO_NUM_11 | RST | 触控复位 |

### 音频系统 (ES8311 + ES7210)

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO_NUM_12 | I2S BCLK | 位时钟 |
| GPIO_NUM_13 | I2S LRCK | 左右声道时钟 |
| GPIO_NUM_14 | I2S DOUT | 数据输出 (Codec → P4) |
| GPIO_NUM_15 | I2S DIN | 数据输入 (P4 → Codec) |
| GPIO_NUM_16 | I2C SDA | 音频Codec I2C数据线 |
| GPIO_NUM_17 | I2C SCL | 音频Codec I2C时钟线 |
| GPIO_NUM_18 | PA EN | 功放使能 |

### ESP32-C6 协处理器 (SDIO)

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| — | SDIO CLK | SDIO 时钟 |
| — | SDIO CMD | SDIO 命令 |
| — | SDIO D0~D3 | SDIO 数据 |

> 通过 SDIO 接口与 ESP32-C6 通信，扩展 Wi-Fi 6 / 蓝牙功能。C6 另有独立的 Type-C 刷写口。

### TF卡 (SDIO 3.0)

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| — | SDMMC CLK | 时钟 |
| — | SDMMC CMD | 命令 |
| — | SDMMC D0~D3 | 数据 |

### 按键

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO_NUM_0 | BOOT KEY | 下载/启动按键 (Strapping引脚) |
| GPIO_NUM_21 | PWR KEY | 电源按键 |
| GPIO_NUM_22 | RESET | 复位按键（连接至硬件复位） |

### USB

| 接口 | 引脚 | 说明 |
|------|------|------|
| Type-C (直连) | GPIO_USB_DP/DM | USB 1.1 FS 直连P4 |
| Type-C (UART) | GPIO_19/20 (UART) | USB转UART桥接芯片 |
| Type-A (OTG) | USB_OTG_DP/DM | USB 2.0 HS OTG |

### LED

| ESP32-P4 引脚 | 功能 | 说明 |
|---------------|------|------|
| GPIO_NUM_25 | LED | 状态指示灯 |

## PH2.0 扩展端子

### RS485 端子

| 引脚 | 信号 | 说明 |
|------|------|------|
| 1 | 485A | RS485 A线 |
| 2 | 485B | RS485 B线 |
| 3 | GND | 接地 |
| 4 | 5V | 5V 电源 |

| 控制引脚 | 功能 |
|----------|------|
| GPIO_NUM_28 | RS485 TX |
| GPIO_NUM_29 | RS485 RX |
| GPIO_NUM_30 | RS485 DIR | 收发方向控制 |

### CAN 端子

| 引脚 | 信号 | 说明 |
|------|------|------|
| 1 | CANH | CAN H |
| 2 | CANL | CAN L |
| 3 | GND | 接地 |
| 4 | 5V | 5V 电源 |

### I2C 端子

| 引脚 | 信号 | ESP32-P4 引脚 | 说明 |
|------|------|---------------|------|
| 1 | SDA | GPIO_NUM_31 | I2C 数据线 |
| 2 | SCL | GPIO_NUM_32 | I2C 时钟线 |
| 3 | GND | — | 接地 |
| 4 | 3V3 | — | 3.3V 电源 |

### UART 端子

| 引脚 | 信号 | ESP32-P4 引脚 | 说明 |
|------|------|---------------|------|
| 1 | TX | GPIO_NUM_33 | UART 发送 |
| 2 | RX | GPIO_NUM_34 | UART 接收 |
| 3 | GND | — | 接地 |
| 4 | 3V3 | — | 3.3V 电源 |

### GPIO 扩展端子 (12PIN)

此端子扩展了 17 个可自由定义的 GPIO，以及 5V/3V3/GND 电源。具体引脚分配请参考官方原理图。

## 注意事项

1. MIPI-DSI/MIPI-CSI/SDIO 等高速接口引脚为专用引脚，不可复用为普通 GPIO
2. GPIO0 为 Strapping 引脚，上电时的电平会影响启动模式
3. 使用扩展端子的 I2C/UART 时，需确保与板载外设使用的 I2C/UART 总线不冲突
4. RS485/CAN 接口需外接相应的收发器（已板载），终端电阻按需配置
5. 扩展 GPIO 为 3.3V 电平，不可直接接 5V 信号

> 注：完整引脚图和原理图请从微雪官方Wiki资源页面下载。
> 文档链接：https://www.waveshare.com/wiki/ESP32-P4-WIFI6-Touch-LCD-7B#Schematic_Diagram
