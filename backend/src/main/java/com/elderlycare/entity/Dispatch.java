package com.elderlycare.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 派工单实体
 */
@Data
@TableName("dispatch")
public class Dispatch {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long alertId;
    private Long handlerId;
    private String description;
    private String result;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
