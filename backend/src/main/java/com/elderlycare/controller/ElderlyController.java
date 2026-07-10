package com.elderlycare.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.dto.AlertDTO;
import com.elderlycare.dto.ElderlyRequest;
import com.elderlycare.dto.ElderlyResponse;
import com.elderlycare.service.AlertService;
import com.elderlycare.service.ElderlyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/elderly")
@RequiredArgsConstructor
public class ElderlyController {

    private final ElderlyService elderlyService;
    private final AlertService alertService;

    @GetMapping
    public ResponseEntity<Result<IPage<ElderlyResponse>>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long communityId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String name) {
        return ResponseEntity.ok(Result.success(elderlyService.findPage(page, size, communityId, status, name)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Result<ElderlyResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(elderlyService.findById(id)));
    }

    @GetMapping("/{id}/alerts")
    public ResponseEntity<Result<PageResult<AlertDTO>>> alertsByElderly(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(Result.success(alertService.list(id, null, null, null, page, size)));
    }

    @PostMapping
    public ResponseEntity<Result<ElderlyResponse>> create(@Valid @RequestBody ElderlyRequest request) {
        ElderlyResponse elderly = elderlyService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(elderly));
    }

    @PutMapping
    public ResponseEntity<Result<ElderlyResponse>> update(@Valid @RequestBody ElderlyRequest request) {
        return ResponseEntity.ok(Result.success(elderlyService.update(request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        elderlyService.delete(id);
        return ResponseEntity.ok(Result.success(null));
    }

    @GetMapping("/search")
    public ResponseEntity<Result<List<ElderlyResponse>>> search(@RequestParam String keyword) {
        return ResponseEntity.ok(Result.success(elderlyService.search(keyword)));
    }

    @PostMapping("/register")
    public ResponseEntity<Result<ElderlyResponse>> register(@Valid @RequestBody ElderlyRequest request) {
        ElderlyResponse elderly = elderlyService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(elderly));
    }

    @PutMapping("/update-by-contact")
    public ResponseEntity<Result<ElderlyResponse>> updateByContact(@Valid @RequestBody ElderlyRequest request) {
        return ResponseEntity.ok(Result.success(elderlyService.updateByContact(request.getName(), request.getPhone(), request)));
    }
}