package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 告警响应 DTO（含关联名称）
 */
@Data
public class AlertDTO {
    private Long id;
    private String type;
    private String typeName;
    private Long elderlyId;
    private String elderlyName;
    private Long communityId;
    private String communityName;
    private Long deviceId;
    private String source;
    private String status;
    private String statusName;
    private String priority;
    private Long handlerId;
    private String handlerName;
    private String cause;
    private String details;
    private LocalDateTime happenedAt;
    private LocalDateTime resolvedAt;
    private LocalDateTime createdAt;
}
