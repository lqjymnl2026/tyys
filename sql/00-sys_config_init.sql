-- ============================================================
-- 天韵艺术 · 系统规则参数初始化脚本
-- 版本: v1.0  |  数据库: MySQL 8.0  |  字符集: utf8mb4
-- 说明: 参数默认值对应《02-课时计算规则表.md》，均可通过后台
--       「系统设置 → 规则配置」页面修改。
-- ============================================================

CREATE TABLE IF NOT EXISTS sys_config (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  config_key    VARCHAR(50)  NOT NULL UNIQUE COMMENT '参数键',
  config_value  VARCHAR(255) NOT NULL COMMENT '参数值',
  description   VARCHAR(200) COMMENT '说明',
  updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统规则参数';

INSERT INTO sys_config (config_key, config_value, description) VALUES
-- 请假规则
('leave_advance_hours',      '4',    '提前请假时限（小时），超过走临时请假'),
('monthly_free_temp_leave',  '2',    '每月免费临时请假次数'),
('temp_leave_charge',        '0',    '临时请假默认是否扣课时（1扣 0不扣）'),
('temp_leave_over_deduct',   '0.5',  '临时请假超出免费次数后每次扣课时'),
('suspend_approve_months',   '3',    '连续停课超过该月数需校长审批'),

-- 消课规则
('late_grace_minutes',       '15',   '迟到免扣分钟数，超过标记迟到'),
('attendance_revert_hours',  '24',   '点名撤销时限（小时），超时需教务/校长权限'),
('session_attendance_window','30',   '课前可点名窗口（分钟）'),
('group_coef_1v2',           '0.6',  '小组课 1对2 消课折算系数'),
('group_coef_1v3',           '0.5',  '小组课 1对3 消课折算系数'),
('group_coef_1v4',           '0.4',  '小组课 1对4 消课折算系数'),

-- 扣减顺序与赠课
('deduct_priority',          'expiry,normal,gift', '扣减顺序：临期包优先→正课→赠课'),
('gift_deduct_order',        'LAST', '赠课扣减方式：LAST最后扣 / RATIO按比例'),
('gift_deduct_ratio',        '9:1',  '正课:赠课 比例（RATIO模式使用）'),
('gift_refundable',          '0',    '赠课是否可退（0不可退）'),

-- 有效期与提醒
('low_lesson_threshold',     '2',    '课时不足提醒阈值（剩余课时）'),
('expiry_remind_days',       '7,3',  '课时包到期提醒天数（逗号分隔，可多个）'),
('expiry_grace_days',        '30',   '到期宽限期（天），期内可续费激活'),

-- 补课与退费
('makeup_enabled',           '1',    '请假后是否自动进补课池（1是 0否）'),
('refund_handling_fee',      '0',    '退费手续费（元）')
ON DUPLICATE KEY UPDATE
  config_value = VALUES(config_value),
  description  = VALUES(description);

-- 使用示例（业务代码读取）:
--   SELECT config_value FROM sys_config WHERE config_key = 'leave_advance_hours';
-- 建议在应用启动时加载全部参数到缓存(Redis)，参数变更后刷新缓存。
