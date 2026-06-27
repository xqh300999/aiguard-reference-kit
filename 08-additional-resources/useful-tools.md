# 推荐开发工具

本文档推荐项目开发过程中常用的工具，涵盖IDE、代码编辑器、调试工具、串口工具、网络工具等。

---

## 一、IDE与代码编辑器

### Python/后端开发

- **PyCharm** (推荐)
  - 说明：JetBrains出品的Python IDE，功能强大，智能补全、调试、Git集成完善
  - 版本：有免费社区版和付费专业版，社区版足够日常开发使用
  - 平台：Windows/macOS/Linux
  - 官网：https://www.jetbrains.com/pycharm/

- **Visual Studio Code** (推荐)
  - 说明：微软出品的轻量级但可扩展性强的编辑器，通过插件支持几乎所有语言
  - 平台：Windows/macOS/Linux
  - 官网：https://code.visualstudio.com/
  - 推荐插件：Python、Pylance、autoDocstring、Python Type Hint

### Web/前端开发

- **Visual Studio Code** (推荐)
  - 推荐插件：Volar (Vue3)、ESLint、Prettier、TypeScript Vue Plugin (Volar)、Debugger for Chrome
  - 其他可选插件：Auto Close Tag、Auto Rename Tag、Path Intellisense

- **WebStorm**
  - 说明：JetBrains出品的前端IDE，开箱即用，功能完善
  - 官网：https://www.jetbrains.com/webstorm/

### HarmonyOS开发

- **DevEco Studio** (必须)
  - 说明：华为官方HarmonyOS应用开发IDE，基于IntelliJ IDEA
  - 官网：https://developer.harmonyos.com/cn/develop/deveco-studio
  - 注意：必须使用对应版本的DevEco Studio和SDK

### 通用编辑器

- **Sublime Text**：轻量快速，适合快速查看/编辑文件
- **Vim/Neovim**：命令行编辑器，适合在服务器上编辑文件
- **Notepad++** (Windows)：免费轻量，适合快速查看各种文件

---

## 二、版本管理工具

- **Git** (必须)
  - 说明：分布式版本控制系统
  - 官网：https://git-scm.com/
  - 图形化客户端可选：
    - SourceTree (免费)
    - GitKraken (有免费版)
    - IDE内置Git工具（推荐日常使用）

- **GitHub Desktop**
  - 说明：GitHub官方的简单Git客户端，适合新手
  - 官网：https://desktop.github.com/

---

## 三、串口与硬件调试工具

### 串口调试工具

- **串口调试助手** 通用选择：
  - **Windows**：
    - SSCOM（推荐，简单好用）
    - SecureCRT（功能强大，付费）
    - PuTTY（免费经典）
    - Tera Term（开源免费）
  - **macOS**：
    - CoolTerm（推荐，免费跨平台）
    - Serial（付费但好用）
    - screen/minicom（命令行工具）
  - **Linux**：
    - minicom
    - screen
    - gtkterm（图形化）
    - picocom（轻量命令行）

- **通用跨平台推荐**：
  - **PuTTY**：经典免费，支持SSH/串口
  - **MobaXterm** (Windows)：集成SSH、串口、FTP等多种功能
  - **Tabby** (原Terminus)：现代终端模拟器，跨平台，支持SSH/串口

### 烧录工具

- **ESP32/ESP8266**：
  - **esptool.py** (必须)：乐鑫官方命令行烧录工具
  - **Flash Download Tools** (Windows)：乐鑫官方图形化烧录工具
  - **ESP Web Flasher**：网页版烧录工具，无需安装

- **通用**：
  - **balenaEtcher**：跨平台镜像烧录工具，适合烧写SD卡/USB镜像
  - **Raspberry Pi Imager**：树莓派官方镜像烧录工具

### 硬件调试与测量

- **万用表** (必备基础工具)
  - 用途：测量电压、电流、电阻、通断等
  - 建议选择自动量程、带蜂鸣器通断档的数字万用表

- **逻辑分析仪** (推荐调试通信协议)
  - 用途：抓取I2C/SPI/UART等数字信号，分析通信协议
  - 推荐：DreamSourceLab DSLogic、Saleae Logic（有开源兼容版）
  - 软件：PulseView（开源sigrok）、KingstVIS

- **示波器** (进阶可选)
  - 用途：观察模拟信号波形，调试信号完整性、电源纹波等
  - 如果只是入门学习，低带宽的入门级示波器即可

---

## 四、网络调试工具

### API测试工具

- **Postman** (推荐)
  - 说明：功能强大的API调试工具，支持保存请求、集合、环境变量等
  - 官网：https://www.postman.com/
  - 免费版足够日常使用

- **curl** (必须掌握)
  - 说明：命令行HTTP客户端，所有开发平台都可用
  - 优势：快速测试、可脚本化、方便分享请求
  - 提示：浏览器开发者工具可以直接把请求复制为curl命令

- **Apifox**
  - 说明：国产API工具，集文档、调试、Mock、测试于一体
  - 官网：https://www.apifox.com/

- **HTTPie**
  - 说明：更友好的命令行HTTP客户端，比curl更易用
  - 官网：https://httpie.io/

