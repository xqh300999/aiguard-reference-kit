package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.elderlycare.dto.AiReportDTO;
import com.elderlycare.dto.HealthScoreDTO;
import com.elderlycare.entity.Alert;
import com.elderlycare.entity.CareLog;
import com.elderlycare.entity.Device;
import com.elderlycare.entity.Elderly;
import com.elderlycare.mapper.AlertMapper;
import com.elderlycare.mapper.CareLogMapper;
import com.elderlycare.mapper.DeviceMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * AI 功能实现
 * <p>
 * 评分算法：活动量(40%) + 告警频率(30%) + 关怀覆盖率(20%) + 设备在线(10%)
 * <p>
 * 说明：当前为基于规则的本 地评分与报告生成，未接入通义千问；
 * 后续可替换 aiReport 为外部 AI 调用，AI 不可用时返回 503。
 */
@Service
@RequiredArgsConstructor
public class AiServiceImpl implements AiService {

    private final ElderlyMapper elderlyMapper;
    private final AlertMapper alertMapper;
    private final CareLogMapper careLogMapper;
    private final DeviceMapper deviceMapper;

    @Override
    public HealthScoreDTO healthScore(Long elderlyId) {
        Elderly elderly = elderlyMapper.selectById(elderlyId);
        if (elderly == null) {
            throw new RuntimeException("老人不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime weekAgo = now.minusDays(7);

        // 设备（取该老人绑定的设备）
        Device device = deviceMapper.selectOne(
                new LambdaQueryWrapper<Device>().eq(Device::getElderlyId, elderlyId));

        // 近 7 天告警数
        long recentAlerts = alertMapper.selectCount(
                new LambdaQueryWrapper<Alert>()
                        .eq(Alert::getElderlyId, elderlyId)
                        .ge(Alert::getHappenedAt, weekAgo));

        // 近 7 天关怀记录数
        long recentCareLogs = careLogMapper.selectCount(
                new LambdaQueryWrapper<CareLog>()
                        .eq(CareLog::getElderlyId, elderlyId)
                        .ge(CareLog::getCreatedAt, weekAgo));

        // ===== 评分计算 =====
        // 1. 设备在线 (10%)
        int onlineScore = (device != null && "ONLINE".equals(device.getStatus())) ? 10 : 0;

        // 2. 告警频率 (30%)：0 条=30，每条扣 6 分，最低 0
        int alertsScore = (int) Math.max(0, 30 - recentAlerts * 6);

        // 3. 关怀覆盖率 (20%)：>=3 条=20，>=1 条=15，0 条=5
        int careScore = recentCareLogs >= 3 ? 20 : (recentCareLogs >= 1 ? 15 : 5);

        // 4. 活动量 (40%)：以设备最近心跳时间作为活动代理
        int activityScore;
        if (device != null && device.getLastHeartbeat() != null) {
            long hours = Duration.between(device.getLastHeartbeat(), now).toHours();
            if (hours <= 1) {
                activityScore = 40;
            } else if (hours <= 24) {
                activityScore = 30;
            } else {
                activityScore = 15;
            }
        } else {
            activityScore = 10;
        }

        int total = activityScore + alertsScore + careScore + onlineScore;

        return HealthScoreDTO.builder()
                .score(total)
                .breakdown(Map.of(
                        "activity", activityScore,
                        "alerts", alertsScore,
                        "care", careScore,
                        "online", onlineScore))
                .evaluateAt(now)
                .build();
    }

    @Override
    public AiReportDTO aiReport(Long elderlyId) {
        HealthScoreDTO score = healthScore(elderlyId);
        Elderly elderly = elderlyMapper.selectById(elderlyId);

        LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
        long recentAlerts = alertMapper.selectCount(
                new LambdaQueryWrapper<Alert>()
                        .eq(Alert::getElderlyId, elderlyId)
                        .ge(Alert::getHappenedAt, weekAgo));
        long recentCare = careLogMapper.selectCount(
                new LambdaQueryWrapper<CareLog>()
                        .eq(CareLog::getElderlyId, elderlyId)
                        .ge(CareLog::getCreatedAt, weekAgo));

        String level;
        if (score.getScore() >= 80) {
            level = "良好";
        } else if (score.getScore() >= 60) {
            level = "一般";
        } else {
            level = "需关注";
        }

        String report = String.format(
                "%s 当前健康评分 %d 分（%s）。近 7 天告警 %d 次、关怀记录 %d 次。" +
                        "评分明细：活动量 %d、告警 %d、关怀 %d、在线 %d。",
                elderly.getName(),
                score.getScore(), level,
                recentAlerts, recentCare,
                score.getBreakdown().get("activity"),
                score.getBreakdown().get("alerts"),
                score.getBreakdown().get("care"),
                score.getBreakdown().get("online"));

        if (recentAlerts > 0) {
            report += "建议：关注近期告警，安排社区人员跟进。";
        } else if (recentCare == 0) {
            report += "建议：近期无关怀记录，建议安排走访或电话关怀。";
        } else {
            report += "建议：保持当前关怀频率。";
        }

        return AiReportDTO.builder()
                .report(report)
                .generatedAt(LocalDateTime.now())
                .build();
    }

    @Override
    public AiReportDTO generateDailyReport(Long elderlyId) {
        return aiReport(elderlyId);
    }
}
