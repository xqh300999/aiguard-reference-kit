# DevOps 工具链

AIguard 使用 Docker 进行容器化部署，Git 进行版本控制，实现一致的开发和生产环境。

## 目录

- [Docker](docker.md) - Docker 与 Docker Compose 容器化部署
- [Git](git.md) - Git 版本控制最佳实践
- [官方链接](official-links.md) - Docker/Git官方文档链接

## 技术栈概览

| 工具 | 用途 |
|------|------|
| Docker | 应用容器化 |
| Docker Compose | 多容器编排 |
| Git | 代码版本控制 |
| GitHub/Gitee | 代码托管 |

## 快速参考

```bash
# 检查 Docker 安装
docker --version
docker compose version

# 启动整个服务栈
docker compose up -d

# 查看运行状态
docker compose ps

# 查看日志
docker compose logs -f backend

# Git 基本操作
git status
git add .
git commit -m "feat: add new feature"
git push
```

## 常见坑点

1. 树莓派 ARM64 架构需使用支持 aarch64 的 Docker 镜像，部分镜像仅提供 x86 版本
2. Docker 容器时间需挂载 `/etc/localtime` 或设置 `TZ` 环境变量
3. Git 提交信息建议遵循 Conventional Commits 规范
4. 敏感信息（密码、API Key）不要提交到 Git 仓库，使用 `.env` 文件

## 官方链接

详见 [official-links.md](official-links.md)。
