package com.elderlycare.model.dto;

import lombok.Data;

/**
 * 更新派工单 DTO（处理结果 + 状态）
 */
@Data
public class DispatchUpdateDTO {
    private String result;
    private String status;
    private String description;
    /** 同步更新 alert 的 cause 字段 */
    private String cause;
    /** 同步更新 alert 的 details 字段 */
    private String details;
}
