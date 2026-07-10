package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 关怀计划响应 DTO（含关联名称）
 */
@Data
public class CarePlanDTO {
    private Long id;
    private Long elderlyId;
    private String elderlyName;
    private Long workerId;
    private String workerName;
    private String planType;
    private String frequency;
    private LocalDate startDate;
    private LocalDate endDate;
    private String notes;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
