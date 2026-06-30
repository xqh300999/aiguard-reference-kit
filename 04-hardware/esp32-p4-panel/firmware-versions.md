# ESP32-P4 中控屏固件版本开发经验

本文档记录 AI-Guard 项目中 ESP32-P4-WIFI6-Touch-LCD-7B 中控屏两个固件版本的完整开发经验，包含关键技术决策、踩坑记录、调试修复过程与构建刷写命令。配套阅读：[README.md](./README.md)（硬件规格与版本概览）、[flashing-guide.md](./flashing-guide.md)（刷写流程）。

## 1. 概述

ESP32-P4 中控屏在 AI-Guard 项目中共经历两个里程碑版本：

| 版本 | 发布日期 | 定位 | 关键特征 |
|------|----------|------|----------|
| V0.5 | 2026-06-26 | 纯原生 Dashboard 固件 | 面向嵌入式 GUI 教学，无语音交互 |
| V1.0 | 2026-06-29 | 接入小智语音助手 | 完整语音链路 + Dashboard 前景 UI |

**两个版本的关系**：

- V0.5 是 V1.0 的原型探索阶段，验证了 ESP32-P4 + LVGL 9.x + Waveshare BSP 在 Dashboard 场景下的可行性，确立了告警评估优先级、HTTP 轮询节奏、UI 卡片布局等核心设计。
- V1.0 在 V0.5 基础上接入小智 xiaozhi-esp32 v2.2.4，将 Dashboard 从"独立应用"改造为"小智前景 UI"，同时引入语音交互、AP 配网、OTA 等完整产品化能力。
- V1.0 并非简单的功能叠加，而是基于小智源码树的 Overlay 注入式重构，对音频系统、LVGL 线程模型、字体加载、UI 刷新策略都做了根本性改造。

两者不存在"哪个更好"的简单结论：V0.5 适合教学演示与快速验证，V1.0 适合产品化落地。从 V0.5 升级到 V1.0 需要重新理解小智的架构约束（详见第 5 节）。

## 2. V0.5 开发经验

### 2.1 关键技术决策

#### 2.1.1 BSP display lock 防 WDT

**背景**：ESP32-P4 的 LVGL 渲染运行在独立任务中，主任务（HTTP 轮询、告警评估）若直接调用 `lv_obj_set_*` 等 LVGL API，会与渲染任务竞争访问 LVGL 对象树，触发 Task WDT 或导致内存损坏。

**决策**：所有 LVGL 访问必须包裹在 `bsp_display_lock(200)` / `bsp_display_unlock()` 之间，超时 200ms。

**实现要点**：
- 超时选 200ms 是经验值：太短会误报 lock 失败，太长会拖慢主任务。
- lock 持有时间应尽量短，避免在 lock 内执行 HTTP 请求、日志输出等耗时操作。
- 告警评估纯函数不访问 LVGL，应在 lock 外执行，仅把"刷新 UI"这一步放进 lock。

#### 2.1.2 Device Token 认证

**背景**：AI-Guard 后端 REST API 要求设备携带 device token 进行身份认证，否则返回 HTTP 403。

**决策**：
- device token 在 menuconfig 中编译时硬编码（`CONFIG_AIGUARD_DEVICE_TOKEN`）。
- HTTP 请求头添加 `Authorization: Bearer <token>`。
- token 不在运行时持久化，也不通过 NVS 存储，避免泄密风险。

**取舍**：编译时硬编码不支持运行时换 token，但对于教学场景足够；产品化场景应改为 NVS 存储或后端下发。

#### 2.1.3 中文字体子集生成

**背景**：LVGL 默认不带中文字体，完整 Source Han Sans SC 字体体积过大（~10MB）无法塞进 Flash。

**决策**：使用 `lv_font_conv` 工具按"使用到的字符集"生成子集，仅保留 Dashboard 实际显示的中文（约 200 字），生成 20px 和 24px 两个字号。

**生成流程**：
1. 扫描代码中所有 `lv_label_set_text` 调用，收集中文字符集合。
2. 将字符集合写入 `glyphs.txt`。
3. 调用 `lv_font_conv` 生成 C 文件：
   ```bash
   lv_font_conv --font SourceHanSansSC-Regular.otf \
     --size 24 \
     --bpp 4 \
     --format lvgl \
     --glyphs-file glyphs.txt \
     --output font_sc_24.c
   ```
