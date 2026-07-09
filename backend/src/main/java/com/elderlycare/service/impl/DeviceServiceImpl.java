package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.dto.DeviceRequest;
import com.elderlycare.dto.DeviceResponse;
import com.elderlycare.entity.Community;
import com.elderlycare.entity.Device;
import com.elderlycare.entity.Elderly;
import com.elderlycare.exception.BusinessException;
import com.elderlycare.mapper.CommunityMapper;
import com.elderlycare.mapper.DeviceMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.service.DeviceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DeviceServiceImpl implements DeviceService {

    private final DeviceMapper deviceMapper;
    private final CommunityMapper communityMapper;
    private final ElderlyMapper elderlyMapper;

    @Override
    @Transactional
    public DeviceResponse create(DeviceRequest request) {
        validateCommunityId(request.getCommunityId());

        Device device = Device.builder()
                .name(request.getName())
                .type(request.getType())
                .mac(request.getMac())
                .communityId(request.getCommunityId())
                .status(request.getStatus() != null ? request.getStatus() : "OFFLINE")
                .battery(request.getBattery())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        deviceMapper.insert(device);
        return DeviceResponse.fromEntity(deviceMapper.selectById(device.getId()));
    }

    @Override
    @Transactional
    public DeviceResponse update(Long id, DeviceRequest request) {
        Device device = deviceMapper.selectById(id);
        if (device == null) {
            throw new BusinessException("设备不存在");
        }

        validateCommunityId(request.getCommunityId());

        device.setName(request.getName());
        device.setType(request.getType());
        device.setMac(request.getMac());
        device.setCommunityId(request.getCommunityId());
        device.setStatus(request.getStatus());
        device.setBattery(request.getBattery());
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateById(device);
        return DeviceResponse.fromEntity(deviceMapper.selectById(id));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Device device = deviceMapper.selectById(id);
        if (device == null) {
            throw new BusinessException("设备不存在");
        }
        deviceMapper.deleteById(id);
    }

    @Override
    public DeviceResponse findById(Long id) {
        Device device = deviceMapper.selectById(id);
        if (device == null) {
            throw new BusinessException("设备不存在");
        }
        return DeviceResponse.fromEntity(device);
    }

    @Override
    public IPage<DeviceResponse> findPage(int page, int size) {
        Page<Device> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Device> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Device::getCreatedAt);
        IPage<Device> devicePage = deviceMapper.selectPage(pageParam, wrapper);
        return devicePage.convert(DeviceResponse::fromEntity);
    }

    @Override
    @Transactional
    public DeviceResponse bind(Long deviceId, Long elderlyId) {
        Device device = deviceMapper.selectById(deviceId);
        if (device == null) {
            throw new BusinessException("设备不存在");
        }

        Elderly elderly = elderlyMapper.selectById(elderlyId);
        if (elderly == null) {
            throw new BusinessException("老人不存在");
        }

        device.setElderlyId(elderlyId);
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateById(device);
        return DeviceResponse.fromEntity(deviceMapper.selectById(deviceId));
    }

    @Override
    @Transactional
    public DeviceResponse unbind(Long deviceId) {
        Device device = deviceMapper.selectById(deviceId);
        if (device == null) {
            throw new BusinessException("设备不存在");
        }

        device.setElderlyId(null);
        device.setUpdatedAt(LocalDateTime.now());
        deviceMapper.updateById(device);
        return DeviceResponse.fromEntity(deviceMapper.selectById(deviceId));
    }

    private void validateCommunityId(Long communityId) {
        Community community = communityMapper.findById(communityId);
        if (community == null) {
            throw new BusinessException("社区不存在");
        }
    }
}
