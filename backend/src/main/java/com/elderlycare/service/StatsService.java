package com.elderlycare.service;

import com.elderlycare.model.dto.StatsAlertTrendDTO;
import com.elderlycare.model.dto.StatsCareDTO;
import com.elderlycare.model.dto.StatsOverviewDTO;

import java.io.IOException;
import java.io.OutputStream;

/**
 * 统计 Service
 * <p>对应 API 文档 §10 统计报表
 */
public interface StatsService {

    /**
     * 10.1 仪表盘总览
     *
     * @param communityId 社区 ID（为 null 时统计全部）
     * @return totalElderly / todayAlerts / onlineDevices / pendingAlerts
     */
    StatsOverviewDTO overview(Long communityId);

    /**
     * 10.2 告警统计趋势
     *
     * @param communityId 社区 ID
     * @param period      daily / weekly / monthly
     */
    StatsAlertTrendDTO alertTrend(Long communityId, String period);

    /**
     * 10.3 关怀统计
     *
     * @param communityId 社区 ID
     * @param period      daily / weekly / monthly
     */
    StatsCareDTO careTrend(Long communityId, String period);

    /**
     * 10.4 导出 Excel（3 个 Sheet：老人列表、告警统计、关怀统计）
     *
     * @param communityId 社区 ID（为 null 时导出全部）
     * @param out         输出流
     */
    void exportExcel(Long communityId, OutputStream out) throws IOException;
}
