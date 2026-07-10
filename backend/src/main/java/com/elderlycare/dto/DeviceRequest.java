package com.elderlycare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceRequest {

    @NotBlank(message = "设备名称不能为空")
    @Size(max = 100, message = "设备名称不能超过100个字符")
    private String name;

    @Size(max = 20, message = "设备类型不能超过20个字符")
    private String type;

    @NotBlank(message = "设备MAC地址不能为空")
    @Size(max = 20, message = "设备MAC地址不能超过20个字符")
    private String mac;

    @NotNull(message = "社区ID不能为空")
    private Long communityId;

    @Size(max = 20, message = "设备状态不能超过20个字符")
    private String status;

    private Integer battery;
}
