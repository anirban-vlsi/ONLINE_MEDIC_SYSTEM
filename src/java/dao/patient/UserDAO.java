package dao.patient;

import dao.common.DBConnection;
import model.patient.User;

import java.io.ByteArrayInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class UserDAO {

    // Register a new user with status NOT VERIFIED and profile_picture NULL
    public boolean registerUser(User user) {

        String sql = "INSERT INTO user "
                   + "(name, email, gender, mobile_no, password, profile_picture, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getGender());
            ps.setString(4, user.getMobileNo());
            ps.setString(5, user.getPassword());
            ps.setBytes(6, null); // Always start as null
            ps.setString(7, "NOT VERIFIED"); // Always start as NOT VERIFIED

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setUserId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }

            return false;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Find user by email
    public User getUserByEmail(String email) {

        String sql = "SELECT user_id, name, email, gender, mobile_no, password, profile_picture, status FROM user WHERE email = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setGender(rs.getString("gender"));
                    user.setMobileNo(rs.getString("mobile_no"));
                    user.setPassword(rs.getString("password"));
                    user.setProfilePicture(rs.getBytes("profile_picture"));
                    user.setStatus(rs.getString("status"));
                    return user;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Find user by user ID
    public User getUserById(int userId) {

        String sql = "SELECT user_id, name, email, gender, mobile_no, password, profile_picture, status FROM user WHERE user_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setGender(rs.getString("gender"));
                    user.setMobileNo(rs.getString("mobile_no"));
                    user.setPassword(rs.getString("password"));
                    user.setProfilePicture(rs.getBytes("profile_picture"));
                    user.setStatus(rs.getString("status"));
                    return user;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Update patient profile details and optionally re-upload profile picture
    // Trigger trg_user_auto_verify will fire on UPDATE and auto-verify if conditions are met
    public boolean updateProfile(int userId, String name, String gender, String mobileNo, byte[] pictureBytes) {
        String sql;
        boolean hasPicture = (pictureBytes != null && pictureBytes.length > 0);
        if (hasPicture) {
            sql = "UPDATE user SET name = ?, gender = ?, mobile_no = ?, profile_picture = ? WHERE user_id = ?";
        } else {
            sql = "UPDATE user SET name = ?, gender = ?, mobile_no = ? WHERE user_id = ?";
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, name);
            ps.setString(2, gender);
            ps.setString(3, mobileNo);
            if (hasPicture) {
                ps.setBytes(4, pictureBytes);
                ps.setInt(5, userId);
            } else {
                ps.setInt(4, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Direct authoritative check of user verification status from MySQL
    public String getUserStatusById(int userId) {

        String sql = "SELECT status FROM user WHERE user_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Check if user already has a profile picture uploaded (One-time check)
    public boolean isProfilePictureUploaded(int userId) {

        String sql = "SELECT profile_picture FROM user WHERE user_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    byte[] bytes = rs.getBytes("profile_picture");
                    return bytes != null && bytes.length > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Get raw profile picture image bytes
    public byte[] getProfilePictureByUserId(int userId) {

        String sql = "SELECT profile_picture FROM user WHERE user_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBytes("profile_picture");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get all patients with search and status filtering (Admin DAO delegation)
    public java.util.List<User> getPatients(String search, String statusFilter) {
        java.util.List<User> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT user_id, name, email, gender, mobile_no, status FROM user WHERE 1=1 ");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR email LIKE ? OR mobile_no LIKE ? OR user_id = ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            int id = -1;
            try { id = Integer.parseInt(search.trim()); } catch (Exception ignored) {}
            params.add(id);
        }

        sql.append("ORDER BY user_id DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setName(rs.getString("name"));
                    u.setEmail(rs.getString("email"));
                    u.setGender(rs.getString("gender"));
                    u.setMobileNo(rs.getString("mobile_no"));
                    u.setStatus(rs.getString("status"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Update user status
    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE user SET status = ? WHERE user_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete user account
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM user WHERE user_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Atomically uploads the profile picture and marks the user as VERIFIED.
     */
    public boolean updateProfilePictureAndVerify(int userId, byte[] pictureBytes) {
        if (pictureBytes == null || pictureBytes.length == 0 || userId <= 0) {
            return false;
        }

        String checkSql = "SELECT profile_picture, status FROM user WHERE user_id = ? FOR UPDATE";
        String updateSql = "UPDATE user SET profile_picture = ?, status = 'VERIFIED' WHERE user_id = ?";

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            if (con == null) {
                return false;
            }

            con.setAutoCommit(false);

            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setInt(1, userId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                updatePs.setBinaryStream(1, new ByteArrayInputStream(pictureBytes), pictureBytes.length);
                updatePs.setInt(2, userId);

                int rows = updatePs.executeUpdate();
                if (rows > 0) {
                    con.commit();
                    return true;
                } else {
                    con.rollback();
                    return false;
                }
            }

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (Exception ignored) {}
            }
        }
    }
}
