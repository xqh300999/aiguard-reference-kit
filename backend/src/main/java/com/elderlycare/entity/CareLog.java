package com.elderlycare.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 关怀记录实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("care_log")
public class CareLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long planId;
    private Long workerId;
    private Long elderlyId;
    private String type;
    private String elderlyStatus;
    private String notes;
    private LocalDateTime createdAt;
}