4. 将生成的 `.c` 文件加入 CMake 编译列表。

**注意**：每次新增中文文案都要重新生成子集，否则会显示为方块。这是 V0.5 的已知痛点，V1.0 改为继承主题字体后此问题消失。

#### 2.1.4 UI 动作投递主循环防白屏

**背景**：HTTP 回调或告警评估直接修改 LVGL 对象，可能与渲染任务冲突导致白屏或花屏。

**决策**：引入 action queue 机制：
- 主循环每 100ms 轮询 action queue。
- 任何需要修改 UI 的逻辑都投递一个 action（lambda + 上下文数据）到 queue。
- 主循环取出 action 后在 `bsp_display_lock` 保护下执行。

**优势**：
- UI 修改永远在主任务中执行，避免多线程竞争。
- action queue 起到"防抖"作用，高频事件不会压垮 UI。

**代价**：100ms 的轮询粒度意味着 UI 刷新有最高 100ms 延迟。

### 2.2 常见坑点与解决方案

#### 2.2.1 Task WDT 触发

- **症状**：串口日志出现 `Task watchdog got triggered. The following tasks did not reset the watchdog in time`，系统重启。
- **原因**：
  - HTTP 请求在 `bsp_display_lock` 内执行，lock 持有时间过长。
  - 主循环 `while(true)` 没有 `vTaskDelay` 让出 CPU。
  - LVGL 渲染任务被频繁打断。
- **解决方案**：
  - HTTP 请求移出 lock 区，先拿数据再 lock 刷新 UI。
  - 主循环必须 `vTaskDelay(pdMS_TO_TICKS(100))`。
  - 检查 menuconfig 中 `CONFIG_ESP_TASK_WDT_TIMEOUT_S` 是否合理（建议 ≥ 5s）。

#### 2.2.2 HTTP 403 错误

- **症状**：所有 API 请求返回 403 Forbidden。
- **原因**：缺少 device token 或 token 错误。
- **排查步骤**：
  1. 用 `curl -H "Authorization: Bearer <token>" <url>` 验证后端是否接受该 token。
  2. 检查 menuconfig 中 `CONFIG_AIGUARD_DEVICE_TOKEN` 是否正确配置。
  3. 抓包确认请求头是否真的带上了 `Authorization`（有些 HTTP 客户端库会吞掉自定义头）。
- **解决方案**：正确配置 device token，并在 HTTP 客户端初始化时显式设置 `Authorization` 头。

#### 2.2.3 中文显示为方块

- **症状**：UI 上中文位置显示为 □ 或空白。
- **原因**：字体子集未包含该字符。
- **排查步骤**：
  1. 检查 `lv_label_set_text` 中的字符串。
  2. 对照 `glyphs.txt` 是否包含所有字符。
- **解决方案**：重新生成字体子集，加入遗漏的字符，重新编译。

#### 2.2.4 屏幕白屏

- **症状**：UI 完全不显示或显示为纯白 / 纯黑。
- **原因**：
  - 多任务并发访问 LVGL 对象树。
  - 显存不足导致渲染失败。
  - 屏幕初始化序列未正确执行。
- **排查步骤**：
  1. 串口日志确认 LVGL 初始化是否成功。
  2. 临时禁用 HTTP 轮询任务，看白屏是否消失（若是，则是并发问题）。
  3. 检查 `bsp_display_lock` 是否被正确使用。
- **解决方案**：所有 LVGL 访问走 action queue + display lock。

#### 2.2.5 告警确认无法抑制后续告警

- **症状**：用户点击"确认告警"后，告警音继续响，覆盖层不消失。
- **原因**：告警评估纯函数未读取"已确认"状态，下一轮轮询又重新触发告警。
- **解决方案**：
  - 在告警评估函数中增加 `acknowledged` 参数。
  - 用户点击确认后设置 `acknowledged = true`，直到告警状态变化才重置。
  - 评估函数在 `acknowledged == true` 时返回非告警状态。

