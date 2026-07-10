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
@TableName("elderly")
public class Elderly {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("name")
    private String name;

    /** 年龄（schema.sql 用 age INT，非 birth_date） */
    @TableField("age")
    private Integer age;

    @TableField("gender")
    private String gender;

    @TableField("address")
    private String address;

    @TableField("phone")
    private String phone;

    /** 紧急联系人电话（schema.sql 字段为 emergency_contact） */
    @TableField("emergency_contact")
    private String emergencyContact;

    /** 健康备注（schema.sql 字段为 health_notes） */
    @TableField("health_notes")
    private String healthNotes;

    @TableField("community_id")
    private Long communityId;

    /** 绑定设备 MAC（schema.sql 字段为 device_mac） */
    @TableField("device_mac")
    private String deviceMac;

    @TableField("status")
    private String status;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
