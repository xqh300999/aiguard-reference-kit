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

页面列出可用的固件版本，选择对应硬件的版本：
- 选择 `xiaozhi-v2.2.4-esp32s3-watch`（对应Waveshare ESP32-S3手表板）
- 如面板固件已支持，选择对应P4版本

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
