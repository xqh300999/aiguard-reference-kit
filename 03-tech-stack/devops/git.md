# Git 版本控制

Git 是分布式版本控制系统，用于 AIguard 项目的源代码管理和协作开发。

## 快速参考

### Git 配置

```bash
# 设置用户名和邮箱（提交记录显示）
git config --global user.name "Your Name"
git config --global user.email "veVw@ozij4.GLa"

# 设置默认分支名为 main
git config --global init.defaultBranch main

# 配置 SSH Key（推荐用于 GitHub/Gitee）
ssh-keygen -t ed25519 -C "veVw@ozij4.GLa"
# 公钥：~/.ssh/id_ed25519.pub，添加到代码托管平台

# 检查配置
git config --list
```

### 常用命令速查

```bash
# 仓库操作
git init                           # 初始化新仓库
git clone <url>                    # 克隆远程仓库
git remote -v                      # 查看远程仓库地址
git remote add origin <url>        # 添加远程仓库

# 日常提交
git status                         # 查看文件状态
git add <file>                     # 添加文件到暂存区
git add .                          # 添加所有修改文件
git commit -m "commit message"     # 提交
git commit --amend                 # 修改最后一次提交

# 分支操作
git branch                         # 查看本地分支
git branch -a                      # 查看所有分支
git checkout -b feature/xxx        # 创建并切换到新分支
git switch main                    # 切换分支（新版推荐）
git merge feature/xxx              # 合并分支到当前分支
git branch -d feature/xxx          # 删除已合并分支
git branch -D feature/xxx          # 强制删除分支

# 远程同步
git fetch                          # 获取远程更新（不合并）
git pull                           # 拉取并合并远程更新
git push                           # 推送到远程
git push -u origin main            # 首次推送设置上游
git push origin --delete feature/xxx  # 删除远程分支

# 撤销/回退
git diff                           # 查看未暂存的修改
git diff --staged                  # 查看已暂存的修改
git restore <file>                 # 撤销工作区修改
git restore --staged <file>        # 取消暂存
git reset HEAD~1                   # 回退一次提交（保留修改）
git reset --hard HEAD~1            # 回退一次提交（丢弃修改，谨慎！）
git revert <commit-hash>           # 创建新提交来撤销指定提交

# 查看历史
git log                            # 查看提交历史
git log --oneline --graph          # 简洁图形化历史
git log --oneline -20              # 最近20条记录
git show <commit-hash>             # 查看某次提交详情
git blame <file>                   # 查看文件每行修改记录

# 暂存（临时保存工作区）
git stash                          # 暂存当前修改
git stash list                     # 查看暂存列表
git stash pop                      # 恢复最近一次暂存
git stash drop                     # 删除最近一次暂存
```

### 分支命名规范

| 分支类型 | 命名格式 | 示例 |
|----------|----------|------|
| 主分支 | `main` | `main` |
| 开发分支 | `develop` | `develop` |
| 功能分支 | `feature/<功能描述>` | `feature/mqtt-device-control` |
| 修复分支 | `fix/<问题描述>` | `fix/websocket-reconnect` |
| 热修复分支 | `hotfix/<问题描述>` | `hotfix/critical-auth-bug` |
| 发布分支 | `release/<版本号>` | `release/v1.0.0` |

### Conventional Commits 提交规范

提交信息格式：
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型：**

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能）|
| `refactor` | 重构（不是新功能也不是修复）|
| `perf` | 性能优化 |
| `test` | 添加/修改测试 |
| `chore` | 构建过程或辅助工具变动 |
| `ci` | CI/CD 配置 |

**提交示例：**
```
feat(backend): 添加上传传感器数据 API

- 新增 POST /api/sensor-data 接口
- 支持批量写入传感器数据
- 添加参数校验和异常处理

Closes #12
```

```
fix(mqtt): 修复设备离线后 MQTT 连接不释放问题
docs: 更新 README 安装说明
refactor(ai): 重构 Qwen 服务工具调用逻辑
chore(deps): 升级 Spring Boot 到 3.3.0
```

### .gitignore 参考

```gitignore
# Java
*.class
*.jar
*.war
target/
!.mvn/wrapper/maven-wrapper.jar

# Node / Vue
node_modules/
dist/
dist-ssr/
*.local
.npm
.vite

# IDE
.idea/
*.iml
.vscode/
*.swp
*.swo
.DS_Store
Thumbs.db

# Logs
*.log
logs/
backend-logs/

# Environment & Secrets
.env
.env.local
.env.*.local
application-prod.yml

# Docker volumes
mosquitto/data/
mosquitto/log/
homeassistant/
pgdata/

# Build outputs
build/
out/

# HarmonyOS
entry/build/
*.hap
local.properties
```

