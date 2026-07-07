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
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '管理员', '13800138000', 'ADMIN', NULL, 'ACTIVE'),
('worker1', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '张护工', '13800138001', 'WORKER', 1, 'ACTIVE'),
('worker2', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '李护士', '13800138002', 'WORKER', 2, 'ACTIVE');

INSERT INTO elderly (name, age, gender, address, phone, emergency_contact, health_notes, community_id, status) VALUES
('王大爷', 78, 'MALE', '幸福社区3号楼101', '010-88886666', '13800138001', '高血压，每天服药', 1, 'ACTIVE'),
('李奶奶', 82, 'FEMALE', '幸福社区5号楼202', '010-88887777', '13800138002', '糖尿病，需定期检查', 1, 'ACTIVE'),
('张爷爷', 75, 'MALE', '幸福社区2号楼301', '010-88885555', '13800138003', '心脏病史', 1, 'ACTIVE'),
('刘奶奶', 80, 'FEMALE', '阳光家园1号楼101', '010-66668888', '13800138004', '关节炎', 2, 'ACTIVE'),
('陈大爷', 76, 'MALE', '阳光家园3号楼201', '010-66669999', '13800138005', '无特殊病史', 2, 'ACTIVE');

INSERT INTO device (name, type, mac, community_id, status, battery, last_heartbeat) VALUES
('王大爷的手表', 'WATCH', 'A1:B2:C3:D4:E5:F6', 1, 'ONLINE', 85, NOW()),
('李奶奶的手表', 'WATCH', 'A1:B2:C3:D4:E5:F7', 1, 'ONLINE', 72, NOW()),
('社区大屏', 'PANEL', 'P1:Q2:R3:S4:T5:U6', 1, 'ONLINE', 100, NOW());