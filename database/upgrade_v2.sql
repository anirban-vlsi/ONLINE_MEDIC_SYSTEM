USE `medic`;

-- 2. Doctor Availability table enhancements
ALTER TABLE `doctor_availability` DROP FOREIGN KEY `fk_avail_doctor`;
ALTER TABLE `doctor_availability` DROP INDEX `uk_doctor_day`;
ALTER TABLE `doctor_availability` ADD UNIQUE KEY `uk_doctor_day_mode` (`doctor_reg_no`, `day_of_week`, `visit_mode`);
ALTER TABLE `doctor_availability` ADD CONSTRAINT `fk_avail_doctor` FOREIGN KEY (`doctor_reg_no`) REFERENCES `doctor` (`registration_number`) ON DELETE CASCADE;

-- 3. Appointment table enhancements
ALTER TABLE `appointment`
    ADD COLUMN `visit_type` VARCHAR(20) NOT NULL DEFAULT 'CLINIC' AFTER `doctor_reg_no`,
    ADD COLUMN `patient_city` VARCHAR(100) DEFAULT NULL AFTER `visit_type`,
    ADD COLUMN `patient_home_address` TEXT DEFAULT NULL AFTER `patient_city`,
    ADD COLUMN `fee_charged` DECIMAL(10,2) NOT NULL DEFAULT 500.00 AFTER `patient_home_address`,
    ADD COLUMN `proposed_date` DATE DEFAULT NULL AFTER `reason`,
    ADD COLUMN `proposed_time` TIME DEFAULT NULL AFTER `proposed_date`,
    ADD COLUMN `doctor_remarks` TEXT DEFAULT NULL AFTER `proposed_time`,
    ADD COLUMN `payment_status` VARCHAR(20) NOT NULL DEFAULT 'UNPAID' AFTER `status`;

-- 4. Financial Transaction table rebuild
DROP TABLE IF EXISTS `financial_transaction`;
CREATE TABLE `financial_transaction` (
    `transaction_id` VARCHAR(100) PRIMARY KEY,
    `service_type` VARCHAR(20) NOT NULL, -- 'APPOINTMENT' or 'PHARMACY'
    `reference_id` INT NOT NULL, -- appointment_id or order_id
    `patient_user_id` INT NOT NULL,
    `provider_id` VARCHAR(100) DEFAULT NULL, -- doctor_reg_no or 'PHARMACY'
    `gross_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `commission_rate` DECIMAL(5,2) NOT NULL DEFAULT 15.00,
    `admin_commission` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `provider_payout` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_method` VARCHAR(50) NOT NULL DEFAULT 'UPI', -- UPI, CARD, NET_BANKING
    `transaction_status` VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    `transaction_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ft_service` (`service_type`, `reference_id`),
    INDEX `idx_ft_user` (`patient_user_id`),
    INDEX `idx_ft_provider` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Pharmacist table
CREATE TABLE IF NOT EXISTS `pharmacist` (
    `pharmacist_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `full_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `pharmacy_name` VARCHAR(150) NOT NULL DEFAULT 'Central Hospital Pharmacy',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `pharmacist` (`username`, `full_name`, `email`, `password`, `phone`, `pharmacy_name`)
VALUES ('pharmacist', 'Chief Pharmacist', 'pharmacist@medic.local', SHA2('manager', 256), '+91-9876543220', 'Central Hospital Pharmacy')
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`);

-- 6. Emergency Operator table
CREATE TABLE IF NOT EXISTS `emergency_operator` (
    `operator_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `full_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `dispatch_center` VARCHAR(150) NOT NULL DEFAULT 'City Emergency Control 108',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `emergency_operator` (`username`, `full_name`, `email`, `password`, `phone`, `dispatch_center`)
VALUES ('operator', 'Emergency Dispatch Lead', 'emergency@medic.local', SHA2('manager', 256), '+91-9876543221', 'City Emergency Control 108')
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`);

-- 7. Feedback and Report table
CREATE TABLE IF NOT EXISTS `feedback_report` (
    `report_id` INT AUTO_INCREMENT PRIMARY KEY,
    `reporter_role` VARCHAR(20) NOT NULL, -- 'PATIENT', 'DOCTOR'
    `reporter_id` VARCHAR(100) NOT NULL, -- user_id or doctor_reg_no
    `target_type` VARCHAR(20) NOT NULL, -- 'DOCTOR', 'PATIENT', 'PHARMACY', 'AMBULANCE'
    `target_id` VARCHAR(100) NOT NULL,
    `reference_id` INT DEFAULT NULL,
    `report_category` VARCHAR(20) NOT NULL, -- 'FEEDBACK', 'COMPLAINT'
    `rating` INT DEFAULT NULL, -- 1 to 5
    `comments` TEXT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'REVIEWED', 'ACTION_TAKEN'
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_fb_target` (`target_type`, `target_id`),
    INDEX `idx_fb_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. Moderation status on medicine and ambulance
ALTER TABLE `medicine`
    ADD COLUMN `moderation_status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' AFTER `is_active`;

ALTER TABLE `ambulance`
    ADD COLUMN `base_hospital` VARCHAR(150) DEFAULT 'Central Hospital' AFTER `driver_phone`,
    ADD COLUMN `moderation_status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' AFTER `current_status`;
