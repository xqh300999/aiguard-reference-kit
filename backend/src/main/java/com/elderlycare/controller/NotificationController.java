package com.elderlycare.controller;

import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.dto.NotificationDTO;
import com.elderlycare.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 通知接口
 * <p>对应 API 文档 §12 通知
 */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * 12.1 通知列表
     */
    @GetMapping
    public Result<PageResult<NotificationDTO>> list(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(notificationService.list(userId, page, size));
    }

    /**
     * 12.2 标记已读
     */
    @PatchMapping("/{id}/read")
    public Result<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return Result.success(null);
    }

    /**
     * 12.3 未读数
     */
    @GetMapping("/unread-count")
    public Result<Map<String, Object>> unreadCount(@RequestParam Long userId) {
        return Result.success(Map.of("unreadCount", notificationService.unreadCount(userId)));
    }
}
