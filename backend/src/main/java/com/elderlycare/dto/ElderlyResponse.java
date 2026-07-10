package com.elderlycare.dto;

import com.elderlycare.entity.Elderly;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ElderlyResponse {

    private Long id;
    private String name;
    private Integer age;
    private String gender;
    private String phone;
    private String address;
    private Long communityId;
    private String communityName;
    private String emergencyContact;
    private String healthNotes;
    private String deviceMac;
    private String status;
    private String healthStatus;
    private String todayStatus;
    private Integer recentAlertCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private DeviceInfo device;

    public static ElderlyResponse fromEntity(Elderly elderly) {
        return ElderlyResponse.builder()
                .id(elderly.getId())
                .name(elderly.getName())
                .age(elderly.getAge())
                .gender(elderly.getGender())
                .phone(elderly.getPhone())
                .address(elderly.getAddress())
                .communityId(elderly.getCommunityId())
                .emergencyContact(elderly.getEmergencyContact())
                .healthNotes(elderly.getHealthNotes())
                .deviceMac(elderly.getDeviceMac())
                .status(elderly.getStatus())
                .createdAt(elderly.getCreatedAt())
                .updatedAt(elderly.getUpdatedAt())
                .build();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DeviceInfo {
        private Long id;
        private String name;
        private String type;
        private String status;
        private LocalDateTime lastHeartbeat;
        private Integer battery;
    }
}
