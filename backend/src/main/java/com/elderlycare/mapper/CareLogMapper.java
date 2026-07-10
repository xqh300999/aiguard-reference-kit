package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.dto.CareLogDTO;
import com.elderlycare.entity.CareLog;
import com.elderlycare.entity.CarePlan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 关怀记录 Mapper
 */
@Mapper
public interface CareLogMapper extends BaseMapper<CareLog> {

    /**
     * 根据 id 查询关怀计划（取 elderlyId / workerId）
     */
    @Select("SELECT id, elderly_id, worker_id FROM care_plan WHERE id = #{id}")
    CarePlan selectCarePlanById(@Param("id") Long id);

    /**
     * 分页查询关怀记录（关联 elderly / user / care_plan 取名称）
     */
    @Select("<script>" +
            "SELECT cl.id, cl.plan_id AS planId, cl.worker_id AS workerId, u.real_name AS workerName, " +
            "cl.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "cl.type, cl.elderly_status AS elderlyStatus, cl.notes, " +
            "cp.plan_type AS planType, cl.created_at AS createdAt " +
            "FROM care_log cl " +
            "LEFT JOIN elderly el ON cl.elderly_id = el.id " +
            "LEFT JOIN user u ON cl.worker_id = u.id " +
            "LEFT JOIN care_plan cp ON cl.plan_id = cp.id " +
            "<where>" +
            "  <if test='planId != null'>AND cl.plan_id = #{planId}</if>" +
            "  <if test='workerId != null'>AND cl.worker_id = #{workerId}</if>" +
            "</where>" +
            "ORDER BY cl.created_at DESC" +
            "</script>")
    IPage<CareLogDTO> selectCareLogPage(IPage<CareLogDTO> page,
                                        @Param("planId") Long planId,
                                        @Param("workerId") Long workerId);

    /**
     * 查询单条关怀记录详情（关联名称）
     */
    @Select("SELECT cl.id, cl.plan_id AS planId, cl.worker_id AS workerId, u.real_name AS workerName, " +
            "cl.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "cl.type, cl.elderly_status AS elderlyStatus, cl.notes, " +
            "cp.plan_type AS planType, cl.created_at AS createdAt " +
            "FROM care_log cl " +
            "LEFT JOIN elderly el ON cl.elderly_id = el.id " +
            "LEFT JOIN user u ON cl.worker_id = u.id " +
            "LEFT JOIN care_plan cp ON cl.plan_id = cp.id " +
            "WHERE cl.id = #{id}")
    CareLogDTO selectCareLogDetail(@Param("id") Long id);
}
