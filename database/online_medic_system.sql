-- ============================================================================
-- ONLINE_MEDIC_SYSTEM — Master Database Schema
-- Version : 2.0 (Enhanced)
-- Engine  : MySQL 8.0+  /  InnoDB
-- Charset : utf8mb4 (utf8mb4_0900_ai_ci)
--
-- Modules covered:
--   1. Patient            (user, patient)
--   2. Doctor             (doctor, doctor_availability)
--   3. Pharmacy           (medicine, pharmacy_order, pharmacy_order_item, pharmacist)
--   4. Emergency          (ambulance, emergency_request, emergency_operator)
--   5. Admin              (admin, activity_log, financial_transaction, feedback_report)
--   6. Cross-module       (appointment, prescription)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `medic`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `medic`;

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS `feedback_report`;
DROP TABLE IF EXISTS `financial_transaction`;
DROP TABLE IF EXISTS `pharmacy_order_item`;
DROP TABLE IF EXISTS `pharmacy_order`;
DROP TABLE IF EXISTS `prescription`;
DROP TABLE IF EXISTS `appointment`;
DROP TABLE IF EXISTS `emergency_request`;
DROP TABLE IF EXISTS `ambulance`;
DROP TABLE IF EXISTS `emergency_operator`;
DROP TABLE IF EXISTS `doctor_availability`;
DROP TABLE IF EXISTS `pharmacist`;
DROP TABLE IF EXISTS `activity_log`;
DROP TABLE IF EXISTS `patient`;
DROP TABLE IF EXISTS `admin`;
DROP TABLE IF EXISTS `medicine`;
DROP TABLE IF EXISTS `doctor`;
DROP TABLE IF EXISTS `user`;

