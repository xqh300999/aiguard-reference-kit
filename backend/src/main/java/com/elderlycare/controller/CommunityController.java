package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.CommunityRequest;
import com.elderlycare.entity.Community;
import com.elderlycare.service.CommunityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/community")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;

    @GetMapping
    public ResponseEntity<Result<List<Community>>> list() {
        return ResponseEntity.ok(Result.success(communityService.findAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Result<Community>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(Result.success(communityService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<Result<Community>> create(@Valid @RequestBody CommunityRequest request) {
        Community community = communityService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Result.success(community));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Result<Community>> update(@PathVariable Long id, @Valid @RequestBody CommunityRequest request) {
        return ResponseEntity.ok(Result.success(communityService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> delete(@PathVariable Long id) {
        communityService.delete(id);
        return ResponseEntity.ok(Result.success(null));
    }
}