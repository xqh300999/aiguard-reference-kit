package com.elderlycare.controller;

import com.elderlycare.common.Result;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {

    @GetMapping("/dashboard")
    public ResponseEntity<Result<String>> getAdminDashboard(Authentication authentication) {
        return ResponseEntity.ok(Result.success("管理员仪表盘 - " + authentication.getName()));
    }

    @GetMapping("/users")
    public ResponseEntity<Result<String>> manageUsers() {
        return ResponseEntity.ok(Result.success("管理所有用户"));
    }
}