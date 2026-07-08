package com.elderlycare.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 统计相关 Mapper
 * <p>对应 API 文档 §10.1 仪表盘总览
 */
@Mapper
public interface StatsMapper {

    @Select("SELECT COUNT(*) FROM elderly")
    long countElderly();

    @Select("SELECT COUNT(*) FROM device WHERE status = 'ONLINE'")
    long countOnlineDevices();

    @Select("SELECT COUNT(*) FROM alert WHERE status = 'PENDING'")
    long countPendingAlerts();

    /**
     * 今日告警数：以 happened_at 落在今日 00:00 之后为准
     */
    @Select("SELECT COUNT(*) FROM alert WHERE happened_at >= #{startOfToday}")
    long countTodayAlerts(java.time.LocalDateTime startOfToday);
}
