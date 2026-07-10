package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.elderlycare.entity.CarePlan;
import org.apache.ibatis.annotations.Mapper;

/**
 * 关怀计划 Mapper
 */
@Mapper
public interface CarePlanMapper extends BaseMapper<CarePlan> {
}
