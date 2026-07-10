package com.elderlycare.service;

import com.elderlycare.dto.AiReportDTO;
import com.elderlycare.dto.HealthScoreDTO;

/**
 * AI 功能 Service
 */
public interface AiService {

    /**
     * 11.1 健康评分
     * 评分算法：活动量(40%) + 告警频率(30%) + 关怀覆盖率(20%) + 设备在线(10%)
     */
    HealthScoreDTO healthScore(Long elderlyId);

    /**
     * 11.2 AI 健康报告
     */
    AiReportDTO aiReport(Long elderlyId);

    /**
     * 11.3 触发 AI 日报生成
     */
    AiReportDTO generateDailyReport(Long elderlyId);
}
