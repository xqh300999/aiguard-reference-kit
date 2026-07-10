package com.elderlycare.service;

import com.elderlycare.common.PageResult;
import com.elderlycare.dto.AlertCreateDTO;
import com.elderlycare.dto.AlertDTO;
import com.elderlycare.dto.AlertUpdateDTO;

/**
 * 告警 Service
 */
public interface AlertService {

    /**
     * 6.1 创建告警
     */
    AlertDTO create(AlertCreateDTO dto);

    /**
     * 告警列表（分页 + 筛选）
     */
    PageResult<AlertDTO> list(Long elderlyId, Long communityId, String status, String type, int page, int size);

    /**
     * 告警详情
     */
    AlertDTO detail(Long id);

    /**
     * 更新告警状态（单向流转：PENDING → PROCESSING → RESOLVED）
     */
    AlertDTO updateStatus(Long id, AlertUpdateDTO dto);
}
