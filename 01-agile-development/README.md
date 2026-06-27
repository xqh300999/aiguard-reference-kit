# 敏捷开发实践

> **用途**：本文档介绍 AiGuard 项目如何在 1 个月（4 个 Sprint）中应用敏捷开发方法，包括 Scrum 框架、Sprint 节奏、以及提供可复用的会议模板。敏捷实践方式可根据团队实际情况调整。

## 模块概述

AiGuard 项目采用 Scrum 敏捷开发框架，以 1 个月为一个完整的开发周期，包含 4 个 Sprint，每个 Sprint 为期约 1 周。本模块提供 Scrum 基础知识、会议模板和学习资源。

## 内容列表

| 文档 | 用途 |
|------|------|
| [scrum-basics.md](scrum-basics.md) | Scrum 基础概念、角色定义、四个仪式说明 |
| [sprint-templates/](sprint-templates/) | Sprint 各类会议模板 |
| &nbsp;&nbsp;├─ [sprint-planning-template.md](sprint-templates/sprint-planning-template.md) | Sprint 计划会议模板 |
| &nbsp;&nbsp;├─ [daily-standup-template.md](sprint-templates/daily-standup-template.md) | 每日站会模板 |
| &nbsp;&nbsp;└─ [sprint-retrospective-template.md](sprint-templates/sprint-retrospective-template.md) | Sprint 回顾会议模板 |
| [resources.md](resources.md) | 敏捷学习资源链接 |

## 1 个月 4 个 Sprint 节奏

```
第 0 周 (准备期)
├── Sprint 0 准备：环境搭建、需求理解、学习路径规划
└── 产品待办列表梳理（Product Backlog Refinement）

第 1 周 (Sprint 1) - 基础功能
├── Sprint 计划会（Sprint Planning）
├── 开发阶段：每日站会
├── Sprint 评审会（Sprint Review）
└── Sprint 回顾会（Sprint Retrospective）

第 2 周 (Sprint 2) - 核心业务
├── Sprint 计划会
├── 开发阶段：每日站会
├── Sprint 评审会
└── Sprint 回顾会

第 3 周 (Sprint 3) - 高级特性
├── Sprint 计划会
├── 开发阶段：每日站会
├── Sprint 评审会
└── Sprint 回顾会

第 4 周 (Sprint 4) - 集成与交付
├── Sprint 计划会
├── 开发阶段：每日站会
├── 系统集成测试
├── Sprint 评审会（最终交付演示）
└── Sprint 回顾会（月度总结）
```

## 各 Sprint 目标参考

| Sprint | 主题 | 目标 | 交付物 |
|--------|------|------|--------|
| Sprint 1 | 基础功能 | 搭建项目骨架，实现基础 CRUD 与消息通路 | 可运行的基础版本，设备能上报数据 |
| Sprint 2 | 核心业务 | 实现核心业务逻辑，规则引擎，告警处理 | 核心功能可用，设备联动正常 |
| Sprint 3 | 高级特性 | AI 助手、日报生成、语音交互等高级功能 | 高级功能可演示 |
| Sprint 4 | 集成交付 | 集成测试、Bug 修复、部署准备、文档完善 | 可交付的版本，完整文档 |

> **说明**：以上 Sprint 主题与目标仅为参考。实现方式不限，团队可根据项目实际情况和优先级灵活调整 Sprint 范围和目标。

## 敏捷原则提醒

1. **个体和互动** 高于流程和工具
2. **可工作的软件** 高于详尽的文档
3. **客户合作** 高于合同谈判
4. **响应变化** 高于遵循计划

也就是说，尽管右侧有价值，我们更重视左侧的价值。模板和流程是为了帮助团队，而不是束缚团队。鼓励根据团队实际情况调整实践方式。

## 建议阅读顺序

1. 先阅读 [scrum-basics.md](scrum-basics.md) 理解 Scrum 基础
2. 浏览 [sprint-templates/](sprint-templates/) 了解各类会议模板
3. 参考 [resources.md](resources.md) 深入学习敏捷
