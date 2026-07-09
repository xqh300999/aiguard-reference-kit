package com.elderlycare.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.dto.ElderlyRequest;
import com.elderlycare.dto.ElderlyResponse;

import java.util.List;

public interface ElderlyService {

    ElderlyResponse create(ElderlyRequest request);

    ElderlyResponse update(ElderlyRequest request);

    void delete(Long id);

    ElderlyResponse findById(Long id);

    IPage<ElderlyResponse> findPage(int page, int size, Long communityId, String status, String name);

    List<ElderlyResponse> search(String keyword);

    ElderlyResponse register(ElderlyRequest request);

    ElderlyResponse updateByContact(String name, String phone, ElderlyRequest request);
}