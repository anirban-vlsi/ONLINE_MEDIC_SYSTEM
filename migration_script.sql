-- ============================================================================
-- ONLINE_MEDIC_SYSTEM - Database Migration Script
-- Purpose:
-- 1. Ensure user table retains profile_picture (LONGBLOB) and status (VARCHAR(20)).
-- 2. Remove patient_picture and status columns from patient table (verification
--    and profile picture belong strictly to the user account level).
-- ============================================================================

USE medic;

-- Step 1: Ensure user table has the required fields
-- user_id, name, email, gender, mobile_no, password, profile_picture, status
-- (These already exist in the database)

-- Step 2: Remove patient_picture and status from the patient table
-- (Safe migration executed: foreign key and primary key are preserved)
ALTER TABLE patient
  DROP COLUMN IF EXISTS patient_picture,
  DROP COLUMN IF EXISTS status;

-- Step 3: Verify the remaining structure of the patient table
DESCRIBE patient;

-- Step 4: Verify the structure of the user table
DESCRIBE user;
