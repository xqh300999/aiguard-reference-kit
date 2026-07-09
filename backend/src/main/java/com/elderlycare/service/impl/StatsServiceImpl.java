package com.elderlycare.service.impl;

import com.elderlycare.mapper.StatsMapper;
import com.elderlycare.model.dto.StatsAlertTrendDTO;
import com.elderlycare.model.dto.StatsCareDTO;
import com.elderlycare.model.dto.StatsOverviewDTO;
import com.elderlycare.model.dto.TrendRow;
import com.elderlycare.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StatsServiceImpl implements StatsService {

    private final StatsMapper statsMapper;

    // ==================== 10.1 仪表盘总览 ====================

    @Override
    public StatsOverviewDTO overview(Long communityId) {
        LocalDateTime startOfToday = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);

        long totalElderly = statsMapper.countElderly(communityId);
        long todayAlerts = statsMapper.countTodayAlerts(startOfToday, communityId);
        long onlineDevices = statsMapper.countOnlineDevices(communityId);
        long pendingAlerts = statsMapper.countPendingAlerts(communityId);

        return new StatsOverviewDTO(totalElderly, todayAlerts, onlineDevices, pendingAlerts);
    }

    // ==================== 10.2 告警统计趋势 ====================

    @Override
    public StatsAlertTrendDTO alertTrend(Long communityId, String period) {
        PeriodConfig pc = PeriodConfig.of(period);
        List<TrendRow> rows = statsMapper.alertTrend(communityId, pc.start, pc.dateFormat);

        StatsAlertTrendDTO dto = new StatsAlertTrendDTO();
        dto.setPeriod(pc.period);
        dto.setRecords(groupAlert(rows));
        return dto;
    }

    // ==================== 10.3 关怀统计 ====================

    @Override
    public StatsCareDTO careTrend(Long communityId, String period) {
        PeriodConfig pc = PeriodConfig.of(period);
        List<TrendRow> rows = statsMapper.careTrend(communityId, pc.start, pc.dateFormat);

        StatsCareDTO dto = new StatsCareDTO();
        dto.setPeriod(pc.period);
        dto.setRecords(groupCare(rows));
        return dto;
    }

    // ==================== 10.4 导出 Excel ====================

    @Override
    public void exportExcel(Long communityId, OutputStream out) throws IOException {
        List<Map<String, Object>> elderlyList = statsMapper.exportElderly(communityId);
        List<Map<String, Object>> alertList = statsMapper.exportAlerts(communityId);
        List<Map<String, Object>> careList = statsMapper.exportCareLogs(communityId);

        try (Workbook workbook = new XSSFWorkbook()) {
            CellStyle headerStyle = createHeaderStyle(workbook);

            // Sheet 1: 老人列表
            writeSheet(workbook, headerStyle, "老人列表",
                    new String[]{"ID", "姓名", "年龄", "性别", "社区", "电话", "紧急联系人", "健康备注", "状态"},
                    new String[]{"id", "name", "age", "gender", "communityName", "phone", "emergencyContact", "healthNotes", "status"},
                    elderlyList);

            // Sheet 2: 告警统计
            writeSheet(workbook, headerStyle, "告警统计",
                    new String[]{"ID", "类型", "老人姓名", "社区", "状态", "优先级", "发生时间"},
                    new String[]{"id", "type", "elderlyName", "communityName", "status", "priority", "happenedAt"},
                    alertList);

            // Sheet 3: 关怀统计
            writeSheet(workbook, headerStyle, "关怀统计",
                    new String[]{"ID", "类型", "老人姓名", "护工", "老人状态", "备注", "记录时间"},
                    new String[]{"id", "type", "elderlyName", "workerName", "elderlyStatus", "notes", "createdAt"},
                    careList);

            workbook.write(out);
        }
    }

    // ==================== 内部工具 ====================

    /** 按 period 计算时间范围与日期格式 */
    private record PeriodConfig(String period, LocalDateTime start, String dateFormat) {
        static PeriodConfig of(String period) {
            if (period == null) period = "weekly";
            return switch (period.toLowerCase()) {
                case "daily" -> new PeriodConfig("daily",
                        LocalDate.now().minusDays(6).atStartOfDay(), "%Y-%m-%d");
                case "monthly" -> new PeriodConfig("monthly",
                        LocalDate.now().minusMonths(5).withDayOfMonth(1).atStartOfDay(), "%Y-%m");
                default -> new PeriodConfig("weekly",
                        LocalDate.now().minusWeeks(3).atStartOfDay(), "%x-W%v");
            };
        }
    }

    /** 将 TrendRow 列表按 label 分组为告警趋势记录 */
    private List<StatsAlertTrendDTO.Record> groupAlert(List<TrendRow> rows) {
        Map<String, List<TrendRow>> grouped = groupByLabel(rows);
        List<StatsAlertTrendDTO.Record> records = new ArrayList<>();
        grouped.forEach((label, typeRows) -> {
            long total = sumCount(typeRows);
            List<StatsAlertTrendDTO.Detail> details = typeRows.stream()
                    .map(r -> new StatsAlertTrendDTO.Detail(r.getType(), countOf(r)))
                    .collect(Collectors.toList());
            records.add(new StatsAlertTrendDTO.Record(label, total, details));
        });
        return records;
    }

    /** 将 TrendRow 列表按 label 分组为关怀统计记录 */
    private List<StatsCareDTO.Record> groupCare(List<TrendRow> rows) {
        Map<String, List<TrendRow>> grouped = groupByLabel(rows);
        List<StatsCareDTO.Record> records = new ArrayList<>();
        grouped.forEach((label, typeRows) -> {
            long total = sumCount(typeRows);
            List<StatsCareDTO.Detail> details = typeRows.stream()
                    .map(r -> new StatsCareDTO.Detail(r.getType(), countOf(r)))
                    .collect(Collectors.toList());
            records.add(new StatsCareDTO.Record(label, total, details));
        });
        return records;
    }

    private LinkedHashMap<String, List<TrendRow>> groupByLabel(List<TrendRow> rows) {
        return rows.stream().collect(Collectors.groupingBy(
                TrendRow::getLabel, LinkedHashMap::new, Collectors.toList()));
    }

    private long sumCount(List<TrendRow> rows) {
        return rows.stream().mapToLong(this::countOf).sum();
    }

    private long countOf(TrendRow r) {
        return r.getCount() != null ? r.getCount() : 0L;
    }

    // ---------- Excel 工具 ----------

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);
        return style;
    }

    private void writeSheet(Workbook workbook, CellStyle headerStyle, String sheetName,
                            String[] headers, String[] keys, List<Map<String, Object>> data) {
        Sheet sheet = workbook.createSheet(sheetName);
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }
        for (int i = 0; i < data.size(); i++) {
            Row row = sheet.createRow(i + 1);
            Map<String, Object> item = data.get(i);
            for (int j = 0; j < keys.length; j++) {
                row.createCell(j).setCellValue(str(item.get(keys[j])));
            }
        }
        // 自适应列宽
        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private String str(Object v) {
        if (v == null) return "";
        if (v instanceof java.util.Date) {
            return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format((java.util.Date) v);
        }
        if (v instanceof LocalDateTime) {
            return ((LocalDateTime) v).toString();
        }
        return v.toString();
    }
}
