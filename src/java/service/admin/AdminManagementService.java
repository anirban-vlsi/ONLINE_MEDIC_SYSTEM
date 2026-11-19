package service.admin;

import dao.admin.AdminDAO;
import dao.common.DBConnection;
import dao.doctor.DoctorDAO;
import dao.patient.PatientDAO;
import dao.patient.UserDAO;
import model.admin.Admin;
import model.admin.AdminRole;
import model.doctor.Doctor;
import model.patient.Patient;
import model.patient.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminManagementService {

    private final AdminDAO adminDAO = new AdminDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final PatientDAO patientDAO = new PatientDAO();

    // -------------------------------------------------------------
    // PATIENT MANAGEMENT
    // -------------------------------------------------------------

    // Get all registered users (patients) with optional search and status filtering
    public List<User> getPatients(String search, String statusFilter) {
        return userDAO.getPatients(search, statusFilter);
    }

    // Get user detail including linked patient profiles
    public User getPatientDetails(int userId) {
        return userDAO.getUserById(userId);
    }

    public List<Patient> getLinkedPatientDependents(int userId) {
        return patientDAO.getPatientsByUserId(userId);
    }

    // Block or Unblock a patient user account
    public boolean setPatientBlockStatus(int userId, boolean block, Admin actingAdmin, String reason, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_BLOCK_PATIENTS)) {
            return false;
        }

        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        String oldStatus = user.getStatus();
        String newStatus;
        if (block) {
            newStatus = "BLOCKED";
        } else {
            // When unblocking: if user has completed profile & photo, restore VERIFIED, otherwise NOT VERIFIED
            boolean hasPic = userDAO.isProfilePictureUploaded(userId);
            boolean hasFields = user.getName() != null && !user.getName().trim().isEmpty()
                             && user.getEmail() != null && !user.getEmail().trim().isEmpty()
                             && user.getGender() != null && !user.getGender().trim().isEmpty()
                             && user.getMobileNo() != null && !user.getMobileNo().trim().isEmpty();
            newStatus = (hasPic && hasFields) ? "VERIFIED" : "NOT VERIFIED";
        }

        boolean ok = userDAO.updateUserStatus(userId, newStatus);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                block ? "PATIENT_BLOCKED" : "PATIENT_UNBLOCKED",
                "Patient #" + userId + " (" + user.getName() + ") status changed from " + oldStatus + " to " + newStatus + ". Reason: " + (reason != null ? reason : "Administrative moderation"),
                "USER", String.valueOf(userId), "SUCCESS", ip
            );
            return true;
        }
        return false;
    }

    // Permanently remove a patient record (Super Admin only with safeguards)
    public boolean removePatient(int userId, Admin actingAdmin, String reason, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_REMOVE_PATIENTS)) {
            return false;
        }

        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        boolean ok = userDAO.deleteUser(userId);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                "PATIENT_DELETED",
                "Patient account #" + userId + " (" + user.getName() + " - " + user.getEmail() + ") was permanently deleted. Reason: " + (reason != null ? reason : "Super Admin removal action"),
                "USER", String.valueOf(userId), "SUCCESS", ip
            );
            return true;
        }
        return false;
    }

    // -------------------------------------------------------------
    // DOCTOR MANAGEMENT
    // -------------------------------------------------------------

    // Get all doctors with optional search and status filtering
    public List<Doctor> getDoctors(String search, String statusFilter) {
        return doctorDAO.getDoctors(search, statusFilter);
    }

    // Authorize or reject a pending doctor
    public boolean authorizeDoctor(String regNo, boolean approve, Admin actingAdmin, String reason, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_AUTHORIZE_DOCTORS)) {
            return false;
        }

        Doctor doc = doctorDAO.getDoctorByRegistrationNumber(regNo);
        if (doc == null) {
            return false;
        }

        String newStatus = approve ? "VERIFIED" : "REJECTED";
        boolean ok = doctorDAO.updateVerificationStatus(regNo, newStatus);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                approve ? "DOCTOR_APPROVED" : "DOCTOR_REJECTED",
                "Doctor " + doc.getDoctorName() + " (Lic: " + regNo + ") was " + (approve ? "APPROVED" : "REJECTED") + ". Reason: " + (reason != null ? reason : "Credential review"),
                "DOCTOR", regNo, "SUCCESS", ip
            );
            return true;
        }
        return false;
    }

    // Block or Unblock a doctor
    public boolean setDoctorBlockStatus(String regNo, boolean block, Admin actingAdmin, String reason, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_BLOCK_DOCTORS)) {
            return false;
        }

        Doctor doc = doctorDAO.getDoctorByRegistrationNumber(regNo);
        if (doc == null) {
            return false;
        }

        String newStatus = block ? "BLOCKED" : "VERIFIED";
        boolean ok = doctorDAO.updateVerificationStatus(regNo, newStatus);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                block ? "DOCTOR_BLOCKED" : "DOCTOR_UNBLOCKED",
                "Doctor " + doc.getDoctorName() + " (Lic: " + regNo + ") status updated to " + newStatus + ". Reason: " + (reason != null ? reason : "Administrative moderation"),
                "DOCTOR", regNo, "SUCCESS", ip
            );
            return true;
        }
        return false;
    }

    // -------------------------------------------------------------
    // ADMINISTRATOR MANAGEMENT (Super Admin Only)
    // -------------------------------------------------------------

    public List<Admin> getAllAdmins(Admin actingAdmin) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_MANAGE_ADMINS)) {
            return new ArrayList<>();
        }
        return adminDAO.getAllAdmins();
    }

    public boolean createAdministrator(Admin newAdmin, String rawPassword, Admin actingAdmin, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_MANAGE_ADMINS)) {
            return false;
        }

        if (newAdmin == null || rawPassword == null || rawPassword.trim().isEmpty()) {
            return false;
        }

        if (adminDAO.isEmailExists(newAdmin.getEmail().trim())) {
            return false;
        }

        newAdmin.setPasswordHash(AdminService.hashPassword(rawPassword));
        if (newAdmin.getRole() == null || !AdminRole.isValidRole(newAdmin.getRole())) {
            newAdmin.setRole(AdminRole.ADMIN);
        }

        boolean ok = adminDAO.createAdmin(newAdmin);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                "ADMIN_CREATED",
                "New administrator account created: " + newAdmin.getFullName() + " (" + newAdmin.getEmail() + ") with role " + newAdmin.getRole(),
                "ADMIN", String.valueOf(newAdmin.getAdminId()), "SUCCESS", ip
            );
            return true;
        }
        return false;
    }

    public boolean updateAdminRoleAndStatus(int targetAdminId, String newRole, String newStatus, Admin actingAdmin, String ip) {
        if (!AdminService.hasPermission(actingAdmin, AdminService.PERM_MANAGE_ADMINS)) {
            return false;
        }

        // Prevent modifying oneself to avoid lockout
        if (actingAdmin.getAdminId() == targetAdminId && !"ACTIVE".equalsIgnoreCase(newStatus)) {
            return false;
        }

        Admin target = adminDAO.getAdminById(targetAdminId);
        if (target == null) {
            return false;
        }

        boolean ok = adminDAO.updateAdminRoleAndStatus(targetAdminId, newRole, newStatus);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(actingAdmin.getAdminId()), actingAdmin.getFullName(), "ADMIN",
                "ADMIN_MODIFIED",
                "Admin #" + targetAdminId + " (" + target.getFullName() + ") updated: Role=" + newRole + ", Status=" + newStatus,
                "ADMIN", String.valueOf(targetAdminId), "SUCCESS", ip
            );
            return true;
        }
        return false;
    }
}
