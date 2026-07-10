package com.elderlycare.dto;

import com.elderlycare.entity.Device;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceResponse {

    private Long id;
    private String name;
    private String type;
    private String mac;
    private Long elderlyId;
    private Long communityId;
    private String status;
    private LocalDateTime lastHeartbeat;
    private Integer battery;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static DeviceResponse fromEntity(Device device) {
        return DeviceResponse.builder()
                .id(device.getId())
                .name(device.getName())
                .type(device.getType())
                .mac(device.getMac())
                .elderlyId(device.getElderlyId())
                .communityId(device.getCommunityId())
                .status(device.getStatus())
                .lastHeartbeat(device.getLastHeartbeat())
                .battery(device.getBattery())
                .createdAt(device.getCreatedAt())
                .updatedAt(device.getUpdatedAt())
                .build();
    }
}
