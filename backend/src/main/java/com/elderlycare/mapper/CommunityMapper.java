package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.elderlycare.entity.Community;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface CommunityMapper extends BaseMapper<Community> {

    @Select("SELECT * FROM community WHERE id = #{id}")
    Community findById(@Param("id") Long id);

    @Select("SELECT * FROM community ORDER BY created_at DESC")
    List<Community> findAll();

    @Select("SELECT COUNT(*) FROM user WHERE community_id = #{communityId} AND status = 'ACTIVE'")
    long countUsersByCommunityId(@Param("communityId") Long communityId);

    @Select("SELECT COUNT(*) FROM elderly WHERE community_id = #{communityId}")
    long countElderlyByCommunityId(@Param("communityId") Long communityId);
}
