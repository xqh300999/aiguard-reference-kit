# ESP Web Tools 浏览器刷写指南

## 概述

ESP Web Tools 是由 ESPHome 团队开发的开源Web刷写工具，允许用户通过浏览器直接刷写ESP32固件，无需安装Python、esptool或任何刷写软件，仅需一个支持WebUSB的浏览器。

**推荐浏览器：** Google Chrome、Microsoft Edge（基于Chromium）

**不支持：** Safari、Firefox（WebUSB支持有限或不支持）

## 准备工作

1. 使用 Chrome/Edge 浏览器
2. USB数据线（支持数据传输）
3. ESP开发板
4. 稳定的网络连接（需从网络加载固件）

## 固件下载

> **重要**：固件二进制文件不再存放在本仓库中。使用 ESP Web Tools 刷写前，请先从 Gitee Release 下载所需固件到本地。

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

# 2. 下载固件（以 ESP32-P4 V1.0 为例，请替换 <Gitee仓库地址>）
curl -L -O https://<Gitee仓库地址>/aiguard-reference-kit/releases/download/v1.0/xiaozhi_p4_panel_v1.0_merged.bin

# 3. 校验 SHA-256（推荐，校验值以 Release 附件页公布的为准）
shasum -a 256 xiaozhi_p4_panel_v1.0_merged.bin
```

> ESP Web Tools 通常通过 manifest.json 中的 `path` 字段加载固件。如使用本地托管的刷写页面，请将下载的固件文件放到 manifest.json 所在目录，并确保 `path` 指向本地文件；如使用官方/远程托管页面，则页面会自动从 manifest 中的 URL 拉取固件，但仍建议提前下载并在本地保留一份以备离线刷写。

下载完成后，即可按下文步骤使用 ESP Web Tools 刷写到设备。

## 使用步骤

### 第一步：打开刷写页面

访问为AIguard准备的ESP Web Tools刷写页面（如果有托管页面），或者使用通用的ESP Web Tools刷写页面。

本地也可以创建HTML页面使用ESP Web Tools，核心代码结构：

```html
<script type="module" src="https://unpkg.com/esp-web-tools@9/dist/web/install-button.js?module"></script>
<esp-web-install-button manifest="manifest.json">
  <button slot="activate">刷写固件</button>
</esp-web-install-button>
```

### 第二步：连接设备

1. 用USB线将开发板连接到电脑
2. 点击页面上的「刷写固件」/「Connect」按钮
3. 浏览器弹出串口选择对话框
4. 选择你的ESP32设备对应的串口（如 `USB Serial`、`CP210x`、`CH340`、`USB JTAG/UART` 等）
5. 点击「连接」

### 第三步：选择固件版本

页面列出可用的固件版本，选择对应硬件的版本（请与「固件下载」一节下载的文件对应）：
- `xiaozhi-v2.2.4-esp32s3-watch` —— 对应 Waveshare ESP32-S3 手表板（固件文件 `v2.2.4_waveshare-esp32-s3-touch-amoled-2.06.zip`）
- `aiguard-p4-panel-v0.5` —— 对应 Waveshare ESP32-P4 中控屏（纯 Dashboard，固件文件 `aiguard_p4_panel_v0.5.bin`）
- `xiaozhi-p4-panel-v1.0` —— 对应 Waveshare ESP32-P4 中控屏（接入小智，固件文件 `xiaozhi_p4_panel_v1.0_merged.bin`）

### 第四步：开始刷写

1. 点击「安装」/「Install」开始刷写
2. 工具会自动：
   - 擦除Flash（首次刷写建议擦除）
   - 下载固件到浏览器
   - 进入下载模式（支持自动下载的设备自动进入）
   - 写入固件
   - 验证写入
3. 等待进度条完成（通常1-3分钟）
4. 看到「安装完成」/「Installation complete」提示

### 第五步：首次启动

1. 刷写完成后，按一下开发板的RESET键，或重新插拔USB
2. 设备将启动新固件
3. 如果是首次刷写，设备应进入配网模式

## Manifest 文件格式

如果需要自行托管ESP Web Tools刷写页，manifest.json示例：

```json
{
  "name": "AIguard 固件",
  "version": "v2.2.4",
  "home_assistant_domain": "aiguard",
  "funding_url": "",
  "new_install_prompt_erase": true,
  "builds": [
    {
      "chipFamily": "ESP32-S3",
      "parts": [
        { "path": "bootloader.bin", "offset": 0 },
        { "path": "partition-table.bin", "offset": 32768 },
        { "path": "ota_data_initial.bin", "offset": 53248 },
        { "path": "firmware.bin", "offset": 65536 }
      ]
    }
  ]
}
```

如果有合并好的单文件固件（merged/factory bin），可以更简单：

```json
{
  "builds": [
    {
      "chipFamily": "ESP32-S3",
      "parts": [
        { "path": "xiaozhi-v2.2.4-esp32s3-watch-factory.bin", "offset": 0 }
      ]
    }
  ]
}
```

## 常见问题

### 浏览器不弹出串口选择
- 确认使用 Chrome/Edge 浏览器
- 尝试使用隐身窗口
- 检查浏览器是否有WebUSB权限被禁用

### 找不到设备
- 检查USB线是否支持数据传输
- 确认USB驱动已安装
- 尝试更换USB端口
- 断开其他USB串口设备

### 自动下载失败，无法进入刷写模式
- 手动进入下载模式：按住BOOT键，按RESET键，松开RESET，再松开BOOT
- 然后点击浏览器的连接/重试按钮

### 刷写过程中断
- 不要使用USB集线器，直连电脑USB口
- 更换USB线或USB端口
- 确保刷写过程中电脑不会休眠
- 重试刷写

### 刷写后设备无反应
- 按RESET键复位
- 确认固件对应正确的芯片型号（esp32s3 vs esp32p4）
- 检查manifest中的偏移地址是否正确
- 尝试先擦除Flash再刷写

## 日志查看

刷写完成后，ESP Web Tools还提供：
- **查看日志**：点击「Logs」/「查看日志」按钮可连接设备串口查看实时日志
- **重置设备**：发送复位命令
- 这对首次调试很有用，无需额外安装串口工具
