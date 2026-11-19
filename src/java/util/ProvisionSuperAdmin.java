package util;

import dao.common.DBConnection;
import service.admin.AdminService;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Utility to provision or update the initial Super Admin account.
 * Seeds admin@medic.local / manager with PBKDF2 hash and cleans up obsolete test records.
 */
public class ProvisionSuperAdmin {
    public static void main(String[] args) {
        String email = "admin@medic.local";
        String rawPassword = "manager";
        String fullName = "Super Administrator";
        String role = "SUPER_ADMIN";
        String status = "ACTIVE";

        // Hash password with PBKDF2 (AdminService.hashPassword)
        String hashed = AdminService.hashPassword(rawPassword);

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                System.err.println("Database connection failed. Please ensure MySQL is running.");
                return;
            }

            // Check if admin@medic.local exists
            String checkSql = "SELECT admin_id FROM admin WHERE email = ?";
            Integer existingId = null;
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("admin_id");
                    }
                }
            }

            if (existingId != null) {
                String updateSql = "UPDATE admin SET full_name = ?, password_hash = ?, role = ?, account_status = ? WHERE admin_id = ?";
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setString(1, fullName);
                    ps.setString(2, hashed);
                    ps.setString(3, role);
                    ps.setString(4, status);
                    ps.setInt(5, existingId);
                    ps.executeUpdate();
                    System.out.println("Super Admin (" + email + ") updated successfully with ID: " + existingId);
                }
            } else {
                String insertSql = "INSERT INTO admin (full_name, email, password_hash, role, account_status) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setString(1, fullName);
                    ps.setString(2, email);
                    ps.setString(3, hashed);
                    ps.setString(4, role);
                    ps.setString(5, status);
                    ps.executeUpdate();
                    System.out.println("Super Admin (" + email + ") created successfully.");
                }
            }

            // Delete obsolete test accounts if any
            String deleteOldSql = "DELETE FROM admin WHERE email != ?";
            try (PreparedStatement ps = con.prepareStatement(deleteOldSql)) {
                ps.setString(1, email);
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    System.out.println("Cleaned up " + deleted + " old/test admin account(s).");
                }
            }

            System.out.println("Super Admin provisioning complete: " + email + " / " + rawPassword);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
