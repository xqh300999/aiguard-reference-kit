package com.elderlycare.controller;

import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.dto.CareLogCreateDTO;
import com.elderlycare.dto.CareLogDTO;
import com.elderlycare.service.CareLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 关怀记录接口
 * <p>对应 API 文档 §9 关怀记录
 */
@RestController
@RequestMapping("/api/v1/care-logs")
@RequiredArgsConstructor
public class CareLogController {

    private final CareLogService careLogService;

    /**
     * 9.1 创建关怀记录
     */
    @PostMapping
    public Result<CareLogDTO> create(@RequestBody CareLogCreateDTO dto) {
        return Result.success(careLogService.create(dto));
    }

    /**
     * 9.2 关怀记录列表
     */
    @GetMapping
    public Result<PageResult<CareLogDTO>> list(
            @RequestParam(required = false) Long planId,
            @RequestParam(required = false) Long workerId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(careLogService.list(planId, workerId, page, size));
    }

    /**
     * 9.3 关怀记录详情
     */
    @GetMapping("/{id}")
    public Result<CareLogDTO> detail(@PathVariable Long id) {
        return Result.success(careLogService.detail(id));
    }
}
