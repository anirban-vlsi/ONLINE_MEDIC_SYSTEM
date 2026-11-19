-- ============================================================================
-- ONLINE_MEDIC_SYSTEM - Admin Module Database Migration Script
-- Creates:
-- 1. admin: Administrative accounts supporting Super Admin, Admin, and Moderator roles
-- 2. activity_log: Centralized audit log tracking Patient, Doctor, and Admin operations
-- 3. financial_transaction: Secure financial transaction records
-- ============================================================================

USE medic;

-- 1. Administrative Accounts Table
CREATE TABLE IF NOT EXISTS `admin` (
    `admin_id` INT AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `phone` VARCHAR(20) DEFAULT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` VARCHAR(30) NOT NULL DEFAULT 'ADMIN', -- 'SUPER_ADMIN', 'ADMIN', 'MODERATOR'
    `account_status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE', 'SUSPENDED'
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP NULL DEFAULT NULL,
    `last_activity` TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Centralized Activity & Audit Logs Table
CREATE TABLE IF NOT EXISTS `activity_log` (
    `activity_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `actor_id` VARCHAR(100) NOT NULL,
    `actor_name` VARCHAR(150) DEFAULT NULL,
    `actor_type` VARCHAR(20) NOT NULL, -- 'PATIENT', 'DOCTOR', 'ADMIN', 'SYSTEM'
    `activity_type` VARCHAR(50) NOT NULL, -- 'LOGIN', 'LOGOUT', 'REGISTRATION', 'DOCTOR_APPROVAL', 'USER_BLOCKED', etc.
    `action_description` TEXT NOT NULL,
    `target_entity_type` VARCHAR(50) DEFAULT NULL, -- 'USER', 'DOCTOR', 'ADMIN', 'TRANSACTION'
    `target_entity_id` VARCHAR(100) DEFAULT NULL,
    `result` VARCHAR(20) NOT NULL DEFAULT 'SUCCESS', -- 'SUCCESS', 'FAILURE'
    `ip_address` VARCHAR(50) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_actor` (`actor_type`, `actor_id`),
    INDEX `idx_activity_type` (`activity_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Financial Transaction Table
CREATE TABLE IF NOT EXISTS `financial_transaction` (
    `transaction_id` VARCHAR(100) PRIMARY KEY,
    `patient_user_id` INT NOT NULL,
    `doctor_reg_no` VARCHAR(100) DEFAULT NULL,
    `amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_method` VARCHAR(50) NOT NULL DEFAULT 'CASH', -- 'ONLINE', 'CARD', 'UPI', 'CASH'
    `transaction_status` VARCHAR(20) NOT NULL DEFAULT 'SUCCESS', -- 'SUCCESS', 'PENDING', 'FAILED', 'REFUNDED'
    `payment_reference` VARCHAR(100) DEFAULT NULL,
    `transaction_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_txn_patient` (`patient_user_id`),
    INDEX `idx_txn_doctor` (`doctor_reg_no`),
    CONSTRAINT `fk_txn_patient` FOREIGN KEY (`patient_user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Seed Super Administrator Account (Password: SuperAdmin@Medic2026 hashed with SHA-256)
-- Hash of 'SuperAdmin@Medic2026' = 4252ef0e3da101dcf2941fa44fef88e7b99c759fec39e7ae71e469509df6389f
INSERT INTO `admin` (`full_name`, `email`, `phone`, `password_hash`, `role`, `account_status`)
SELECT 'Primary System Administrator', 'superadmin@medic.local', '+91-9800210307',
       SHA2('SuperAdmin@Medic2026', 256), 'SUPER_ADMIN', 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM `admin` WHERE `email` = 'superadmin@medic.local');

-- Verify schemas
DESCRIBE `admin`;
DESCRIBE `activity_log`;
DESCRIBE `financial_transaction`;
