package dao.admin;

import dao.common.DBConnection;
import model.admin.Admin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    // Retrieve administrator by Email
    public Admin getAdminByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT admin_id, full_name, email, phone, password_hash, role, "
                   + "account_status, created_at, last_login, last_activity "
                   + "FROM admin WHERE email = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdmin(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Retrieve administrator by ID
    public Admin getAdminById(int adminId) {
        if (adminId <= 0) {
            return null;
        }

        String sql = "SELECT admin_id, full_name, email, phone, password_hash, role, "
                   + "account_status, created_at, last_login, last_activity "
                   + "FROM admin WHERE admin_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, adminId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAdmin(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Retrieve all administrators
    public List<Admin> getAllAdmins() {
        List<Admin> list = new ArrayList<>();
        String sql = "SELECT admin_id, full_name, email, phone, password_hash, role, "
                   + "account_status, created_at, last_login, last_activity "
                   + "FROM admin ORDER BY admin_id ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapAdmin(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Create a new administrator account (Super Admin only)
    public boolean createAdmin(Admin admin) {
        if (admin == null) {
            return false;
        }

        String sql = "INSERT INTO admin "
                   + "(full_name, email, phone, password_hash, role, account_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, admin.getFullName());
            ps.setString(2, admin.getEmail());
            ps.setString(3, admin.getPhone());
            ps.setString(4, admin.getPasswordHash());
            ps.setString(5, admin.getRole() != null ? admin.getRole() : "ADMIN");
            ps.setString(6, admin.getAccountStatus() != null ? admin.getAccountStatus() : "ACTIVE");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        admin.setAdminId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update administrator role and account status
    public boolean updateAdminRoleAndStatus(int adminId, String role, String status) {
        if (adminId <= 0) {
            return false;
        }

        String sql = "UPDATE admin SET role = ?, account_status = ? WHERE admin_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, role);
            ps.setString(2, status);
            ps.setInt(3, adminId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update last login timestamp upon successful login
    public void updateLastLogin(int adminId) {
        String sql = "UPDATE admin SET last_login = CURRENT_TIMESTAMP, last_activity = CURRENT_TIMESTAMP WHERE admin_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, adminId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Update last activity timestamp on sensitive action
    public void updateLastActivity(int adminId) {
        String sql = "UPDATE admin SET last_activity = CURRENT_TIMESTAMP WHERE admin_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, adminId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Check if an email exists
    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM admin WHERE email = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Admin mapAdmin(ResultSet rs) throws Exception {
        Admin admin = new Admin();
        admin.setAdminId(rs.getInt("admin_id"));
        admin.setFullName(rs.getString("full_name"));
        admin.setEmail(rs.getString("email"));
        admin.setPhone(rs.getString("phone"));
        admin.setPasswordHash(rs.getString("password_hash"));
        admin.setRole(rs.getString("role"));
        admin.setAccountStatus(rs.getString("account_status"));
        admin.setCreatedAt(rs.getTimestamp("created_at"));
        admin.setLastLogin(rs.getTimestamp("last_login"));
        admin.setLastActivity(rs.getTimestamp("last_activity"));
        return admin;
    }
}
