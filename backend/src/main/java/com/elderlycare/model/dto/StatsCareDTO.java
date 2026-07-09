package com.elderlycare.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 关怀统计 DTO
 * <p>对应 API 文档 §10.3 GET /api/v1/stats/care/{communityId}?period=weekly
 */
@Data
public class StatsCareDTO {

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
        /** 该时间段关怀总数 */
        private long total;
        /** 按关怀类型分类的明细 */
        private List<Detail> details;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Detail {
        /** 关怀类型 */
        private String type;
        /** 数量 */
        private long count;
    }
}
