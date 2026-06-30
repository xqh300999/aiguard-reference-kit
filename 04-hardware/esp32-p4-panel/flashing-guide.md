# ESP32-P4-WIFI6-Touch-LCD-7B 固件刷写指南

## 准备工作

### 硬件准备
1. ESP32-P4-WIFI6-Touch-LCD-7B 开发板
2. USB 数据线（Type-A 转 Type-C，支持数据传输）
3. 电脑（Windows / Linux / macOS）

### USB 端口选择
开发板有两个 Type-C 接口，刷写固件时注意选择：

| Type-C 接口 | 用途 | 说明 |
|-------------|------|------|
| USB TO UART（标注 CH343/类似字样） | 固件刷写、串口调试 | 常规刷写使用此口 |
| USB 1.1 FS 直连 | USB 直连、USB OTG功能调试 | 通过 USB-OTA 刷写时使用 |

### 软件准备
- **ESP-IDF v5.3.1 或更高版本**（推荐，官方主要支持此框架）
- **esptool.py**：命令行工具
- **ESP Web Tools**：浏览器刷写（如支持）

## 刷写前注意事项

1. 使用支持数据传输的 USB 数据线
2. 确认使用正确的 Type-C 端口（USB TO UART 端口用于常规刷写）
3. 如无法识别串口，请先安装 USB 驱动（参见 [06-firmware/notes/driver-installation.md](../../06-firmware/notes/driver-installation.md)）
4. ESP32-P4 是较新芯片，确保刷写工具版本支持 P4 芯片
5. 刷写过程中请勿断开 USB 连接
6. 注意：板载 ESP32-C6 协处理器有独立的刷写端子，刷写 P4 固件时无需操作 C6

## 进入下载模式

### 自动下载模式（推荐）
ESP-IDF 和新版本 esptool.py 支持 ESP32-P4 的自动下载，通过串口控制 RTS/DTR 信号自动进入下载模式，无需手动按键。

### 手动进入下载模式（自动模式失败时）
1. 按住 BOOT 按键
2. 按一下 RESET 按键
3. 松开 RESET 按键
4. 松开 BOOT 按键
5. 此时开发板进入固件下载模式

## 刷写方法

### 方法一：ESP-IDF（官方推荐）

1. 配置 ESP-IDF 环境，确保版本 ≥ v5.3.1
2. 设置目标芯片：
   ```bash
   idf.py set-target esp32p4
   ```
3. 配置项目（menuconfig）：
   - 根据屏幕参数配置 MIPI-DSI
   - 配置 Flash 大小为 32MB
4. 编译：
   ```bash
   idf.py build
   ```
5. 设置串口并刷写：
   ```bash
   idf.py -p PORT flash
   ```
6. 监视串口输出：
   ```bash
   idf.py -p PORT monitor
   ```

### 方法二：esptool.py 命令行刷写

参见 [06-firmware/flashing-tools/esptool.md](../../06-firmware/flashing-tools/esptool.md)

基本命令示例：
```bash
esptool.py --chip esp32p4 --port PORT write_flash -z 0x0 firmware.bin
```

注意：esptool.py 版本需支持 ESP32-P4（v4.7 或更高版本）。

### 方法三：ESP32-C6 协处理器刷写

板载 ESP32-C6 模组有独立的刷写端子：
1. 使用 USB 转串口模块连接 C6 UART 端子
2. C6 刷写方法与普通 ESP32-C6 开发板相同
3. 通常情况下无需单独刷写 C6 固件，出厂已预烧录

## 屏幕唤醒注意事项

ESP32-P4 的 MIPI-DSI 屏幕在复位后需要初始化序列才能正常显示。首次刷写自定义固件时，需注意：

1. 参考微雪官方 Demo 中的屏幕初始化代码
2. 确保在 app_main 中正确调用屏幕唤醒序列
3. 屏幕背光控制引脚 (GPIO23) 需正确配置
4. 如刷写后屏幕不亮，先检查背光是否开启，再检查屏幕初始化序列

## 出厂固件恢复

1. 从微雪官方Wiki资源页面下载出厂固件
2. 使用 esptool.py 擦除 Flash：
   ```bash
   esptool.py --chip esp32p4 --port PORT erase_flash
   ```
3. 按照官方提供的刷写地址写入固件（出厂固件通常是多个分区文件）

## 常见问题

### 无法识别串口
- 确认使用 USB TO UART 端口而非 USB 直连端口
- 安装 CH343/CP2102 等 USB 转串口驱动
- 更换 USB 数据线或 USB 端口
- 检查设备管理器中是否有未识别设备

### 刷写失败
- 确认 esptool.py 版本支持 ESP32-P4
- 尝试手动进入下载模式
- 降低刷写波特率（115200 或更低）
- 检查是否有其他程序占用串口

### 刷写后屏幕黑屏
- 检查屏幕背光是否使能（GPIO23）
- 确认屏幕初始化序列是否正确执行
- 通过串口日志确认系统是否正常启动
- 参考官方 Demo 检查 MIPI-DSI 配置参数

