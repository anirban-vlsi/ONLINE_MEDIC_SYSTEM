-- ============================================================================
-- ONLINE_MEDIC_SYSTEM - Doctor Table Migration Script
-- Purpose:
-- Create the 'doctor' table for the Doctor Registration & Authentication Module.
--
-- Constraints & Rules:
-- 1. registration_number is VARCHAR(100), PRIMARY KEY, non-auto-incrementing (provided by doctor).
-- 2. email is VARCHAR(150), UNIQUE, NOT NULL.
-- 3. verification_status defaults to 'PENDING'.
-- 4. created_at defaults to CURRENT_TIMESTAMP.
-- 5. Existing 'user' and 'patient' tables are preserved completely untouched.
-- ============================================================================

USE medic;

CREATE TABLE IF NOT EXISTS `doctor` (
    `registration_number` VARCHAR(100) NOT NULL,
    `doctor_name` VARCHAR(150) NOT NULL,
    `age` INT NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `address` TEXT NOT NULL,
    `specialization` VARCHAR(150) NOT NULL,
    `verification_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`registration_number`),
    UNIQUE KEY `uk_doctor_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Verify table creation
DESCRIBE `doctor`;