### 2.3 构建与刷写命令

```bash
# 1. 进入项目目录
cd aiguard-panel-v0.5

# 2. 设置 ESP-IDF 环境（每次新终端都要执行）
. $HOME/esp/esp-idf/export.sh

# 3. 设置目标芯片
idf.py set-target esp32p4

# 4. 配置项目（首次或修改配置时）
idf.py menuconfig
#   - AI-Guard Configuration → 设备 token、后端 URL、WiFi SSID/密码
#   - Partition Table → 32MB Flash 分区表
#   - ESP32-P4 → MIPI-DSI 屏幕参数

# 5. 编译
idf.py build

# 6. 刷写并监视（PORT 替换为实际串口，如 /dev/cu.usbserial-XXXX）
idf.py -p PORT flash monitor

# 7. 退出 monitor：Ctrl + ]
```

**只刷写不监视**：
```bash
idf.py -p PORT flash
```

**擦除整片 Flash 后重新刷写**（配置变更或行为异常时使用）：
```bash
idf.py -p PORT erase-flash
idf.py -p PORT flash
```

## 3. V1.0 开发经验

### 3.1 Overlay 注入方案详解

#### 3.1.1 工作原理

V1.0 不采用 Fork 小智源码树的方式，而是采用 **Overlay 注入**：

```
xiaozhi-esp32/              ← 小智源码树（保持原样，不修改）
├── main/
├── components/
└── ...

aiguard-overlay/            ← AI-Guard 注入层
├── apply-overlay.sh        ← 注入脚本
├── main/aiguard_dashboard/ ← Dashboard 模块
├── components/aiguard_*    ← AI-Guard 自定义组件
└── patches/                ← 对小智源码的最小补丁
```

`apply-overlay.sh` 的工作流程：

1. **校验基线**：检查小智源码树的 git commit 是否为 `e77dedb`，避免基线漂移。
2. **复制文件**：将 `aiguard-overlay/` 下的目录结构复制到小智源码树对应位置（`main/`、`components/`）。
3. **应用补丁**：遍历 `patches/*.patch`，用 `git apply` 打到小智源码上。补丁都是最小侵入式，仅修改必要行。
4. **更新 CMakeLists**：将 AI-Guard 模块加入小智的 CMake 编译列表。
5. **生成配置**：根据 `aiguard-overlay/config/` 下的 Kfragment 合并到小智的 Kconfig。

#### 3.1.2 优势

- **小智源码保持原样**：升级小智版本时，只需 rebase overlay，不需要逐文件解决 merge 冲突。
- **改动可追溯**：所有 AI-Guard 改动都集中在 `aiguard-overlay/`，review 时一目了然。
- **回滚简单**：`git checkout .` 即可移除 overlay，恢复纯净小智。
- **不污染上游**：方便将来将 AI-Guard Dashboard 作为独立 PR 提交给小智社区。

#### 3.1.3 注意事项

- 补丁必须基于具体 commit 编写，小智升级后补丁可能失效，需要重新生成。
- overlay 复制是覆盖式，同名文件会被替换，命名时加 `aiguard_` 前缀避免冲突。
- 注入后必须跑契约测试（51 个）确认小智原有行为未被破坏。

### 3.2 关键技术决策

#### 3.2.1 ES8311 单 owner 原则

**背景**：V0.5 中告警音直接操作 ES8311 句柄；V1.0 中小智的 `BoxAudioCodec` 也需要独占 ES8311 做语音编解码。两个 owner 同时操作会导致 I2S 总线冲突。

**决策**：
- ES8311 的唯一 owner 是小智的 `BoxAudioCodec`。
- 告警音不再直接操作 ES8311，而是调用 `Application::PlaySound(OGG_SUCCESS / OGG_ALERT)`，由小智的音频管线统一播放。
- AI-Guard 自定义的告警音 OGG 文件通过 `assets` 机制注册到小智的音频资源表。

**收益**：彻底消除音频资源竞争，告警音与 TTS 自然排队播放。

#### 3.2.2 字体继承（nullptr 继承主题字体）

