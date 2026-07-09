package com.elderlycare.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("device")
public class Device {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("name")
    private String name;

    @TableField("type")
    private String type;

    @TableField("mac")
    private String mac;

    @TableField("elderly_id")
    private Long elderlyId;

    @TableField("community_id")
    private Long communityId;

    @TableField("status")
    private String status;

    @TableField("last_heartbeat")
    private LocalDateTime lastHeartbeat;

    @TableField("battery")
    private Integer battery;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
