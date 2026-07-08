package com.elderlycare.mapper;

import com.elderlycare.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM user WHERE username = #{username} AND status = 'ACTIVE' LIMIT 1")
    User findByUsername(@Param("username") String username);
}