**背景**：V0.5 用字体子集，每次改文案都要重新生成；V1.0 中小智 `Assets::Apply()` 会 mmap 完整 CJK 字体到屏幕主题，所有 `lv_label` 默认继承主题字体。

**决策**：
- 所有 AI-Guard 的 `lv_label_create` 后，**不调用** `lv_obj_set_style_text_font(label, &my_font, 0)`。
- 让 `text_font` 保持 `nullptr`，自动继承 screen 主题字体（即小智 mmap 的完整 CJK 字体）。
- 字号通过 `lv_obj_set_style_text_font` 配合小智提供的预设字号（如 `font_medium`、`font_large`）控制。

**收益**：
- 任意中文文案都能显示，不再需要维护子集。
- 字体体积由小智统一管理，AI-Guard 不重复打包。
- 字号风格与小智原生 UI 一致。

#### 3.2.3 lvgl_port_lock 公共 C API

**背景**：小智的 LVGL 访问通过 `lvgl_port_lock(timeout_ms)` 保护，但该函数默认是 `static` 的内部 API。AI-Guard 的 C 代码（如告警评估回调）需要访问 LVGL。

**决策**：
- 在小智 `lvgl_port` 组件中暴露一个公共 C API：`lvgl_port_lock(uint32_t timeout_ms)` 与 `lvgl_port_unlock()`。
- 通过 overlay 补丁修改 `lvgl_port.h`，将函数声明从 `static` 改为 extern。
- AI-Guard 代码调用 `lvgl_port_lock(30000)`（30 秒超时，足够完成 UI 刷新）。

**为什么不用 `Application::Schedule()`**：
- `Schedule()` 适合"投递一个 C++ lambda 到主任务"，但 AI-Guard 部分逻辑是 C 代码，无法直接用 lambda。
- `lvgl_port_lock` 适合"当前任务短暂持有锁做少量 UI 修改"。
- 两者配合使用：复杂刷新用 `Schedule()`，简单字段更新用 `lvgl_port_lock`。

#### 3.2.4 ToggleChatState 触发语音交互

**背景**：用户点击 Dashboard 上的"小智"按钮，需要唤起小智语音交互。

**决策**：
- 按钮点击事件中调用小智的 `Application::GetInstance().ToggleChatState()`。
- 同时播放 `OGG_SUCCESS` 提示音给用户反馈。
- 小智内部会处理唤醒 → 聆听 → TTS 的完整链路，AI-Guard 不需要干预。

**注意**：`ToggleChatState` 是状态翻转，再次点击会结束当前对话。AI-Guard 的按钮文案要根据状态切换（"小智" / "结束"）。

#### 3.2.5 15 秒静音超时回待机

**背景**：用户唤起小智后若不说话，应自动回待机，避免一直处于聆听状态消耗资源。

**决策**：
- 监听小智的 `listening` 状态。
- 进入聆听后启动 15 秒定时器。
- 检测到音频能量低于阈值（静音）持续 15 秒，调用 `ToggleChatState` 结束对话。
- 定时器在用户开始说话后取消。

**参数调优**：15 秒是经验值，太短会误判用户思考时间，太长会浪费资源。

### 3.3 真机调试修复记录

以下为 V1.0 开发过程中在真机上遇到并修复的具体问题，按发现顺序排列。

#### 3.3.1 触摸坐标 180° 错位

- **症状**：点击屏幕左上角，响应出现在右下角；点击右下角，响应出现在左上角。整体如同旋转了 180°。
- **原因**：Waveshare ESP32-P4-7B 的 GT911 触控芯片物理安装方向与 LCD 面板相差 180°，出厂固件可能在 LCD 驱动中做了软件旋转，但小智 BSP 默认未做。
- **排查**：在触摸事件回调中打印 `(x, y)`，对比实际点击位置，确认是单纯的坐标翻转。
- **修复**：在 GT911 驱动的触摸数据读取处，将 `(x, y)` 替换为 `(screen_width - 1 - x, screen_height - 1 - y)`。补丁放在 `patches/0001-gt911-rotate-180.patch`。

#### 3.3.2 中文不显示

