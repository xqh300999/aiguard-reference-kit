SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `alert`;
CREATE TABLE `alert` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL DEFAULT 'ABNORMAL',
  `elderly_id` bigint DEFAULT NULL,
  `community_id` bigint NOT NULL,
  `device_id` bigint DEFAULT NULL,
  `source` varchar(20) NOT NULL DEFAULT 'SYSTEM',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `priority` varchar(20) NOT NULL DEFAULT 'MEDIUM',
  `handler_id` bigint DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `cause` text,
  `details` text,
  `happened_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_alert_type` (`type`),
  KEY `idx_alert_elderly_id` (`elderly_id`),
  KEY `idx_alert_community_id` (`community_id`),
  KEY `idx_alert_device_id` (`device_id`),
  KEY `idx_alert_status` (`status`),
  KEY `idx_alert_priority` (`priority`),
  KEY `idx_alert_handler_id` (`handler_id`),
  KEY `idx_alert_happened_at` (`happened_at`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `care_log`;
CREATE TABLE `care_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `plan_id` bigint DEFAULT NULL,
  `worker_id` bigint NOT NULL,
  `elderly_id` bigint NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'OTHER',
  `elderly_status` varchar(20) NOT NULL DEFAULT 'GOOD',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_care_log_plan_id` (`plan_id`),
  KEY `idx_care_log_worker_id` (`worker_id`),
  KEY `idx_care_log_elderly_id` (`elderly_id`),
  KEY `idx_care_log_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `care_plan`;
CREATE TABLE `care_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `elderly_id` bigint NOT NULL,
  `worker_id` bigint NOT NULL,
  `plan_type` varchar(20) NOT NULL DEFAULT 'OTHER',
  `frequency` varchar(20) NOT NULL DEFAULT 'DAILY',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `notes` text,
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_care_plan_elderly_id` (`elderly_id`),
  KEY `idx_care_plan_worker_id` (`worker_id`),
  KEY `idx_care_plan_status` (`status`),
  KEY `idx_care_plan_start_date` (`start_date`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `community`;
CREATE TABLE `community` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `area` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_community_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `device`;
CREATE TABLE `device` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'WATCH',
  `mac` varchar(20) NOT NULL,
  `community_id` bigint NOT NULL,
  `elderly_id` bigint DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'OFFLINE',
  `battery` int DEFAULT '100',
  `last_heartbeat` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mac` (`mac`),
  KEY `idx_device_mac` (`mac`),
  KEY `idx_device_type` (`type`),
  KEY `idx_device_community_id` (`community_id`),
  KEY `idx_device_elderly_id` (`elderly_id`),
  KEY `idx_device_status` (`status`),
  KEY `idx_device_last_heartbeat` (`last_heartbeat`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `dispatch`;
CREATE TABLE `dispatch` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `alert_id` bigint NOT NULL,
  `handler_id` bigint NOT NULL,
  `description` text,
  `result` varchar(20) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alert_id` (`alert_id`),
  KEY `idx_dispatch_alert_id` (`alert_id`),
  KEY `idx_dispatch_handler_id` (`handler_id`),
  KEY `idx_dispatch_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `elderly`;
CREATE TABLE `elderly` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `age` int DEFAULT NULL,
  `gender` varchar(10) DEFAULT 'MALE',
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `emergency_contact` varchar(20) DEFAULT NULL,
  `health_notes` text,
  `community_id` bigint NOT NULL,
  `device_mac` varchar(20) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_elderly_name` (`name`),
  KEY `idx_elderly_community_id` (`community_id`),
  KEY `idx_elderly_status` (`status`),
  KEY `idx_elderly_device_mac` (`device_mac`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `alert_id` bigint DEFAULT NULL,
  `title` varchar(100) NOT NULL,
  `content` text,
  `type` varchar(20) NOT NULL DEFAULT 'INFO',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notification_user_id` (`user_id`),
  KEY `idx_notification_alert_id` (`alert_id`),
  KEY `idx_notification_is_read` (`is_read`),
  KEY `idx_notification_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `real_name` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'WORKER',
  `community_id` bigint DEFAULT NULL,
  `elderly_id` bigint DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_user_username` (`username`),
  KEY `idx_user_role` (`role`),
  KEY `idx_user_community_id` (`community_id`),
  KEY `idx_user_status` (`status`),
  KEY `idx_user_elderly_id` (`elderly_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Seed data
INSERT INTO `community` VALUES (1,'幸福社区','北京市海淀区中关村大街1号','海淀区','2026-07-09 09:47:16','2026-07-09 09:47:16'),(2,'阳光家园','北京市朝阳区望京街9号','朝阳区','2026-07-09 09:47:16','2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (1,'王大爷',78,'MALE','幸福社区3号楼101','010-88886666','13800138001','高血压，每天服药',1,'A1:B2:C3:D4:E5:F6','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(2,'李奶奶',82,'FEMALE','幸福社区5号楼202','010-88887777','13800138002','糖尿病，需定期检查',1,'A1:B2:C3:D4:E5:F7','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(3,'张爷爷',75,'MALE','幸福社区2号楼301','010-88885555','13800138003','心脏病史',1,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(4,'刘奶奶',80,'FEMALE','阳光家园1号楼101','010-66668888','13800138004','关节炎',2,'A1:B2:C3:D4:E5:F8','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(5,'陈大爷',76,'MALE','阳光家园3号楼201','010-66669999','13800138005','无特殊病史',2,'A1:B2:C3:D4:E5:F9','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(6,'老王',78,'MALE','1','12312341234','1','良好',1,NULL,'ACTIVE','2026-07-10 14:33:12','2026-07-10 14:33:12');
INSERT INTO `device` VALUES (1,'王大爷的手表','WATCH','A1:B2:C3:D4:E5:F6',1,1,'ONLINE',85,'2026-07-09 10:52:40','2026-07-09 09:47:16','2026-07-09 10:52:40'),(2,'李奶奶的手表','WATCH','A1:B2:C3:D4:E5:F7',1,2,'ONLINE',72,'2026-07-09 09:47:16','2026-07-09 09:47:16','2026-07-09 09:47:16'),(3,'社区大屏','PANEL','P1:Q2:R3:S4:T5:U6',1,NULL,'ONLINE',100,'2026-07-09 09:47:16','2026-07-09 09:47:16','2026-07-09 09:47:16'),(4,'刘奶奶的手表','WATCH','A1:B2:C3:D4:E5:F8',2,4,'ONLINE',90,'2026-07-09 09:47:16','2026-07-09 09:47:16','2026-07-09 09:47:16'),(5,'陈大爷的手表','WATCH','A1:B2:C3:D4:E5:F9',2,5,'OFFLINE',15,'2026-07-08 20:00:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(6,'阳光家园大屏','PANEL','P1:Q2:R3:S4:T5:U7',2,NULL,'ONLINE',100,'2026-07-09 09:47:16','2026-07-09 09:47:16','2026-07-09 09:47:16'),(7,'Allen的测试手表','WATCH','AL:LE:N_:9',1,NULL,'ONLINE',85,NULL,'2026-07-10 14:52:55','2026-07-10 14:52:55');
INSERT INTO `user` VALUES (1,'admin','$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.','管理员','13800138000','ADMIN',NULL,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-10 11:26:17'),(2,'worker1','$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.','张护工','13800138001','WORKER',1,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-10 11:26:17'),(3,'worker2','$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.','李护士','13800138002','WORKER',2,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-10 11:26:17'),(4,'family1','$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.','王小明','13800138003','FAMILY',1,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-10 11:26:17'),(5,'family2','$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.','刘小红','13800138004','FAMILY',2,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-10 11:26:17'),(9,'111111','$2a$10$khp7Joy6eGxwJhUwp2JVxePnjfUOD.6vj.O21NrFsM3LhPjWlJI72','小王','11111111111','FAMILY',1,NULL,'ACTIVE','2026-07-10 11:18:13','2026-07-10 11:18:13'),(10,'121','$2a$10$g.TseIQ/qF052oEHhQYQ.OugqwguChnuG5wBLhhkv8ZajQ0UC1JTW','肖恩昂','13300000000','FAMILY',1,NULL,'ACTIVE','2026-07-10 11:19:06','2026-07-10 11:19:06');
INSERT INTO `alert` VALUES (1,'SOS',1,1,1,'WATCH','PENDING','HIGH',NULL,30.5728000,104.0668000,NULL,NULL,'2026-07-09 10:30:00',NULL,'2026-07-09 09:47:16','2026-07-09 09:47:16'),(2,'INACTIVITY',2,1,2,'WATCH','RESOLVED','MEDIUM',3,NULL,NULL,'误触SOS按钮','到达现场检查无异常','2026-07-07 08:00:00','2026-07-09 11:05:21','2026-07-09 09:47:16','2026-07-09 11:05:21'),(3,'SOS',4,2,4,'WATCH','PENDING','HIGH',NULL,30.5728000,104.0668000,NULL,NULL,'2026-07-06 09:30:00',NULL,'2026-07-09 09:47:16','2026-07-09 09:47:16'),(4,'FALL',1,1,1,'WATCH','RESOLVED','HIGH',2,30.5728000,104.0668000,'老人卫生间滑倒','到达现场检查，老人无大碍','2026-07-05 14:00:00','2026-07-05 15:30:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(5,'LOW_BATTERY',5,2,5,'WATCH','RESOLVED','MEDIUM',2,NULL,NULL,'电量低于20%','提醒家属充电，已恢复正常','2026-07-04 10:00:00','2026-07-04 10:30:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(6,'ABNORMAL',3,1,NULL,'APP','RESOLVED','MEDIUM',2,NULL,NULL,'心率异常','社区人员上门检查，心率恢复正常','2026-07-03 11:00:00','2026-07-03 14:00:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(7,'SOS',2,1,2,'WATCH','RESOLVED','HIGH',3,30.5728000,104.0668000,'老人误触SOS按钮','电话确认老人安全','2026-06-30 16:00:00','2026-07-01 09:00:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(8,'PHONE',1,1,NULL,'RULE','RESOLVED','LOW',2,NULL,NULL,'常规电话关怀','老人精神状态良好','2026-07-01 10:00:00','2026-07-01 10:15:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(9,'LOW_BATTERY',1,1,1,'WATCH','RESOLVED','MEDIUM',2,NULL,NULL,'电量低于15%','已充电至85%','2026-06-28 09:00:00','2026-06-28 09:30:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(10,'FALL',4,2,4,'WATCH','RESOLVED','HIGH',3,30.5728000,104.0668000,'客厅摔倒','家属陪同就医，已返回家中','2026-06-25 15:00:00','2026-06-25 16:00:00','2026-07-09 09:47:16','2026-07-09 09:47:16'),(11,'DEVICE_OFFLINE',3,1,NULL,'SYSTEM','RESOLVED','MEDIUM',3,NULL,NULL,'设备长时间离线','重启设备后恢复在线','2026-06-20 22:00:00','2026-06-21 08:00:00','2026-07-09 09:47:16','2026-07-09 09:47:16');
INSERT INTO `care_plan` VALUES (1,1,2,'PHONE_CALL','WEEKLY','2026-07-01','2026-12-31','每周电话了解王大爷身体状况','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(2,2,2,'VISIT','MONTHLY','2026-07-01','2026-12-31','每月上门走访李奶奶','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(3,3,3,'MEDICINE_REMIND','DAILY','2026-07-01','2026-12-31','每日提醒张爷爷服药','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(4,4,3,'PHONE_CALL','WEEKLY','2026-07-01','2026-12-31','每周电话关怀刘奶奶','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(5,5,3,'VISIT','EVERY_2_DAYS','2026-07-01',NULL,'每两天走访陈大爷','ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16');
INSERT INTO `care_log` VALUES (1,1,2,1,'PHONE','GOOD','老人精神状态良好，血压正常','2026-07-08 10:00:00'),(2,2,2,2,'VISIT','FAIR','老人血糖偏高，建议控制饮食','2026-07-06 14:00:00'),(3,3,3,3,'MEDICINE','GOOD','按时服药，无异常','2026-07-07 09:00:00'),(4,1,2,1,'PHONE','GOOD','老人反映睡眠质量改善','2026-07-01 10:00:00'),(5,2,2,2,'PHONE','GOOD','老人情绪稳定，血糖平稳','2026-06-30 15:00:00'),(6,3,3,3,'VISIT','POOR','老人胸闷，建议去医院检查','2026-06-25 14:00:00'),(7,4,3,4,'PHONE','GOOD','老人关节疼痛缓解','2026-07-05 10:00:00'),(8,4,3,4,'VISIT','FAIR','老人行动不便，建议增加护理频次','2026-06-28 14:00:00');
INSERT INTO `dispatch` VALUES (1,2,2,'到达现场检查，老人无大碍','老人误触','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(2,4,3,'电话确认老人安全','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(3,5,2,'提醒家属充电，已恢复正常','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(4,6,2,'社区人员上门检查，心率恢复正常','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(5,7,3,NULL,NULL,'ACTIVE','2026-07-09 09:47:16','2026-07-09 09:47:16'),(6,9,2,'已充电至85%','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(7,10,3,'家属陪同就医，已返回家中','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(8,11,3,'重启设备后恢复在线','RESOLVED','COMPLETED','2026-07-09 09:47:16','2026-07-09 09:47:16'),(9,13,2,'上门查看',NULL,'ACTIVE','2026-07-09 11:05:11','2026-07-09 11:05:11'),(10,61,1,'测试','RESOLVED','COMPLETED','2026-07-10 14:37:55','2026-07-10 14:37:55'),(11,56,1,'测试接单','RESOLVED','COMPLETED','2026-07-10 14:40:53','2026-07-10 14:40:53'),(12,51,1,'老人滑倒了','RESOLVED','COMPLETED','2026-07-10 14:43:23','2026-07-10 14:43:23'),(13,60,1,NULL,NULL,'ACTIVE','2026-07-10 14:44:52','2026-07-10 14:44:52'),(14,62,1,'不小心滑倒了','RESOLVED','COMPLETED','2026-07-10 14:54:44','2026-07-10 14:54:44'),(15,59,2,'这是一条测试用的数据','NEED_HOSPITAL','COMPLETED','2026-07-10 14:56:09','2026-07-10 14:56:09'),(16,63,2,'滑倒了','NEED_HOSPITAL','COMPLETED','2026-07-10 14:58:04','2026-07-10 14:58:04'),(17,58,2,'1','NEED_FOLLOW_UP','COMPLETED','2026-07-10 14:58:43','2026-07-10 14:58:43');
INSERT INTO `notification` VALUES (1,2,1,'新SOS告警','王大爷触发SOS紧急告警，请尽快处理','ALERT',0,'2026-07-09 10:30:00','2026-07-09 09:47:17'),(2,2,2,'活动异常告警','李奶奶近12小时无活动记录','ALERT',0,'2026-07-07 08:00:00','2026-07-09 09:47:17'),(3,3,3,'新SOS告警','刘奶奶触发SOS紧急告警，请尽快处理','ALERT',0,'2026-07-06 09:30:00','2026-07-09 09:47:17'),(4,1,NULL,'系统运行正常','所有设备在线，无异常','INFO',1,'2026-07-09 08:00:00','2026-07-09 09:47:17'),(5,2,NULL,'关怀提醒','今日需电话关怀王大爷','INFO',1,'2026-07-09 09:00:00','2026-07-09 09:47:17');
