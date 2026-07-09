package com.elderlycare.controller;

import com.elderlycare.common.PageResult;
import com.elderlycare.common.Result;
import com.elderlycare.model.dto.AlertDTO;
import com.elderlycare.model.dto.AlertUpdateDTO;
import com.elderlycare.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 告警接口
 * <p>对应 API 文档 §6 告警管理
 */
@RestController
@RequestMapping("/api/v1/alerts")
@RequiredArgsConstructor
public class AlertController {

    private final AlertService alertService;

    /**
     * 6.2 告警列表
     */
    @GetMapping
    public Result<PageResult<AlertDTO>> list(
            @RequestParam(required = false) Long communityId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(alertService.list(communityId, status, type, page, size));
    }

    /**
     * 6.3 告警详情
     */
    @GetMapping("/{id}")
    public Result<AlertDTO> detail(@PathVariable Long id) {
        return Result.success(alertService.detail(id));
    }

    /**
     * 6.4 更新告警（状态单向流转）
     */
    @PatchMapping("/{id}")
    public Result<AlertDTO> updateStatus(@PathVariable Long id,
                                         @RequestBody AlertUpdateDTO dto) {
        return Result.success(alertService.updateStatus(id, dto));
    }
}
