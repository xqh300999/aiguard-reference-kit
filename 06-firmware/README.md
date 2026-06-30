# AIguard 固件文档总览

本文档目录包含 AIguard 参考套件的固件相关文档。

> **重要说明**：固件二进制文件**不再直接存放在本仓库中**。所有固件包均通过 **Gitee Release** 统一发布，请通过下文的下载地址获取。

## 目录结构

```
06-firmware/
├── README.md                    # 本文档
├── checksums.txt                # 固件校验值（SHA-256）参考格式
├── xiaozhi/                     # 小智AI对话固件
│   └── README.md                # 固件说明/适用硬件/下载方式
├── flashing-tools/              # 固件刷写工具
│   ├── README.md                # 工具总览
│   ├── esp-web-tools.md         # 浏览器刷写指南
│   └── esptool.md               # esptool.py命令行刷写
└── notes/                       # 注意事项
    ├── driver-installation.md   # USB驱动安装指南
    └── firmware-update-tips.md  # 固件升级/回退注意事项
```

> 说明：`xiaozhi/` 目录下仅保留说明文档，不再包含任何 `.zip`/`.bin` 固件文件。固件统一从 Gitee Release 下载。

## 固件版本说明

| 固件名称 | 版本 | 适用硬件 | 基础 | 下载文件 | 说明 |
|----------|------|----------|------|----------|------|
| xiaozhi-s3-watch | v2.2.4 | ESP32-S3-Touch-AMOLED-2.06 | 小智开源固件 | v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip | 手表形态AI对话+跌倒检测 |
| xiaozhi-p4-panel-v05 | v0.5 | ESP32-P4-WIFI6-Touch-LCD-7B | AI-Guard原生 | aiguard_p4_panel_v0.5.bin | 纯Dashboard中控屏固件 |
| xiaozhi-p4-panel-v10 | v1.0 | ESP32-P4-WIFI6-Touch-LCD-7B | 小智v2.2.4+overlay | xiaozhi_p4_panel_v1.0_merged.bin | 接入小智语音的中控屏固件 |

## 固件下载

### 下载地址

固件通过 Gitee Release 发布，下载地址格式为：

```
https://gitee.com/<owner>/aiguard-reference-kit/releases/download/v<版本>/<下载文件>
```

> ⚠️ **占位符说明**：`<owner>` 与 `<Gitee仓库地址>` 为占位符，**请替换为实际 Gitee 仓库地址**。Gitee 仓库创建完成后，请将本文档及子文档中的占位符统一替换为真实地址。

### 各固件下载链接（占位）

- **xiaozhi-s3-watch v2.2.4**
  `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v2.2.4/v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip`

- **xiaozhi-p4-panel-v05 v0.5**
  `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v0.5/aiguard_p4_panel_v0.5.bin`

- **xiaozhi-p4-panel-v10 v1.0**
  `https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v1.0/xiaozhi_p4_panel_v1.0_merged.bin`

### Release 总览页

如需浏览所有历史版本，请访问：

```
https://<Gitee仓库地址>/aiguard-reference-kit/releases
```

## 校验方式

固件下载完成后，**强烈建议**校验文件完整性，避免下载损坏或被篡改。

校验值参考格式存储在 [checksums.txt](checksums.txt) 中。下载后执行以下命令计算 SHA-256，并与 Release 页公布的校验值比对：

```bash
# 计算下载文件的 SHA-256
shasum -a 256 <下载的固件文件名>

# 示例
shasum -a 256 v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip
```

> 注：`checksums.txt` 中给出的是校验值**参考格式**与待填写模板。实际 SHA-256 校验值以各 Release 附件页公布的为准。

## 刷写流程概要

1. 安装USB驱动（首次使用时）
2. 从 Gitee Release 下载对应硬件的固件文件
3. 下载后校验文件 SHA-256（推荐）
4. 选择刷写工具（浏览器或命令行）
5. 进入下载模式
6. 执行刷写
7. 验证运行
8. 配置设备连网等

详细步骤请参考各工具文档和注意事项：

- 浏览器刷写：[flashing-tools/esp-web-tools.md](flashing-tools/esp-web-tools.md)
- 命令行刷写：[flashing-tools/esptool.md](flashing-tools/esptool.md)
- 刷写工具总览：[flashing-tools/README.md](flashing-tools/README.md)
- 驱动安装：[notes/driver-installation.md](notes/driver-installation.md)
- 升级/回退注意事项：[notes/firmware-update-tips.md](notes/firmware-update-tips.md)

## 小智固件说明

小智系列固件的版本信息、适用硬件、功能特性、固件包内容等详细说明请参考：

- [xiaozhi/README.md](xiaozhi/README.md)
