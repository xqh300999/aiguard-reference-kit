# AIguard 固件文档总览

本文档目录包含 AIguard 参考套件的固件相关文档。

## 目录结构

```
06-firmware/
├── README.md                    # 本文档
├── checksums.txt                # 固件校验值（SHA-256）
├── xiaozhi/                     # 小智AI对话固件
│   └── README.md                # v2.2.4固件说明/适用硬件
├── flashing-tools/              # 固件刷写工具
│   ├── README.md                # 工具总览
│   ├── esp-web-tools.md         # 浏览器刷写指南
│   └── esptool.md               # esptool.py命令行刷写
└── notes/                       # 注意事项
    ├── driver-installation.md   # USB驱动安装指南
    └── firmware-update-tips.md  # 固件升级/回退注意事项
```

## 固件版本说明

| 固件名称 | 版本 | 适用硬件 | 基础 | 说明 |
|----------|------|----------|------|------|
| xiaozhi | v2.2.4 | ESP32-S3-Touch-AMOLED-2.06 | 小智开源固件 | AI对话基础，集成AIguard跌倒检测等功能 |

## 固件文件命名约定

固件文件统一命名格式：
```
{固件名}-{版本}-{硬件平台}.{扩展名}
```

示例：
- `xiaozhi-v2.2.4-esp32s3-watch.bin` - ESP32-S3手表版合并固件
- `xiaozhi-v2.2.4-esp32s3-watch-factory.bin` - ESP32-S3手表版工厂固件（含bootloader等）
- `xiaozhi-v2.2.4-esp32p4-panel.bin` - ESP32-P4面板版固件（如提供）

## 校验值

固件包的 SHA-256 校验值存储在 [checksums.txt](checksums.txt) 中。
刷写前建议校验文件完整性：
```bash
shasum -a 256 -c checksums.txt
```

## 刷写流程概要

1. 安装USB驱动（首次使用时）
2. 选择刷写工具（浏览器或命令行）
3. 下载对应硬件的固件
4. 进入下载模式
5. 执行刷写
6. 验证运行
7. 配置设备连网等

详细步骤请参考各工具文档和注意事项。
