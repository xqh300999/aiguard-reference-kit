package com.elderlycare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 告警统计趋势 DTO
 * <p>对应 API 文档 §10.2 GET /api/v1/stats/alerts/{communityId}?period=weekly
 */
@Data
public class StatsAlertTrendDTO {

    /** 统计周期：daily / weekly / monthly */
    private String period;

    /** 趋势记录 */
    private List<Record> records;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Record {
        /** 时间标签 */
        private String label;
        /** 该时间段告警总数 */
        private long total;
        /** 按告警类型分类的明细 */
        private List<Detail> details;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Detail {
        /** 告警类型 */
        private String type;
        /** 数量 */
        private long count;
    }
}
