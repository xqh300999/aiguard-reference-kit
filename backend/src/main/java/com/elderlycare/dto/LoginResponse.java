package com.elderlycare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String token;
    private Long userId;
    private String role;
    private String realName;
    private Long elderlyId;
    private String elderlyName;
    private Long communityId;
    private String communityName;
}