package com.elderlycare.dto;

import com.elderlycare.entity.Elderly;
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
public class ElderlyResponse {

    private Long id;
    private String name;
    private Integer age;
    private String gender;
    private LocalDate birthDate;
    private String phone;
    private String address;
    private Long communityId;
    private String communityName;
    private String emergencyContact;
    private String emergencyPhone;
    private String healthNotes;
    private String roomNumber;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private DeviceInfo device;

    public static ElderlyResponse fromEntity(Elderly elderly) {
        return ElderlyResponse.builder()
                .id(elderly.getId())
                .name(elderly.getName())
                .gender(elderly.getGender())
                .birthDate(elderly.getBirthDate())
                .phone(elderly.getPhone())
                .address(elderly.getAddress())
                .communityId(elderly.getCommunityId())
                .emergencyContact(elderly.getEmergencyContact())
                .emergencyPhone(elderly.getEmergencyPhone())
                .healthNotes(elderly.getHealthStatus())
                .roomNumber(elderly.getRoomNumber())
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