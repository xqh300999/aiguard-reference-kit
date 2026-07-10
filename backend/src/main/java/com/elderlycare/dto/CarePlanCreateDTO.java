package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDate;

/**
 * 创建/更新关怀计划 DTO
 */
@Data
public class CarePlanCreateDTO {
    private Long elderlyId;
    private Long workerId;
    private String planType;
    private String frequency;
    private LocalDate startDate;
    private LocalDate endDate;
    private String notes;
}
