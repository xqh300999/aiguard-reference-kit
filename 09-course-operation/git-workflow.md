# Git 协作建议

> **用途**：本文档提供 AiGuard 小学期项目中的 Git 分支、提交、PR/MR 和 Issue 关联建议。说明面向第一次参与 Git 协作的同学，重点是先跑通一轮最小 Demo，再进入正式开发。具体仓库地址和分支名称可根据课程实际安排调整。

## 先理解三个概念

| 概念 | 可以这样理解 |
|------|--------------|
| 仓库 | 项目的云端文件夹，代码、文档和提交记录都在里面 |
| 分支 | 同一个项目里的不同工作线，例如主线、A 组工作线、个人工作线 |
| PR/MR | Pull Request / Merge Request，用来请求把一个分支的改动合入另一个分支 |

本课程建议使用：

```text
main
└── team-a/dev
    ├── feature/team-a-git-demo-zhangsan
    ├── feature/team-a-backend-lisi
    └── fix/team-a-issue-12
```

其中：

- `main`：稳定资料和阶段评审入口。
- `team-a/dev`：A 组共同开发分支。
- `feature/...`：个人功能分支，组员在这里完成自己的任务。
- `fix/...`：个人修复分支，用于修 Bug。

## 分支约定参考

| 分支 | 建议用途 |
|------|----------|
| `main` | 稳定资料、课程模板、参考说明和最终归档 |
| `team-a/dev` | A 组日常开发与文档维护 |
| `team-b/dev` | B 组日常开发与文档维护 |
| `team-c/dev` | C 组日常开发与文档维护 |
| `team-d/dev` | D 组日常开发与文档维护 |
| `feature/team-a-<任务>-<姓名>` | A 组成员的小功能或个人任务分支 |
| `fix/team-a-<问题>-<姓名>` | A 组成员的 Bug 修复分支 |

`main` 建议保持稳定，日常代码和文档可以先在小组分支中推进。阶段性成果稳定后，再通过 PR/MR 归档或请求评审。

## 第 0 步：建议先做一轮 Git 测试 Demo

正式开发前，建议每个小组先用 20-30 分钟完成一次“测试 PR”。这个测试不做业务功能，只验证每个人是否会：

1. 克隆仓库。
2. 切到本组分支。
3. 创建个人分支。
4. 修改一个测试文件。
5. 提交并推送。
6. 在网页上发起 PR。
7. 由 SM 审查并合并。

这一步很有必要。它可以在第一天提前暴露账号权限、分支名称、推送失败、PR 目标分支选错等问题，避免正式开发时才卡住。

测试建议使用一个独立目录，例如：

```text
groups/team-a/git-demo/
```

每位成员只添加自己的测试文件，例如：

```text
groups/team-a/git-demo/zhangsan.md
```

文件内容可以很简单：

```text
# zhangsan Git Demo

- 小组：A 组
- 角色：后端开发
- 本次测试：clone、branch、commit、push、PR
```

测试 PR 合并后，说明该成员已经跑通基本协作流程。

## 一般组员 Demo 流程

以下命令以 A 组、成员张三为例。实际使用时，请替换：

- `team-a/dev`：替换为自己小组的分支。
- `zhangsan`：替换为自己的姓名或拼音。
- 仓库地址：替换为课程实际仓库地址。

### 1. 克隆仓库

```bash
git clone https://gitee.com/Catherine618/aiguard-reference-kit.git
```

这条命令会把云端仓库下载到本地电脑。

### 2. 进入项目目录

```bash
cd aiguard-reference-kit
```

这条命令进入刚刚下载好的项目文件夹。

### 3. 获取远端最新分支

```bash
git fetch origin
```

这条命令会从 Gitee 获取最新的分支信息。

### 4. 切到本组分支

```bash
git switch team-a/dev
```

这条命令表示进入 A 组的共同开发分支。请将 `team-a/dev` 替换为所在小组的分支名称。

### 5. 从本组分支创建个人测试分支

```bash
git switch -c feature/team-a-git-demo-zhangsan
```

