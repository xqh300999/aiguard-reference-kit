package com.elderlycare.dto;

import lombok.Data;

/**
 * 创建关怀记录 DTO
 */
@Data
public class CareLogCreateDTO {
    private Long planId;
    private Long workerId;
    private String type;
    private String elderlyStatus;
    private String notes;
}
