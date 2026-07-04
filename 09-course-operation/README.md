# 小学期课程协作指南

> **用途**：本文档介绍 AiGuard 小学期课程中的 Git 协作、Issue 求助、Sprint 验收和过程证据整理方式。以下内容是课程协作参考约定，可根据团队实际情况调整。

## 模块概述

AiGuard 小学期项目强调“可运行、可验证、可复盘”的工程实践。本模块提供一套课程协作建议，帮助团队把代码、问题、测试、文档和个人贡献沉淀到 Gitee 中。

本目录关注“如何协作”，`00-08` 目录仍然是项目技术资料、协议说明、硬件文档和故障排查指南。

## 内容列表

| 文档 | 用途 |
|------|------|
| [git-workflow.md](git-workflow.md) | Git 分支、提交、PR/MR 和 Issue 关联建议 |
| [issue-rules.md](issue-rules.md) | Issue 求助、Bug 反馈、标签和关闭标准 |
| [sprint-checklist.md](sprint-checklist.md) | Sprint 0-3 与终期验收的交付物参考 |
| [assessment.md](assessment.md) | 课程评价维度与过程证据说明 |
| [support-mechanism.md](support-mechanism.md) | 团队互助、共性问题沉淀和答疑节奏建议 |
| [templates/](templates/) | 站会、评审、问题求助、Bug 反馈等 Markdown 模板 |

## 课程主线

所有团队建议先围绕共同 MVP 建立最小可运行闭环：

```text
老人端/设备或模拟器触发 SOS 或异常事件
→ MQTT 或等效方式上报
→ 后端接收并入库
→ 子女端或社区端展示报警
→ 家属或社区确认处理
→ 形成状态流转和日志追溯
```

特色功能可以围绕安全守护、亲情关怀、社区服务、AI 智慧等方向展开，但建议先接入主链路，再做体验和智能化增强。

## 建议阅读顺序

1. 先阅读 [git-workflow.md](git-workflow.md)，确认所在小组的分支和提交流程。
2. 再阅读 [issue-rules.md](issue-rules.md)，了解如何用 Issue 提问、报 Bug 和沉淀解决过程。
3. 每个 Sprint 开始前参考 [sprint-checklist.md](sprint-checklist.md)，明确本轮交付物。
4. 准备报告和答辩时参考 [assessment.md](assessment.md)，整理个人贡献证据。
5. 遇到共性问题或跨组协作时参考 [support-mechanism.md](support-mechanism.md)。

## 仓库使用建议

| 分支或区域 | 建议用途 |
|------------|----------|
| `main` | 稳定资料、课程模板、参考说明和最终归档 |
| `team-a/dev`、`team-b/dev` 等 | 各小组日常开发与文档维护 |
| Issue | 技术求助、Bug 反馈、任务讨论、经验沉淀 |
| PR/MR | 个人分支合入小组分支、阶段成果归档或请求评审 |

> **提示**：如果课程实际采用不同分支命名或仓库组织方式，可保留本目录的方法论，只调整具体分支名称。

## Issue 模板

仓库已在 [.gitee/ISSUE_TEMPLATE/](../.gitee/ISSUE_TEMPLATE/) 中配置表单式 Issue 模板。新建 Issue 时可根据问题类型选择：

- 技术求助
- Bug 反馈
- 主链路阻塞
- 功能建议
- 文档改进
- 经验分享

这些模板会自动关联相应中文标签，便于后续筛选、答疑和整理 FAQ。
