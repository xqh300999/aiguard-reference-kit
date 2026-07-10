package com.elderlycare.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 创建告警请求 DTO
 */
@Data
public class AlertCreateDTO {
    private String type;
    private Long elderlyId;
    private String source;
    private BigDecimal lat;
    private BigDecimal lng;
}
