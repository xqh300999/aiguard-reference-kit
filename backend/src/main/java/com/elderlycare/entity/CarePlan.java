package com.elderlycare.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 关怀计划实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("care_plan")
public class CarePlan {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long elderlyId;
    private Long workerId;
    private String planType;
    private String frequency;
    private LocalDate startDate;
    private LocalDate endDate;
    private String notes;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
