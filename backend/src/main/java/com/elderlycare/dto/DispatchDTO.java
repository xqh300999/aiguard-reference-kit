package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 派工单响应 DTO（含关联名称）
 */
@Data
public class DispatchDTO {
    private Long id;
    private Long alertId;
    private String alertType;
    private String alertStatus;
    private Long elderlyId;
    private String elderlyName;
    private Long communityId;
    private String communityName;
    private Long handlerId;
    private String handlerName;
    private String description;
    private String result;
    private String status;
    private String statusName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