-- ============================================================================
-- 1. USER (Patient account — authentication & profile)
-- ============================================================================
CREATE TABLE `user` (
    `user_id`         INT AUTO_INCREMENT PRIMARY KEY,
    `name`            VARCHAR(150) NOT NULL,
    `email`           VARCHAR(150) NOT NULL UNIQUE,
    `gender`          VARCHAR(10)  DEFAULT NULL,
    `mobile_no`       VARCHAR(20)  DEFAULT NULL,
    `password`        VARCHAR(255) NOT NULL,
    `profile_picture` LONGBLOB     DEFAULT NULL,
    `status`          VARCHAR(20)  NOT NULL DEFAULT 'NOT VERIFIED',
    `created_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_user_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TRIGGER: Auto-verify patient when all required profile fields are complete
DELIMITER //
CREATE TRIGGER `trg_user_auto_verify`
BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    IF  NEW.`name` IS NOT NULL AND TRIM(NEW.`name`) != ''
        AND NEW.`email` IS NOT NULL AND TRIM(NEW.`email`) != ''
        AND NEW.`gender` IS NOT NULL AND TRIM(NEW.`gender`) != ''
        AND NEW.`mobile_no` IS NOT NULL AND TRIM(NEW.`mobile_no`) != ''
        AND NEW.`profile_picture` IS NOT NULL AND LENGTH(NEW.`profile_picture`) > 0
        AND NEW.`status` != 'BLOCKED'
    THEN
        SET NEW.`status` = 'VERIFIED';
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- 2. PATIENT (Family member profiles linked to a user account)
-- ============================================================================
CREATE TABLE `patient` (
    `patient_id`         INT AUTO_INCREMENT PRIMARY KEY,
    `user_id`            INT NOT NULL,
    `patient_name`       VARCHAR(150) NOT NULL,
    `date_of_birth`      DATE DEFAULT NULL,
    `gender`             VARCHAR(10)  NOT NULL,
    `relation`           VARCHAR(50)  NOT NULL,
    `mobile_no`          VARCHAR(20)  DEFAULT NULL,
    `blood_group`        VARCHAR(10)  DEFAULT NULL,
    `allergies`          TEXT DEFAULT NULL,
    `medical_conditions` TEXT DEFAULT NULL,
    `created_at`         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_patient_user` (`user_id`),
    CONSTRAINT `fk_patient_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 3. DOCTOR (Registration, specialization, city, and home visit profile)
-- ============================================================================
CREATE TABLE `doctor` (
    `registration_number`  VARCHAR(100) NOT NULL,
    `doctor_name`          VARCHAR(150) NOT NULL,
    `age`                  INT NOT NULL,
    `email`                VARCHAR(150) NOT NULL,
    `password`             VARCHAR(255) NOT NULL,
    `address`              TEXT NOT NULL,
    `city`                 VARCHAR(100) NOT NULL DEFAULT 'Bangalore',
    `specialization`       VARCHAR(150) NOT NULL,
    `consultation_fee`     DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    `home_visit_available` BOOLEAN NOT NULL DEFAULT FALSE,
    `home_visit_fee`       DECIMAL(10,2) DEFAULT NULL,
    `service_areas`        VARCHAR(255) DEFAULT NULL,
    `verification_status`  VARCHAR(20)  NOT NULL DEFAULT 'NOT VERIFIED',
    `created_at`           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`registration_number`),
    UNIQUE KEY `uk_doctor_email` (`email`),
    INDEX `idx_doctor_status` (`verification_status`),
    INDEX `idx_doctor_specialization` (`specialization`),
    INDEX `idx_doctor_city` (`city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 4. DOCTOR AVAILABILITY (Clinic vs Home Visit weekly schedule & quotas)
-- ============================================================================
CREATE TABLE `doctor_availability` (
    `availability_id`      INT AUTO_INCREMENT PRIMARY KEY,
    `doctor_reg_no`        VARCHAR(100) NOT NULL,
    `visit_mode`           VARCHAR(20) NOT NULL DEFAULT 'CLINIC',
    `day_of_week`          ENUM('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
    `start_time`           TIME NOT NULL,
    `end_time`             TIME NOT NULL,
    `max_patients_per_day` INT NOT NULL DEFAULT 20,
    `max_patients`         INT NOT NULL DEFAULT 20,
    `is_active`            TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY `uk_doctor_day_mode` (`doctor_reg_no`, `day_of_week`, `visit_mode`),
    CONSTRAINT `fk_avail_doctor`
        FOREIGN KEY (`doctor_reg_no`) REFERENCES `doctor` (`registration_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 5. APPOINTMENT (Consultations with clinic/home visit & rescheduling)
-- ============================================================================
CREATE TABLE `appointment` (
    `appointment_id`       INT AUTO_INCREMENT PRIMARY KEY,
    `patient_id`           INT NOT NULL,
    `user_id`              INT NOT NULL,
    `doctor_reg_no`        VARCHAR(100) NOT NULL,
    `visit_type`           VARCHAR(20) NOT NULL DEFAULT 'CLINIC',
    `patient_city`         VARCHAR(100) DEFAULT NULL,
    `patient_home_address` TEXT DEFAULT NULL,
    `fee_charged`          DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    `appointment_date`     DATE NOT NULL,
    `appointment_time`     TIME NULL DEFAULT NULL,
    `reason`               TEXT DEFAULT NULL,
    `proposed_date`        DATE DEFAULT NULL,
    `proposed_time`        TIME DEFAULT NULL,
    `doctor_remarks`       TEXT DEFAULT NULL,
    `status`               VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        -- PENDING, CONFIRMED, RESCHEDULE_PROPOSED, COMPLETED, CANCELLED
    `payment_status`       VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
        -- UNPAID, PAID
    `admin_remarks`        TEXT DEFAULT NULL,
    `created_at`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_appt_patient`  (`patient_id`),
    INDEX `idx_appt_user`     (`user_id`),
    INDEX `idx_appt_doctor`   (`doctor_reg_no`),
    INDEX `idx_appt_date`     (`appointment_date`),
    INDEX `idx_appt_status`   (`status`),
    CONSTRAINT `fk_appt_patient`
        FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_appt_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_appt_doctor`
        FOREIGN KEY (`doctor_reg_no`) REFERENCES `doctor` (`registration_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 6. PRESCRIPTION (Issued by doctor for patient after appointment)
-- ============================================================================
CREATE TABLE `prescription` (
    `prescription_id`      INT AUTO_INCREMENT PRIMARY KEY,
    `appointment_id`       INT NOT NULL,
    `patient_id`           INT NOT NULL,
    `doctor_reg_no`        VARCHAR(100) NOT NULL,
    `diagnosis`            TEXT NOT NULL,
    `medicines`            TEXT NOT NULL,
    `dosage_instructions`  TEXT DEFAULT NULL,
    `notes`                TEXT DEFAULT NULL,
    `prescribed_date`      DATE NOT NULL,
    `follow_up_date`       DATE DEFAULT NULL,
    `created_at`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_rx_appointment` (`appointment_id`),
    INDEX `idx_rx_patient`     (`patient_id`),
    INDEX `idx_rx_doctor`      (`doctor_reg_no`),
    CONSTRAINT `fk_rx_appointment`
        FOREIGN KEY (`appointment_id`) REFERENCES `appointment` (`appointment_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rx_patient`
        FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rx_doctor`
        FOREIGN KEY (`doctor_reg_no`) REFERENCES `doctor` (`registration_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 7. MEDICINE (Pharmacy catalog & inventory)
-- ============================================================================
CREATE TABLE `medicine` (
    `medicine_id`           INT AUTO_INCREMENT PRIMARY KEY,
    `medicine_name`         VARCHAR(200) NOT NULL,
    `category`              VARCHAR(100) NOT NULL DEFAULT 'General',
    `manufacturer`          VARCHAR(200) DEFAULT NULL,
    `unit_price`            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `stock_quantity`        INT NOT NULL DEFAULT 0,
    `requires_prescription` TINYINT(1) NOT NULL DEFAULT 1,
    `description`           TEXT DEFAULT NULL,
    `is_active`             TINYINT(1) NOT NULL DEFAULT 1,
    `moderation_status`     VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        -- ACTIVE, BLOCKED
    `created_at`            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_med_category` (`category`),
    INDEX `idx_med_name`     (`medicine_name`),
    INDEX `idx_med_mod`      (`moderation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 8. PHARMACIST (Pharmacy operator portal account)
-- ============================================================================
CREATE TABLE `pharmacist` (
    `pharmacist_id`  INT AUTO_INCREMENT PRIMARY KEY,
    `username`       VARCHAR(100) NOT NULL UNIQUE,
    `full_name`      VARCHAR(150) NOT NULL,
    `email`          VARCHAR(150) NOT NULL UNIQUE,
    `password`       VARCHAR(255) NOT NULL,
    `phone`          VARCHAR(20) DEFAULT NULL,
    `pharmacy_name`  VARCHAR(150) NOT NULL DEFAULT 'Central Hospital Pharmacy',
    `created_at`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 9. PHARMACY ORDER (Orders placed by patients)
-- ============================================================================
CREATE TABLE `pharmacy_order` (
    `order_id`         INT AUTO_INCREMENT PRIMARY KEY,
    `user_id`          INT NOT NULL,
    `prescription_id`  INT DEFAULT NULL,
    `order_status`     VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        -- PENDING, PROCESSING, READY, DISPENSED, CANCELLED
    `total_amount`     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_method`   VARCHAR(50)  NOT NULL DEFAULT 'CASH',
    `payment_status`   VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
        -- PENDING, PAID, REFUNDED
    `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_pord_user`     (`user_id`),
    INDEX `idx_pord_rx`       (`prescription_id`),
    INDEX `idx_pord_status`   (`order_status`),
    CONSTRAINT `fk_pord_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_pord_rx`
        FOREIGN KEY (`prescription_id`) REFERENCES `prescription` (`prescription_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 10. PHARMACY ORDER ITEM (Line items within order)
-- ============================================================================
CREATE TABLE `pharmacy_order_item` (
    `item_id`      INT AUTO_INCREMENT PRIMARY KEY,
    `order_id`     INT NOT NULL,
    `medicine_id`  INT NOT NULL,
    `quantity`     INT NOT NULL DEFAULT 1,
    `unit_price`   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `subtotal`     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_poi_order`
        FOREIGN KEY (`order_id`) REFERENCES `pharmacy_order` (`order_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_poi_medicine`
        FOREIGN KEY (`medicine_id`) REFERENCES `medicine` (`medicine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 11. EMERGENCY OPERATOR (Emergency dispatch portal account)
-- ============================================================================
CREATE TABLE `emergency_operator` (
    `operator_id`      INT AUTO_INCREMENT PRIMARY KEY,
    `username`         VARCHAR(100) NOT NULL UNIQUE,
    `full_name`        VARCHAR(150) NOT NULL,
    `email`            VARCHAR(150) NOT NULL UNIQUE,
    `password`         VARCHAR(255) NOT NULL,
    `phone`            VARCHAR(20) DEFAULT NULL,
    `dispatch_center`  VARCHAR(150) NOT NULL DEFAULT 'City Emergency Control 108',
    `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 12. AMBULANCE (Fleet inventory for emergency services)
-- ============================================================================
CREATE TABLE `ambulance` (
    `ambulance_id`      INT AUTO_INCREMENT PRIMARY KEY,
    `vehicle_number`    VARCHAR(50) NOT NULL UNIQUE,
    `ambulance_type`    VARCHAR(50) NOT NULL DEFAULT 'BASIC',
        -- BASIC, ADVANCED, ICU
    `driver_name`       VARCHAR(150) DEFAULT NULL,
    `driver_phone`      VARCHAR(20) DEFAULT NULL,
    `base_hospital`     VARCHAR(150) DEFAULT 'Central Hospital',
    `current_status`    VARCHAR(20)  NOT NULL DEFAULT 'AVAILABLE',
        -- AVAILABLE, ON_DUTY, MAINTENANCE
    `moderation_status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        -- ACTIVE, BLOCKED
    `location`          VARCHAR(255) DEFAULT NULL,
    `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_amb_status` (`current_status`),
    INDEX `idx_amb_mod`    (`moderation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 13. EMERGENCY REQUEST (Patient requests emergency assistance)
-- ============================================================================
CREATE TABLE `emergency_request` (
    `request_id`       INT AUTO_INCREMENT PRIMARY KEY,
    `user_id`          INT NOT NULL,
    `patient_id`       INT DEFAULT NULL,
    `ambulance_id`     INT DEFAULT NULL,
    `emergency_type`   VARCHAR(100) NOT NULL DEFAULT 'GENERAL',
        -- GENERAL, CARDIAC, ACCIDENT, MATERNITY, FIRE, OTHER
    `description`      TEXT DEFAULT NULL,
    `pickup_address`   TEXT NOT NULL,
    `contact_phone`    VARCHAR(20) NOT NULL,
    `latitude`         DECIMAL(10,8) DEFAULT NULL,
    `longitude`        DECIMAL(11,8) DEFAULT NULL,
    `request_status`   VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        -- PENDING, DISPATCHED, EN_ROUTE, ARRIVED, COMPLETED, CANCELLED
    `priority`         VARCHAR(10)  NOT NULL DEFAULT 'MEDIUM',
        -- LOW, MEDIUM, HIGH, CRITICAL
    `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_er_user`     (`user_id`),
    INDEX `idx_er_status`   (`request_status`),
    INDEX `idx_er_priority` (`priority`),
    CONSTRAINT `fk_er_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_er_patient`
        FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_er_ambulance`
        FOREIGN KEY (`ambulance_id`) REFERENCES `ambulance` (`ambulance_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 14. ADMIN (Administrative accounts — RBAC)
-- ============================================================================
CREATE TABLE `admin` (
    `admin_id`        INT AUTO_INCREMENT PRIMARY KEY,
    `full_name`       VARCHAR(150) NOT NULL,
    `email`           VARCHAR(150) NOT NULL UNIQUE,
    `phone`           VARCHAR(20) DEFAULT NULL,
    `password_hash`   VARCHAR(255) NOT NULL,
    `role`            VARCHAR(30)  NOT NULL DEFAULT 'ADMIN',
        -- SUPER_ADMIN, ADMIN, MODERATOR
    `account_status`  VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
        -- ACTIVE, INACTIVE, SUSPENDED
    `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_login`      TIMESTAMP NULL DEFAULT NULL,
    `last_activity`   TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 15. ACTIVITY LOG (Centralized audit trail)
-- ============================================================================
CREATE TABLE `activity_log` (
    `activity_id`        BIGINT AUTO_INCREMENT PRIMARY KEY,
    `actor_id`           VARCHAR(100) NOT NULL,
    `actor_name`         VARCHAR(150) DEFAULT NULL,
    `actor_type`         VARCHAR(20)  NOT NULL,
        -- PATIENT, DOCTOR, ADMIN, PHARMACIST, EMERGENCY_OP, SYSTEM
    `activity_type`      VARCHAR(50)  NOT NULL,
    `action_description` TEXT NOT NULL,
    `target_entity_type` VARCHAR(50) DEFAULT NULL,
    `target_entity_id`   VARCHAR(100) DEFAULT NULL,
    `result`             VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
        -- SUCCESS, FAILURE
    `ip_address`         VARCHAR(50) DEFAULT NULL,
    `created_at`         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_log_actor`   (`actor_type`, `actor_id`),
    INDEX `idx_log_type`    (`activity_type`),
    INDEX `idx_log_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 16. FINANCIAL TRANSACTION (Payment records & automated commission splits)
-- ============================================================================
CREATE TABLE `financial_transaction` (
    `transaction_id`     VARCHAR(100) PRIMARY KEY,
    `service_type`       VARCHAR(20) NOT NULL, -- 'APPOINTMENT' or 'PHARMACY'
    `reference_id`       INT NOT NULL, -- appointment_id or order_id
    `patient_user_id`    INT NOT NULL,
    `provider_id`        VARCHAR(100) DEFAULT NULL, -- doctor_reg_no or 'PHARMACY'
    `gross_amount`       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `commission_rate`    DECIMAL(5,2) NOT NULL DEFAULT 15.00,
    `admin_commission`   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `provider_payout`    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_method`     VARCHAR(50) NOT NULL DEFAULT 'UPI', -- UPI, CARD, NET_BANKING
    `transaction_status` VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    `transaction_date`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ft_service`  (`service_type`, `reference_id`),
    INDEX `idx_ft_user`     (`patient_user_id`),
    INDEX `idx_ft_provider` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 17. FEEDBACK & REPORT (Trust, safety, ratings, and moderation)
-- ============================================================================
CREATE TABLE `feedback_report` (
    `report_id`       INT AUTO_INCREMENT PRIMARY KEY,
    `reporter_role`   VARCHAR(20) NOT NULL, -- 'PATIENT', 'DOCTOR'
    `reporter_id`     VARCHAR(100) NOT NULL, -- user_id or doctor_reg_no
    `target_type`     VARCHAR(20) NOT NULL, -- 'DOCTOR', 'PATIENT', 'PHARMACY', 'AMBULANCE'
    `target_id`       VARCHAR(100) NOT NULL,
    `reference_id`    INT DEFAULT NULL,
    `report_category` VARCHAR(20) NOT NULL, -- 'FEEDBACK', 'COMPLAINT'
    `rating`          INT DEFAULT NULL, -- 1 to 5
    `comments`        TEXT NOT NULL,
    `status`          VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'REVIEWED', 'ACTION_TAKEN'
    `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_fb_target` (`target_type`, `target_id`),
    INDEX `idx_fb_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- ---- Seed Medicines ----
INSERT INTO `medicine` (`medicine_name`, `category`, `manufacturer`, `unit_price`, `stock_quantity`, `requires_prescription`, `description`, `moderation_status`) VALUES
('Paracetamol 500mg',        'Analgesic',       'Cipla',              5.00,  500, 0, 'Fever and pain relief tablet', 'ACTIVE'),
('Amoxicillin 500mg',        'Antibiotic',      'Sun Pharma',        12.50,  300, 1, 'Broad-spectrum antibiotic capsule', 'ACTIVE'),
('Cetirizine 10mg',          'Antihistamine',   'Dr. Reddys',         8.00,  400, 0, 'Allergy relief tablet', 'ACTIVE'),
('Omeprazole 20mg',          'Antacid',         'Cipla',             15.00,  350, 1, 'Acid reflux and ulcer treatment', 'ACTIVE'),
('Metformin 500mg',          'Antidiabetic',    'USV Limited',       10.00,  250, 1, 'Blood sugar management tablet', 'ACTIVE'),
('Amlodipine 5mg',           'Antihypertensive','Torrent Pharma',    12.00,  200, 1, 'Blood pressure management tablet', 'ACTIVE'),
('Azithromycin 500mg',       'Antibiotic',      'Alkem Labs',        45.00,  150, 1, 'Macrolide antibiotic for bacterial infections', 'ACTIVE'),
('Ibuprofen 400mg',          'Analgesic',       'Abbott',             7.00,  400, 0, 'Anti-inflammatory pain relief', 'ACTIVE'),
('Pantoprazole 40mg',        'Antacid',         'Sun Pharma',        18.00,  300, 1, 'Proton pump inhibitor for GERD', 'ACTIVE'),
('Vitamin D3 60000IU',       'Supplement',      'Mankind Pharma',    35.00,  200, 0, 'Weekly vitamin D supplement', 'ACTIVE'),
('ORS Powder',               'Rehydration',     'FDC Limited',        8.00,  500, 0, 'Oral rehydration salts', 'ACTIVE'),
('Dolo 650',                 'Analgesic',       'Micro Labs',         5.50,  600, 0, 'Paracetamol 650mg for pain and fever', 'ACTIVE');

-- ---- Seed Ambulances ----
INSERT INTO `ambulance` (`vehicle_number`, `ambulance_type`, `driver_name`, `driver_phone`, `base_hospital`, `current_status`, `moderation_status`, `location`) VALUES
('KA-01-AB-1234', 'BASIC',    'Raju Kumar',    '+91-9876543210', 'Central Hospital',   'AVAILABLE',   'ACTIVE', 'Central Hospital, Bangalore'),
('KA-01-CD-5678', 'ADVANCED', 'Suresh Nair',   '+91-9876543211', 'City Medical Center', 'AVAILABLE',   'ACTIVE', 'City Medical Center, Bangalore'),
('KA-02-EF-9012', 'ICU',      'Mahesh Singh',  '+91-9876543212', 'District Hospital',  'AVAILABLE',   'ACTIVE', 'District Hospital, Mysore'),
('KA-03-GH-3456', 'BASIC',    'Arun Patel',    '+91-9876543213', 'Garage Bay',         'MAINTENANCE', 'ACTIVE', 'Garage Bay, Hubli'),
('KA-01-IJ-7890', 'ADVANCED', 'Deepak Sharma', '+91-9876543214', 'Manipal Hospital',   'AVAILABLE',   'ACTIVE', 'Emergency Block, Manipal Hospital');

-- ---- Seed Super Admin Account (Email: admin@medic.local, Password: manager) ----
INSERT INTO `admin` (`full_name`, `email`, `password_hash`, `role`, `account_status`)
VALUES ('Super Administrator', 'admin@medic.local', '100000:cb2de675031b926b5332679bc4365093:f2a91629dac1443ae42b1bd3c059ad638bb8c480ac19ba90fb4c8b5e113a0474', 'SUPER_ADMIN', 'ACTIVE')
ON DUPLICATE KEY UPDATE `password_hash` = VALUES(`password_hash`), `role` = VALUES(`role`), `account_status` = VALUES(`account_status`);

-- ---- Seed Pharmacist Account (Password: manager) ----
INSERT INTO `pharmacist` (`username`, `full_name`, `email`, `password`, `phone`, `pharmacy_name`)
VALUES ('pharmacist', 'Chief Pharmacist', 'pharmacist@medic.local', SHA2('manager', 256), '+91-9876543220', 'Central Hospital Pharmacy')
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`);

-- ---- Seed Emergency Operator Account (Password: manager) ----
INSERT INTO `emergency_operator` (`username`, `full_name`, `email`, `password`, `phone`, `dispatch_center`)
VALUES ('operator', 'Emergency Dispatch Lead', 'emergency@medic.local', SHA2('manager', 256), '+91-9876543221', 'City Emergency Control 108')
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`);
