package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 关怀记录响应 DTO（含关联名称）
 */
@Data
public class CareLogDTO {
    private Long id;
    private Long planId;
    private Long workerId;
    private String workerName;
    private Long elderlyId;
    private String elderlyName;
    private String type;
    private String elderlyStatus;
    private String notes;
    private String planType;
    private LocalDateTime createdAt;
}
