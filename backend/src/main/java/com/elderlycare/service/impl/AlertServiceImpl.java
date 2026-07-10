package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.common.PageResult;
import com.elderlycare.mapper.AlertMapper;
import com.elderlycare.dto.AlertDTO;
import com.elderlycare.dto.AlertUpdateDTO;
import com.elderlycare.entity.Alert;
import com.elderlycare.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AlertServiceImpl implements AlertService {

    private final AlertMapper alertMapper;

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
    public PageResult<AlertDTO> list(Long communityId, String status, String type, int page, int size) {
        IPage<AlertDTO> p = new Page<>(page, size);
        IPage<AlertDTO> result = alertMapper.selectAlertPage(p, communityId, status, type);
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

        return detail(id);
    }

    /** 填充 typeName / statusName */
    private void fillNames(AlertDTO dto) {
        dto.setTypeName(TYPE_NAMES.getOrDefault(dto.getType(), dto.getType()));
        dto.setStatusName(STATUS_NAMES.getOrDefault(dto.getStatus(), dto.getStatus()));
    }
}
