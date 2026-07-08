package com.elderlycare.service;

import com.elderlycare.dto.LoginRequest;
import com.elderlycare.dto.LoginResponse;
import com.elderlycare.entity.User;
import com.elderlycare.mapper.UserMapper;
import com.elderlycare.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    public LoginResponse login(LoginRequest request) {
        User user = userMapper.findByUsername(request.getUsername());

        if (user == null) {
            throw new RuntimeException("用户名或密码错误");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole(), user.getRealName());

        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .role(user.getRole())
                .realName(user.getRealName())
                .build();
    }
}