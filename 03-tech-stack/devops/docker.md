# Docker

Docker 是容器化平台，用于打包、分发和运行应用，实现环境一致性和快速部署。

## 快速参考

### Docker 安装（树莓派 ARM64）

```bash
# 方法一：官方一键安装脚本
curl -fsSL https://get.docker.com | sh

# 启动并设置开机自启
sudo systemctl enable docker
sudo systemctl start docker

# 将当前用户加入 docker 组（免 sudo）
sudo usermod -aG docker $USER
newgrp docker

# 验证安装
docker --version
docker run hello-world
```

```bash
# 方法二：apt 安装
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**配置国内镜像加速：**
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Docker 常用命令

```bash
# 镜像操作
docker images                          # 列出本地镜像
docker pull <image>                    # 拉取镜像
docker rmi <image>                     # 删除镜像
docker build -t myapp:latest .         # 构建镜像

# 容器操作
docker ps                              # 列出运行中容器
docker ps -a                           # 列出所有容器
docker run -d --name myapp -p 8080:8080 myapp  # 启动容器
docker start/stop/restart <container>  # 启动/停止/重启容器
docker rm <container>                  # 删除容器
docker logs -f <container>             # 查看日志
docker exec -it <container> bash       # 进入容器
docker inspect <container>             # 查看容器详情

# 系统维护
docker system df                       # 查看磁盘使用
docker system prune -a                 # 清理无用镜像/容器
docker volume ls                       # 列出数据卷
docker network ls                      # 列出网络
```

### Dockerfile 编写（Spring Boot 示例）

**多阶段构建（推荐，减小镜像体积）：**
```dockerfile
# 构建阶段
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

# 运行阶段
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# 环境变量
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**Dockerfile 编写 Vue 前端：**
```dockerfile
# 构建阶段
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com
RUN npm ci
COPY . .
RUN npm run build

# 运行阶段（Nginx）
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose

AIguard 完整服务栈 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  # MQTT Broker
  mosquitto:
    image: eclipse-mosquitto:2
    container_name: aiguard-mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/log:/mosquitto/log
    environment:
      - TZ=Asia/Shanghai

  # openGauss 数据库（或使用 PostgreSQL 兼容替代）
  database:
    image: postgres:15-alpine
    container_name: aiguard-db
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: aiguard
      POSTGRES_USER: aiguard
      POSTGRES_PASSWORD: Aiguard@123
      TZ: Asia/Shanghai
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aiguard"]
      interval: 10s
      timeout: 5s
      retries: 5

  # 后端服务
  backend:
    build:
      context: ./aiguard-backend
      dockerfile: Dockerfile
    container_name: aiguard-backend
    restart: unless-stopped
    ports:
      - "8080:8080"
    depends_on:
      database:
        condition: service_healthy
      mosquitto:
        condition: service_started
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:postgresql://database:5432/aiguard
      SPRING_DATASOURCE_USERNAME: aiguard
      SPRING_DATASOURCE_PASSWORD: Aiguard@123
      SPRING_MQTT_BROKER_URL: tcp://mosquitto:1883
      QWEN_API_KEY: ${QWEN_API_KEY}
      TZ: Asia/Shanghai
    volumes:
      - ./backend-logs:/app/logs

  # 前端（Nginx）
  frontend:
    build:
      context: ./aiguard-admin
      dockerfile: Dockerfile
    container_name: aiguard-frontend
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend

  # Home Assistant（可选）
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: aiguard-ha
    restart: unless-stopped
    network_mode: host
    privileged: true
    volumes:
      - ./homeassistant:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      TZ: Asia/Shanghai

volumes:
  pgdata:
```

**常用 Compose 命令：**
```bash
docker compose up -d                 # 后台启动所有服务
docker compose up -d backend         # 只启动后端
docker compose down                  # 停止并删除容器
docker compose down -v               # 停止并删除数据卷（谨慎！）
docker compose ps                    # 查看服务状态
docker compose logs -f backend       # 查看后端日志
docker compose pull                  # 拉取最新镜像
docker compose build                 # 重新构建镜像
docker compose restart backend       # 重启后端服务
docker compose exec backend bash     # 进入后端容器
```

