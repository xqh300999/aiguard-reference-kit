package com.elderlycare.service;

import com.elderlycare.common.PageResult;
import com.elderlycare.dto.NotificationDTO;

/**
 * 通知 Service
 */
public interface NotificationService {

    /**
     * 通知列表（分页）
     */
    PageResult<NotificationDTO> list(Long userId, int page, int size);

    /**
     * 标记通知为已读
     */
    void markAsRead(Long id);

    /**
     * 未读通知数
     */
    Long unreadCount(Long userId);
}
