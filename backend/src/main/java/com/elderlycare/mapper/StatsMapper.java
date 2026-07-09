package com.elderlycare.mapper;

import com.elderlycare.model.dto.TrendRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 统计相关 Mapper
 * <p>对应 API 文档 §10 统计报表（10.1 总览 / 10.2 告警趋势 / 10.3 关怀统计 / 10.4 导出 Excel）
 */
@Mapper
public interface StatsMapper {

    // ==================== 10.1 仪表盘总览 ====================

    /** 老人总数（communityId 为 null 时统计全部） */
    @Select("<script>SELECT COUNT(*) FROM elderly <where> <if test='communityId != null'>community_id = #{communityId}</if> </where></script>")
    long countElderly(@Param("communityId") Long communityId);

    /** 在线设备数 */
    @Select("<script>SELECT COUNT(*) FROM device <where> status = 'ONLINE' <if test='communityId != null'>AND community_id = #{communityId}</if> </where></script>")
    long countOnlineDevices(@Param("communityId") Long communityId);

    /** 待处理告警数 */
    @Select("<script>SELECT COUNT(*) FROM alert <where> status = 'PENDING' <if test='communityId != null'>AND community_id = #{communityId}</if> </where></script>")
    long countPendingAlerts(@Param("communityId") Long communityId);

    /** 今日告警数：以 happened_at 落在今日 00:00 之后为准 */
    @Select("<script>SELECT COUNT(*) FROM alert <where> happened_at &gt;= #{startOfToday} <if test='communityId != null'>AND community_id = #{communityId}</if> </where></script>")
    long countTodayAlerts(@Param("startOfToday") LocalDateTime startOfToday, @Param("communityId") Long communityId);

    // ==================== 10.2 告警统计趋势 ====================

    /** 按时间分组统计告警（daily/weekly/monthly 由 dateFormat 决定） */
    @Select("SELECT DATE_FORMAT(happened_at, #{dateFormat}) AS label, type, COUNT(*) AS count " +
            "FROM alert WHERE community_id = #{communityId} AND happened_at >= #{start} " +
            "GROUP BY label, type ORDER BY label")
    List<TrendRow> alertTrend(@Param("communityId") Long communityId,
                              @Param("start") LocalDateTime start,
                              @Param("dateFormat") String dateFormat);

    // ==================== 10.3 关怀统计 ====================

    /** 按时间分组统计关怀记录 */
    @Select("SELECT DATE_FORMAT(cl.created_at, #{dateFormat}) AS label, cl.type, COUNT(*) AS count " +
            "FROM care_log cl INNER JOIN elderly e ON cl.elderly_id = e.id " +
            "WHERE e.community_id = #{communityId} AND cl.created_at >= #{start} " +
            "GROUP BY label, cl.type ORDER BY label")
    List<TrendRow> careTrend(@Param("communityId") Long communityId,
                             @Param("start") LocalDateTime start,
                             @Param("dateFormat") String dateFormat);

    // ==================== 10.4 导出 Excel ====================

    /** 老人列表（带社区名） */
    @Select("<script>SELECT e.id, e.name, e.age, e.gender, e.phone, e.emergency_contact AS emergencyContact, " +
            "e.health_notes AS healthNotes, e.status, c.name AS communityName " +
            "FROM elderly e LEFT JOIN community c ON e.community_id = c.id " +
            "<where> <if test='communityId != null'>e.community_id = #{communityId}</if> </where> " +
            "ORDER BY e.id</script>")
    List<Map<String, Object>> exportElderly(@Param("communityId") Long communityId);

    /** 告警列表（带老人名、社区名） */
    @Select("<script>SELECT a.id, a.type, a.status, a.priority, a.happened_at AS happenedAt, " +
            "el.name AS elderlyName, c.name AS communityName " +
            "FROM alert a LEFT JOIN elderly el ON a.elderly_id = el.id LEFT JOIN community c ON a.community_id = c.id " +
            "<where> <if test='communityId != null'>a.community_id = #{communityId}</if> </where> " +
            "ORDER BY a.happened_at DESC</script>")
    List<Map<String, Object>> exportAlerts(@Param("communityId") Long communityId);

    /** 关怀记录列表（带老人名、护工名） */
    @Select("<script>SELECT cl.id, cl.type, cl.elderly_status AS elderlyStatus, cl.notes, cl.created_at AS createdAt, " +
            "el.name AS elderlyName, u.real_name AS workerName " +
            "FROM care_log cl LEFT JOIN elderly el ON cl.elderly_id = el.id LEFT JOIN user u ON cl.worker_id = u.id " +
            "<where> <if test='communityId != null'>el.community_id = #{communityId}</if> </where> " +
            "ORDER BY cl.created_at DESC</script>")
    List<Map<String, Object>> exportCareLogs(@Param("communityId") Long communityId);
}