这条命令会创建一个属于自己的测试分支。组员不要直接在 `team-a/dev` 上修改。

### 6. 新增或修改一个测试文件

可以在编辑器中创建文件：

```text
groups/team-a/git-demo/zhangsan.md
```

也可以先用系统文件管理器创建文件，再写入自己的测试说明。

### 7. 查看当前改动

```bash
git status
```

这条命令会显示哪些文件被新增、修改或删除。提交前建议都看一眼。

### 8. 添加要提交的文件

```bash
git add groups/team-a/git-demo/zhangsan.md
```

这条命令表示“把这个文件放入本次提交”。如果有多个文件，可以逐个 `git add`。

### 9. 生成一次提交

```bash
git commit -m "docs(team-a): add zhangsan git demo"
```

这条命令会在本地生成一条提交记录。`-m` 后面是提交说明，建议写清楚做了什么。

### 10. 推送个人分支到 Gitee

```bash
git push -u origin feature/team-a-git-demo-zhangsan
```

这条命令会把个人分支上传到 Gitee。第一次推送该分支时建议带 `-u`，之后可以简化为 `git push`。

### 11. 在 Gitee 网页上发起 PR/MR

网页上创建 PR/MR 时，选择：

```text
源分支：feature/team-a-git-demo-zhangsan
目标分支：team-a/dev
```

PR/MR 标题建议：

```text
[A组][Git Demo] 张三完成协作流程测试
```

PR/MR 描述建议写：

```text
## 本次修改
新增张三的 Git Demo 测试文件。

## 验证内容
- 已 clone 仓库
- 已从 team-a/dev 创建个人分支
- 已完成 commit 和 push
- 请求合并到 team-a/dev
```

## SM Demo 流程

SM 建议先完成自己的 Demo，再组织组员完成 Demo。以下以 A 组 SM 为例。

### 1. 确认本组分支存在

```bash
git clone https://gitee.com/Catherine618/aiguard-reference-kit.git
cd aiguard-reference-kit
git fetch origin
git switch team-a/dev
```

如果课程仓库已经提前创建好 `team-a/dev`，这一步可以直接成功。

如果小组分支尚未创建，可由有权限的成员参考：

```bash
git switch main
git pull origin main
git switch -c team-a/dev
git push -u origin team-a/dev
```

这些命令的含义是：先回到 `main`，拉取最新内容，再创建 A 组分支并推送到 Gitee。

### 2. 初始化小组 Demo 目录

```bash
mkdir -p groups/team-a/git-demo
```

这条命令会创建 A 组 Git 测试目录。如果在 Windows PowerShell 中执行失败，可以直接用文件管理器创建同名目录。

Git 不会提交空目录，因此还需要创建一个说明文件：

```text
groups/team-a/git-demo/README.md
```

文件内容可以写：

```text
# A 组 Git Demo

本目录用于测试组员是否已经跑通 clone、branch、commit、push 和 PR 流程。
```

### 3. 创建 SM 自己的测试分支

```bash
git switch -c feature/team-a-git-demo-sm
```

### 4. 新增 SM 测试文件并提交

```bash
git status
git add groups/team-a/git-demo/README.md
git commit -m "docs(team-a): initialize git demo folder"
git push -u origin feature/team-a-git-demo-sm
```

然后在 Gitee 网页上发起 PR/MR：

```text
源分支：feature/team-a-git-demo-sm
目标分支：team-a/dev
```

### 5. 审查组员 PR/MR

SM 审查时建议看四点：

1. 目标分支是否为本组 `team-a/dev`。
2. 是否只改了自己的测试文件或对应任务文件。
3. 提交说明是否能看懂。
4. PR/MR 描述是否写了验证内容。

确认无误后，SM 可以合并到 `team-a/dev`。

### 6. 检查合并结果

SM 合并多个组员 PR/MR 后，可以在本地检查：

```bash
git switch team-a/dev
git pull origin team-a/dev
git log --oneline --max-count=5
```

