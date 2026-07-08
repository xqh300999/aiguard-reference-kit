package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.model.dto.StatsOverviewDTO;
import com.elderlycare.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 统计接口
 * <p>对应 API 文档 §10.1 GET /api/v1/stats/overview
 */
@RestController
@RequestMapping("/api/v1/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    @GetMapping("/overview")
    public Result<StatsOverviewDTO> overview() {
        return Result.success(statsService.overview());
    }
}
