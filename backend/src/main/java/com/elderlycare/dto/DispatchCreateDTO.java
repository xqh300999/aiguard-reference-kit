package com.elderlycare.dto;

import lombok.Data;

/**
 * 创建派工单 DTO
 */
@Data
public class DispatchCreateDTO {
    private Long alertId;
    private Long handlerId;
    private String description;
}
