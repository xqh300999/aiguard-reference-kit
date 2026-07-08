package com.elderlycare.service.impl;

import com.elderlycare.mapper.StatsMapper;
import com.elderlycare.model.dto.StatsOverviewDTO;
import com.elderlycare.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Service
@RequiredArgsConstructor
public class StatsServiceImpl implements StatsService {

    private final StatsMapper statsMapper;

    @Override
    public StatsOverviewDTO overview() {
        LocalDateTime startOfToday = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);

        long totalElderly = statsMapper.countElderly();
        long todayAlerts = statsMapper.countTodayAlerts(startOfToday);
        long onlineDevices = statsMapper.countOnlineDevices();
        long pendingAlerts = statsMapper.countPendingAlerts();

        return new StatsOverviewDTO(totalElderly, todayAlerts, onlineDevices, pendingAlerts);
    }
}
