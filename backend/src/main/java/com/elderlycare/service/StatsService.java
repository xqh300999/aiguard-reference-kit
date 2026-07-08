package com.elderlycare.service;

import com.elderlycare.model.dto.StatsOverviewDTO;

/**
 * 统计 Service
 */
public interface StatsService {

    /**
     * 仪表盘总览统计
     *
     * @return 4 字段：totalElderly / todayAlerts / onlineDevices / pendingAlerts
     */
    StatsOverviewDTO overview();
}
