# 开发基础工具

> **用途**：本文档介绍开发过程中常用的基础工具（Git、Docker、screen、命令行）的核心使用方法。如果你已经熟悉这些工具，可以跳过本文档；如果是初学者或需要复习，本文档提供快速上手指南。

---

## Git 版本控制

### 核心概念

- **Repository（仓库）**：项目的代码存储目录
- **Commit（提交）**：代码变更的快照
- **Branch（分支）**：独立的开发线
- **Remote（远程）**：托管在服务器上的仓库（如 GitHub/GitLab）

### 常用命令

```bash
# 克隆仓库
git clone <repository-url>

# 查看当前状态
git status

# 查看提交历史
git log
git log --oneline --graph --all  # 图形化简洁视图

# 创建并切换分支
git checkout -b feature/your-feature-name
# 或较新版本 Git
git switch -c feature/your-feature-name

# 添加文件到暂存区
git add <file>
git add .  # 添加所有变更文件

# 提交变更
git commit -m "feat: 描述你的变更内容"

# 推送到远程
git push origin feature/your-feature-name

# 拉取最新代码
git pull origin main

# 切换分支
git checkout main
git switch main

# 合并分支
git checkout main
git merge feature/your-feature-name
```

### 提交信息规范

推荐使用语义化提交信息：

```
<type>(<scope>): <subject>

类型(type)：
- feat: 新功能
- fix: 修复 Bug
- docs: 文档更新
- style: 代码格式调整（不影响功能）
- refactor: 重构（不新增功能也不修 Bug）
- test: 测试相关
- chore: 构建/工具/依赖相关

示例：
feat(backend): 添加设备告警规则接口
fix(panel): 修复屏幕触摸无响应问题
docs(readme): 更新安装说明
```

### 学习资源
- [官方] Git 官方文档: https://git-scm.com/doc
- [推荐] Pro Git 电子书: https://git-scm.com/book/zh/v2
- [社区] 廖雪峰 Git 教程: https://www.liaoxuefeng.com/wiki/896043488029600
- [推荐] 可视化学习 Git: https://learngitbranching.js.org/

---

## Docker 容器化

### 核心概念

- **Image（镜像）**：应用程序的只读模板
- **Container（容器）**：镜像的运行实例
- **Dockerfile**：构建镜像的脚本
- **docker-compose.yml**：多容器应用的编排配置

### 常用命令

```bash
# 启动服务（在 docker-compose.yml 目录下）
docker compose up -d

# 查看运行中的容器
docker compose ps
docker ps

# 查看服务日志
docker compose logs -f <service-name>
# 例如：docker compose logs -f mosquitto

# 停止服务
docker compose down

# 停止并删除数据卷（谨慎使用）
docker compose down -v

# 拉取最新镜像
docker compose pull

# 构建镜像
docker compose build

# 进入容器内部
docker exec -it <container-name> bash
docker exec -it <container-name> sh  # 轻量级镜像用 sh
```

### AiGuard 常用操作

```bash
# 启动所有中间件（MQTT 等）
cd aiguard/docker
docker compose up -d

# 查看 MQTT broker 日志
docker compose logs -f mosquitto
```

### 学习资源
- [官方] Docker 入门: https://docs.docker.com/get-started/
- [官方] Docker Compose 文档: https://docs.docker.com/compose/
- [社区] Docker — 从入门到实践: https://yeasy.gitbook.io/docker_practice/

---

## screen 终端会话管理

### 什么是 screen？

screen 是一个终端多路复用工具，可以让你：
- 在一个终端窗口中运行多个终端会话
- 会话在后台运行，即使网络断开也不会中断
- 随时重新连接到后台会话

### 常用命令

```bash
# 创建一个新的 named 会话
screen -S <session-name>
# 例如：screen -S backend

# 列出所有会话
screen -ls

# 重新连接到一个会话
screen -r <session-name>
screen -r -d <session-name>  # 如果会话 attached，先 detach 再连接

# 终止当前会话（在会话内）
exit
# 或按 Ctrl+D

# 在会话外终止会话
screen -S <session-name> -X quit
```

### screen 内快捷键

