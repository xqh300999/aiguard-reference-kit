package com.elderlycare.service;

import com.elderlycare.common.PageResult;
import com.elderlycare.model.dto.DispatchCreateDTO;
import com.elderlycare.model.dto.DispatchDTO;
import com.elderlycare.model.dto.DispatchUpdateDTO;

/**
 * 派工 Service
 */
public interface DispatchService {

    /**
     * 创建派工单 + 同步 alert 状态为 PROCESSING
     */
    DispatchDTO create(DispatchCreateDTO dto);

    /**
     * 派工单列表（分页 + 筛选）
     */
    PageResult<DispatchDTO> list(Long alertId, Long handlerId, String status, int page, int size);

    /**
     * 派工单详情
     */
    DispatchDTO detail(Long id);

    /**
     * 更新派工单（处理结果 + 双表同步 alert）
     */
    DispatchDTO update(Long id, DispatchUpdateDTO dto);
}
