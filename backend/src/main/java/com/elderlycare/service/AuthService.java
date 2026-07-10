package com.elderlycare.service;

import com.elderlycare.dto.LoginRequest;
import com.elderlycare.dto.LoginResponse;
import com.elderlycare.dto.RegisterRequest;
import com.elderlycare.dto.UserResponse;
import com.elderlycare.entity.Community;
import com.elderlycare.entity.User;
import com.elderlycare.exception.BusinessException;
import com.elderlycare.mapper.CommunityMapper;
import com.elderlycare.mapper.UserMapper;
import com.elderlycare.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final CommunityMapper communityMapper;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    public LoginResponse login(LoginRequest request) {
        User user = userMapper.findByUsername(request.getUsername());

        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole(), user.getRealName());

        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .role(user.getRole())
                .realName(user.getRealName())
                .elderlyId(user.getElderlyId())
                .build();
    }

    @Transactional
    public UserResponse registerMobile(RegisterRequest request) {
        if (!"FAMILY".equals(request.getRole())) {
            throw new BusinessException("移动端仅支持注册家属角色");
        }
        return doRegister(request);
    }

    @Transactional
    public UserResponse registerWeb(RegisterRequest request) {
        if (!"FAMILY".equals(request.getRole()) && !"COMMUNITY_WORKER".equals(request.getRole())) {
            throw new BusinessException("网页端仅支持注册家属或社区工作人员角色");
        }
        return doRegister(request);
    }

    private UserResponse doRegister(RegisterRequest request) {
        long count = userMapper.countByUsernameExcludeId(request.getUsername(), null);
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }

        Community community = communityMapper.findById(request.getCommunityId());
        if (community == null) {
            throw new BusinessException("社区不存在");
        }

        User user = User.builder()
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .realName(request.getRealName())
                .phone(request.getPhone())
                .role(request.getRole())
                .communityId(request.getCommunityId())
                .status("ENABLED")
                .build();
        userMapper.insert(user);
        return UserResponse.fromEntity(userMapper.selectById(user.getId()));
    }
}