所有 screen 快捷键以 `Ctrl+A` 开头（按完 Ctrl+A 再按后续键）：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+A` `D` | Detach（离开会话，后台继续运行）|
| `Ctrl+A` `C` | 创建新窗口 |
| `Ctrl+A` `N` | 切换到下一个窗口 |
| `Ctrl+A` `P` | 切换到上一个窗口 |
| `Ctrl+A` `0-9` | 切换到指定编号窗口 |
| `Ctrl+A` `"` | 列出所有窗口 |
| `Ctrl+A` `?` | 帮助 |
| `Ctrl+A` `K` | 强制关闭当前窗口 |

### AiGuard 使用示例

```bash
# 启动后端服务在后台运行
screen -S backend
cd aiguard/backend
./mvnw spring-boot:run
# 按 Ctrl+A D 离开会话

# 稍后重新连接查看日志
screen -r backend

# 启动模拟设备
screen -S mock
cd aiguard/scripts/mock-device
node mock-all-devices.js
# Ctrl+A D 离开
```

### 学习资源
- [官方] GNU Screen 手册: https://www.gnu.org/software/screen/manual/
- [社区] screen 快速教程: https://linuxize.com/post/how-to-use-linux-screen/

---

## 命令行基础

### 文件与目录操作

```bash
# 查看当前目录
pwd

# 列出文件
ls
ls -la  # 显示详细信息，包括隐藏文件

# 切换目录
cd <path>
cd ..    # 返回上级目录
cd ~     # 回到用户主目录
cd -     # 返回上一个目录

# 创建目录
mkdir <dir-name>
mkdir -p path/to/dir  # 创建多级目录

# 创建文件
touch <file-name>

# 复制文件/目录
cp <source> <destination>
cp -r <source-dir> <destination-dir>

# 移动/重命名
mv <source> <destination>

# 删除文件
rm <file-name>
rm -r <dir-name>  # 删除目录
# 注意：rm 删除不可恢复，谨慎使用！
```

### 文件查看与编辑

```bash
# 查看文件内容
cat <file>
less <file>  # 分页查看（q 退出，/ 搜索）
head <file>  # 查看前几行
tail <file>  # 查看后几行
tail -f <file>  # 实时追踪文件变化（看日志常用）

# 文本编辑器
nano <file>  # 简单易用，适合新手
vim <file>   # 功能强大，学习曲线较陡
```

### 进程管理

```bash
# 查看进程
ps aux
ps aux | grep <keyword>  # 搜索特定进程

# 查看实时进程
top
# 或更友好的工具：htop（需要安装）

# 终止进程
kill <pid>
kill -9 <pid>  # 强制终止

# 后台运行命令
<command> &
# 例如：./start-service.sh &
```

### 网络与端口

```bash
# 查看端口占用
lsof -i :<port>
netstat -tlnp | grep <port>

# 测试网络连通性
ping <host>

# HTTP 请求
curl <url>
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' <url>
http <url>  # 更友好的工具（需要安装 httpie）
```

### 其他实用技巧

```bash
# 命令历史
history
!n          # 执行历史中第 n 条命令
Ctrl+R      # 反向搜索历史命令

# 自动补全
<Tab>       # 补全命令或文件名
<Tab><Tab>  # 列出所有可能的补全

# 管道与重定向
command1 | command2     # 将 command1 的输出作为 command2 的输入
command > file          # 将输出写入文件（覆盖）
command >> file         # 将输出追加到文件
command < file          # 从文件读取输入

# 查找文件
find <path> -name "<pattern>"
# 例如：find . -name "*.java"

# 搜索文件内容
grep "<pattern>" <file>
grep -r "<pattern>" <dir>  # 递归搜索
```

### 推荐学习资源

- [推荐] Linux 命令行大全（书籍）
- [社区] Linux 101: https://101.lug.ustc.edu.cn/
- [社区] 命令行快速参考: https://ss64.com/bash/
- [推荐] explainshell（命令解释）: https://explainshell.com/

---

## 小贴士

1. **多用 Tab 补全**：既快又能避免打错字
2. **善用 history 和 Ctrl+R**：不用重复输入长命令
3. **多开 screen 窗口**：每个服务一个窗口，井井有条
4. **tail -f 看日志**：调试时非常实用
5. **遇到不会的命令**：`man <command>` 查看手册，或用 `<command> --help`
