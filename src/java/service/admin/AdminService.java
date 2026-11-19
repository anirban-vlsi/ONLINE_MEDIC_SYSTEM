package service.admin;

import dao.admin.AdminDAO;
import model.admin.Admin;
import model.admin.AdminRole;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.security.MessageDigest;

public class AdminService {

    public static final String PERM_VIEW_PATIENTS = "VIEW_PATIENTS";
    public static final String PERM_BLOCK_PATIENTS = "BLOCK_PATIENTS";
    public static final String PERM_REMOVE_PATIENTS = "REMOVE_PATIENTS";
    public static final String PERM_VIEW_DOCTORS = "VIEW_DOCTORS";
    public static final String PERM_AUTHORIZE_DOCTORS = "AUTHORIZE_DOCTORS";
    public static final String PERM_BLOCK_DOCTORS = "BLOCK_DOCTORS";
    public static final String PERM_VIEW_TRANSACTIONS = "VIEW_TRANSACTIONS";
    public static final String PERM_VIEW_ACTIVITY_LOGS = "VIEW_ACTIVITY_LOGS";
    public static final String PERM_MANAGE_ADMINS = "MANAGE_ADMINS";

    private final AdminDAO adminDAO;

    public AdminService() {
        this.adminDAO = new AdminDAO();
    }

    public AdminService(AdminDAO adminDAO) {
        this.adminDAO = adminDAO;
    }

    // Secure password hashing using PBKDF2WithHmacSHA256
    // Stored format: iterations:saltHex:hashHex
    private static final int ITERATIONS = 100_000;
    private static final int SALT_LENGTH = 16; // bytes
    private static final int KEY_LENGTH = 256; // bits

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                                 + Character.digit(hex.charAt(i+1), 16));
        }
        return data;
    }

    public static String hashPassword(String password) {
        if (password == null) {
            return null;
        }
        try {
            java.security.SecureRandom sr = new java.security.SecureRandom();
            byte[] salt = new byte[SALT_LENGTH];
            sr.nextBytes(salt);
            javax.crypto.SecretKeyFactory skf = javax.crypto.SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            javax.crypto.spec.PBEKeySpec spec = new javax.crypto.spec.PBEKeySpec(
                    password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
            byte[] hash = skf.generateSecret(spec).getEncoded();
            return ITERATIONS + ":" + bytesToHex(salt) + ":" + bytesToHex(hash);
        } catch (Exception e) {
            return null;
        }
    }

    // Verify a raw password against stored PBKDF2 hash
    public static boolean verifyPassword(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null) {
            return false;
        }
        try {
            String[] parts = storedHash.split(":");
            if (parts.length != 3) {
                return false;
            }
            int iterations = Integer.parseInt(parts[0]);
            byte[] salt = hexToBytes(parts[1]);
            byte[] hash = hexToBytes(parts[2]);
            javax.crypto.SecretKeyFactory skf = javax.crypto.SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            javax.crypto.spec.PBEKeySpec spec = new javax.crypto.spec.PBEKeySpec(
                    rawPassword.toCharArray(), salt, iterations, hash.length * 8);
            byte[] testHash = skf.generateSecret(spec).getEncoded();
            return java.util.Arrays.equals(hash, testHash);
        } catch (Exception e) {
            return false;
        }
    }

    // Authenticate administrator credentials
    public Admin authenticateAdmin(String email, String rawPassword) {
        if (email == null || email.trim().isEmpty() || rawPassword == null || rawPassword.trim().isEmpty()) {
            return null;
        }

        Admin admin = adminDAO.getAdminByEmail(email.trim());
        if (admin != null) {
            String storedHash = admin.getPasswordHash();
            if (storedHash != null && verifyPassword(rawPassword, storedHash)) {
                // Update last login
                adminDAO.updateLastLogin(admin.getAdminId());
                return admin;
            }
        }
        return null;
    }

    // Retrieve authenticated admin from active session with authoritative database check
    public static Admin getAuthenticatedAdmin(HttpServletRequest request) {
        if (request == null) {
            return null;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object adminIdObj = session.getAttribute("adminId");
        if (adminIdObj == null) {
            return null;
        }

        int adminId;
        try {
            adminId = (Integer) adminIdObj;
        } catch (Exception e) {
            return null;
        }

        AdminDAO dao = new AdminDAO();
        Admin admin = dao.getAdminById(adminId);

        if (admin != null && admin.isActive()) {
            dao.updateLastActivity(adminId);
            return admin;
        }

        return null;
    }

    // Enforce Role-Based Access Control (RBAC)
    public static boolean hasPermission(Admin admin, String permission) {
        if (admin == null || !admin.isActive() || permission == null) {
            return false;
        }

        String role = admin.getRole();
        if (AdminRole.SUPER_ADMIN.equalsIgnoreCase(role)) {
            // Super Admin has full administrative privileges
            return true;
        }

        if (AdminRole.ADMIN.equalsIgnoreCase(role)) {
            // Admin can perform moderation, verification, view logs & transactions, but NOT manage admins or delete patients
            return PERM_VIEW_PATIENTS.equals(permission)
                || PERM_BLOCK_PATIENTS.equals(permission)
                || PERM_VIEW_DOCTORS.equals(permission)
                || PERM_AUTHORIZE_DOCTORS.equals(permission)
                || PERM_BLOCK_DOCTORS.equals(permission)
                || PERM_VIEW_TRANSACTIONS.equals(permission)
                || PERM_VIEW_ACTIVITY_LOGS.equals(permission);
        }

        if (AdminRole.MODERATOR.equalsIgnoreCase(role)) {
            // Moderator has view-only monitoring access
            return PERM_VIEW_PATIENTS.equals(permission)
                || PERM_VIEW_DOCTORS.equals(permission)
                || PERM_VIEW_ACTIVITY_LOGS.equals(permission);
        }

        return false;
    }

    public AdminDAO getAdminDAO() {
        return adminDAO;
    }
}
