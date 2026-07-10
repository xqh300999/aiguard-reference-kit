package com.elderlycare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 健康评分响应
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthScoreDTO {
    private int score;
    private Map<String, Integer> breakdown;
    private LocalDateTime evaluateAt;
}
