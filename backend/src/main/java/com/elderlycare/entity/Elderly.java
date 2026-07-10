package com.elderlycare.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
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

    @TableField("gender")
    private String gender;

    @TableField("birth_date")
    private LocalDate birthDate;

    @TableField("phone")
    private String phone;

    @TableField("address")
    private String address;

    @TableField("community_id")
    private Long communityId;

    @TableField("emergency_contact")
    private String emergencyContact;

    @TableField("emergency_phone")
    private String emergencyPhone;

    @TableField("health_status")
    private String healthStatus;

    @TableField("room_number")
    private String roomNumber;

    @TableField("status")
    private String status;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}