### 镜像架构说明

| 架构 | 树莓派 | 常见标识 |
|------|--------|----------|
| x86_64/amd64 | 否 | linux/amd64 |
| arm64/aarch64 | 是（树莓派3/4/5） | linux/arm64/v8 |
| armv7/armhf | 树莓派2/部分32位系统 | linux/arm/v7 |

**树莓派必须使用 arm64 镜像**，官方镜像大多支持多架构（multi-arch），拉取时自动选择对应架构。

可用 `docker buildx` 构建多架构镜像：
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t myrepo/aiguard:latest --push .
```

### 数据持久化

Docker 容器数据在容器删除后丢失，需使用 Volume 或 Bind Mount：

```yaml
# Named Volume（推荐，Docker管理）
volumes:
  pgdata:
services:
  db:
    volumes:
      - pgdata:/var/lib/postgresql/data

# Bind Mount（绑定挂载，方便直接访问）
services:
  mosquitto:
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
```

## 常见坑点

1. **树莓派 ARM64 镜像问题**
   - 部分 Docker Hub 镜像仅提供 x86_64 版本，ARM 无法运行
   - 运行前确认镜像支持 arm64：在 Docker Hub 查看 Tags
   - openGauss 官方镜像 x86 为主，开发阶段可用 PostgreSQL 替代
   - 搜索镜像时可添加 `arm64` 或 `aarch64` 关键词

2. **容器时间不正确**
   - Docker 容器默认 UTC 时间，比北京时间晚 8 小时
   - 解决方法：设置 `TZ=Asia/Shanghai` 并挂载 `/etc/localtime:/etc/localtime:ro`
   - Java 应用还需设置 JVM 时区：`-Duser.timezone=Asia/Shanghai`

3. **容器间通信**
   - Compose 中服务名即 DNS 名，可直接用服务名访问（如 `jdbc:postgresql://database:5432`）
   - 不要用 `localhost` 或 `127.0.0.1`（那是容器自己）
   - 容器要访问宿主机服务：Docker Desktop 用 `host.docker.internal`；Linux 用 `--network=host` 或 docker0 网关 IP

4. **日志膨胀占满磁盘**
   - Docker 默认不限制日志大小，长期运行可能占满 SD 卡
   - 配置 `daemon.json` 的 `log-opts` 限制单个日志文件大小和数量（见上方安装配置）
   - 定期执行 `docker system prune` 清理

5. **网络模式选择**
   - `bridge`（默认）：容器在虚拟网络中，端口映射访问
   - `host`：直接使用宿主机网络，性能好，无需端口映射
   - Home Assistant 必须用 host 模式才能发现局域网设备
   - host 模式下端口映射无效，容器直接占用宿主机端口

6. **权限问题**
   - 容器内默认 root 用户，挂载目录权限可能不匹配
   - 特定服务（如 HA、Mosquitto）需 `--privileged` 或指定 user
   - USB 设备（Zigbee 适配器）需 `--device /dev/ttyUSB0:/dev/ttyUSB0`

7. **构建缓存问题**
   - Dockerfile 中变化不频繁的层放前面（如安装依赖）
   - COPY pom.xml 先于 COPY src 可利用缓存加速构建
   - 构建出错时可用 `--no-cache` 强制重新构建

8. **环境变量与 .env**
   - Compose 自动读取当前目录 `.env` 文件中的变量
   - 敏感信息（API Key、密码）放在 `.env` 中，不提交到 Git
   - `.env.example` 提交模板，实际 `.env` 加入 `.gitignore`

## 官方链接

详见 [official-links.md](official-links.md)。

- Docker 官网：https://www.docker.com/
- Docker 文档：https://docs.docker.com/
- Docker Compose 文档：https://docs.docker.com/compose/
- Docker Hub：https://hub.docker.com/
- Dockerfile 最佳实践：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- Docker 多架构构建：https://docs.docker.com/build/building/multi-platform/
