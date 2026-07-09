package com.elderlycare.model.dto;

import lombok.Data;

/**
 * 趋势查询行（告警趋势 / 关怀统计通用）
 */
@Data
public class TrendRow {

    /** 时间标签（按 period 格式化，如 2026-07-05 / 2026-W27 / 2026-07） */
    private String label;

    /** 类型（告警类型或关怀类型） */
    private String type;

    /** 数量 */
    private Long count;
}
