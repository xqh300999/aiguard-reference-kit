package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.common.PageResult;
import com.elderlycare.mapper.AlertMapper;
import com.elderlycare.mapper.DispatchMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.mapper.NotificationMapper;
import com.elderlycare.mapper.UserMapper;
import com.elderlycare.dto.AlertCreateDTO;
import com.elderlycare.dto.AlertDTO;
import com.elderlycare.dto.AlertUpdateDTO;
import com.elderlycare.dto.DispatchDTO;
import com.elderlycare.entity.Alert;
import com.elderlycare.entity.Dispatch;
import com.elderlycare.entity.Elderly;
import com.elderlycare.entity.Notification;
import com.elderlycare.entity.User;
import com.elderlycare.service.AlertService;
import com.elderlycare.websocket.AlertWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AlertServiceImpl implements AlertService {

    private final AlertMapper alertMapper;
    private final ElderlyMapper elderlyMapper;
    private final DispatchMapper dispatchMapper;
    private final UserMapper userMapper;
    private final NotificationMapper notificationMapper;
    private final AlertWebSocketHandler alertWebSocketHandler;
    private final ObjectMapper objectMapper;

    // 告警类型中文映射
    private static final Map<String, String> TYPE_NAMES = Map.of(
            "SOS", "紧急求助",
            "FALL", "跌倒告警",
            "INACTIVITY", "活动异常",
            "LOW_BATTERY", "低电量",
            "DEVICE_OFFLINE", "设备离线",
            "ABNORMAL", "数据异常",
            "PHONE", "电话关怀"
    );

    // 告警状态中文映射
    private static final Map<String, String> STATUS_NAMES = Map.of(
            "PENDING", "待处理",
            "PROCESSING", "处理中",
            "RESOLVED", "已解决",
            "NEED_HOSPITAL", "需送医"
    );

    // 状态流转顺序（单向）
    private static final Map<String, Integer> STATUS_ORDER = Map.of(
            "PENDING", 0,
            "PROCESSING", 1,
            "RESOLVED", 2,
            "NEED_HOSPITAL", 2
    );

    @Override
    public AlertDTO create(AlertCreateDTO dto) {
        Elderly elderly = elderlyMapper.selectById(dto.getElderlyId());
        if (elderly == null) {
            throw new RuntimeException("老人不存在");
        }

        Alert alert = new Alert();
        alert.setType(dto.getType());
        alert.setElderlyId(dto.getElderlyId());
        alert.setCommunityId(elderly.getCommunityId());
        alert.setSource(dto.getSource() == null ? "APP" : dto.getSource());
        alert.setStatus("PENDING");
        // SOS 类型优先级 HIGH，其余默认 MEDIUM
        alert.setPriority("SOS".equals(dto.getType()) ? "HIGH" : "MEDIUM");
        alert.setHappenedAt(LocalDateTime.now());
        if (dto.getLat() != null) {
            alert.setLat(dto.getLat());
        }
        if (dto.getLng() != null) {
            alert.setLng(dto.getLng());
        }
        alertMapper.insert(alert);

        // 创建通知：通知社区工作者
        createAlertNotification(alert, elderly);

        // WebSocket 实时推送 NEW_ALERT
        broadcastAlert("NEW_ALERT", alert);

        return detail(alert.getId());
    }

    @Override
    public PageResult<AlertDTO> list(Long elderlyId, Long communityId, String status, String type, int page, int size) {
        IPage<AlertDTO> p = new Page<>(page, size);
        IPage<AlertDTO> result = alertMapper.selectAlertPage(p, elderlyId, communityId, status, type);
        result.getRecords().forEach(this::fillNames);
        return new PageResult<>(result.getRecords(), result.getTotal(), result.getCurrent(), result.getSize());
    }

    @Override
    public AlertDTO detail(Long id) {
        AlertDTO dto = alertMapper.selectAlertDetail(id);
        if (dto == null) {
            throw new RuntimeException("告警不存在");
        }
        fillNames(dto);
        fillNotificationId(dto);

        Dispatch dispatch = dispatchMapper.selectOne(
                new LambdaQueryWrapper<Dispatch>().eq(Dispatch::getAlertId, id));
        if (dispatch != null) {
            DispatchDTO dispatchDTO = new DispatchDTO();
            dispatchDTO.setId(dispatch.getId());
            dispatchDTO.setAlertId(dispatch.getAlertId());
            dispatchDTO.setHandlerId(dispatch.getHandlerId());
            dispatchDTO.setStatus(dispatch.getStatus());
            dispatchDTO.setDescription(dispatch.getDescription());
            dispatchDTO.setResult(dispatch.getResult());
            dispatchDTO.setCreatedAt(dispatch.getCreatedAt());
            if (dispatch.getHandlerId() != null) {
                User handler = userMapper.selectById(dispatch.getHandlerId());
                if (handler != null) {
                    dispatchDTO.setHandlerName(handler.getRealName());
                }
            }
            dto.setDispatch(dispatchDTO);
        }

        return dto;
    }

    @Override
    public AlertDTO updateStatus(Long id, AlertUpdateDTO dto) {
        Alert alert = alertMapper.selectById(id);
        if (alert == null) {
            throw new RuntimeException("告警不存在");
        }

        // 校验状态单向流转
        String oldStatus = alert.getStatus();
        String newStatus = dto.getStatus();
        if (newStatus != null && !newStatus.equals(oldStatus)) {
            Integer oldOrder = STATUS_ORDER.get(oldStatus);
            Integer newOrder = STATUS_ORDER.get(newStatus);
            if (oldOrder == null || newOrder == null || newOrder < oldOrder) {
                throw new RuntimeException("告警状态不能从 " + STATUS_NAMES.getOrDefault(oldStatus, oldStatus)
                        + " 回退到 " + STATUS_NAMES.getOrDefault(newStatus, newStatus));
            }
            alert.setStatus(newStatus);
            if ("RESOLVED".equals(newStatus) || "NEED_HOSPITAL".equals(newStatus)) {
                alert.setResolvedAt(LocalDateTime.now());
            }
        }
        if (dto.getCause() != null) {
            alert.setCause(dto.getCause());
        }
        if (dto.getDetails() != null) {
            alert.setDetails(dto.getDetails());
        }
        alertMapper.updateById(alert);

        // WebSocket 实时推送 ALERT_UPDATE
        broadcastAlertUpdate(alert);

        return detail(id);
    }

    /** 填充 typeName / statusName */
    private void fillNames(AlertDTO dto) {
        dto.setTypeName(TYPE_NAMES.getOrDefault(dto.getType(), dto.getType()));
        dto.setStatusName(STATUS_NAMES.getOrDefault(dto.getStatus(), dto.getStatus()));
    }

    /** 广播告警 WebSocket 消息 */
    private void broadcastAlert(String msgType, Alert alert) {
        try {
            String elderlyName = null;
            if (alert.getElderlyId() != null) {
                Elderly elderly = elderlyMapper.selectById(alert.getElderlyId());
                if (elderly != null) {
                    elderlyName = elderly.getName();
                }
            }
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("alertId", alert.getId());
            data.put("type", alert.getType());
            data.put("elderlyName", elderlyName);
            data.put("communityId", alert.getCommunityId());
            data.put("status", alert.getStatus());
            data.put("happenedAt", alert.getHappenedAt());

            Map<String, Object> message = new LinkedHashMap<>();
            message.put("type", msgType);
            message.put("data", data);

            alertWebSocketHandler.broadcast(objectMapper.writeValueAsString(message));
        } catch (Exception ignored) {
        }
    }

    /** 告警状态变更推送 ALERT_UPDATE */
    private void broadcastAlertUpdate(Alert alert) {
        broadcastAlert("ALERT_UPDATE", alert);
    }

    /** 创建告警通知：通知社区工作者 + 家属用户 */
    private void createAlertNotification(Alert alert, Elderly elderly) {
        String typeName = TYPE_NAMES.getOrDefault(alert.getType(), alert.getType());
        String title = "新" + typeName + "告警";
        String content = elderly.getName() + "触发" + typeName + "，请尽快处理";

        // 通知社区工作者
        LambdaQueryWrapper<User> workerWrapper = new LambdaQueryWrapper<>();
        workerWrapper.eq(User::getCommunityId, elderly.getCommunityId());
        workerWrapper.eq(User::getRole, "WORKER");
        workerWrapper.eq(User::getStatus, "ACTIVE");
        userMapper.selectList(workerWrapper).forEach(worker -> {
            Notification notification = Notification.builder()
                    .userId(worker.getId())
                    .alertId(alert.getId())
                    .title(title)
                    .content(content)
                    .type("ALERT")
                    .isRead(false)
                    .build();
            notificationMapper.insert(notification);
        });

        // 通知绑定该老人的家属用户
        LambdaQueryWrapper<User> familyWrapper = new LambdaQueryWrapper<>();
        familyWrapper.eq(User::getElderlyId, elderly.getId());
        familyWrapper.eq(User::getStatus, "ACTIVE");
        userMapper.selectList(familyWrapper).forEach(family -> {
            Notification notification = Notification.builder()
                    .userId(family.getId())
                    .alertId(alert.getId())
                    .title(title)
                    .content(content)
                    .type("ALERT")
                    .isRead(false)
                    .build();
            notificationMapper.insert(notification);
        });
    }

    /** 填充 notificationId（取该告警的第一条通知） */
    private void fillNotificationId(AlertDTO dto) {
        Notification notification = notificationMapper.selectOne(
                new LambdaQueryWrapper<Notification>()
                        .eq(Notification::getAlertId, dto.getId())
                        .orderByAsc(Notification::getId)
                        .last("LIMIT 1"));
        if (notification != null) {
            dto.setNotificationId(notification.getId());
        }
    }
}
