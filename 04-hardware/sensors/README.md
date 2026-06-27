# 传感器模块总览

本文档目录包含 AIguard 参考套件所使用和推荐的传感器相关文档。

## 已集成传感器

| 传感器 | 型号 | 所在硬件 | 接口 | 主要功能 | 文档 |
|--------|------|----------|------|----------|------|
| 六轴IMU | QMI8658 | ESP32-S3-Watch | I2C | 加速度+陀螺仪、跌倒检测、计步 | [qmi8658.md](qmi8658.md) |

## 推荐扩展传感器

| 传感器类型 | 推荐型号/方案 | 接口 | 适用场景 | 文档 |
|------------|--------------|------|----------|------|
| 门磁传感器 | 干簧管/MH-Z16 | GPIO | 门窗开合检测 | [other-sensors.md](other-sensors.md) |
| 温湿度 | SHT30/AHT20/DHT22 | I2C/GPIO | 环境温湿度监测 | [other-sensors.md](other-sensors.md) |
| 烟雾/燃气 | MQ-2/MQ-5 | ADC/GPIO | 烟雾/可燃气体报警 | [other-sensors.md](other-sensors.md) |
| 人体感应 | HC-SR501/AM312 | GPIO | 人体存在检测 | [other-sensors.md](other-sensors.md) |
| 光照度 | BH1750/VEML7700 | I2C | 环境光检测 | [other-sensors.md](other-sensors.md) |
| 心率血氧 | MAX30102 | I2C | 健康监测 | [other-sensors.md](other-sensors.md) |

## 传感器接入方式

### ESP32-S3-Watch（手表端）
- 板载 I2C 总线（GPIO14/GPIO15）已连接 QMI8658、FT3168、PCF85063
- 扩展 I2C 接口焊盘与板载总线共用，需注意 I2C 地址冲突
- 额外传感器可考虑通过 BLE 外接

### ESP32-P4-Panel（面板端）
- 独立的 PH2.0 I2C 扩展端子（GPIO31/GPIO32）
- RS485/CAN 总线可接入工业级传感器
- GPIO 扩展端子提供 17 个可配置 IO
- 支持 USB 外接传感器
