package com.elderlycare.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.dto.DeviceRequest;
import com.elderlycare.dto.DeviceResponse;

public interface DeviceService {

    DeviceResponse create(DeviceRequest request);

    DeviceResponse update(Long id, DeviceRequest request);

    void delete(Long id);

    DeviceResponse findById(Long id);

    IPage<DeviceResponse> findPage(int page, int size);

    DeviceResponse bind(Long deviceId, Long elderlyId);

    DeviceResponse unbind(Long deviceId);
}