### WebSocket测试工具

- **wscat**
  - 说明：命令行WebSocket客户端，基于Node.js
  - 安装：`npm install -g wscat`

- **websocat**
  - 说明：功能强大的命令行WebSocket工具，类似netcat for WebSocket
  - 项目地址：https://github.com/vi/websocat

- **WebSocket King** (浏览器插件/客户端)
  - 说明：图形化WebSocket测试工具，支持发送/接收消息

- 浏览器开发者工具：Network标签→WS，可以直接调试WebSocket

### MQTT调试工具

- **MQTTX** (推荐)
  - 说明：EMQ出品的跨平台MQTT客户端，图形化界面，功能完善
  - 官网：https://mqttx.app/

- **mosquitto_clients**
  - 说明：mosquitto自带的命令行工具，包括mosquitto_pub和mosquitto_sub
  - 安装：macOS `brew install mosquitto`，Ubuntu `apt install mosquitto-clients`

- **MQTT Explorer**
  - 说明：可视化MQTT客户端，方便查看主题结构
  - 官网：http://mqtt-explorer.com/

### 网络抓包与分析

- **Wireshark** (推荐)
  - 说明：最经典的网络抓包分析工具，支持几乎所有协议
  - 官网：https://www.wireshark.org/
  - 提示：可以学习使用过滤器快速定位感兴趣的数据包

- **tcpdump**
  - 说明：命令行抓包工具，适合在服务器上使用
  - 抓包结果可以保存后用Wireshark打开分析

- **Fiddler** / **Charles**
  - 说明：HTTP/HTTPS抓包代理工具，适合分析Web请求、移动端App网络请求

### 局域网扫描与端口检测

- **Advanced IP Scanner** (Windows)
  - 说明：快速扫描局域网内的设备IP和MAC地址
  - 官网：https://www.advanced-ip-scanner.com/

- **nmap** (推荐学习使用)
  - 说明：强大的网络扫描和安全审计工具，跨平台
  - 官网：https://nmap.org/
  - 常用命令：`nmap -sn 192.168.1.0/24` 扫描网段存活主机

- **Angry IP Scanner**
  - 说明：跨平台开源IP扫描工具
  - 官网：https://angryip.org/

- **netcat (nc)**
  - 说明：网络工具中的"瑞士军刀"，可以测试端口连通性、发送TCP/UDP数据
  - 常用：`nc -zv IP 端口` 测试端口是否开放

---

## 五、数据库工具

- **DBeaver Community** (推荐)
  - 说明：免费开源的通用数据库工具，支持几乎所有数据库（SQLite/MySQL/PostgreSQL等）
  - 官网：https://dbeaver.io/

- **Navicat**
  - 说明：功能强大的数据库GUI工具，付费但好用
  - 也可以使用免费的Navicat Premium Lite版本

- **DB Browser for SQLite**
  - 说明：专门用于SQLite数据库的轻量GUI工具
  - 官网：https://sqlitebrowser.org/

- **命令行客户端**
  - sqlite3：SQLite自带命令行
  - mysql：MySQL命令行客户端
  - psql：PostgreSQL命令行客户端

---

## 六、其他实用工具

### API接口模拟与Mock

- **Mock.js**：前端Mock数据生成库
- **json-server**：快速搭建REST API Mock服务器
- **Postman Mock Server**：Postman内置的Mock功能

### 格式化与校验

- **JSON**：浏览器控制台、Postman、jq（命令行JSON处理工具）
- **在线工具**：可以搜索JSON格式化、YAML格式化、Base64编解码等在线工具
- **jq**：命令行JSON处理神器，适合处理接口返回数据

### 终端与Shell增强

- **Windows Terminal** (Windows)：微软新一代终端，支持多标签
- **iTerm2** (macOS)：macOS下最好用的终端替代品
- **Oh My Zsh**：zsh配置框架，提供丰富的插件和主题
- **Starship**：跨平台的漂亮Shell提示符

### 笔记与文档

- **Typora**：Markdown编辑器，所见即所得
- **Obsidian**：知识库型Markdown笔记工具，支持双向链接
- **Notion**：全能笔记/项目管理工具
- **Draw.io / diagrams.net**：免费开源绘图工具，可以画流程图、架构图、电路图

### 文件比较与合并

- **Beyond Compare**：功能强大的文件/文件夹比较工具
- **WinMerge** (Windows)：免费开源的文件比较工具
- IDE内置的Diff工具（日常使用足够）
- **Meld**：跨平台开源可视化diff/merge工具

---

## 工具选择建议

1. **不要贪多**：先熟练掌握核心必备工具（Git、一个IDE、curl、串口工具、浏览器DevTools），其他工具根据需要逐步添加
2. **优先跨平台**：选择跨平台工具，在不同操作系统下能保持一致的使用习惯
3. **免费开源优先**：学习阶段优先选择免费或开源工具
4. **效率优先**：工具是为了提高效率，不要花太多时间折腾工具配置而忽略了开发本身
5. **学习命令行**：虽然图形化工具直观，但命令行工具在自动化、远程操作、脚本化方面有不可替代的优势，建议掌握常用的命令行工具
