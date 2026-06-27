# 后端技术栈

AIguard 后端采用 Java 17 + Spring Boot 3 + openGauss 构建，通过 MQTT 和 WebSocket 与前端和设备通信。

## 目录

- [Java 17](java-17.md) - JDK 17 新特性与核心概念
- [Spring Boot 3](spring-boot-3.md) - 快速入门、REST API、安全、数据访问
- [openGauss](opengauss.md) - 开源关系型数据库介绍与使用
- [MQTT](mqtt.md) - 消息队列遥测传输协议
- [WebSocket](websocket.md) - 全双工通信协议与 Spring 集成
- [官方链接](official-links.md) - 所有后端技术官方文档链接

## 技术栈概览

| 层级 | 技术 | 版本 | 用途 |
|------|------|------|------|
| 语言 | Java | 17 LTS | 主要开发语言 |
| 框架 | Spring Boot | 3.x | 应用框架 |
| 数据库 | openGauss | 5.x / 3.x LTS | 关系型数据存储 |
| 消息协议 | MQTT | 3.1.1 / 5.0 | 设备通信 |
| 实时通信 | WebSocket | RFC 6455 | 前端实时推送 |
| 构建工具 | Maven / Gradle | 3.9+ / 8.x | 项目构建与依赖管理 |

## 快速参考

```bash
# 检查 Java 版本
java -version
# openjdk version "17.0.x"

# 创建 Spring Boot 项目（使用 start.spring.io）
curl https://start.spring.io/starter.zip -d dependencies=web,data-jpa,security,websocket,amqp \
  -d type=maven-project -d baseDir=aiguard-backend -o aiguard-backend.zip

# 常用 Maven 命令
./mvnw spring-boot:run          # 运行应用
./mvnw clean package            # 打包
./mvnw test                     # 运行测试
```

## 常见坑点

1. Spring Boot 3 要求最低 JDK 17，不支持 JDK 8/11
2. openGauss 基于 PostgreSQL 开发，但部分语法和驱动存在差异
3. MQTT 客户端依赖 Eclipse Paho 或 Spring Integration，注意版本兼容性
4. WebSocket 需处理跨域和连接断开重连问题
5. JDK 17 强封装内部 API，部分旧库可能需要添加 `--add-opens` 参数

## 官方链接

详见 [official-links.md](official-links.md)。
