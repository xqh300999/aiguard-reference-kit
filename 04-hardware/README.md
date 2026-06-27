# AIguard 硬件文档总览

本文档目录包含 AIguard 参考套件的硬件相关文档。

## 目录结构

```
04-hardware/
├── README.md                    # 本文档
├── esp32-s3-watch/              # ESP32-S3 智能手表开发板
│   ├── README.md                # 规格说明
│   ├── pinout.md                # 引脚定义
│   └── flashing-guide.md        # 固件刷写指南
├── esp32-p4-panel/              # ESP32-P4 7寸中控面板
│   ├── README.md                # 规格说明
│   ├── pinout.md                # 引脚定义
│   └── flashing-guide.md        # 固件刷写指南
├── sensors/                     # 传感器模块
│   ├── README.md                # 传感器总览
│   ├── qmi8658.md               # QMI8658 六轴IMU
│   └── other-sensors.md         # 其他传感器选型
└── home-assistant/              # Home Assistant 集成
    ├── README.md                # HA集成说明
    └── supported-devices.md     # HA兼容设备推荐
```

## 硬件平台

### 便携/穿戴终端：ESP32-S3-Touch-AMOLED-2.06
- 微雪电子出品，手表形态开发板
- ESP32-S3R8 双核处理器，240MHz
- 2.06寸 AMOLED 电容触控屏 (410×502)
- 板载 QMI8658 六轴IMU，支持跌倒检测
- 板载 ES8311 音频编解码
- AXP2101 电源管理，支持锂电池
- 8MB PSRAM + 32MB Flash
- Wi-Fi + BLE 5

### 家庭中控面板：ESP32-P4-WIFI6-Touch-LCD-7B
- 微雪电子出品，7寸桌面/壁挂面板
- ESP32-P4 RISC-V 双核处理器，360MHz + ESP32-C6 协处理器 (Wi-Fi 6/BT 5)
- 7寸 IPS 电容触控屏 (1024×600)
- MIPI-CSI 摄像头接口，支持1080P
- ES8311 + ES7210 音频方案，支持回声消除
- RS485/CAN 工业总线接口
- 32MB PSRAM + 32MB Flash

## 参考链接

- 微雪 ESP32-S3 官方文档：https://www.waveshare.com/wiki/ESP32-S3-Touch-AMOLED-2.06
- 微雪 ESP32-P4 官方文档：https://www.waveshare.com/wiki/ESP32-P4-WIFI6-Touch-LCD-7B
