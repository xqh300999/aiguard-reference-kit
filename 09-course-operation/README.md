# 小学期课程运行规则

本目录用于《全栈系统设计与实现》小学期课程的协作、提问、验收和考核说明。`00-08` 目录仍是 AI-Guard 技术参考资料；本目录只说明课程如何运行。

## 课程主线

所有小组必须优先完成共同 MVP：

```text
老人端/设备或模拟器触发 SOS 或异常事件
-> MQTT 或等效方式上报
-> 后端接收并入库
-> 子女端或社区端展示报警
-> 家属或社区确认处理
-> 形成状态流转和日志追溯
```

特色功能必须接入主链路，不能只做孤立页面或孤立演示。

## 学生先读什么

1. [git-workflow.md](git-workflow.md)：知道自己在哪个分支工作，如何提交，如何关联 Issue。
2. [issue-rules.md](issue-rules.md)：知道如何提问、报 Bug、关闭问题。
3. [sprint-checklist.md](sprint-checklist.md)：知道每周要交付什么。
4. [assessment.md](assessment.md)：知道哪些证据会进入成绩。

## 仓库使用原则

- `main` 分支由教师维护，放基础资料、模板、稳定说明和最终归档材料。
- 学生小组在各自长期分支工作，例如 `team-a/dev`、`team-b/dev`、`team-c/dev`、`team-d/dev`。
- 全班统一使用本仓库 Issue 提问、报 Bug、沉淀 FAQ。
- 代码提交、Issue、PR/MR、测试记录、文档更新要能互相关联。

## 常用模板

- [templates/issue-question.md](templates/issue-question.md)：技术求助模板
- [templates/issue-bug.md](templates/issue-bug.md)：Bug 报告模板
- [templates/daily-standup.md](templates/daily-standup.md)：每日站会模板
- [templates/sprint-review.md](templates/sprint-review.md)：Sprint 评审模板

## Skill 安装提醒

如果需要安装 `aiguard-knowledge` Skill，请安装完整仓库，不要只复制 `skills/aiguard-knowledge/` 目录。Skill 通过相对路径读取 `00-09` 目录中的资料，只复制 Skill 目录会导致资料引用失效。
