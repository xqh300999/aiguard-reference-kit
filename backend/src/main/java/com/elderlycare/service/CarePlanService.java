package com.elderlycare.service;

import com.elderlycare.common.PageResult;
import com.elderlycare.dto.CarePlanCreateDTO;
import com.elderlycare.dto.CarePlanDTO;

/**
 * 关怀计划 Service
 */
public interface CarePlanService {

    /**
     * 创建关怀计划
     */
    CarePlanDTO create(CarePlanCreateDTO dto);

    /**
     * 关怀计划列表（分页 + 筛选）
     */
    PageResult<CarePlanDTO> list(Long workerId, Long elderlyId, String status, int page, int size);

    /**
     * 关怀计划详情
     */
    CarePlanDTO detail(Long id);

    /**
     * 更新关怀计划
     */
    CarePlanDTO update(Long id, CarePlanCreateDTO dto);

    /**
     * 删除关怀计划
     */
    void delete(Long id);
}
