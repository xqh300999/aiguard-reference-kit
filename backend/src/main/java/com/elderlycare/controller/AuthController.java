package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.LoginRequest;
import com.elderlycare.dto.LoginResponse;
import com.elderlycare.dto.RegisterRequest;
import com.elderlycare.dto.UserResponse;
import com.elderlycare.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<Result<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(Result.success(response));
    }

    @PostMapping("/register")
    public ResponseEntity<Result<UserResponse>> registerMobile(@Valid @RequestBody RegisterRequest request) {
        UserResponse user = authService.registerMobile(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(user));
    }
}