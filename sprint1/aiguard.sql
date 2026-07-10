/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : aiguard

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 10/07/2026 15:03:00
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for alert
-- ----------------------------
DROP TABLE IF EXISTS `alert`;
CREATE TABLE `alert`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ABNORMAL',
  `elderly_id` bigint NULL DEFAULT NULL,
  `community_id` bigint NOT NULL,
  `device_id` bigint NULL DEFAULT NULL,
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MEDIUM',
  `handler_id` bigint NULL DEFAULT NULL,
  `lat` decimal(10, 7) NULL DEFAULT NULL,
  `lng` decimal(10, 7) NULL DEFAULT NULL,
  `cause` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `happened_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_alert_type`(`type` ASC) USING BTREE,
  INDEX `idx_alert_elderly_id`(`elderly_id` ASC) USING BTREE,
  INDEX `idx_alert_community_id`(`community_id` ASC) USING BTREE,
  INDEX `idx_alert_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_alert_status`(`status` ASC) USING BTREE,
  INDEX `idx_alert_priority`(`priority` ASC) USING BTREE,
  INDEX `idx_alert_handler_id`(`handler_id` ASC) USING BTREE,
  INDEX `idx_alert_happened_at`(`happened_at` ASC) USING BTREE,
  CONSTRAINT `fk_alert_community` FOREIGN KEY (`community_id`) REFERENCES `community` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_alert_device` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_alert_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_alert_handler` FOREIGN KEY (`handler_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of alert
-- ----------------------------
INSERT INTO `alert` VALUES (1, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-09 10:30:00', NULL, '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (2, 'INACTIVITY', 2, 1, 2, 'WATCH', 'RESOLVED', 'MEDIUM', 3, NULL, NULL, '误触SOS按钮', '到达现场检查无异常', '2026-07-07 08:00:00', '2026-07-09 11:05:21', '2026-07-09 09:47:16', '2026-07-09 11:05:21');
INSERT INTO `alert` VALUES (3, 'SOS', 4, 2, 4, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-06 09:30:00', NULL, '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (4, 'FALL', 1, 1, 1, 'WATCH', 'RESOLVED', 'HIGH', 2, 30.5728000, 104.0668000, '老人卫生间滑倒', '到达现场检查，老人无大碍', '2026-07-05 14:00:00', '2026-07-05 15:30:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (5, 'LOW_BATTERY', 5, 2, 5, 'WATCH', 'RESOLVED', 'MEDIUM', 2, NULL, NULL, '电量低于20%', '提醒家属充电，已恢复正常', '2026-07-04 10:00:00', '2026-07-04 10:30:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (6, 'ABNORMAL', 3, 1, NULL, 'APP', 'RESOLVED', 'MEDIUM', 2, NULL, NULL, '心率异常', '社区人员上门检查，心率恢复正常', '2026-07-03 11:00:00', '2026-07-03 14:00:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (7, 'SOS', 2, 1, 2, 'WATCH', 'RESOLVED', 'HIGH', 3, 30.5728000, 104.0668000, '老人误触SOS按钮', '电话确认老人安全', '2026-06-30 16:00:00', '2026-07-01 09:00:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (8, 'PHONE', 1, 1, NULL, 'RULE', 'RESOLVED', 'LOW', 2, NULL, NULL, '常规电话关怀', '老人精神状态良好', '2026-07-01 10:00:00', '2026-07-01 10:15:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (9, 'LOW_BATTERY', 1, 1, 1, 'WATCH', 'RESOLVED', 'MEDIUM', 2, NULL, NULL, '电量低于15%', '已充电至85%', '2026-06-28 09:00:00', '2026-06-28 09:30:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (10, 'FALL', 4, 2, 4, 'WATCH', 'RESOLVED', 'HIGH', 3, 30.5728000, 104.0668000, '客厅摔倒', '家属陪同就医，已返回家中', '2026-06-25 15:00:00', '2026-06-25 16:00:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (11, 'DEVICE_OFFLINE', 3, 1, NULL, 'SYSTEM', 'RESOLVED', 'MEDIUM', 3, NULL, NULL, '设备长时间离线', '重启设备后恢复在线', '2026-06-20 22:00:00', '2026-06-21 08:00:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `alert` VALUES (12, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, NULL, NULL, NULL, 'battery=15', '2026-07-09 10:51:17', NULL, '2026-07-09 10:51:16', '2026-07-09 10:51:16');
INSERT INTO `alert` VALUES (13, 'SOS', 1, 1, 1, 'WATCH', 'PROCESSING', 'HIGH', 2, NULL, NULL, NULL, 'battery=15', '2026-07-09 10:51:26', NULL, '2026-07-09 10:51:26', '2026-07-09 11:05:11');
INSERT INTO `alert` VALUES (14, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, NULL, NULL, NULL, 'battery=15', '2026-07-09 14:30:37', NULL, '2026-07-09 14:30:36', '2026-07-09 14:30:36');
INSERT INTO `alert` VALUES (15, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-09 15:30:53', NULL, '2026-07-09 15:30:52', '2026-07-09 15:30:52');
INSERT INTO `alert` VALUES (16, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-09 15:31:01', NULL, '2026-07-09 15:31:01', '2026-07-09 15:31:01');
INSERT INTO `alert` VALUES (17, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-09 15:31:23', NULL, '2026-07-09 15:31:23', '2026-07-09 15:31:23');
INSERT INTO `alert` VALUES (18, 'SOS', 1, 1, 1, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-09 15:32:16', NULL, '2026-07-09 15:32:15', '2026-07-09 15:32:15');
INSERT INTO `alert` VALUES (19, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:14:26', NULL, '2026-07-10 09:14:25', '2026-07-10 09:14:25');
INSERT INTO `alert` VALUES (20, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:14:54', NULL, '2026-07-10 09:14:54', '2026-07-10 09:14:54');
INSERT INTO `alert` VALUES (21, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:15:06', NULL, '2026-07-10 09:15:06', '2026-07-10 09:15:06');
INSERT INTO `alert` VALUES (22, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:15:53', NULL, '2026-07-10 09:15:52', '2026-07-10 09:15:52');
INSERT INTO `alert` VALUES (23, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:16:04', NULL, '2026-07-10 09:16:04', '2026-07-10 09:16:04');
INSERT INTO `alert` VALUES (24, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:43:30', NULL, '2026-07-10 09:43:30', '2026-07-10 09:43:30');
INSERT INTO `alert` VALUES (25, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 09:43:41', NULL, '2026-07-10 09:43:41', '2026-07-10 09:43:41');
INSERT INTO `alert` VALUES (26, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:00:47', NULL, '2026-07-10 10:00:47', '2026-07-10 10:00:47');
INSERT INTO `alert` VALUES (27, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:00:59', NULL, '2026-07-10 10:00:58', '2026-07-10 10:00:58');
INSERT INTO `alert` VALUES (28, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:06:58', NULL, '2026-07-10 10:06:58', '2026-07-10 10:06:58');
INSERT INTO `alert` VALUES (29, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:07:10', NULL, '2026-07-10 10:07:10', '2026-07-10 10:07:10');
INSERT INTO `alert` VALUES (30, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:30:53', NULL, '2026-07-10 10:30:52', '2026-07-10 10:30:52');
INSERT INTO `alert` VALUES (31, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:31:05', NULL, '2026-07-10 10:31:04', '2026-07-10 10:31:04');
INSERT INTO `alert` VALUES (32, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:33:38', NULL, '2026-07-10 10:33:37', '2026-07-10 10:33:37');
INSERT INTO `alert` VALUES (33, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 10:33:49', NULL, '2026-07-10 10:33:49', '2026-07-10 10:33:49');
INSERT INTO `alert` VALUES (34, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:19:56', NULL, '2026-07-10 11:19:55', '2026-07-10 11:19:55');
INSERT INTO `alert` VALUES (35, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:36:45', NULL, '2026-07-10 11:36:45', '2026-07-10 11:36:45');
INSERT INTO `alert` VALUES (36, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:36:46', NULL, '2026-07-10 11:36:45', '2026-07-10 11:36:45');
INSERT INTO `alert` VALUES (37, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:39:40', NULL, '2026-07-10 11:39:39', '2026-07-10 11:39:39');
INSERT INTO `alert` VALUES (38, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:40:36', NULL, '2026-07-10 11:40:35', '2026-07-10 11:40:35');
INSERT INTO `alert` VALUES (39, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:40:47', NULL, '2026-07-10 11:40:47', '2026-07-10 11:40:47');
INSERT INTO `alert` VALUES (40, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:42:08', NULL, '2026-07-10 11:42:07', '2026-07-10 11:42:07');
INSERT INTO `alert` VALUES (41, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:42:19', NULL, '2026-07-10 11:42:19', '2026-07-10 11:42:19');
INSERT INTO `alert` VALUES (42, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:43:14', NULL, '2026-07-10 11:43:13', '2026-07-10 11:43:13');
INSERT INTO `alert` VALUES (43, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 11:43:26', NULL, '2026-07-10 11:43:25', '2026-07-10 11:43:25');
INSERT INTO `alert` VALUES (44, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 13:56:21', NULL, '2026-07-10 13:56:21', '2026-07-10 13:56:21');
INSERT INTO `alert` VALUES (45, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:00:09', NULL, '2026-07-10 14:00:08', '2026-07-10 14:00:08');
INSERT INTO `alert` VALUES (46, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:00:20', NULL, '2026-07-10 14:00:20', '2026-07-10 14:00:20');
INSERT INTO `alert` VALUES (47, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:01:35', NULL, '2026-07-10 14:01:35', '2026-07-10 14:01:35');
INSERT INTO `alert` VALUES (48, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:01:47', NULL, '2026-07-10 14:01:47', '2026-07-10 14:01:47');
INSERT INTO `alert` VALUES (49, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:08:10', NULL, '2026-07-10 14:08:10', '2026-07-10 14:08:10');
INSERT INTO `alert` VALUES (50, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:08:22', NULL, '2026-07-10 14:08:22', '2026-07-10 14:08:22');
INSERT INTO `alert` VALUES (51, 'SOS', 1, 1, NULL, 'WATCH', 'RESOLVED', 'HIGH', 1, 30.5728000, 104.0668000, '卫生间滑倒', '老人滑倒了', '2026-07-10 14:08:34', '2026-07-10 14:43:38', '2026-07-10 14:08:34', '2026-07-10 14:43:37');
INSERT INTO `alert` VALUES (52, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:10:41', NULL, '2026-07-10 14:10:40', '2026-07-10 14:10:40');
INSERT INTO `alert` VALUES (53, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:10:52', NULL, '2026-07-10 14:10:52', '2026-07-10 14:10:52');
INSERT INTO `alert` VALUES (54, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:11:23', NULL, '2026-07-10 14:11:23', '2026-07-10 14:11:23');
INSERT INTO `alert` VALUES (55, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:11:35', NULL, '2026-07-10 14:11:34', '2026-07-10 14:11:34');
INSERT INTO `alert` VALUES (56, 'SOS', 1, 1, NULL, 'WATCH', 'RESOLVED', 'HIGH', 1, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:21:45', '2026-07-10 14:41:05', '2026-07-10 14:21:45', '2026-07-10 14:41:05');
INSERT INTO `alert` VALUES (57, 'SOS', 1, 1, NULL, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:21:57', NULL, '2026-07-10 14:21:56', '2026-07-10 14:21:56');
INSERT INTO `alert` VALUES (58, 'SOS', 1, 1, NULL, 'WATCH', 'RESOLVED', 'HIGH', 2, 30.5728000, 104.0668000, '1', '1', '2026-07-10 14:25:12', '2026-07-10 14:58:59', '2026-07-10 14:25:12', '2026-07-10 14:58:58');
INSERT INTO `alert` VALUES (59, 'SOS', 1, 1, NULL, 'WATCH', 'RESOLVED', 'HIGH', 2, 30.5728000, 104.0668000, '卫生间滑倒了', '这是一条测试用的数据', '2026-07-10 14:30:18', '2026-07-10 14:56:32', '2026-07-10 14:30:17', '2026-07-10 14:56:32');
INSERT INTO `alert` VALUES (60, 'SOS', 1, 1, NULL, 'WATCH', 'PROCESSING', 'HIGH', 1, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:30:47', NULL, '2026-07-10 14:30:46', '2026-07-10 14:44:52');
INSERT INTO `alert` VALUES (61, 'SOS', 1, 1, NULL, 'WATCH', 'RESOLVED', 'HIGH', 1, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 14:30:58', '2026-07-10 14:40:07', '2026-07-10 14:30:57', '2026-07-10 14:40:06');
INSERT INTO `alert` VALUES (62, 'SOS', 1, 1, 7, 'WATCH', 'RESOLVED', 'HIGH', 1, 30.5728000, 104.0668000, '滑倒了', '不小心滑倒了', '2026-07-10 14:54:28', '2026-07-10 14:54:58', '2026-07-10 14:54:27', '2026-07-10 14:54:57');
INSERT INTO `alert` VALUES (63, 'SOS', 1, 1, 7, 'WATCH', 'RESOLVED', 'HIGH', 2, 30.5728000, 104.0668000, '滑倒了', '滑倒了', '2026-07-10 14:57:53', '2026-07-10 14:58:18', '2026-07-10 14:57:52', '2026-07-10 14:58:18');
INSERT INTO `alert` VALUES (64, 'SOS', 1, 1, 7, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 15:02:45', NULL, '2026-07-10 15:02:44', '2026-07-10 15:02:44');
INSERT INTO `alert` VALUES (65, 'SOS', 1, 1, 7, 'WATCH', 'PENDING', 'HIGH', NULL, 30.5728000, 104.0668000, NULL, NULL, '2026-07-10 15:02:45', NULL, '2026-07-10 15:02:44', '2026-07-10 15:02:44');

-- ----------------------------
-- Table structure for care_log
-- ----------------------------
DROP TABLE IF EXISTS `care_log`;
CREATE TABLE `care_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `plan_id` bigint NULL DEFAULT NULL,
  `worker_id` bigint NOT NULL,
  `elderly_id` bigint NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `elderly_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'GOOD',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_care_log_plan_id`(`plan_id` ASC) USING BTREE,
  INDEX `idx_care_log_worker_id`(`worker_id` ASC) USING BTREE,
  INDEX `idx_care_log_elderly_id`(`elderly_id` ASC) USING BTREE,
  INDEX `idx_care_log_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `fk_care_log_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_care_log_plan` FOREIGN KEY (`plan_id`) REFERENCES `care_plan` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_care_log_worker` FOREIGN KEY (`worker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of care_log
-- ----------------------------
INSERT INTO `care_log` VALUES (1, 1, 2, 1, 'PHONE', 'GOOD', '老人精神状态良好，血压正常', '2026-07-08 10:00:00');
INSERT INTO `care_log` VALUES (2, 2, 2, 2, 'VISIT', 'FAIR', '老人血糖偏高，建议控制饮食', '2026-07-06 14:00:00');
INSERT INTO `care_log` VALUES (3, 3, 3, 3, 'MEDICINE', 'GOOD', '按时服药，无异常', '2026-07-07 09:00:00');
INSERT INTO `care_log` VALUES (4, 1, 2, 1, 'PHONE', 'GOOD', '老人反映睡眠质量改善', '2026-07-01 10:00:00');
INSERT INTO `care_log` VALUES (5, 2, 2, 2, 'PHONE', 'GOOD', '老人情绪稳定，血糖平稳', '2026-06-30 15:00:00');
INSERT INTO `care_log` VALUES (6, 3, 3, 3, 'VISIT', 'POOR', '老人胸闷，建议去医院检查', '2026-06-25 14:00:00');
INSERT INTO `care_log` VALUES (7, 4, 3, 4, 'PHONE', 'GOOD', '老人关节疼痛缓解', '2026-07-05 10:00:00');
INSERT INTO `care_log` VALUES (8, 4, 3, 4, 'VISIT', 'FAIR', '老人行动不便，建议增加护理频次', '2026-06-28 14:00:00');

-- ----------------------------
-- Table structure for care_plan
-- ----------------------------
DROP TABLE IF EXISTS `care_plan`;
CREATE TABLE `care_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `elderly_id` bigint NOT NULL,
  `worker_id` bigint NOT NULL,
  `plan_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `frequency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DAILY',
  `start_date` date NOT NULL,
  `end_date` date NULL DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_care_plan_elderly_id`(`elderly_id` ASC) USING BTREE,
  INDEX `idx_care_plan_worker_id`(`worker_id` ASC) USING BTREE,
  INDEX `idx_care_plan_status`(`status` ASC) USING BTREE,
  INDEX `idx_care_plan_start_date`(`start_date` ASC) USING BTREE,
  CONSTRAINT `fk_care_plan_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_care_plan_worker` FOREIGN KEY (`worker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of care_plan
-- ----------------------------
INSERT INTO `care_plan` VALUES (1, 1, 2, 'PHONE_CALL', 'WEEKLY', '2026-07-01', '2026-12-31', '每周电话了解王大爷身体状况', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `care_plan` VALUES (2, 2, 2, 'VISIT', 'MONTHLY', '2026-07-01', '2026-12-31', '每月上门走访李奶奶', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `care_plan` VALUES (3, 3, 3, 'MEDICINE_REMIND', 'DAILY', '2026-07-01', '2026-12-31', '每日提醒张爷爷服药', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `care_plan` VALUES (4, 4, 3, 'PHONE_CALL', 'WEEKLY', '2026-07-01', '2026-12-31', '每周电话关怀刘奶奶', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `care_plan` VALUES (5, 5, 3, 'VISIT', 'EVERY_2_DAYS', '2026-07-01', NULL, '每两天走访陈大爷', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');

-- ----------------------------
-- Table structure for community
-- ----------------------------
DROP TABLE IF EXISTS `community`;
CREATE TABLE `community`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `area` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_community_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community
-- ----------------------------
INSERT INTO `community` VALUES (1, '幸福社区', '北京市海淀区中关村大街1号', '海淀区', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `community` VALUES (2, '阳光家园', '北京市朝阳区望京街9号', '朝阳区', '2026-07-09 09:47:16', '2026-07-09 09:47:16');

-- ----------------------------
-- Table structure for device
-- ----------------------------
DROP TABLE IF EXISTS `device`;
CREATE TABLE `device`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WATCH',
  `mac` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `community_id` bigint NOT NULL,
  `elderly_id` bigint NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OFFLINE',
  `battery` int NULL DEFAULT 100,
  `last_heartbeat` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `mac`(`mac` ASC) USING BTREE,
  INDEX `idx_device_mac`(`mac` ASC) USING BTREE,
  INDEX `idx_device_type`(`type` ASC) USING BTREE,
  INDEX `idx_device_community_id`(`community_id` ASC) USING BTREE,
  INDEX `idx_device_elderly_id`(`elderly_id` ASC) USING BTREE,
  INDEX `idx_device_status`(`status` ASC) USING BTREE,
  INDEX `idx_device_last_heartbeat`(`last_heartbeat` ASC) USING BTREE,
  CONSTRAINT `fk_device_community` FOREIGN KEY (`community_id`) REFERENCES `community` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_device_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device
-- ----------------------------
INSERT INTO `device` VALUES (1, '王大爷的手表', 'WATCH', 'A1:B2:C3:D4:E5:F6', 1, 1, 'ONLINE', 85, '2026-07-09 10:52:40', '2026-07-09 09:47:16', '2026-07-09 10:52:40');
INSERT INTO `device` VALUES (2, '李奶奶的手表', 'WATCH', 'A1:B2:C3:D4:E5:F7', 1, 2, 'ONLINE', 72, '2026-07-09 09:47:16', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `device` VALUES (3, '社区大屏', 'PANEL', 'P1:Q2:R3:S4:T5:U6', 1, NULL, 'ONLINE', 100, '2026-07-09 09:47:16', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `device` VALUES (4, '刘奶奶的手表', 'WATCH', 'A1:B2:C3:D4:E5:F8', 2, 4, 'ONLINE', 90, '2026-07-09 09:47:16', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `device` VALUES (5, '陈大爷的手表', 'WATCH', 'A1:B2:C3:D4:E5:F9', 2, 5, 'OFFLINE', 15, '2026-07-08 20:00:00', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `device` VALUES (6, '阳光家园大屏', 'PANEL', 'P1:Q2:R3:S4:T5:U7', 2, NULL, 'ONLINE', 100, '2026-07-09 09:47:16', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `device` VALUES (7, 'Allen的测试手表', 'WATCH', 'AL:LE:N_:9', 1, NULL, 'ONLINE', 85, NULL, '2026-07-10 14:52:55', '2026-07-10 14:52:55');

-- ----------------------------
-- Table structure for dispatch
-- ----------------------------
DROP TABLE IF EXISTS `dispatch`;
CREATE TABLE `dispatch`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `alert_id` bigint NOT NULL,
  `handler_id` bigint NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `alert_id`(`alert_id` ASC) USING BTREE,
  INDEX `idx_dispatch_alert_id`(`alert_id` ASC) USING BTREE,
  INDEX `idx_dispatch_handler_id`(`handler_id` ASC) USING BTREE,
  INDEX `idx_dispatch_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_dispatch_alert` FOREIGN KEY (`alert_id`) REFERENCES `alert` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_dispatch_handler` FOREIGN KEY (`handler_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dispatch
-- ----------------------------
INSERT INTO `dispatch` VALUES (1, 2, 2, '到达现场检查，老人无大碍', '老人误触', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (2, 4, 3, '电话确认老人安全', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (3, 5, 2, '提醒家属充电，已恢复正常', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (4, 6, 2, '社区人员上门检查，心率恢复正常', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (5, 7, 3, NULL, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (6, 9, 2, '已充电至85%', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (7, 10, 3, '家属陪同就医，已返回家中', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (8, 11, 3, '重启设备后恢复在线', 'RESOLVED', 'COMPLETED', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `dispatch` VALUES (9, 13, 2, '上门查看', NULL, 'ACTIVE', '2026-07-09 11:05:11', '2026-07-09 11:05:11');
INSERT INTO `dispatch` VALUES (10, 61, 1, '测试', 'RESOLVED', 'COMPLETED', '2026-07-10 14:37:55', '2026-07-10 14:37:55');
INSERT INTO `dispatch` VALUES (11, 56, 1, '测试接单', 'RESOLVED', 'COMPLETED', '2026-07-10 14:40:53', '2026-07-10 14:40:53');
INSERT INTO `dispatch` VALUES (12, 51, 1, '老人滑倒了', 'RESOLVED', 'COMPLETED', '2026-07-10 14:43:23', '2026-07-10 14:43:23');
INSERT INTO `dispatch` VALUES (13, 60, 1, NULL, NULL, 'ACTIVE', '2026-07-10 14:44:52', '2026-07-10 14:44:52');
INSERT INTO `dispatch` VALUES (14, 62, 1, '不小心滑倒了', 'RESOLVED', 'COMPLETED', '2026-07-10 14:54:44', '2026-07-10 14:54:44');
INSERT INTO `dispatch` VALUES (15, 59, 2, '这是一条测试用的数据', 'NEED_HOSPITAL', 'COMPLETED', '2026-07-10 14:56:09', '2026-07-10 14:56:09');
INSERT INTO `dispatch` VALUES (16, 63, 2, '滑倒了', 'NEED_HOSPITAL', 'COMPLETED', '2026-07-10 14:58:04', '2026-07-10 14:58:04');
INSERT INTO `dispatch` VALUES (17, 58, 2, '1', 'NEED_FOLLOW_UP', 'COMPLETED', '2026-07-10 14:58:43', '2026-07-10 14:58:43');

-- ----------------------------
-- Table structure for elderly
-- ----------------------------
DROP TABLE IF EXISTS `elderly`;
CREATE TABLE `elderly`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `age` int NULL DEFAULT NULL,
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MALE',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `emergency_contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `health_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `community_id` bigint NOT NULL,
  `device_mac` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_elderly_name`(`name` ASC) USING BTREE,
  INDEX `idx_elderly_community_id`(`community_id` ASC) USING BTREE,
  INDEX `idx_elderly_status`(`status` ASC) USING BTREE,
  INDEX `idx_elderly_device_mac`(`device_mac` ASC) USING BTREE,
  CONSTRAINT `fk_elderly_community` FOREIGN KEY (`community_id`) REFERENCES `community` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of elderly
-- ----------------------------
INSERT INTO `elderly` VALUES (1, '王大爷', 78, 'MALE', '幸福社区3号楼101', '010-88886666', '13800138001', '高血压，每天服药', 1, 'A1:B2:C3:D4:E5:F6', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (2, '李奶奶', 82, 'FEMALE', '幸福社区5号楼202', '010-88887777', '13800138002', '糖尿病，需定期检查', 1, 'A1:B2:C3:D4:E5:F7', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (3, '张爷爷', 75, 'MALE', '幸福社区2号楼301', '010-88885555', '13800138003', '心脏病史', 1, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (4, '刘奶奶', 80, 'FEMALE', '阳光家园1号楼101', '010-66668888', '13800138004', '关节炎', 2, 'A1:B2:C3:D4:E5:F8', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (5, '陈大爷', 76, 'MALE', '阳光家园3号楼201', '010-66669999', '13800138005', '无特殊病史', 2, 'A1:B2:C3:D4:E5:F9', 'ACTIVE', '2026-07-09 09:47:16', '2026-07-09 09:47:16');
INSERT INTO `elderly` VALUES (6, '老王', 78, 'MALE', '1', '12312341234', '1', '良好', 1, NULL, 'ACTIVE', '2026-07-10 14:33:12', '2026-07-10 14:33:12');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `alert_id` bigint NULL DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INFO',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notification_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_notification_alert_id`(`alert_id` ASC) USING BTREE,
  INDEX `idx_notification_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_notification_type`(`type` ASC) USING BTREE,
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_notification_alert` FOREIGN KEY (`alert_id`) REFERENCES `alert` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 2, 1, '新SOS告警', '王大爷触发SOS紧急告警，请尽快处理', 'ALERT', 0, '2026-07-09 10:30:00', '2026-07-09 09:47:17');
INSERT INTO `notification` VALUES (2, 2, 2, '活动异常告警', '李奶奶近12小时无活动记录', 'ALERT', 0, '2026-07-07 08:00:00', '2026-07-09 09:47:17');
INSERT INTO `notification` VALUES (3, 3, 3, '新SOS告警', '刘奶奶触发SOS紧急告警，请尽快处理', 'ALERT', 0, '2026-07-06 09:30:00', '2026-07-09 09:47:17');
INSERT INTO `notification` VALUES (4, 1, NULL, '系统运行正常', '所有设备在线，无异常', 'INFO', 1, '2026-07-09 08:00:00', '2026-07-09 09:47:17');
INSERT INTO `notification` VALUES (5, 2, NULL, '关怀提醒', '今日需电话关怀王大爷', 'INFO', 1, '2026-07-09 09:00:00', '2026-07-09 09:47:17');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WORKER',
  `community_id` bigint NULL DEFAULT NULL,
  `elderly_id` bigint NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_user_username`(`username` ASC) USING BTREE,
  INDEX `idx_user_role`(`role` ASC) USING BTREE,
  INDEX `idx_user_community_id`(`community_id` ASC) USING BTREE,
  INDEX `idx_user_status`(`status` ASC) USING BTREE,
  INDEX `idx_user_elderly_id`(`elderly_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_community` FOREIGN KEY (`community_id`) REFERENCES `community` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_user_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.', '管理员', '13800138000', 'ADMIN', NULL, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-10 11:26:17');
INSERT INTO `user` VALUES (2, 'worker1', '$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.', '张护工', '13800138001', 'WORKER', 1, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-10 11:26:17');
INSERT INTO `user` VALUES (3, 'worker2', '$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.', '李护士', '13800138002', 'WORKER', 2, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-10 11:26:17');
INSERT INTO `user` VALUES (4, 'family1', '$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.', '王小明', '13800138003', 'FAMILY', 1, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-10 11:26:17');
INSERT INTO `user` VALUES (5, 'family2', '$2a$10$asEdPPtMVbhD0c667o9EDeEixUO4hRN4BQvnVvRTBLYSHTtWAhGy.', '刘小红', '13800138004', 'FAMILY', 2, NULL, 'ACTIVE', '2026-07-09 09:47:16', '2026-07-10 11:26:17');
INSERT INTO `user` VALUES (9, '111111', '$2a$10$khp7Joy6eGxwJhUwp2JVxePnjfUOD.6vj.O21NrFsM3LhPjWlJI72', '小王', '11111111111', 'FAMILY', 1, NULL, 'ACTIVE', '2026-07-10 11:18:13', '2026-07-10 11:18:13');
INSERT INTO `user` VALUES (10, '121', '$2a$10$g.TseIQ/qF052oEHhQYQ.OugqwguChnuG5wBLhhkv8ZajQ0UC1JTW', '肖恩昂', '13300000000', 'FAMILY', 1, NULL, 'ACTIVE', '2026-07-10 11:19:06', '2026-07-10 11:19:06');

-- ----------------------------
-- Migration for existing databases
-- ----------------------------

-- 1. user.elderly_id 外键（如果还没有）
ALTER TABLE `user`
  ADD CONSTRAINT `fk_user_elderly` FOREIGN KEY (`elderly_id`) REFERENCES `elderly` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT;

-- 2. notification.alert_id 字段（如果还没有）
ALTER TABLE `notification`
  ADD COLUMN `alert_id` bigint NULL DEFAULT NULL AFTER `user_id`;
CREATE INDEX `idx_notification_alert_id` ON `notification` (`alert_id`);
ALTER TABLE `notification`
  ADD CONSTRAINT `fk_notification_alert` FOREIGN KEY (`alert_id`) REFERENCES `alert` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- 3. 统一 user.status 为 ACTIVE
UPDATE `user` SET `status` = 'ACTIVE' WHERE `status` = 'ENABLED';

SET FOREIGN_KEY_CHECKS = 1;
