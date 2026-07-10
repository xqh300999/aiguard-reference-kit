package com.elderlycare.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.elderlycare.entity.User;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM user WHERE username = #{username} AND status = 'ACTIVE' LIMIT 1")
    User findByUsername(@Param("username") String username);

    @Select("SELECT COUNT(*) FROM user WHERE username = #{username} AND id != #{excludeId}")
    long countByUsernameExcludeId(@Param("username") String username, @Param("excludeId") Long excludeId);
}