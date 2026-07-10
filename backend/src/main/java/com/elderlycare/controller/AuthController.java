package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.LoginRequest;
import com.elderlycare.dto.LoginResponse;
import com.elderlycare.dto.RefreshResponse;
import com.elderlycare.dto.RegisterRequest;
import com.elderlycare.dto.UserResponse;
import jakarta.servlet.http.HttpServletRequest;
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

    /**
     * 1.2 Token 刷新
     */
    @PostMapping("/refresh")
    public Result<RefreshResponse> refresh(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        String token = (bearer != null && bearer.startsWith("Bearer ")) ? bearer.substring(7) : null;
        if (token == null) {
            throw new RuntimeException("未携带 Token");
        }
        return Result.success(authService.refresh(token));
    }
}