### 刷写后系统反复重启
- 检查 Flash 大小配置是否为 32MB
- 确认分区表配置与实际 Flash 大小匹配
- 检查电源供应是否稳定
- 检查是否有看门狗超时导致的复位

## 固件版本选择

AI-Guard 项目为 ESP32-P4 中控屏提供两个固件版本，面向不同使用场景。刷写前请根据需求选择对应版本。详细的版本差异与开发经验请参考 [firmware-versions.md](./firmware-versions.md)。

### 版本选择决策表

| 使用场景 | 推荐版本 | 理由 |
|----------|----------|------|
| 嵌入式 GUI 教学 / Dashboard 原理学习 | V0.5 | 代码独立、结构简单、易于阅读 |
| 仅需环境监测与告警展示，不需语音 | V0.5 | 资源占用低（app free 80%） |
| 需要语音交互（唤醒、聆听、TTS） | V1.0 | 接入小智完整语音链路 |
| 需要 OTA 远程升级 | V1.0 | 内置小智原生 OTA |
| 需要运行时 WiFi 配网（部署到多环境） | V1.0 | 支持 AP 配网 + 长按重配网 |
| 希望体验小智生态（技能、MCP、多模态） | V1.0 | 完整接入小智框架 |

### V0.5 固件刷写（适用于纯 Dashboard 教学）

**适用场景**：嵌入式 GUI 教学、Dashboard 原理验证、不需要语音交互的固定部署场景。

**前置条件**：
- 已安装 ESP-IDF v5.5.2（参见 [firmware-versions.md](./firmware-versions.md) 第 4 节）
- 已获取 V0.5 源码或预编译 bin

**方式一：源码编译刷写**

```bash
# 1. 进入 V0.5 项目目录
cd aiguard-panel-v0.5

# 2. 激活 ESP-IDF 环境
. $HOME/esp/esp-idf/export.sh

# 3. 设置目标芯片（首次）
idf.py set-target esp32p4

# 4. 配置项目（首次或修改配置时）
idf.py menuconfig
# 关键配置项：
#   - AI-Guard Configuration → 设备 token（必填，否则 HTTP 403）
#   - AI-Guard Configuration → 后端 API URL
#   - AI-Guard Configuration → WiFi SSID / 密码（编译时硬编码）
#   - Partition Table → 32MB Flash 分区表

# 5. 编译
idf.py build

# 6. 刷写并监视
idf.py -p PORT flash monitor
```

**方式二：预编译 bin 刷写**

```bash
# 1. 下载 V0.5 预编译固件（见下文"固件获取方式"）
# 2. 擦除 Flash（首次或切换版本时）
esptool.py --chip esp32p4 --port PORT erase_flash

# 3. 刷写
esptool.py --chip esp32p4 --port PORT write_flash -z 0x0 aiguard-panel-v0.5.bin
```

**V0.5 注意事项**：
- WiFi 凭据在 menuconfig 中编译时硬编码，刷写后无法运行时修改。换 WiFi 必须重新 menuconfig + 编译 + 刷写。
- 不支持 OTA，升级必须重新刷写。
- 不带 device token 会持续 HTTP 403，Dashboard 不显示数据。

### V1.0 固件刷写（适用于完整语音交互教学）

**适用场景**：需要语音交互、OTA 升级、运行时配网的产品化场景。

**前置条件**：
- 已安装 ESP-IDF v5.5.2
- 已克隆小智源码树（commit `e77dedb`）
- 已获取 AI-Guard overlay 包

**方式一：源码编译刷写（推荐）**

```bash
# 1. 准备小智源码树（首次）
git clone https://gitee.com/xiaozhi-esp32/xiaozhi-esp32.git
cd xiaozhi-esp32
git checkout e77dedb   # 必须精确到该 commit，否则 overlay 补丁可能失败

# 2. 执行 overlay 注入
bash ../aiguard-overlay/apply-overlay.sh .

# 3. 激活 ESP-IDF 环境
. $HOME/esp/esp-idf/export.sh

# 4. 设置目标芯片（首次）
idf.py set-target esp32p4

# 5. 配置项目（首次）
idf.py menuconfig
# 关键配置项：
#   - Xiaozhi Configuration → WiFi 配网模式选 AP（运行时配网）
#   - Xiaozhi Configuration → OTA URL（编译时硬编码）
#   - AI-Guard Configuration → 后端 API URL、设备 token
#   - Partition Table → 小智默认分区表（已含 OTA 分区）

# 6. 编译
idf.py build

# 7. 刷写并监视
idf.py -p PORT flash monitor
```

**方式二：预编译 bin 刷写**

```bash
# 1. 下载 V1.0 预编译固件（见下文"固件获取方式"）
# 2. 擦除 Flash（首次或从 V0.5 切换时必须）
esptool.py --chip esp32p4 --port PORT erase_flash

# 3. 刷写（V1.0 通常是多个分区文件，按官方提供的地址表写入）
esptool.py --chip esp32p4 --port PORT write_flash \
  -z 0x0 bootloader.bin \
  0x10000 aiguard-panel-v1.0.bin \
  0x8000 partition-table.bin
```