- **症状**：V1.0 早期所有中文标签显示为空白或方块。
- **原因**：直接复用了 V0.5 的字体子集代码（`lv_obj_set_style_text_font(label, &font_sc_24, 0)`），覆盖了小智主题字体；而字体子集在小智环境下未正确加载。
- **排查**：临时移除 `set_style_text_font` 调用，发现中文正常显示（继承主题字体）。
- **修复**：删除所有 AI-Guard 标签的 `set_style_text_font` 调用，统一用 `nullptr` 继承主题字体。字号通过小智预设的 `font_medium` / `font_large` 控制。

#### 3.3.3 屏幕几秒一重启

- **症状**：设备运行后，屏幕每隔几秒黑屏再亮，UI 反复重置。
- **原因**：V0.5 遗留的 10Hz UI 刷新策略（每 100ms 全量刷新所有卡片）在小智环境下与 LVGL 渲染任务冲突，触发看门狗或显存溢出，导致 LVGL 任务重启。
- **排查**：降低刷新频率到 1Hz，问题消失。
- **修复**：
  - UI 刷新改为 1Hz 定期刷新（每秒一次）。
  - 告警状态变化时立即触发一次刷新（事件驱动）。
  - action queue 仍保持 100ms 轮询，但 queue 中绝大多数时候是空的，实际刷新只在 1Hz 或告警变化时发生。

#### 3.3.4 SetTheme 空指针崩溃

- **症状**：调用 `lv_obj_set_style_*` 或 `lv_label_set_text` 时崩溃，backtrace 指向 `lv_obj` 内部。
- **原因**：基类 widget（如 screen 本身）在 `lv_obj_create` 后未正确初始化，`obj->spec_attr` 或 `obj->style_list` 为 `nullptr`，LVGL 内部解引用空指针。
- **排查**：在 crash 处加 `assert(obj != nullptr)` 与日志打印 `obj->spec_attr` 地址。
- **修复**：
  - 所有 widget 创建后立即检查返回值非空。
  - 调用 `lv_obj_set_style_*` 前加 `nullptr` 守护：`if (obj && obj->spec_attr) { ... }`。
  - 排查 `lv_obj_delete` 后仍被引用的悬垂指针（use-after-free 表现为同类 crash）。

#### 3.3.5 OGG 编码格式

- **症状**：把告警音 `.ogg` 文件扔进 assets，播放时无声。
- **原因**：OGG 是容器格式，内部编码可以是 Vorbis 或 OPUS。小智的音频解码器只认 OPUS，Vorbis 编码的 OGG 会被静默丢弃。
- **排查**：用 `ffprobe alarm.ogg` 查看内部编码，发现是 `vorbis`。
- **修复**：
  ```bash
  # 将 Vorbis OGG 转为 OPUS OGG
  ffmpeg -i alarm_vorbis.ogg -c:a libopus -b:a 32k alarm_opus.ogg
  ```
  替换 assets 中的文件后正常播放。AI-Guard 告警音（嘟嘟嘟 4 音，3 秒间隔重复）均采用 OPUS 编码。

#### 3.3.6 字号过大

- **症状**：某些标签文字溢出卡片边界，或顶栏文字被截断。
- **原因**：V0.5 用的 24px 字体在小智主题字体下视觉宽度更大（完整 CJK 字体度量与子集不同）。
- **排查**：对比 V0.5 与 V1.0 同一标签的渲染效果。
- **修复**：
  - 顶栏小字改为小智 `font_small`（约 16px）。
  - 卡片标题用 `font_medium`（约 20px）。
  - 数值用 `font_large`（约 28px）。
  - 告警覆盖层主文字用 `font_xlarge`（约 36px）。
  - 全部用小智预设字号，不再硬编码像素值。

#### 3.3.7 SOS 重复播放

- **症状**：SOS 触发后告警音连成一片，听不清"嘟嘟嘟"的节奏。
- **原因**：1Hz UI 刷新每次都检查到 SOS 状态为 true，重复调用 `PlaySound(OGG_ALERT)`，多个实例叠加播放。
- **排查**：在 `PlaySound` 调用处加日志，发现每秒触发一次。
- **修复**：
  - 引入 `alert_playing` 标志位。
  - `PlaySound` 前检查标志位，已在播放则跳过。
  - 监听小智音频管线的"播放结束"事件，重置标志位。
  - SOS 解除时主动停止播放并重置标志位。

