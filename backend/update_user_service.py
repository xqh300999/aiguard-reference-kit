content = '''package com.elderlycare.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.elderlycare.dto.UserRequest;
import com.elderlycare.dto.UserResponse;
import com.elderlycare.entity.Elderly;
import com.elderlycare.entity.User;
import com.elderlycare.exception.BusinessException;
import com.elderlycare.mapper.ElderlyMapper;
import com.elderlycare.mapper.UserMapper;
import com.elderlycare.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final ElderlyMapper elderlyMapper;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public UserResponse create(UserRequest request) {
        long count = userMapper.countByUsernameExcludeId(request.getUsername(), null);
        if (count > 0) {
            throw new RuntimeException("用户名已存在");
        }

        User user = User.builder()
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .realName(request.getRealName())
                .phone(request.getPhone())
                .role(request.getRole())
                .communityId(request.getCommunityId())
                .status("ACTIVE")
                .build();
        userMapper.insert(user);
        return UserResponse.fromEntity(userMapper.selectById(user.getId()));
    }

    @Override
    @Transactional
    public UserResponse update(Long id, UserRequest request) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        long count = userMapper.countByUsernameExcludeId(request.getUsername(), id);
        if (count > 0) {
            throw new RuntimeException("用户名已存在");
        }

        user.setUsername(request.getUsername());
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        user.setRealName(request.getRealName());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole());
        user.setCommunityId(request.getCommunityId());
        userMapper.updateById(user);
        return UserResponse.fromEntity(userMapper.selectById(id));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        userMapper.deleteById(id);
    }

    @Override
    public UserResponse findById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        return UserResponse.fromEntity(user);
    }

    @Override
    public IPage<UserResponse> findPage(int page, int size) {
        Page<User> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(User::getCreatedAt);
        IPage<User> userPage = userMapper.selectPage(pageParam, wrapper);
        return userPage.convert(UserResponse::fromEntity);
    }

    @Override
    @Transactional
    public UserResponse bindElderly(Long userId, Long elderlyId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        Elderly elderly = elderlyMapper.selectById(elderlyId);
        if (elderly == null) {
            throw new BusinessException("老人不存在");
        }

        user.setElderlyId(elderlyId);
        userMapper.updateById(user);
        return UserResponse.fromEntity(userMapper.selectById(userId));
    }

    @Override
    @Transactional
    public UserResponse bindElderlyByContact(Long userId, String name, String phone) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        LambdaQueryWrapper<Elderly> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Elderly::getName, name);
        wrapper.eq(Elderly::getPhone, phone);
        Elderly elderly = elderlyMapper.selectOne(wrapper);

        if (elderly == null) {
            throw new BusinessException("未找到匹配的老人，请检查姓名和电话");
        }

        user.setElderlyId(elderly.getId());
        userMapper.updateById(user);
        return UserResponse.fromEntity(userMapper.selectById(userId));
    }
}
'''

with open(r'E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\service\impl\UserServiceImpl.java', 'w', encoding='utf-8') as f:
    f.write(content)

print("UserServiceImpl updated successfully")
