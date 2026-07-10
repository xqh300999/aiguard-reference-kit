package com.elderlycare.dto;

import lombok.Data;

/**
 * 告警状态更新 DTO（PATCH）
 */
@Data
public class AlertUpdateDTO {
    private String status;
    private String cause;
    private String details;
}
