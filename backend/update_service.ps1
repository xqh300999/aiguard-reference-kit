$content = @"
package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.dto.ElderlyRequest;
import com.elderlycare.dto.ElderlyResponse;
import com.elderlycare.entity.Community;
import com.elderlycare.entity.Elderly;
import com.elderlycare.exception.BusinessException;
import com.elderlycare.mapper.CommunityMapper;
import com.elderlycare.mapper.DeviceMapper;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.service.ElderlyService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        validateCommunityId(request.getCommunityId());

        Elderly elderly = Elderly.builder()
                .name(request.getName())
                .gender(request.getGender())
                .birthDate(request.getBirthDate())
                .phone(request.getPhone())
                .address(request.getAddress())
                .communityId(request.getCommunityId())
                .emergencyContact(request.getEmergencyContact())
                .emergencyPhone(request.getEmergencyPhone())
                .healthStatus(request.getHealthStatus())
                .roomNumber(request.getRoomNumber())
                .status("ACTIVE")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        elderlyMapper.insert(elderly);
        return ElderlyResponse.fromEntity(elderlyMapper.selectById(elderly.getId()));
    }

    @Override
    @Transactional
    public ElderlyResponse update(Long id, ElderlyRequest request) {
        Elderly elderly = elderlyMapper.selectById(id);
        if (elderly == null) {
            throw new BusinessException("老人信息不存在");
        }

        if (request.getCommunityId() != null) {
            validateCommunityId(request.getCommunityId());
        }

        if (request.getName() != null) elderly.setName(request.getName());
        if (request.getGender() != null) elderly.setGender(request.getGender());
        if (request.getBirthDate() != null) elderly.setBirthDate(request.getBirthDate());
        if (request.getPhone() != null) elderly.setPhone(request.getPhone());
        if (request.getAddress() != null) elderly.setAddress(request.getAddress());
        if (request.getCommunityId() != null) elderly.setCommunityId(request.getCommunityId());
        if (request.getEmergencyContact() != null) elderly.setEmergencyContact(request.getEmergencyContact());
        if (request.getEmergencyPhone() != null) elderly.setEmergencyPhone(request.getEmergencyPhone());
        if (request.getHealthStatus() != null) elderly.setHealthStatus(request.getHealthStatus());
        if (request.getRoomNumber() != null) elderly.setRoomNumber(request.getRoomNumber());
        elderly.setUpdatedAt(LocalDateTime.now());
        elderlyMapper.updateById(elderly);
        return ElderlyResponse.fromEntity(elderlyMapper.selectById(id));
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
        return ElderlyResponse.fromEntity(elderly);
    }

    @Override
    public IPage<ElderlyResponse> findPage(int page, int size) {
        Page<Elderly> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Elderly::getCreatedAt);
        IPage<Elderly> elderlyPage = elderlyMapper.selectPage(pageParam, wrapper);
        return elderlyPage.convert(ElderlyResponse::fromEntity);
    }

    @Override
    public List<ElderlyResponse> search(String keyword) {
        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(Elderly::getName, keyword);
        wrapper.orderByDesc(Elderly::getCreatedAt);
        List<Elderly> list = elderlyMapper.selectList(wrapper);
        return list.stream().map(ElderlyResponse::fromEntity).collect(Collectors.toList());
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
        if (request.getBirthDate() != null) elderly.setBirthDate(request.getBirthDate());
        if (request.getPhone() != null) elderly.setPhone(request.getPhone());
        if (request.getAddress() != null) elderly.setAddress(request.getAddress());
        if (request.getCommunityId() != null) elderly.setCommunityId(request.getCommunityId());
        if (request.getEmergencyContact() != null) elderly.setEmergencyContact(request.getEmergencyContact());
        if (request.getEmergencyPhone() != null) elderly.setEmergencyPhone(request.getEmergencyPhone());
        if (request.getHealthStatus() != null) elderly.setHealthStatus(request.getHealthStatus());
        if (request.getRoomNumber() != null) elderly.setRoomNumber(request.getRoomNumber());
        elderly.setUpdatedAt(LocalDateTime.now());
        elderlyMapper.updateById(elderly);
        return ElderlyResponse.fromEntity(elderlyMapper.selectById(elderly.getId()));
    }

    private void validateCommunityId(Long communityId) {
        Community community = communityMapper.findById(communityId);
        if (community == null) {
            throw new BusinessException("社区不存在");
        }
    }
}
"@
[System.IO.File]::WriteAllText("E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\service\impl\ElderlyServiceImpl.java", $content, [System.Text.Encoding]::UTF8)
Write-Host "ElderlyServiceImpl updated successfully"
