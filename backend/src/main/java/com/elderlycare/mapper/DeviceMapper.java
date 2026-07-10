package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.elderlycare.entity.Device;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Update;

/**
 * 设备 Mapper
 */
@Mapper
public interface DeviceMapper extends BaseMapper<Device> {

    @Update("UPDATE device SET elderly_id = NULL, updated_at = NOW() WHERE elderly_id = #{elderlyId}")
    void unbindByElderlyId(Long elderlyId);
}