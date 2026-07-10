package com.elderlycare.controller;

import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.dto.DispatchCreateDTO;
import com.elderlycare.dto.DispatchDTO;
import com.elderlycare.dto.DispatchUpdateDTO;
import com.elderlycare.service.DispatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 派工接口
 * <p>对应 API 文档 §7 派工管理
 */
@RestController
@RequestMapping("/api/v1/dispatches")
@RequiredArgsConstructor
public class DispatchController {

    private final DispatchService dispatchService;

    /**
     * 7.1 创建派工单（同步 alert → PROCESSING）
     */
    @PostMapping
    public Result<DispatchDTO> create(@RequestBody DispatchCreateDTO dto) {
        return Result.success(dispatchService.create(dto));
    }

    /**
     * 7.2 派工单列表
     */
    @GetMapping
    public Result<PageResult<DispatchDTO>> list(
            @RequestParam(required = false) Long alertId,
            @RequestParam(required = false) Long handlerId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(dispatchService.list(alertId, handlerId, status, page, size));
    }

    /**
     * 7.3 派工单详情
     */
    @GetMapping("/{id}")
    public Result<DispatchDTO> detail(@PathVariable Long id) {
        return Result.success(dispatchService.detail(id));
    }

    /**
     * 7.4 更新派工单（处理结果 + 双表同步 alert）
     */
    @PatchMapping("/{id}")
    public Result<DispatchDTO> update(@PathVariable Long id,
                                      @RequestBody DispatchUpdateDTO dto) {
        return Result.success(dispatchService.update(id, dto));
    }
}
