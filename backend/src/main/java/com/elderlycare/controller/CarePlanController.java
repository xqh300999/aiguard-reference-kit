package com.elderlycare.controller;

import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.dto.CarePlanCreateDTO;
import com.elderlycare.dto.CarePlanDTO;
import com.elderlycare.service.CarePlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 关怀计划接口
 * <p>对应 API 文档 §8 关怀计划管理
 */
@RestController
@RequestMapping("/api/v1/care-plans")
@RequiredArgsConstructor
public class CarePlanController {

    private final CarePlanService carePlanService;

    /**
     * 8.1 创建关怀计划
     */
    @PostMapping
    public Result<CarePlanDTO> create(@RequestBody CarePlanCreateDTO dto) {
        return Result.success(carePlanService.create(dto));
    }

    /**
     * 8.2 关怀计划列表
     */
    @GetMapping
    public Result<PageResult<CarePlanDTO>> list(
            @RequestParam(required = false) Long workerId,
            @RequestParam(required = false) Long elderlyId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(carePlanService.list(workerId, elderlyId, status, page, size));
    }

    /**
     * 8.3 关怀计划详情
     */
    @GetMapping("/{id}")
    public Result<CarePlanDTO> detail(@PathVariable Long id) {
        return Result.success(carePlanService.detail(id));
    }

    /**
     * 8.4 更新关怀计划
     */
    @PutMapping("/{id}")
    public Result<CarePlanDTO> update(@PathVariable Long id,
                                      @RequestBody CarePlanCreateDTO dto) {
        return Result.success(carePlanService.update(id, dto));
    }

    /**
     * 8.5 删除关怀计划
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        carePlanService.delete(id);
        return Result.success(null);
    }
}
