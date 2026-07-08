package com.elderlycare.controller;

import com.elderlycare.common.Result;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/worker")
public class WorkerController {

    @GetMapping("/tasks")
    public ResponseEntity<Result<String>> getWorkerTasks(Authentication authentication) {
        return ResponseEntity.ok(Result.success("护工任务列表 - " + authentication.getName()));
    }

    @GetMapping("/elderly")
    public ResponseEntity<Result<String>> viewElderly() {
        return ResponseEntity.ok(Result.success("查看老人信息"));
    }
}