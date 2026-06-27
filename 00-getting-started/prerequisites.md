# 开发环境依赖

> **用途**：本文档列出开发 AiGuard 项目所需的软件依赖、版本要求及安装验证方法。实现方式不限，以下版本为推荐配置，你可根据实际情况选择兼容版本。

## 依赖清单

| 软件 | 推荐版本 | 用途 | 必需 |
|------|---------|------|------|
| JDK | 17+ | 后端服务开发运行 | 后端开发必需 |
| Node.js | 20+ | 前端/Web面板开发运行 | 前端/全栈开发必需 |
| Python | 3.10+ | 脚本工具、测试、辅助服务 | 推荐安装 |
| Docker | 最新稳定版 | 容器化部署、中间件运行 | 必需 |
| Git | 最新稳定版 | 版本控制 | 必需 |
| Maven | 3.9+ | Java 项目构建管理 | 后端开发必需 |
| screen | 最新稳定版 | 终端会话管理 | 推荐安装 |

## 安装指南

### JDK 17+

**说明**：Java 开发工具包，用于运行和编译后端服务。

- [官方] Oracle JDK: https://www.oracle.com/java/technologies/downloads/
- [推荐] Adoptium (Eclipse Temurin): https://adoptium.net/
- [社区] OpenJDK: https://openjdk.org/

**验证安装**：
```bash
java -version
# 应显示 openjdk version "17.x.x" 或更高
javac -version
```

### Node.js 20+

**说明**：JavaScript 运行时，用于前端构建和脚本工具。

- [官方] Node.js: https://nodejs.org/
- [推荐] nvm (Node Version Manager): https://github.com/nvm-sh/nvm
- [社区] fnm: https://github.com/Schniz/fnm

**验证安装**：
```bash
node -v
# 应显示 v20.x.x 或更高
npm -v
```

### Python 3.10+

**说明**：Python 解释器，用于运行测试脚本、工具脚本等。

- [官方] Python: https://www.python.org/downloads/
- [推荐] Anaconda/Miniconda: https://www.anaconda.com/download
- [社区] pyenv: https://github.com/pyenv/pyenv

**验证安装**：
```bash
python3 --version
# 应显示 Python 3.10.x 或更高
pip3 --version
```

### Docker

**说明**：容器化平台，用于运行 MQTT、数据库等中间件服务。

- [官方] Docker Desktop: https://www.docker.com/products/docker-desktop/
- [社区] Docker Engine (Linux): https://docs.docker.com/engine/install/

**验证安装**：
```bash
docker --version
docker compose version
# 运行测试容器
docker run hello-world
```

### Git

**说明**：分布式版本控制系统，用于代码管理。

- [官方] Git: https://git-scm.com/downloads
- [推荐] 配合图形化工具：GitHub Desktop / SourceTree / GitKraken

**验证安装**：
```bash
git --version
# 建议配置用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Maven 3.9+

**说明**：Java 项目构建和依赖管理工具。

- [官方] Apache Maven: https://maven.apache.org/download.cgi
- [推荐] 使用 SDKMAN! 管理: https://sdkman.io/

**验证安装**：
```bash
mvn -version
# 应显示 Apache Maven 3.9.x 或更高
```

### screen

**说明**：终端多路复用工具，用于管理多个终端会话，保持后台任务运行。

**macOS 安装**：
```bash
# 使用 Homebrew
brew install screen
```

**Ubuntu/Debian 安装**：
```bash
sudo apt-get update
sudo apt-get install screen
```

**验证安装**：
```bash
screen -version
```

## 可选工具推荐

以下工具非必需，但能显著提升开发效率：

| 工具 | 用途 | 链接 |
|------|------|------|
| Visual Studio Code | 通用代码编辑器 | [官方] https://code.visualstudio.com/ |
| IntelliJ IDEA | Java/Kotlin 开发 IDE | [官方] https://www.jetbrains.com/idea/ |
| Postman / Apifox | API 测试工具 | [官方] https://www.postman.com/ |
| MQTTX / MQTT Explorer | MQTT 客户端调试工具 | [社区] https://mqttx.app/ |
| HTTPie / curl | 命令行 HTTP 客户端 | [官方] https://httpie.io/ |
| jq | JSON 命令行处理工具 | [官方] https://jqlang.github.io/jq/ |

## 环境验证清单

安装完成后，可以运行以下命令快速验证核心环境：

```bash
echo "=== 环境检查 ==="
echo "Git: $(git --version 2>/dev/null || echo '未安装')"
echo "Docker: $(docker --version 2>/dev/null || echo '未安装')"
echo "Docker Compose: $(docker compose version 2>/dev/null || echo '未安装')"
echo "Java: $(java -version 2>&1 | head -n1 || echo '未安装')"
echo "Node: $(node -v 2>/dev/null || echo '未安装')"
echo "Python: $(python3 --version 2>/dev/null || echo '未安装')"
echo "Maven: $(mvn -version 2>/dev/null | head -n1 || echo '未安装')"
echo "screen: $(screen -version 2>/dev/null | head -n1 || echo '未安装')"
```
