package com.elderlycare.service;

import com.elderlycare.common.PageResult;
import com.elderlycare.dto.CareLogCreateDTO;
import com.elderlycare.dto.CareLogDTO;

/**
 * 关怀记录 Service
 */
public interface CareLogService {

    /**
     * 创建关怀记录
     */
    CareLogDTO create(CareLogCreateDTO dto);

    /**
     * 关怀记录列表（分页 + 筛选）
     */
    PageResult<CareLogDTO> list(Long planId, Long workerId, int page, int size);

    /**
     * 关怀记录详情
     */
    CareLogDTO detail(Long id);
}
