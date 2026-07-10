package com.elderlycare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * AI 健康报告响应
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiReportDTO {
    private String report;
    private LocalDateTime generatedAt;
}
