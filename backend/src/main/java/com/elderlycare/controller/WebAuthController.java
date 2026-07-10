package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.RegisterRequest;
import com.elderlycare.dto.UserResponse;
import com.elderlycare.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/web/v1/auth")
@RequiredArgsConstructor
public class WebAuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<Result<UserResponse>> registerWeb(@Valid @RequestBody RegisterRequest request) {
        UserResponse user = authService.registerWeb(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(user));
    }
}