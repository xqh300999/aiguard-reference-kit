# 故障排查流程图

本文件定义故障排查的标准引导流程，供Skill按步骤引导学生自主排查问题。

## 排查总原则

**从下往上，逐层排查**：环境 → 网络 → 后端 → 前端 → 硬件

每一层排查后，先确认问题是否解决，如果没解决再进入下一层。

---

## 第一层：环境问题排查

**文档参考**：`07-troubleshooting/environment.md`

### 检查清单

1. **依赖版本检查**
   - 问题：你用的JDK版本是多少？是不是17+？
   - 检查命令：`java -version`
   - 期望：openjdk version "17.x.x" 或更高

2. **Node.js版本检查**
   - 问题：Node.js版本是不是20+？
   - 检查命令：`node --version`
   - 期望：v20.x.x 或更高

3. **Python版本检查**
   - 问题：Python版本是不是3.10+？
   - 检查命令：`python3 --version`
   - 期望：Python 3.10.x 或更高

4. **Docker是否运行**
   - 问题：Docker Desktop（或Docker Engine）是否已启动？
   - 检查命令：`docker ps`
   - 期望：能正常列出容器（或只有表头）

5. **路径问题**
   - 问题：项目路径是否包含空格或中文？
   - 注意：DevEco Studio和ESP-IDF要求路径不含空格

### 引导话术

> 我们先从开发环境开始排查。请你先依次运行以下命令，把结果告诉我：
> ```bash
> java -version
> node --version
> python3 --version
> docker ps
> ```
> 我们先确认基础依赖都正常。

---

## 第二层：网络问题排查

**文档参考**：`07-troubleshooting/network.md`

### 检查清单

1. **端口占用检查**
   - 常见端口：8080(后端)、5173(大屏)、1883(MQTT)、5432(数据库)、18080(网关)
   - 检查命令：`lsof -nP -iTCP:<端口号> -sTCP:LISTEN`
   - 期望：要么是我们的服务在监听，要么端口空闲

2. **服务连通性**
   - 后端健康检查：`curl http://127.0.0.1:8080/actuator/health`
   - 网关健康检查：`curl http://127.0.0.1:18080/actuator/health`
   - 期望：返回 `{"status":"UP"}`

3. **防火墙检查**
   - 问题：设备连接不上时，检查本机防火墙是否阻止了对应端口
   - 注意：局域网设备访问需要确认本机局域网IP

4. **IP地址确认**
   - 检查命令：`ifconfig` 或 `ip addr`
   - 确认：设备配置的IP地址是不是当前电脑的局域网IP

### 引导话术

> 环境没问题的话，我们来检查网络和端口。请你先运行：
> ```bash
> curl -s http://127.0.0.1:8080/actuator/health
> echo "---"
> lsof -nP -iTCP:8080 -sTCP:LISTEN
> ```
> 看看后端服务是否正常启动在8080端口。

---

## 第三层：后端问题排查

**文档参考**：`07-troubleshooting/backend.md`

### 检查清单

1. **Docker容器状态**
   - 检查命令：`docker ps --format '{{.Names}}\t{{.Status}}'`
   - 期望：aiguard-opengauss、aiguard-mqtt等容器状态为Up

2. **数据库连接**
   - 常见错误：Connection refused to localhost:5432/5433
   - 排查：确认opengauss容器已启动且健康检查通过

3. **HA Token配置**
   - 问题：`.env`文件中`HA_TOKEN`是否正确配置？
   - 检查：HA实时数据是否刷新？接口返回`haConfigured=true`？

4. **后端日志查看**
   - 检查方式：`screen -r aiguard-backend` 查看日志（Ctrl+A D退出）
   - 关注：ERROR级别日志、异常栈信息

### 引导话术

> 网络没问题的话，我们看看后端服务。请先执行：
> ```bash
> docker ps --format '{{.Names}}\t{{.Status}}' | grep -E 'aiguard|mcp'
> ```
> 告诉我哪些容器在运行，状态是什么？

---

## 第四层：前端问题排查

**文档参考**：`07-troubleshooting/frontend.md`

### 检查清单

1. **依赖安装**
   - 问题：web-dashboard目录下是否执行过`npm install`？
   - 检查：是否存在`node_modules`目录

2. **VITE_API_BASE配置**
   - 问题：启动大屏时是否带了`VITE_API_BASE=http://127.0.0.1:8080`？
   - 常见错误：跨域、404都是因为API地址配置不对

3. **鸿蒙应用编译**
   - 问题：DevEco Studio是否同步完成？
   - 检查：ohpm install是否成功？hvigor是否有报错？

4. **浏览器控制台**
   - 问题：按F12打开控制台，有没有红色错误？
   - 关注：Network标签下接口请求的状态码

### 引导话术

> 后端没问题的话，我们看看前端。
> 如果是大屏问题，请先确认你启动命令是：
> ```bash
> VITE_API_BASE=http://127.0.0.1:8080 npm run dev
> ```
> 然后打开浏览器F12控制台，看看有没有红色错误信息？

---

## 第五层：硬件问题排查

**文档参考**：`07-troubleshooting/hardware.md`

### 检查清单

1. **固件版本**
   - 问题：设备刷的固件版本是否正确？v2.2.4？
   - 校验：固件SHA256是否和checksums.txt一致？

2. **OTA地址配置**
   - 问题：设备的OTA地址是否配置为`http://<电脑IP>:18080/xiaozhi/ota/`？
   - 注意：不能用127.0.0.1，要用局域网IP

3. **USB驱动**
   - 问题：电脑是否识别到设备的串口？
   - 检查：Windows设备管理器、macOS的`ls /dev/cu.*`

4. **WiFi配置**
   - 问题：设备连接的WiFi和电脑是不是同一个局域网？
   - 注意：不能用访客WiFi或隔离AP

### 引导话术

> 如果软件层面都没问题，我们来看看硬件。
> 先确认一下：
> 1. 设备刷的是哪个版本固件？
> 2. OTA地址配置的是什么IP？
> 3. 电脑能ping通设备吗？
> 4. MQTT连接日志有没有报错？

---

## 常见问题快速索引

如果学生描述的问题很明确，可以直接跳转到对应排查点：

| 问题现象 | 优先排查 |
|---------|---------|
| `localhost:5433 refused` | 第二层：Docker容器→opengauss是否启动 |
| 小智token解密失败 | 第三层：重启xiaozhi-server重新生成token |
| 工具连接数为0 | 第三层：重启aiguard-mcp-tool |
| HA数据不刷新 | 第三层：检查HA_TOKEN；重启后端 |
| 大屏404/跨域 | 第四层：确认VITE_API_BASE配置 |
| 端口被占用 | 第二层：lsof查找占用进程 |
| 刷固件失败 | 第五层：驱动安装、进入下载模式方法 |
| 设备连不上服务器 | 第二层：防火墙；第五层：OTA地址、WiFi网段 |
