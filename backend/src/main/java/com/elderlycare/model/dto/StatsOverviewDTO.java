package com.elderlycare.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 仪表盘总览统计 DTO
 * <p>对应 API 文档 §10.1 GET /api/v1/stats/overview
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StatsOverviewDTO {

    /** 老人总数 */
    private Long totalElderly;

    /** 今日告警数 */
    private Long todayAlerts;

    /** 在线设备数 */
    private Long onlineDevices;

    /** 待处理告警数 */
    private Long pendingAlerts;
}
