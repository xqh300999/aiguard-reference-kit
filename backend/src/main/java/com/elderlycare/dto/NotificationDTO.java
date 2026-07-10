package com.elderlycare.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知响应 DTO
 */
@Data
public class NotificationDTO {
    private Long id;
    private Long userId;
    private Long alertId;
    private String title;
    private String content;
    private String type;
    private Boolean isRead;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
