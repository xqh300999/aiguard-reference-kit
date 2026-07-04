# Git 协作规则

## 一、分支约定

| 分支 | 用途 | 谁维护 |
|---|---|---|
| `main` | 教师发布资料、模板、稳定说明、最终归档 | 教师 |
| `team-a/dev` | A组日常开发与文档维护 | A组 |
| `team-b/dev` | B组日常开发与文档维护 | B组 |
| `team-c/dev` | C组日常开发与文档维护 | C组 |
| `team-d/dev` | D组日常开发与文档维护 | D组 |
| `feature/<模块>-<任务>` | 小功能或个人任务分支 | 学生 |
| `fix/<issue编号>-<问题>` | Bug 修复分支 | 学生 |

学生不要直接向 `main` 提交课程代码。小组稳定成果可以通过 PR/MR 请求合并或由教师归档。

## 二、第一次使用

```bash
git clone https://gitee.com/Catherine618/aiguard-reference-kit.git
cd aiguard-reference-kit
git fetch origin
git switch team-a/dev
```

把 `team-a/dev` 换成你所在小组分支。

如果本组分支还不存在，由教师或组长创建：

```bash
git switch main
git pull origin main
git switch -c team-a/dev
git push -u origin team-a/dev
```

## 三、日常提交流程

```bash
git switch team-a/dev
git pull origin team-a/dev

# 修改代码或文档
git status
git add <文件>
git commit -m "feat(alert): add sos status transition"
git push origin team-a/dev
```

## 四、提交信息格式

推荐格式：

```text
type(scope): short description
```

常用类型：

| 类型 | 含义 | 示例 |
|---|---|---|
| `feat` | 新功能 | `feat(alert): add sos list api` |
| `fix` | 修复 Bug | `fix(mqtt): align topic name` |
| `docs` | 文档 | `docs(api): update alert response fields` |
| `test` | 测试 | `test(alert): add sos e2e case` |
| `chore` | 配置或杂项 | `chore(repo): initialize team folders` |

提交说明里建议关联 Issue：

```text
fix(mqtt): align topic name

Refs #12
```

## 五、Issue 与提交关联

每个重要任务或 Bug 都应有关联 Issue。建议流程：

1. 先创建 Issue，写清目标、现象、验收标准或 Bug 复现步骤。
2. 提交代码时在 commit message 中写 `Refs #编号`。
3. 修复完成后在 Issue 中补充验证方式。
4. 由 PO/SM/测试负责人确认后关闭 Issue。

## 六、PR/MR 建议

当个人分支需要合入小组分支时，建议提交 PR/MR：

- 目标分支：本组 `team-x/dev`
- 描述中写清关联 Issue、修改内容、测试方式
- 至少由 1 名同组成员检查
- P0/P1 主链路代码建议由教师或企业导师抽查

## 七、敏感信息要求

不得提交以下内容：

- 数据库密码
- AI API Key
- Home Assistant Token
- 设备 Token
- 真实个人隐私数据
- 未脱敏截图或日志

如果误提交，立即通知教师，并更换相关密钥。
