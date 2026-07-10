package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.common.PageResult;
import com.elderlycare.dto.CarePlanCreateDTO;
import com.elderlycare.dto.CarePlanDTO;
import com.elderlycare.entity.CarePlan;
import com.elderlycare.entity.Elderly;
import com.elderlycare.entity.User;
import com.elderlycare.mapper.CarePlanMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.mapper.UserMapper;
import com.elderlycare.service.CarePlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CarePlanServiceImpl implements CarePlanService {

    private final CarePlanMapper carePlanMapper;
    private final ElderlyMapper elderlyMapper;
    private final UserMapper userMapper;

    @Override
    public CarePlanDTO create(CarePlanCreateDTO dto) {
        // 校验 elderlyId 存在
        Elderly elderly = elderlyMapper.selectById(dto.getElderlyId());
        if (elderly == null) {
            throw new RuntimeException("老人不存在");
        }

        CarePlan plan = CarePlan.builder()
                .elderlyId(dto.getElderlyId())
                .workerId(dto.getWorkerId())
                .planType(dto.getPlanType())
                .frequency(dto.getFrequency())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .notes(dto.getNotes())
                .status("ACTIVE")
                .build();
        carePlanMapper.insert(plan);

        return detail(plan.getId());
    }

    @Override
    public PageResult<CarePlanDTO> list(Long workerId, Long elderlyId, String status, int page, int size) {
        LambdaQueryWrapper<CarePlan> wrapper = new LambdaQueryWrapper<CarePlan>()
                .eq(workerId != null, CarePlan::getWorkerId, workerId)
                .eq(elderlyId != null, CarePlan::getElderlyId, elderlyId)
                .eq(status != null && !status.isEmpty(), CarePlan::getStatus, status)
                .orderByDesc(CarePlan::getCreatedAt);

        IPage<CarePlan> p = new Page<>(page, size);
        IPage<CarePlan> result = carePlanMapper.selectPage(p, wrapper);

        List<CarePlanDTO> records = result.getRecords().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        records.forEach(this::fillNames);

        return new PageResult<>(records, result.getTotal(), result.getCurrent(), result.getSize());
    }

    @Override
    public CarePlanDTO detail(Long id) {
        CarePlan plan = carePlanMapper.selectById(id);
        if (plan == null) {
            throw new RuntimeException("关怀计划不存在");
        }
        CarePlanDTO dto = toDTO(plan);
        fillNames(dto);
        return dto;
    }

    @Override
    public CarePlanDTO update(Long id, CarePlanCreateDTO dto) {
        CarePlan plan = carePlanMapper.selectById(id);
        if (plan == null) {
            throw new RuntimeException("关怀计划不存在");
        }

        // 更新内容字段（status 由工作流管理，不在此覆盖）
        plan.setElderlyId(dto.getElderlyId());
        plan.setWorkerId(dto.getWorkerId());
        plan.setPlanType(dto.getPlanType());
        plan.setFrequency(dto.getFrequency());
        plan.setStartDate(dto.getStartDate());
        plan.setEndDate(dto.getEndDate());
        plan.setNotes(dto.getNotes());
        carePlanMapper.updateById(plan);

        return detail(id);
    }

    @Override
    public void delete(Long id) {
        CarePlan plan = carePlanMapper.selectById(id);
        if (plan == null) {
            throw new RuntimeException("关怀计划不存在");
        }
        // 简化处理：直接物理删除。
        // 完整实现应检查 care_log 是否有已执行记录，若有则标记为 CANCELLED 而不物理删除；
        // 但本模块暂不依赖 CareLog，为避免循环依赖此处直接物理删除。
        carePlanMapper.deleteById(id);
    }

    /** 实体转 DTO */
    private CarePlanDTO toDTO(CarePlan plan) {
        CarePlanDTO dto = new CarePlanDTO();
        dto.setId(plan.getId());
        dto.setElderlyId(plan.getElderlyId());
        dto.setWorkerId(plan.getWorkerId());
        dto.setPlanType(plan.getPlanType());
        dto.setFrequency(plan.getFrequency());
        dto.setStartDate(plan.getStartDate());
        dto.setEndDate(plan.getEndDate());
        dto.setNotes(plan.getNotes());
        dto.setStatus(plan.getStatus());
        dto.setCreatedAt(plan.getCreatedAt());
        dto.setUpdatedAt(plan.getUpdatedAt());
        return dto;
    }

    /** 填充 elderlyName / workerName */
    private void fillNames(CarePlanDTO dto) {
        if (dto.getElderlyId() != null) {
            Elderly elderly = elderlyMapper.selectById(dto.getElderlyId());
            if (elderly != null) {
                dto.setElderlyName(elderly.getName());
            }
        }
        if (dto.getWorkerId() != null) {
            User worker = userMapper.selectById(dto.getWorkerId());
            if (worker != null) {
                dto.setWorkerName(worker.getRealName());
            }
        }
    }
}