**V1.0 注意事项**：
- 从 V0.5 切换到 V1.0 必须 `erase_flash`，分区表不同会导致 V0.5 的 NVS 数据冲突。
- 首次启动需要进入 AP 配网模式（见下文）。
- app 分区仅剩 13%（~540KB），自定义资源（OGG、图片）需控制体积。
- OTA URL 编译时硬编码，换 OTA 服务器必须重新编译。

### 固件获取方式

两个版本的预编译固件均发布在 Gitee Release 页面：

- **仓库地址**：`https://gitee.com/aiguard/aiguard-panel-firmware/releases`
- **V0.5 下载**：Release `v0.5.0-panel-dashboard`（标签：`v0.5.0-panel-dashboard`）
- **V1.0 下载**：Release `v1.0.0-xiaozhi-overlay`（标签：`v1.0.0-xiaozhi-overlay`）

**SHA256 校验**（下载后务必校验，避免文件损坏导致刷写失败或设备异常）：

```bash
# macOS / Linux
shasum -a 256 aiguard-panel-v0.5.bin
# 期望输出（示例，实际值以 Release 页面公布为准）：
# <sha256-v0.5>  aiguard-panel-v0.5.bin

shasum -a 256 aiguard-panel-v1.0.bin
# 期望输出：
# <sha256-v1.0>  aiguard-panel-v1.0.bin
```

```bash
# Windows PowerShell
Get-FileHash aiguard-panel-v0.5.bin -Algorithm SHA256
Get-FileHash aiguard-panel-v1.0.bin -Algorithm SHA256
```

**校验失败处理**：
- 重新下载固件。
- 若多次下载校验均失败，到 Gitee 仓库 Issue 区反馈，可能是 Release 文件损坏。
- 不要尝试刷写校验失败的固件，可能导致设备变砖。

完整的 SHA256 值列表见各 Release 页面的 `checksums.txt` 附件，或参考 [06-firmware/checksums.txt](../../06-firmware/checksums.txt)。

### V1.0 配网流程详细说明

V1.0 固件采用小智原生 AP 配网模式，无需在编译时硬编码 WiFi 凭据，部署到不同 WiFi 环境无需重新编译。

#### 配网触发条件

设备在以下情况进入 AP 配网模式：
1. **首次启动**：NVS 中无 WiFi 凭据记录。
2. **长按 10 秒**：设备运行中长按物理按键（或屏幕指定区域）10 秒以上，强制进入重配网模式。
3. **WiFi 连接失败超时**：尝试连接已保存的 WiFi 多次失败后，自动回退到配网模式。

#### AP 配网步骤

1. **进入配网模式**
   - 设备屏幕显示配网提示（或串口日志输出 `AP mode started`）。
   - 设备开启热点，SSID 格式为 `Xiaozhi-XXXX`（XXXX 为设备 MAC 后 4 位）。

2. **手机 / 电脑连接热点**
   - 在手机或电脑的 WiFi 列表中找到 `Xiaozhi-XXXX` 热点。
   - 连接该热点（默认无密码，或密码为 `12345678`，具体见 Release 说明）。

3. **浏览器访问配网页面**
   - 打开浏览器，访问 `http://192.168.4.1`。
   - 页面加载后显示 WiFi 配置表单。

4. **填写 WiFi 信息**
   - 在表单中输入目标 WiFi 的 SSID 和密码。
   - 可选：填写后端 API URL、设备 token（若 menuconfig 中未硬编码）。
   - 点击"保存"或"配置"按钮提交。

5. **设备自动重启并连接**
   - 设备收到配置后保存到 NVS。
   - 设备重启，关闭 AP 热点，切换到 STA 模式连接目标 WiFi。
   - 串口日志输出 `WiFi connected, IP: x.x.x.x` 表示配网成功。

6. **验证配网成功**
   - 设备屏幕 Dashboard 开始显示数据（HTTP 轮询成功）。
   - 长按"小智"按钮可唤醒语音交互（验证网络与小智服务连通）。

#### 配网注意事项

- **热点不可见**：部分手机默认不显示"无互联网"的热点，需在 WiFi 设置中手动刷新或开启"显示无互联网网络"选项。
- **浏览器跳转**：连接热点后部分手机会自动弹出配网页面，若未弹出，手动访问 `http://192.168.4.1`。
- **HTTPS 不可用**：配网页面是 HTTP，不要尝试 `https://192.168.4.1`。
- **5GHz WiFi 不支持**：ESP32-C6 协处理器仅支持 2.4GHz，配置 5GHz WiFi 会连接失败。
- **企业级 WiFi 不支持**：802.1X / WPA-Enterprise 不被支持，仅支持 WPA2-PSK / WPA3-PSK。
- **配置后无法连接**：
  - 检查 SSID 大小写、密码字符。
  - 确认路由器未开启 AP 隔离 / MAC 过滤。
  - 信号强度不足时连接会失败，靠近路由器重试。
- **重配网**：长按 10 秒可随时进入配网模式，覆盖原配置。
- **配网期间无语音**：AP 模式下设备未连接外网，小智语音服务不可用，配网成功后才能使用。
