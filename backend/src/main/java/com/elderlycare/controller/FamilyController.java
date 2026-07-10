package com.elderlycare.controller;

import com.elderlycare.common.Result;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/family")
public class FamilyController {

    @GetMapping("/monitor")
    public ResponseEntity<Result<String>> monitorElderly(Authentication authentication) {
        return ResponseEntity.ok(Result.success("家属监控页面 - " + authentication.getName()));
    }

    @GetMapping("/notifications")
    public ResponseEntity<Result<String>> getNotifications() {
        return ResponseEntity.ok(Result.success("查看通知消息"));
    }
}