这些命令的含义是：回到本组分支，拉取最新合并结果，查看最近 5 条提交。

## 正式开发时的一般组员流程

Demo 跑通后，正式开发也使用同一套流程。

```bash
git switch team-a/dev
git pull origin team-a/dev
git switch -c feature/team-a-alert-page-zhangsan
```

完成代码或文档后：

```bash
git status
git add <文件>
git commit -m "feat(team-a): add alert page"
git push -u origin feature/team-a-alert-page-zhangsan
```

然后在 Gitee 上发起 PR/MR：

```text
源分支：feature/team-a-alert-page-zhangsan
目标分支：team-a/dev
```

## 正式开发时的 SM 流程

SM 的日常流程建议是：

1. 每天确认组员任务是否都有对应分支或 PR/MR。
2. 检查 PR/MR 是否指向本组 `team-x/dev`。
3. 合并前查看改动范围、运行说明和自测证据。
4. 合并后提醒组员拉取最新 `team-x/dev`。
5. Sprint 结束时，从 `team-x/dev` 向 `main` 提交阶段 PR/MR。

阶段 PR/MR 建议：

```text
源分支：team-a/dev
目标分支：main
```

阶段 PR/MR 不一定立即合并，主要用于展示本 Sprint 的阶段成果。

## 提交信息格式

推荐格式：

```text
type(scope): short description
```

常用类型：

| 类型 | 含义 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(alert): add sos list api` |
| `fix` | 修复 Bug | `fix(mqtt): align topic name` |
| `docs` | 文档 | `docs(api): update alert response fields` |
| `test` | 测试 | `test(alert): add sos e2e case` |
| `chore` | 配置或杂项 | `chore(repo): initialize team folders` |

如提交与某个 Issue 有关，可在提交说明中写：

```text
Refs #12
```

## Issue 与提交关联

建议把重要任务或 Bug 与 Issue 关联起来：

1. 先创建 Issue，写清目标、现象、验收标准或 Bug 复现步骤。
2. 提交代码时在 commit message 中写 `Refs #编号`。
3. 修复完成后，在 Issue 中补充验证方式。
4. 由相关成员确认后关闭 Issue。

## PR/MR 描述建议

当个人分支需要合入小组分支时，PR/MR 描述建议包含：

```text
## 关联任务或 Issue
Refs #12

## 本次修改
- 完成了什么功能或文档
- 修改了哪些模块

## 验证方式
- 如何启动
- 如何测试
- 是否有截图、日志或接口结果

## 风险说明
- 是否影响主链路
- 是否需要数据库变更
- 是否需要同步其他成员
```

至少请 1 名同组成员检查。涉及主链路或敏感数据的改动，建议额外说明风险和回滚方式。

## 常见问题

### `git switch team-a/dev` 提示分支不存在怎么办？

先执行：

```bash
git fetch origin
git branch -r
```

查看远端是否存在 `origin/team-a/dev`。如果没有，说明分支可能尚未创建或名称不同。

### 提交时提示没有配置用户名和邮箱怎么办？

可以配置：

```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱"
```

这两条命令用于设置提交记录中的作者信息。

### 推送时提示没有权限怎么办？

请先检查：

- 是否已经加入课程仓库或高校版项目成员。
- 是否登录了正确的 Gitee 账号。
- 是否推送到自己的个人分支，而不是直接推送到 `main`。
- 分支名是否符合课程约定。

### 不小心在 `team-a/dev` 上改了文件怎么办？

如果还没有提交，可以先创建个人分支，把当前改动带过去：

```bash
git switch -c feature/team-a-my-work-zhangsan
```

然后继续 `git add`、`git commit` 和 `git push`。如果已经提交，建议先向 SM 说明情况，再一起处理。

## 敏感信息提醒

以下内容不应提交到公开仓库：

- 数据库密码
- AI API Key
- Home Assistant Token
- 设备 Token
- 真实个人隐私数据
- 未脱敏截图或日志

如果误提交敏感信息，建议尽快更换相关密钥，并在 Issue 或小组记录中说明处理结果。
