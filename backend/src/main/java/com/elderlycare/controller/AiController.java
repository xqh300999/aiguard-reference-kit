package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.AiReportDTO;
import com.elderlycare.dto.HealthScoreDTO;
import com.elderlycare.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * AI 功能接口
 * <p>对应 API 文档 §11 AI 功能
 */
@RestController
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    /**
     * 11.1 健康评分
     */
    @GetMapping("/api/v1/elderly/{id}/health-score")
    public Result<HealthScoreDTO> healthScore(@PathVariable Long id) {
        return Result.success(aiService.healthScore(id));
    }

    /**
     * 11.2 AI 健康报告
     */
    @GetMapping("/api/v1/elderly/{id}/ai-report")
    public Result<AiReportDTO> aiReport(@PathVariable Long id) {
        return Result.success(aiService.aiReport(id));
    }

    /**
     * 11.3 触发 AI 日报生成
     */
    @PostMapping("/api/v1/ai/generate-daily-report")
    public Result<AiReportDTO> generateDailyReport(@RequestBody Map<String, Long> body) {
        Long elderlyId = body.get("elderlyId");
        if (elderlyId == null) {
            throw new RuntimeException("elderlyId 不能为空");
        }
        return Result.success(aiService.generateDailyReport(elderlyId));
    }
}
