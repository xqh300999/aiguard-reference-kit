package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.dto.DispatchDTO;
import com.elderlycare.entity.Dispatch;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 派工单 Mapper
 */
@Mapper
public interface DispatchMapper extends BaseMapper<Dispatch> {

    /**
     * 分页查询派工单列表（关联 alert / elderly / community / user）
     */
    @Select("<script>" +
            "SELECT d.id, d.alert_id AS alertId, a.type AS alertType, a.status AS alertStatus, " +
            "a.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "a.community_id AS communityId, c.name AS communityName, " +
            "d.handler_id AS handlerId, u.real_name AS handlerName, " +
            "d.description, d.result, d.status, " +
            "d.created_at AS createdAt, d.updated_at AS updatedAt " +
            "FROM dispatch d " +
            "INNER JOIN alert a ON d.alert_id = a.id " +
            "LEFT JOIN elderly el ON a.elderly_id = el.id " +
            "LEFT JOIN community c ON a.community_id = c.id " +
            "LEFT JOIN user u ON d.handler_id = u.id " +
            "<where>" +
            "  <if test='alertId != null'>AND d.alert_id = #{alertId}</if>" +
            "  <if test='handlerId != null'>AND d.handler_id = #{handlerId}</if>" +
            "  <if test='status != null and status != \"\"'>AND d.status = #{status}</if>" +
            "</where>" +
            "ORDER BY d.created_at DESC" +
            "</script>")
    IPage<DispatchDTO> selectDispatchPage(IPage<DispatchDTO> page,
                                           @Param("alertId") Long alertId,
                                           @Param("handlerId") Long handlerId,
                                           @Param("status") String status);

    /**
     * 查询单条派工单详情（关联名称）
     */
    @Select("SELECT d.id, d.alert_id AS alertId, a.type AS alertType, a.status AS alertStatus, " +
            "a.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "a.community_id AS communityId, c.name AS communityName, " +
            "d.handler_id AS handlerId, u.real_name AS handlerName, " +
            "d.description, d.result, d.status, " +
            "d.created_at AS createdAt, d.updated_at AS updatedAt " +
            "FROM dispatch d " +
            "INNER JOIN alert a ON d.alert_id = a.id " +
            "LEFT JOIN elderly el ON a.elderly_id = el.id " +
            "LEFT JOIN community c ON a.community_id = c.id " +
            "LEFT JOIN user u ON d.handler_id = u.id " +
            "WHERE d.id = #{id}")
    DispatchDTO selectDispatchDetail(@Param("id") Long id);
}
