package com.elderlycare.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserBindByContactRequest {

    @NotBlank(message = "老人姓名不能为空")
    private String name;

    @NotBlank(message = "老人电话不能为空")
    private String phone;
}