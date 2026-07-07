# 第一周 MVP 说明

## MVP 目标

**老人按下手表 SOS → 后端生成告警 → 社区人员网页端收到消息处理 → 家人 App 收到通知 → 大屏弹出告警**

## 最小运行功能

| 端 | 需要实现的功能 |
|:---|:--------------|
| ESP32-S3 手表 | WiFi 联网、MQTT 连接、SOS 按键(长按3s触发)、心跳上报(60s)、OLED 显示 |
| Mosquitto | MQTT Broker 稳定运行，接收手表消息 |
| 后端 | 6 张表(community/user/elderly/device/alert/dispatch)、JWT 登录认证、老人/设备 CRUD、MQTT 消费 SOS 和心跳、Alert 列表+状态流转、Dispatch 创建+处理 |
| 社区工作台(Web) | 登录页、告警列表(Tab筛选+分页)、告警详情、接单、处理完成 |
| 管理后台(Web) | 登录页、Dashboard(4统计卡片)、社区/老人/用户/设备/告警管理表格 |
| 家人端 App | 登录页、老人卡片+未读红点、告警列表、老人档案 |
| ESP32-P4 大屏 | 屏点亮+LVGL、WiFi+MQTT、SOS 全屏弹窗 |
| 树莓派 | OS 运行、Docker 可用、固定 IP |
| Git 仓库 | 全员可 clone、main 分支保护 |
