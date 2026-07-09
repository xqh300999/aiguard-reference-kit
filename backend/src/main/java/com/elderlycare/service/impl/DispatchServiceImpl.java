package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.common.PageResult;
import com.elderlycare.mapper.AlertMapper;
import com.elderlycare.mapper.DispatchMapper;
import com.elderlycare.model.dto.DispatchCreateDTO;
import com.elderlycare.model.dto.DispatchDTO;
import com.elderlycare.model.dto.DispatchUpdateDTO;
import com.elderlycare.model.entity.Alert;
import com.elderlycare.model.entity.Dispatch;
import com.elderlycare.service.DispatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DispatchServiceImpl implements DispatchService {

    private final DispatchMapper dispatchMapper;
    private final AlertMapper alertMapper;

    private static final Map<String, String> STATUS_NAMES = Map.of(
            "ACTIVE", "处理中",
            "COMPLETED", "已完成",
            "CANCELLED", "已取消"
    );

    @Override
    @Transactional
    public DispatchDTO create(DispatchCreateDTO dto) {
        // 查告警
        Alert alert = alertMapper.selectById(dto.getAlertId());
        if (alert == null) {
            throw new RuntimeException("告警不存在");
        }
        if (!"PENDING".equals(alert.getStatus())) {
            throw new RuntimeException("告警状态为 " + alert.getStatus() + "，无法创建派工单（需 PENDING）");
        }

        // 检查是否已有派工单（alert_id 唯一）
        Dispatch existing = dispatchMapper.selectOne(
                new LambdaQueryWrapper<Dispatch>().eq(Dispatch::getAlertId, dto.getAlertId()));
        if (existing != null) {
            throw new RuntimeException("告警 " + dto.getAlertId() + " 已有派工单，不能重复创建");
        }

        // 创建派工单
        Dispatch dispatch = new Dispatch();
        dispatch.setAlertId(dto.getAlertId());
        dispatch.setHandlerId(dto.getHandlerId());
        dispatch.setDescription(dto.getDescription());
        dispatch.setStatus("ACTIVE");
        dispatchMapper.insert(dispatch);

        // 同步 alert：status → PROCESSING, handler_id
        Alert alertUpdate = new Alert();
        alertUpdate.setId(alert.getId());
        alertUpdate.setStatus("PROCESSING");
        alertUpdate.setHandlerId(dto.getHandlerId());
        alertMapper.updateById(alertUpdate);

        return detail(dispatch.getId());
    }

    @Override
    public PageResult<DispatchDTO> list(Long alertId, Long handlerId, String status, int page, int size) {
        IPage<DispatchDTO> p = new Page<>(page, size);
        IPage<DispatchDTO> result = dispatchMapper.selectDispatchPage(p, alertId, handlerId, status);
        result.getRecords().forEach(this::fillNames);
        return new PageResult<>(result.getRecords(), result.getTotal(), result.getCurrent(), result.getSize());
    }

    @Override
    public DispatchDTO detail(Long id) {
        DispatchDTO dto = dispatchMapper.selectDispatchDetail(id);
        if (dto == null) {
            throw new RuntimeException("派工单不存在");
        }
        fillNames(dto);
        return dto;
    }

    @Override
    @Transactional
    public DispatchDTO update(Long id, DispatchUpdateDTO dto) {
        Dispatch dispatch = dispatchMapper.selectById(id);
        if (dispatch == null) {
            throw new RuntimeException("派工单不存在");
        }

        // 更新派工单字段
        if (dto.getResult() != null) {
            dispatch.setResult(dto.getResult());
        }
        if (dto.getDescription() != null) {
            dispatch.setDescription(dto.getDescription());
        }
        if (dto.getStatus() != null) {
            dispatch.setStatus(dto.getStatus());
        }
        dispatchMapper.updateById(dispatch);

        // 双表同步：更新 alert
        Alert alertUpdate = new Alert();
        alertUpdate.setId(dispatch.getAlertId());
        if (dto.getCause() != null) {
            alertUpdate.setCause(dto.getCause());
        }
        if (dto.getDetails() != null) {
            alertUpdate.setDetails(dto.getDetails());
        }
        // 派工完成 → 告警同步为 RESOLVED
        if ("COMPLETED".equals(dto.getStatus())) {
            alertUpdate.setStatus("RESOLVED");
            alertUpdate.setResolvedAt(LocalDateTime.now());
        }
        alertMapper.updateById(alertUpdate);

        return detail(id);
    }

    private void fillNames(DispatchDTO dto) {
        dto.setStatusName(STATUS_NAMES.getOrDefault(dto.getStatus(), dto.getStatus()));
    }
}
