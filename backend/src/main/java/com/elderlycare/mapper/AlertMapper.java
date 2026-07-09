package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.elderlycare.model.dto.AlertDTO;
import com.elderlycare.model.entity.Alert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 告警 Mapper
 */
@Mapper
public interface AlertMapper extends BaseMapper<Alert> {

    /**
     * 分页查询告警列表（关联 elderly / community / user 取名称）
     */
    @Select("<script>" +
            "SELECT a.id, a.type, a.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "a.community_id AS communityId, c.name AS communityName, " +
            "a.device_id AS deviceId, a.source, a.status, a.priority, " +
            "a.handler_id AS handlerId, u.real_name AS handlerName, " +
            "a.cause, a.details, a.happened_at AS happenedAt, a.resolved_at AS resolvedAt, " +
            "a.created_at AS createdAt " +
            "FROM alert a " +
            "LEFT JOIN elderly el ON a.elderly_id = el.id " +
            "LEFT JOIN community c ON a.community_id = c.id " +
            "LEFT JOIN user u ON a.handler_id = u.id " +
            "<where>" +
            "  <if test='communityId != null'>AND a.community_id = #{communityId}</if>" +
            "  <if test='status != null and status != \"\"'>AND a.status = #{status}</if>" +
            "  <if test='type != null and type != \"\"'>AND a.type = #{type}</if>" +
            "</where>" +
            "ORDER BY a.happened_at DESC" +
            "</script>")
    IPage<AlertDTO> selectAlertPage(IPage<AlertDTO> page,
                                    @Param("communityId") Long communityId,
                                    @Param("status") String status,
                                    @Param("type") String type);

    /**
     * 查询单条告警详情（关联名称）
     */
    @Select("SELECT a.id, a.type, a.elderly_id AS elderlyId, el.name AS elderlyName, " +
            "a.community_id AS communityId, c.name AS communityName, " +
            "a.device_id AS deviceId, a.source, a.status, a.priority, " +
            "a.handler_id AS handlerId, u.real_name AS handlerName, " +
            "a.cause, a.details, a.happened_at AS happenedAt, a.resolved_at AS resolvedAt, " +
            "a.created_at AS createdAt " +
            "FROM alert a " +
            "LEFT JOIN elderly el ON a.elderly_id = el.id " +
            "LEFT JOIN community c ON a.community_id = c.id " +
            "LEFT JOIN user u ON a.handler_id = u.id " +
            "WHERE a.id = #{id}")
    AlertDTO selectAlertDetail(@Param("id") Long id);
}
