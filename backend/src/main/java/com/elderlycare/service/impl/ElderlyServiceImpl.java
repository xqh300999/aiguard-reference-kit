package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.dto.ElderlyRequest;
import com.elderlycare.dto.ElderlyResponse;
import com.elderlycare.entity.Community;
import com.elderlycare.entity.Device;
import com.elderlycare.entity.Elderly;
import com.elderlycare.exception.BusinessException;
import com.elderlycare.mapper.CommunityMapper;
import com.elderlycare.mapper.DeviceMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.service.ElderlyService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ElderlyServiceImpl implements ElderlyService {

    private final ElderlyMapper elderlyMapper;
    private final CommunityMapper communityMapper;
    private final DeviceMapper deviceMapper;

    @Override
    @Transactional
    public ElderlyResponse create(ElderlyRequest request) {
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new BusinessException("姓名不能为空");
        }
        if (request.getCommunityId() == null) {
            throw new BusinessException("社区ID不能为空");
        }
        validateCommunityId(request.getCommunityId());

        Elderly elderly = Elderly.builder()
                .name(request.getName())
                .gender(request.getGender())
                .birthDate(calculateBirthDate(request.getAge(), request.getBirthDate()))
                .phone(request.getPhone())
                .address(request.getAddress())
                .communityId(request.getCommunityId())
                .emergencyContact(request.getEmergencyContact())
                .emergencyPhone(request.getEmergencyPhone())
                .healthStatus(request.getHealthNotes())
                .roomNumber(request.getRoomNumber())
                .status("NORMAL")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        elderlyMapper.insert(elderly);
        return buildResponse(elderlyMapper.selectById(elderly.getId()));
    }

    @Override
    @Transactional
    public ElderlyResponse update(ElderlyRequest request) {
        if (request.getId() == null) {
            throw new BusinessException("老人ID不能为空");
        }

        Elderly elderly = elderlyMapper.selectById(request.getId());
        if (elderly == null) {
            throw new BusinessException("老人信息不存在");
        }

        if (request.getCommunityId() != null) {
            validateCommunityId(request.getCommunityId());
        }

        if (request.getName() != null) elderly.setName(request.getName());
        if (request.getGender() != null) elderly.setGender(request.getGender());
        if (request.getAge() != null || request.getBirthDate() != null) {
            elderly.setBirthDate(calculateBirthDate(request.getAge(), request.getBirthDate()));
        }
        if (request.getPhone() != null) elderly.setPhone(request.getPhone());
        if (request.getAddress() != null) elderly.setAddress(request.getAddress());
        if (request.getCommunityId() != null) elderly.setCommunityId(request.getCommunityId());
        if (request.getEmergencyContact() != null) elderly.setEmergencyContact(request.getEmergencyContact());
        if (request.getEmergencyPhone() != null) elderly.setEmergencyPhone(request.getEmergencyPhone());
        if (request.getHealthNotes() != null) elderly.setHealthStatus(request.getHealthNotes());
        if (request.getRoomNumber() != null) elderly.setRoomNumber(request.getRoomNumber());
        elderly.setUpdatedAt(LocalDateTime.now());
        elderlyMapper.updateById(elderly);
        return buildResponse(elderlyMapper.selectById(request.getId()));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Elderly elderly = elderlyMapper.selectById(id);
        if (elderly == null) {
            throw new BusinessException("老人信息不存在");
        }

        deviceMapper.unbindByElderlyId(id);

        elderlyMapper.deleteById(id);
    }

    @Override
    public ElderlyResponse findById(Long id) {
        Elderly elderly = elderlyMapper.selectById(id);
        if (elderly == null) {
            throw new RuntimeException("老人信息不存在");
        }
        return buildResponse(elderly);
    }

    @Override
    public IPage<ElderlyResponse> findPage(int page, int size, Long communityId, String status, String name) {
        Page<Elderly> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        if (communityId != null) {
            wrapper.eq(Elderly::getCommunityId, communityId);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Elderly::getStatus, status);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(Elderly::getName, name);
        }
        wrapper.orderByDesc(Elderly::getCreatedAt);
        IPage<Elderly> elderlyPage = elderlyMapper.selectPage(pageParam, wrapper);
        return elderlyPage.convert(this::buildResponse);
    }

    @Override
    public List<ElderlyResponse> search(String keyword) {
        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(Elderly::getName, keyword);
        wrapper.orderByDesc(Elderly::getCreatedAt);
        List<Elderly> list = elderlyMapper.selectList(wrapper);
        return list.stream().map(this::buildResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ElderlyResponse register(ElderlyRequest request) {
        return create(request);
    }

    @Override
    @Transactional
    public ElderlyResponse updateByContact(String name, String phone, ElderlyRequest request) {
        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Elderly::getName, name);
        wrapper.eq(Elderly::getPhone, phone);
        Elderly elderly = elderlyMapper.selectOne(wrapper);

        if (elderly == null) {
            throw new BusinessException("未找到匹配的老人，请检查姓名和电话");
        }

        if (request.getCommunityId() != null) {
            validateCommunityId(request.getCommunityId());
        }

        if (request.getName() != null) elderly.setName(request.getName());
        if (request.getGender() != null) elderly.setGender(request.getGender());
        if (request.getAge() != null || request.getBirthDate() != null) {
            elderly.setBirthDate(calculateBirthDate(request.getAge(), request.getBirthDate()));
        }
        if (request.getPhone() != null) elderly.setPhone(request.getPhone());
        if (request.getAddress() != null) elderly.setAddress(request.getAddress());
        if (request.getCommunityId() != null) elderly.setCommunityId(request.getCommunityId());
        if (request.getEmergencyContact() != null) elderly.setEmergencyContact(request.getEmergencyContact());
        if (request.getEmergencyPhone() != null) elderly.setEmergencyPhone(request.getEmergencyPhone());
        if (request.getHealthNotes() != null) elderly.setHealthStatus(request.getHealthNotes());
        if (request.getRoomNumber() != null) elderly.setRoomNumber(request.getRoomNumber());
        elderly.setUpdatedAt(LocalDateTime.now());
        elderlyMapper.updateById(elderly);
        return buildResponse(elderlyMapper.selectById(elderly.getId()));
    }

    private void validateCommunityId(Long communityId) {
        Community community = communityMapper.findById(communityId);
        if (community == null) {
            throw new BusinessException("社区不存在");
        }
    }

    private LocalDate calculateBirthDate(Integer age, LocalDate birthDate) {
        if (birthDate != null) {
            return birthDate;
        }
        if (age != null) {
            return LocalDate.now().minusYears(age);
        }
        return null;
    }

    private ElderlyResponse buildResponse(Elderly elderly) {
        ElderlyResponse response = ElderlyResponse.fromEntity(elderly);

        response.setAge(calculateAge(elderly.getBirthDate()));

        if (elderly.getCommunityId() != null) {
            Community community = communityMapper.findById(elderly.getCommunityId());
            if (community != null) {
                response.setCommunityName(community.getName());
            }
        }

        LambdaQueryWrapper<Device> deviceWrapper = new LambdaQueryWrapper<>();
        deviceWrapper.eq(Device::getElderlyId, elderly.getId());
        Device device = deviceMapper.selectOne(deviceWrapper);
        if (device != null) {
            response.setDevice(ElderlyResponse.DeviceInfo.builder()
                    .id(device.getId())
                    .name(device.getName())
                    .type(device.getType())
                    .status(device.getStatus())
                    .lastHeartbeat(device.getLastHeartbeat())
                    .battery(device.getBattery())
                    .build());
        }

        return response;
    }

    private Integer calculateAge(LocalDate birthDate) {
        if (birthDate == null) {
            return null;
        }
        return (int) java.time.temporal.ChronoUnit.YEARS.between(birthDate, LocalDate.now());
    }
}