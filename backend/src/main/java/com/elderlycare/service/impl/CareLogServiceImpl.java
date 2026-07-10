package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.common.PageResult;
import com.elderlycare.dto.CareLogCreateDTO;
import com.elderlycare.dto.CareLogDTO;
import com.elderlycare.entity.CareLog;
import com.elderlycare.entity.CarePlan;
import com.elderlycare.mapper.CareLogMapper;
import com.elderlycare.service.CareLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CareLogServiceImpl implements CareLogService {

    private final CareLogMapper careLogMapper;

    @Override
    @Transactional
    public CareLogDTO create(CareLogCreateDTO dto) {
        // planId 必填，用于推导 elderlyId / workerId
        if (dto.getPlanId() == null) {
            throw new RuntimeException("planId 不能为空");
        }

        CarePlan plan = careLogMapper.selectCarePlanById(dto.getPlanId());
        if (plan == null) {
            throw new RuntimeException("关怀计划不存在");
        }

        // workerId 优先取请求体，未传则用计划上的 workerId
        Long workerId = dto.getWorkerId() != null ? dto.getWorkerId() : plan.getWorkerId();

        CareLog careLog = CareLog.builder()
                .planId(dto.getPlanId())
                .workerId(workerId)
                .elderlyId(plan.getElderlyId())
                .type(dto.getType() != null ? dto.getType() : "OTHER")
                .elderlyStatus(dto.getElderlyStatus() != null ? dto.getElderlyStatus() : "GOOD")
                .notes(dto.getNotes())
                .build();
        careLogMapper.insert(careLog);

        return detail(careLog.getId());
    }

    @Override
    public PageResult<CareLogDTO> list(Long planId, Long workerId, int page, int size) {
        IPage<CareLogDTO> p = new Page<>(page, size);
        IPage<CareLogDTO> result = careLogMapper.selectCareLogPage(p, planId, workerId);
        return new PageResult<>(result.getRecords(), result.getTotal(), result.getCurrent(), result.getSize());
    }

    @Override
    public CareLogDTO detail(Long id) {
        CareLogDTO dto = careLogMapper.selectCareLogDetail(id);
        if (dto == null) {
            throw new RuntimeException("关怀记录不存在");
        }
        return dto;
    }
}
