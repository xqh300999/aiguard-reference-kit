package com.elderlycare.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.common.Result;
import com.elderlycare.dto.UserBindByContactRequest;
import com.elderlycare.dto.UserBindRequest;
import com.elderlycare.dto.UserRequest;
import com.elderlycare.dto.UserResponse;
import com.elderlycare.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<Result<IPage<UserResponse>>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(Result.success(userService.findPage(page, size)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Result<UserResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(userService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<Result<UserResponse>> create(@Valid @RequestBody UserRequest request) {
        UserResponse user = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Result<UserResponse>> update(@PathVariable Long id, @Valid @RequestBody UserRequest request) {
        return ResponseEntity.ok(Result.success(userService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.ok(Result.success(null));
    }

    @PutMapping("/{id}/bind")
    public ResponseEntity<Result<UserResponse>> bind(@PathVariable Long id, @Valid @RequestBody UserBindRequest request) {
        return ResponseEntity.ok(Result.success(userService.bindElderly(id, request.getElderlyId())));
    }

    @PutMapping("/{id}/bind-by-contact")
    public ResponseEntity<Result<UserResponse>> bindByContact(@PathVariable Long id, @Valid @RequestBody UserBindByContactRequest request) {
        return ResponseEntity.ok(Result.success(userService.bindElderlyByContact(id, request.getName(), request.getPhone())));
    }
}