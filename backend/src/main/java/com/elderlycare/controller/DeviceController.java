package com.elderlycare.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.common.Result;
import com.elderlycare.dto.DeviceBindRequest;
import com.elderlycare.dto.DeviceRequest;
import com.elderlycare.dto.DeviceResponse;
import com.elderlycare.service.DeviceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;

    @GetMapping
    public ResponseEntity<Result<IPage<DeviceResponse>>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(Result.success(deviceService.findPage(page, size)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Result<DeviceResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(deviceService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<Result<DeviceResponse>> create(@Valid @RequestBody DeviceRequest request) {
        DeviceResponse device = deviceService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(device));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Result<DeviceResponse>> update(@PathVariable Long id, @Valid @RequestBody DeviceRequest request) {
        return ResponseEntity.ok(Result.success(deviceService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        deviceService.delete(id);
        return ResponseEntity.ok(Result.success(null));
    }

    @PostMapping("/{id}/bind")
    public ResponseEntity<Result<DeviceResponse>> bind(@PathVariable Long id, @Valid @RequestBody DeviceBindRequest request) {
        return ResponseEntity.ok(Result.success(deviceService.bind(id, request.getElderlyId())));
    }

    @PostMapping("/{id}/unbind")
    public ResponseEntity<Result<DeviceResponse>> unbind(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(deviceService.unbind(id)));
    }
}