#### 3.3.8 全双工打断

- **症状**：小智 TTS 播放中用户说话，无法打断 TTS。
- **原因**：固件侧已支持 realtime 模式（全双工），但服务器端 VAD 未开启，无法识别用户在 TTS 期间说话。
- **排查**：抓取上行音频流，确认麦克风数据正常上传；查看小智服务端日志，确认未触发打断。
- **修复**：本问题需服务端配合，固件侧已就绪。临时方案是用户先点"结束"按钮停止 TTS 再说话。后续服务端开启 VAD 后即可自然打断。

### 3.4 构建与刷写命令

```bash
# 1. 准备小智源码树（首次）
git clone https://gitee.com/xiaozhi-esp32/xiaozhi-esp32.git
cd xiaozhi-esp32
git checkout e77dedb   # V1.0 基线 commit

# 2. 复制 AI-Guard overlay 到与小智源码同级目录
cp -r /path/to/aiguard-overlay ../aiguard-overlay

# 3. 执行 overlay 注入
cd ..
bash aiguard-overlay/apply-overlay.sh xiaozhi-esp32

# 4. 进入注入后的小智源码树
cd xiaozhi-esp32

# 5. 设置 ESP-IDF 环境
. $HOME/esp/esp-idf/export.sh

# 6. 设置目标芯片
idf.py set-target esp32p4

# 7. 配置项目（首次）
idf.py menuconfig
#   - Xiaozhi Configuration → WiFi 配网模式选 AP、OTA URL、设备 token
#   - AI-Guard Configuration → 后端 API URL、告警参数
#   - Partition Table → 小智默认分区表（已含 OTA 分区）

# 8. 编译
idf.py build

# 9. 刷写并监视
idf.py -p PORT flash monitor
```

**重新注入（overlay 改动后）**：
```bash
cd xiaozhi-esp32
git checkout .          # 清除上次 overlay
git clean -fd           # 清除未跟踪文件
bash ../aiguard-overlay/apply-overlay.sh .
idf.py build
```

**契约测试**：
```bash
# 在 overlay 目录下
cd aiguard-overlay
pytest tests/ -v        # 应输出 51 passed
```

## 4. 开发环境要求

### 4.1 ESP-IDF v5.5.2 安装

V0.5 与 V1.0 均基于 ESP-IDF v5.5.2（V0.5 文档中提到的 v5.3.1 是最低要求，实际开发用 v5.5.2）。

```bash
# 1. 克隆 ESP-IDF
mkdir -p ~/esp && cd ~/esp
git clone -b v5.5.2 --recursive https://github.com/espressif/esp-idf.git

# 2. 安装工具链
cd ~/esp/esp-idf
./install.sh esp32p4

# 3. 每次新终端激活环境
. ~/esp/esp-idf/export.sh

# 4. 验证
idf.py --version    # 应输出 v5.5.2
```

**注意事项**：
- ESP-IDF v5.5.2 必须完整克隆 submodule（`--recursive`），否则编译报错。
- macOS 上若 `pip` 安装失败，尝试 `python3 -m pip install --user -r requirements.txt`。
- 工具链默认装在 `~/.espressif/`，空间约 1.5GB。

### 4.2 Python 依赖

以下工具用于构建、测试、资源生成：

```bash
# 基础
pip install pytest pytest-cov

# 字体子集生成（V0.5 用，V1.0 不需要）
pip install lv_font_conv    # 或用 npx lv_font_conv

# SVG 转 PNG（Lucide 图标渲染）
brew install librsvg        # 提供 rsvg-convert
# 或 apt install librsvg2-bin

# 图像处理
pip install Pillow

# OGG 音频编码（V1.0 告警音生成）
brew install ffmpeg
# 或 apt install ffmpeg
```

**版本要求**：
- pytest ≥ 7.0
- Pillow ≥ 9.0
- ffmpeg ≥ 5.0（必须含 `libopus` 编码器）

