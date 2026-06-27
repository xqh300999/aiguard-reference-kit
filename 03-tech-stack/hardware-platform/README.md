# 硬件平台

AIguard 项目采用树莓派5作为本地网关，微雪ESP32系列作为终端节点的硬件架构。

## 目录

- [Raspberry Pi 5](raspberry-pi-5.md) - 主控网关硬件规格与配置
- [微雪 ESP32](waveshare-esp32.md) - ESP32-S3/P4 终端节点开发
- [官方链接](official-links.md) - 各硬件厂商官方文档汇总

## 硬件架构概览

| 角色 | 硬件 | 主要职责 |
|------|------|----------|
| 本地网关 | Raspberry Pi 5 | 后端服务运行、数据处理、AI推理、设备管理 |
| 智能终端 | 微雪 ESP32-S3/P4 | 传感器数据采集、语音交互、设备控制 |

## 快速参考

- 树莓派5默认用户名：`pi`，默认密码：`raspberry`
- ESP32开发推荐使用 ESP-IDF 或 Arduino 框架
- 建议使用 Class 10 以上的 microSD 卡作为树莓派存储介质
- 树莓派5需使用 5V/5A USB-C 电源供电

## 常见坑点

1. 树莓派5必须使用官方电源或满足5V/5A规格的电源，否则会出现降频或不稳定
2. ESP32-S3/P4 部分模块不支持 PSRAM，购买时需注意型号区分
3. 64位系统与32位系统在软件兼容性上存在差异，建议统一使用64位
4. 树莓派5的PCIe接口默认禁用，需在config.txt中手动开启

## 官方链接

详见 [official-links.md](official-links.md)。
