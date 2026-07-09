DROP DATABASE IF EXISTS aiguard;
CREATE DATABASE IF NOT EXISTS aiguard DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE aiguard;

CREATE TABLE community (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    area VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_community_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'WORKER',
    community_id BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_username (username),
    INDEX idx_user_role (role),
    INDEX idx_user_community_id (community_id),
    INDEX idx_user_status (status),
    CONSTRAINT fk_user_community FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE elderly (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT,
    gender VARCHAR(10) DEFAULT 'MALE',
    address VARCHAR(255),
    phone VARCHAR(20),
    emergency_contact VARCHAR(20),
    health_notes TEXT,
    community_id BIGINT NOT NULL,
    device_mac VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_elderly_name (name),
    INDEX idx_elderly_community_id (community_id),
    INDEX idx_elderly_status (status),
    INDEX idx_elderly_device_mac (device_mac),
    CONSTRAINT fk_elderly_community FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE device (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'WATCH',
    mac VARCHAR(20) NOT NULL UNIQUE,
    community_id BIGINT NOT NULL,
    elderly_id BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'OFFLINE',
    battery INT DEFAULT 100,
    last_heartbeat TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_device_mac (mac),
    INDEX idx_device_type (type),
    INDEX idx_device_community_id (community_id),
    INDEX idx_device_elderly_id (elderly_id),
    INDEX idx_device_status (status),
    INDEX idx_device_last_heartbeat (last_heartbeat),
    CONSTRAINT fk_device_community FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE RESTRICT,
    CONSTRAINT fk_device_elderly FOREIGN KEY (elderly_id) REFERENCES elderly(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alert (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20) NOT NULL DEFAULT 'ABNORMAL',
    elderly_id BIGINT,
    community_id BIGINT NOT NULL,
    device_id BIGINT,
    source VARCHAR(20) NOT NULL DEFAULT 'SYSTEM',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    handler_id BIGINT,
    lat DECIMAL(10,7),
    lng DECIMAL(10,7),
    cause TEXT,
    details TEXT,
    happened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_alert_type (type),
    INDEX idx_alert_elderly_id (elderly_id),
    INDEX idx_alert_community_id (community_id),
    INDEX idx_alert_device_id (device_id),
    INDEX idx_alert_status (status),
    INDEX idx_alert_priority (priority),
    INDEX idx_alert_handler_id (handler_id),
    INDEX idx_alert_happened_at (happened_at),
    CONSTRAINT fk_alert_elderly FOREIGN KEY (elderly_id) REFERENCES elderly(id) ON DELETE SET NULL,
    CONSTRAINT fk_alert_community FOREIGN KEY (community_id) REFERENCES community(id) ON DELETE RESTRICT,
    CONSTRAINT fk_alert_device FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE SET NULL,
    CONSTRAINT fk_alert_handler FOREIGN KEY (handler_id) REFERENCES user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dispatch (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    alert_id BIGINT NOT NULL UNIQUE,
    handler_id BIGINT NOT NULL,
    description TEXT,
    result VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_dispatch_alert_id (alert_id),
    INDEX idx_dispatch_handler_id (handler_id),
    INDEX idx_dispatch_status (status),
    CONSTRAINT fk_dispatch_alert FOREIGN KEY (alert_id) REFERENCES alert(id) ON DELETE CASCADE,
    CONSTRAINT fk_dispatch_handler FOREIGN KEY (handler_id) REFERENCES user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE care_plan (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    elderly_id BIGINT NOT NULL,
    worker_id BIGINT NOT NULL,
    plan_type VARCHAR(20) NOT NULL DEFAULT 'OTHER',
    frequency VARCHAR(20) NOT NULL DEFAULT 'DAILY',
    start_date DATE NOT NULL,
    end_date DATE,
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_care_plan_elderly_id (elderly_id),
    INDEX idx_care_plan_worker_id (worker_id),
    INDEX idx_care_plan_status (status),
    INDEX idx_care_plan_start_date (start_date),
    CONSTRAINT fk_care_plan_elderly FOREIGN KEY (elderly_id) REFERENCES elderly(id) ON DELETE CASCADE,
    CONSTRAINT fk_care_plan_worker FOREIGN KEY (worker_id) REFERENCES user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE care_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    plan_id BIGINT,
    worker_id BIGINT NOT NULL,
    elderly_id BIGINT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'OTHER',
    elderly_status VARCHAR(20) NOT NULL DEFAULT 'GOOD',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_care_log_plan_id (plan_id),
    INDEX idx_care_log_worker_id (worker_id),
    INDEX idx_care_log_elderly_id (elderly_id),
    INDEX idx_care_log_created_at (created_at),
    CONSTRAINT fk_care_log_plan FOREIGN KEY (plan_id) REFERENCES care_plan(id) ON DELETE SET NULL,
    CONSTRAINT fk_care_log_worker FOREIGN KEY (worker_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_care_log_elderly FOREIGN KEY (elderly_id) REFERENCES elderly(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    type VARCHAR(20) NOT NULL DEFAULT 'INFO',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_notification_user_id (user_id),
    INDEX idx_notification_is_read (is_read),
    INDEX idx_notification_type (type),
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 测试数据（密码统一为：admin123，使用BCrypt加密）
INSERT INTO community (name, address, area) VALUES
('幸福社区', '北京市海淀区中关村大街1号', '海淀区'),
('阳光家园', '北京市朝阳区望京街9号', '朝阳区');

INSERT INTO user (username, password, real_name, phone, role, community_id, status) VALUES
('admin',   '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '管理员',  '13800138000', 'ADMIN',  NULL, 'ACTIVE'),
('worker1', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '张护工',  '13800138001', 'WORKER', 1,    'ACTIVE'),
('worker2', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '李护士',  '13800138002', 'WORKER', 2,    'ACTIVE'),
('family1', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '王小明',  '13800138003', 'FAMILY', 1,    'ACTIVE'),
('family2', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '刘小红',  '13800138004', 'FAMILY', 2,    'ACTIVE');

INSERT INTO elderly (name, age, gender, address, phone, emergency_contact, health_notes, community_id, status) VALUES
('王大爷', 78, 'MALE',   '幸福社区3号楼101',  '010-88886666', '13800138001', '高血压，每天服药',     1, 'ACTIVE'),
('李奶奶', 82, 'FEMALE', '幸福社区5号楼202',  '010-88887777', '13800138002', '糖尿病，需定期检查',   1, 'ACTIVE'),
('张爷爷', 75, 'MALE',   '幸福社区2号楼301',  '010-88885555', '13800138003', '心脏病史',             1, 'ACTIVE'),
('刘奶奶', 80, 'FEMALE', '阳光家园1号楼101',  '010-66668888', '13800138004', '关节炎',               2, 'ACTIVE'),
('陈大爷', 76, 'MALE',   '阳光家园3号楼201',  '010-66669999', '13800138005', '无特殊病史',           2, 'ACTIVE');

-- 设备（绑定老人 elderly_id）
INSERT INTO device (name, type, mac, community_id, elderly_id, status, battery, last_heartbeat) VALUES
('王大爷的手表',   'WATCH', 'A1:B2:C3:D4:E5:F6', 1, 1,    'ONLINE',  85,  NOW()),
('李奶奶的手表',   'WATCH', 'A1:B2:C3:D4:E5:F7', 1, 2,    'ONLINE',  72,  NOW()),
('社区大屏',       'PANEL', 'P1:Q2:R3:S4:T5:U6', 1, NULL, 'ONLINE',  100, NOW()),
('刘奶奶的手表',   'WATCH', 'A1:B2:C3:D4:E5:F8', 2, 4,    'ONLINE',  90,  NOW()),
('陈大爷的手表',   'WATCH', 'A1:B2:C3:D4:E5:F9', 2, 5,    'OFFLINE', 15,  '2026-07-08 20:00:00'),
('阳光家园大屏',   'PANEL', 'P1:Q2:R3:S4:T5:U7', 2, NULL, 'ONLINE',  100, NOW());

-- 同步 elderly.device_mac（设备绑定后）
UPDATE elderly SET device_mac = 'A1:B2:C3:D4:E5:F6' WHERE id = 1;
UPDATE elderly SET device_mac = 'A1:B2:C3:D4:E5:F7' WHERE id = 2;
UPDATE elderly SET device_mac = 'A1:B2:C3:D4:E5:F8' WHERE id = 4;
UPDATE elderly SET device_mac = 'A1:B2:C3:D4:E5:F9' WHERE id = 5;

-- 告警数据（分布在最近 4 周，覆盖 weekly 趋势；PENDING / PROCESSING / RESOLVED 三种状态）
INSERT INTO alert (type, elderly_id, community_id, device_id, source, status, priority, handler_id, lat, lng, cause, details, happened_at, resolved_at) VALUES
-- 本周 W28 (07/06 ~ 07/12)
('SOS',         1, 1, 1,    'WATCH',  'PENDING',   'HIGH',   NULL, 30.5728, 104.0668, NULL,              NULL,                         '2026-07-09 10:30:00', NULL),
('INACTIVITY',  2, 1, 2,    'WATCH',  'PROCESSING','MEDIUM', 3,    NULL, NULL,     NULL,              NULL,                         '2026-07-07 08:00:00', NULL),
('SOS',         4, 2, 4,    'WATCH',  'PENDING',   'HIGH',   NULL, 30.5728, 104.0668, NULL,             NULL,                         '2026-07-06 09:30:00', NULL),
-- 上周 W27 (06/29 ~ 07/05)
('FALL',        1, 1, 1,    'WATCH',  'RESOLVED',  'HIGH',   2,    30.5728, 104.0668, '老人卫生间滑倒', '到达现场检查，老人无大碍',   '2026-07-05 14:00:00', '2026-07-05 15:30:00'),
('LOW_BATTERY', 5, 2, 5,    'WATCH',  'RESOLVED',  'MEDIUM', 2,    NULL, NULL,     '电量低于20%',     '提醒家属充电，已恢复正常',   '2026-07-04 10:00:00', '2026-07-04 10:30:00'),
('ABNORMAL',    3, 1, NULL, 'APP',    'RESOLVED',  'MEDIUM', 2,    NULL, NULL,     '心率异常',        '社区人员上门检查，心率恢复正常','2026-07-03 11:00:00', '2026-07-03 14:00:00'),
('SOS',         2, 1, 2,    'WATCH',  'RESOLVED',  'HIGH',   3,    30.5728, 104.0668, '老人误触SOS按钮', '电话确认老人安全',           '2026-06-30 16:00:00', '2026-07-01 09:00:00'),
('PHONE',       1, 1, NULL, 'RULE',   'RESOLVED',  'LOW',    2,    NULL, NULL,     '常规电话关怀',    '老人精神状态良好',           '2026-07-01 10:00:00', '2026-07-01 10:15:00'),
-- 两周前 W26 (06/22 ~ 06/28)
('LOW_BATTERY', 1, 1, 1,    'WATCH',  'RESOLVED',  'MEDIUM', 2,    NULL, NULL,     '电量低于15%',     '已充电至85%',                '2026-06-28 09:00:00', '2026-06-28 09:30:00'),
('FALL',        4, 2, 4,    'WATCH',  'RESOLVED',  'HIGH',   3,    30.5728, 104.0668, '客厅摔倒',       '家属陪同就医，已返回家中',   '2026-06-25 15:00:00', '2026-06-25 16:00:00'),
-- 三周前 W25 (06/15 ~ 06/21)
('DEVICE_OFFLINE', 3, 1, NULL, 'SYSTEM','RESOLVED','MEDIUM', 3,    NULL, NULL,     '设备长时间离线',  '重启设备后恢复在线',         '2026-06-20 22:00:00', '2026-06-21 08:00:00');

-- 派单数据（PROCESSING / RESOLVED 告警对应派单）
INSERT INTO dispatch (alert_id, handler_id, description, result, status) VALUES
(2,  2, '到达现场检查，老人无大碍',           'RESOLVED',       'COMPLETED'),
(4,  3, '电话确认老人安全',                   'RESOLVED',       'COMPLETED'),
(5,  2, '提醒家属充电，已恢复正常',           'RESOLVED',       'COMPLETED'),
(6,  2, '社区人员上门检查，心率恢复正常',     'RESOLVED',       'COMPLETED'),
(7,  3, NULL,                                 NULL,             'ACTIVE'),
(9,  2, '已充电至85%',                        'RESOLVED',       'COMPLETED'),
(10, 3, '家属陪同就医，已返回家中',           'RESOLVED',       'COMPLETED'),
(11, 3, '重启设备后恢复在线',                 'RESOLVED',       'COMPLETED');

-- 关怀计划
INSERT INTO care_plan (elderly_id, worker_id, plan_type, frequency, start_date, end_date, notes, status) VALUES
(1, 2, 'PHONE_CALL',     'WEEKLY',       '2026-07-01', '2026-12-31', '每周电话了解王大爷身体状况',     'ACTIVE'),
(2, 2, 'VISIT',          'MONTHLY',      '2026-07-01', '2026-12-31', '每月上门走访李奶奶',             'ACTIVE'),
(3, 3, 'MEDICINE_REMIND','DAILY',        '2026-07-01', '2026-12-31', '每日提醒张爷爷服药',             'ACTIVE'),
(4, 3, 'PHONE_CALL',     'WEEKLY',       '2026-07-01', '2026-12-31', '每周电话关怀刘奶奶',             'ACTIVE'),
(5, 3, 'VISIT',          'EVERY_2_DAYS', '2026-07-01', NULL,         '每两天走访陈大爷',               'ACTIVE');

-- 关怀记录（分布在最近 4 周，覆盖 weekly 趋势）
INSERT INTO care_log (plan_id, worker_id, elderly_id, type, elderly_status, notes, created_at) VALUES
(1, 2, 1, 'PHONE',    'GOOD', '老人精神状态良好，血压正常',           '2026-07-08 10:00:00'),
(2, 2, 2, 'VISIT',    'FAIR', '老人血糖偏高，建议控制饮食',           '2026-07-06 14:00:00'),
(3, 3, 3, 'MEDICINE', 'GOOD', '按时服药，无异常',                     '2026-07-07 09:00:00'),
(1, 2, 1, 'PHONE',    'GOOD', '老人反映睡眠质量改善',                 '2026-07-01 10:00:00'),
(2, 2, 2, 'PHONE',    'GOOD', '老人情绪稳定，血糖平稳',               '2026-06-30 15:00:00'),
(3, 3, 3, 'VISIT',    'POOR', '老人胸闷，建议去医院检查',             '2026-06-25 14:00:00'),
(4, 3, 4, 'PHONE',    'GOOD', '老人关节疼痛缓解',                     '2026-07-05 10:00:00'),
(4, 3, 4, 'VISIT',    'FAIR', '老人行动不便，建议增加护理频次',       '2026-06-28 14:00:00');

-- 通知
INSERT INTO notification (user_id, title, content, type, is_read, created_at) VALUES
(2, '新SOS告警',     '王大爷触发SOS紧急告警，请尽快处理',     'ALERT', FALSE, '2026-07-09 10:30:00'),
(2, '活动异常告警',   '李奶奶近12小时无活动记录',             'ALERT', FALSE, '2026-07-07 08:00:00'),
(3, '新SOS告警',     '刘奶奶触发SOS紧急告警，请尽快处理',     'ALERT', FALSE, '2026-07-06 09:30:00'),
(1, '系统运行正常',   '所有设备在线，无异常',                 'INFO',  TRUE,  '2026-07-09 08:00:00'),
(2, '关怀提醒',       '今日需电话关怀王大爷',                 'INFO',  TRUE,  '2026-07-09 09:00:00');
