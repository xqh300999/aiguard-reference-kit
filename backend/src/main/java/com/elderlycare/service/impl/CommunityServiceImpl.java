package com.elderlycare.service.impl;

import com.elderlycare.dto.CommunityRequest;
import com.elderlycare.entity.Community;
import com.elderlycare.mapper.CommunityMapper;
import com.elderlycare.service.CommunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CommunityServiceImpl implements CommunityService {

    private final CommunityMapper communityMapper;

    @Override
    @Transactional
    public Community create(CommunityRequest request) {
        Community community = Community.builder()
                .name(request.getName())
                .address(request.getAddress())
                .phone(request.getPhone())
                .managerName(request.getManagerName())
                .status("ACTIVE")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        communityMapper.insert(community);
        return communityMapper.findById(community.getId());
    }

    @Override
    @Transactional
    public Community update(Long id, CommunityRequest request) {
        Community community = communityMapper.findById(id);
        if (community == null) {
            throw new RuntimeException("社区不存在");
        }
        community.setName(request.getName());
        community.setAddress(request.getAddress());
        community.setPhone(request.getPhone());
        community.setManagerName(request.getManagerName());
        community.setUpdatedAt(LocalDateTime.now());
        communityMapper.updateById(community);
        return communityMapper.findById(id);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Community community = communityMapper.findById(id);
        if (community == null) {
            throw new RuntimeException("社区不存在");
        }

        long userCount = communityMapper.countUsersByCommunityId(id);
        long elderlyCount = communityMapper.countElderlyByCommunityId(id);

        if (userCount > 0 || elderlyCount > 0) {
            throw new RuntimeException("无法删除：该社区下存在" + userCount + "个用户和" + elderlyCount + "位老人");
        }

        communityMapper.deleteById(id);
    }

    @Override
    public Community findById(Long id) {
        Community community = communityMapper.findById(id);
        if (community == null) {
            throw new RuntimeException("社区不存在");
        }
        return community;
    }

    @Override
    public List<Community> findAll() {
        return communityMapper.findAll();
    }
}