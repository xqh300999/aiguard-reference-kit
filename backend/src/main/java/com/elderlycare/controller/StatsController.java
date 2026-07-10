package com.elderlycare.controller;

import com.elderlycare.common.Result;
import com.elderlycare.dto.StatsAlertTrendDTO;
import com.elderlycare.dto.StatsCareDTO;
import com.elderlycare.dto.StatsOverviewDTO;
import com.elderlycare.service.StatsService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 统计接口
 * <p>对应 API 文档 §10 统计报表
 */
@RestController
@RequestMapping("/api/v1/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    /**
     * 10.1 仪表盘总览
     */
    @GetMapping("/overview")
    public Result<StatsOverviewDTO> overview(@RequestParam(required = false) Long communityId) {
        return Result.success(statsService.overview(communityId));
    }

    /**
     * 10.2 告警统计趋势
     */
    @GetMapping("/alerts/{communityId}")
    public Result<StatsAlertTrendDTO> alertTrend(@PathVariable Long communityId,
                                                 @RequestParam(defaultValue = "weekly") String period) {
        return Result.success(statsService.alertTrend(communityId, period));
    }

    /**
     * 10.3 关怀统计
     */
    @GetMapping("/care/{communityId}")
    public Result<StatsCareDTO> careTrend(@PathVariable Long communityId,
                                          @RequestParam(defaultValue = "weekly") String period) {
        return Result.success(statsService.careTrend(communityId, period));
    }

    /**
     * 10.4 导出 Excel（3 个 Sheet：老人列表、告警统计、关怀统计）
     */
    @GetMapping("/export")
    public void export(@RequestParam(required = false) Long communityId,
                       HttpServletResponse response) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String fileName = URLEncoder.encode("统计报表.xlsx", StandardCharsets.UTF_8);
        response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
        statsService.exportExcel(communityId, response.getOutputStream());
    }
}