### 典型开发工作流

**功能开发流程：**
```bash
# 1. 切换到主分支并拉取最新代码
git checkout main
git pull origin main

# 2. 创建功能分支
git checkout -b feature/device-ota

# 3. 开发并提交
git add .
git commit -m "feat(ota): 添加设备 OTA 升级接口"

# 4. 推送分支到远程
git push -u origin feature/device-ota

# 5. 在 GitHub/Gitee 上创建 Pull Request/Merge Request
# 6. Code Review 通过后合并到 main
# 7. 删除本地和远程分支
git checkout main
git pull origin main
git branch -d feature/device-ota
git push origin --delete feature/device-ota
```

**冲突解决：**
```bash
# 当合并或拉取出现冲突时
git pull origin main
# 出现 CONFLICT 提示，编辑冲突文件
# 冲突标记：
# <<<<<<< HEAD（当前分支）
# 你的代码
# =======
# 远程代码
# >>>>>>> main

# 手动解决后标记为已解决
git add <resolved-file>
git commit -m "merge: 解决合并冲突"
```

### Git 标签（版本发布）

```bash
# 创建标签
git tag v1.0.0                       # 轻量标签
git tag -a v1.0.0 -m "Release v1.0.0"  # 附注标签

# 查看标签
git tag
git show v1.0.0

# 推送标签
git push origin v1.0.0
git push origin --tags               # 推送所有标签

# 检出标签
git checkout v1.0.0

# 删除标签
git tag -d v1.0.0
git push origin --delete v1.0.0
```

## 常见坑点

1. **不要提交敏感信息**
   - API Key、数据库密码、密钥等不要提交到仓库
   - 使用 `.env` + `.gitignore` 管理
   - 若已误提交，需修改所有泄露的密钥，仅修改文件不解决历史记录问题
   - 彻底清除需使用 `git filter-repo` 或 BFG Repo-Cleaner

2. **不要提交大文件**
   - Git 不适合追踪二进制大文件（固件包、镜像、视频等）
   - 大文件会使仓库体积迅速膨胀，clone 变慢
   - 超过 100MB 的文件 GitHub 会拒绝
   - 小智固件 zip 包不要提交到 Git，放 release 附件或其他存储
   - 需要版本管理大文件可使用 Git LFS

3. **提交粒度适中**
   - 不要一次提交包含大量不相关修改
   - 一个提交只做一件事，便于 review 和回退
   - 不要提交临时代码、注释掉的代码、调试打印
   - 格式化代码和功能修改分开提交

4. **不要直接在 main 分支开发**
   - main 分支保持可部署状态
   - 所有功能通过 feature 分支 + PR/MR 合并
   - 合并前确保 CI 通过、代码 review 通过

5. **`git add .` 慎用**
   - `git add .` 会添加所有文件，可能误加入不想提交的文件
   - 建议先用 `git status` 查看变更，确认后再 add
   - 可用 `git add -p` 交互式选择要提交的部分

6. **`--force` 推送风险**
   - `git push --force` 会覆盖远程历史，可能丢失别人提交
   - 仅在自己的 feature 分支上使用，绝对不要在 main 上 force push
   - 推荐使用 `--force-with-lease`（若远程有新提交会拒绝）

7. **正确撤销错误**
   - 未 push 的提交可用 `git reset` 修改
   - 已 push 到远程的提交不要 reset 重写历史，用 `git revert` 创建新提交撤销
   - 硬重置（`--hard`）会丢失未提交修改，操作前确认

8. **换行符问题（Windows vs Linux/macOS）**
   - Windows 使用 CRLF，Linux/macOS 使用 LF
   - 配置 `.gitattributes` 统一换行符
   ```
   * text=auto eol=lf
   *.bat text eol=crlf
   ```
   - 或设置 `git config --global core.autocrlf input`（macOS/Linux）

9. **不要 clone 大仓库历史**
   - 大型仓库首次 clone 慢，可用浅克隆：
   ```bash
   git clone --depth 1 <url>          # 只拉取最新一次提交
   git clone --depth 1 --branch v1.0.0 <url>  # 克隆指定标签
   ```

## 官方链接

详见 [official-links.md](official-links.md)。

- Git 官网：https://git-scm.com/
- Pro Git 中文版（官方电子书）：https://git-scm.com/book/zh/v2
- Git 命令参考：https://git-scm.com/docs
- GitHub Guides：https://guides.github.com/
- Conventional Commits 规范：https://www.conventionalcommits.org/zh-hans/v1.0.0/
- Gitee 码云：https://gitee.com/
- GitHub：https://github.com/
- Git 飞行规则（常见问题解决方案）：https://github.com/k88hudson/git-flight-rules/blob/master/README_zh-CN.md
