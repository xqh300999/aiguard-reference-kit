package com.elderlycare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommunityRequest {

    @NotBlank(message = "社区名称不能为空")
    @Size(max = 100, message = "社区名称不能超过100个字符")
    private String name;

    @Size(max = 255, message = "地址不能超过255个字符")
    private String address;

    @Size(max = 20, message = "联系电话不能超过20个字符")
    private String phone;

    @Size(max = 50, message = "负责人姓名不能超过50个字符")
    private String managerName;
}