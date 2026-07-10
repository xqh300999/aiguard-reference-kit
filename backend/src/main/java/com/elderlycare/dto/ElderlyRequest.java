package com.elderlycare.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ElderlyRequest {

    private Long id;

    @Size(max = 50, message = "姓名不能超过50个字符")
    private String name;

    private Integer age;

    @Size(max = 10, message = "性别不能超过10个字符")
    private String gender;

    private LocalDate birthDate;

    @Size(max = 20, message = "手机号不能超过20个字符")
    private String phone;

    @Size(max = 255, message = "地址不能超过255个字符")
    private String address;

    private Long communityId;

    @Size(max = 50, message = "紧急联系人不能超过50个字符")
    private String emergencyContact;

    @Size(max = 20, message = "紧急联系电话不能超过20个字符")
    private String emergencyPhone;

    @Size(max = 500, message = "健康备注不能超过500个字符")
    private String healthNotes;

    @Size(max = 20, message = "房间号不能超过20个字符")
    private String roomNumber;
}