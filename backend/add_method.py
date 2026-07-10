with open(r'E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\service\impl\UserServiceImpl.java', 'r', encoding='utf-8') as f:
    content = f.read()

new_method = """

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
"""

content = content.replace('return UserResponse.fromEntity(userMapper.selectById(userId));\n    }\n}','return UserResponse.fromEntity(userMapper.selectById(userId));\n    }' + new_method + '}')

with open(r'E:\LiuLanQi2\Git\aiguard-reference-kit\backend\src\main\java\com\elderlycare\service\impl\UserServiceImpl.java', 'w', encoding='utf-8') as f:
    f.write(content)

print("done")