**验证**：
```bash
pytest --version
rsvg-convert --version
python -c "import PIL; print(PIL.__version__)"
ffmpeg -version | grep libopus    # 必须包含 --enable-libopus
lv_font_conv --version
```

## 5. 从 V0.5 升级到 V1.0 的路径建议

V0.5 与 V1.0 是两套不同的代码组织方式，不存在"原地升级"的简单路径。建议按以下步骤迁移：

### 5.1 评估是否需要升级

**保持 V0.5 的场景**：
- 仅做嵌入式 GUI 教学，不需要语音交互。
- Flash 空间紧张（V1.0 app 占用 87%，剩余仅 13%）。
- 不需要 OTA、不需要运行时配网。

**升级到 V1.0 的场景**：
- 需要语音交互作为核心能力。
- 需要 OTA 远程升级。
- 需要运行时配网（部署到不同 WiFi 环境）。
- 希望接入小智生态（技能、MCP、多模态）。

### 5.2 迁移步骤

1. **建立小智源码树基线**
   ```bash
   git clone https://gitee.com/xiaozhi-esp32/xiaozhi-esp32.git
   git checkout e77dedb
   ```
   确认 commit hash 与 V1.0 基线一致。

2. **抽取 V0.5 的业务逻辑**
   - 告警评估纯函数（与 LVGL 无关的部分）直接复用。
   - HTTP API 客户端封装重写：从 `esp_http_client` 改为小智 `Network::CreateHttp()`。
   - 数据模型（温湿度、烟感、气感、门磁）直接复用。

3. **重构 UI 层**
   - 删除所有 `lv_obj_set_style_text_font` 调用，改用 `nullptr` 继承主题字体。
   - 字号改用小智预设（`font_small` / `font_medium` / `font_large` / `font_xlarge`）。
   - UI 刷新策略从 10Hz 改为 1Hz + 事件驱动。
   - LVGL 线程安全从 `bsp_display_lock(200)` 改为 `lvgl_port_lock(30000)` 或 `Application::Schedule()`。

4. **改造音频系统**
   - 删除直接操作 ES8311 的代码。
   - 告警音从 1200Hz 正弦波改为 OPUS 编码 OGG 文件。
   - 通过 `Application::PlaySound()` 播放，注册到小智 assets。

5. **接入小智交互**
   - "小智"按钮调用 `ToggleChatState`。
   - 实现 15 秒静音超时回待机。
   - BottomDock 接入小智对话状态（Twemoji 表情 + 状态 + 滚动文本）。

6. **配网与 OTA**
   - WiFi 配网改用小智 AP 模式（`Xiaozhi-XXXX` 热点 + 浏览器 `192.168.4.1`）。
   - OTA URL 配置到 menuconfig，使用小智原生 OTA 流程。

7. **跑契约测试**
   ```bash
   pytest tests/ -v
   ```
   51 个测试全部通过才算迁移完成。

8. **真机验证清单**
   - [ ] 启动无 crash、无 WDT
   - [ ] WiFi AP 配网成功
   - [ ] 语音唤醒、聆听、TTS 正常
   - [ ] Dashboard 数据轮询正常
   - [ ] 告警音正常播放（OPUS OGG）
   - [ ] 触摸坐标正确（无 180° 错位）
   - [ ] 中文显示正常
   - [ ] 屏幕不重启
   - [ ] OTA 升级流程跑通

### 5.3 不建议的做法

- **不要**直接 Fork 小智源码树然后大改：升级小智版本时 merge 冲突会非常痛苦。用 overlay 注入。
- **不要**保留 V0.5 的字体子集：在小智环境下会覆盖主题字体导致中文不显示。
- **不要**保留 V0.5 的 10Hz 刷新：在小智环境下会触发 LVGL 任务重启。
- **不要**直接操作 ES8311：会与小智音频管线冲突。
- **不要**用 Vorbis 编码的 OGG：小智解码器只认 OPUS。

---

配套文档：
- [README.md](./README.md)：硬件规格与固件版本概览
- [flashing-guide.md](./flashing-guide.md)：刷写流程与固件版本选择
- [../../07-troubleshooting/hardware.md](../../07-troubleshooting/hardware.md)：ESP32-P4 中控屏已知问题排查
