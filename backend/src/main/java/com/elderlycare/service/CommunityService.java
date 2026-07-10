package com.elderlycare.service;

import com.elderlycare.dto.CommunityRequest;
import com.elderlycare.entity.Community;

import java.util.List;

public interface CommunityService {

    Community create(CommunityRequest request);

    Community update(Long id, CommunityRequest request);

    void delete(Long id);

    Community findById(Long id);

    List<Community> findAll();
}