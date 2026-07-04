# Git 协作建议

> **用途**：本文档提供 AiGuard 小学期项目中的 Git 分支、提交、PR/MR 和 Issue 关联建议。具体分支名称可根据课程实际安排调整。

## 分支约定参考

| 分支 | 建议用途 |
|------|----------|
| `main` | 稳定资料、课程模板、参考说明和最终归档 |
| `team-a/dev` | A 组日常开发与文档维护 |
| `team-b/dev` | B 组日常开发与文档维护 |
| `team-c/dev` | C 组日常开发与文档维护 |
| `team-d/dev` | D 组日常开发与文档维护 |
| `feature/<模块>-<任务>` | 小功能或个人任务分支 |
| `fix/<issue编号>-<问题>` | Bug 修复分支 |

`main` 建议保持稳定，日常代码和文档可以先在小组分支中推进。阶段性成果稳定后，再通过 PR/MR 归档或请求评审。

## 第一次使用

```bash
git clone https://gitee.com/Catherine618/aiguard-reference-kit.git
cd aiguard-reference-kit
git fetch origin
git switch team-a/dev
```

请将 `team-a/dev` 替换为所在小组的分支名称。

如果小组分支尚未创建，可参考：

```bash
git switch main
git pull origin main
git switch -c team-a/dev
git push -u origin team-a/dev
```

## 日常提交流程

```bash
git switch team-a/dev
git pull origin team-a/dev

# 修改代码或文档后
git status
git add <文件>
git commit -m "feat(alert): add sos status transition"
git push origin team-a/dev
```

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

## PR/MR 建议

当个人分支需要合入小组分支时，可以提交 PR/MR：

- 目标分支：本组 `team-x/dev`
- 描述中写清关联 Issue、修改内容、测试方式
- 至少请 1 名同组成员检查
- 涉及主链路或敏感数据的改动，建议额外说明风险和回滚方式

## 敏感信息提醒

以下内容不应提交到公开仓库：

- 数据库密码
- AI API Key
- Home Assistant Token
- 设备 Token
- 真实个人隐私数据
- 未脱敏截图或日志

如果误提交敏感信息，建议尽快更换相关密钥，并在 Issue 或小组记录中说明处理结果。
