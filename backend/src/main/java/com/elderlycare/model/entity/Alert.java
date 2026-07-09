package com.elderlycare.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 告警实体
 */
@Data
@TableName("alert")
public class Alert {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String type;
    private Long elderlyId;
    private Long communityId;
    private Long deviceId;
    private String source;
    private String status;
    private String priority;
    private Long handlerId;
    private BigDecimal lat;
    private BigDecimal lng;
    private String cause;
    private String details;
    private LocalDateTime happenedAt;
    private LocalDateTime resolvedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
