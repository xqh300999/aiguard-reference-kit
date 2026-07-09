package com.elderlycare.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.dto.UserRequest;
import com.elderlycare.dto.UserResponse;

public interface UserService {

    UserResponse create(UserRequest request);

    UserResponse update(Long id, UserRequest request);

    void delete(Long id);

    UserResponse findById(Long id);

    IPage<UserResponse> findPage(int page, int size);

    UserResponse bindElderly(Long userId, Long elderlyId);

    UserResponse bindElderlyByContact(Long userId, String name, String phone);
}