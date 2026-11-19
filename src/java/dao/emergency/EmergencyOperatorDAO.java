package dao.emergency;

import dao.common.DBConnection;
import model.emergency.EmergencyOperator;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EmergencyOperatorDAO {

    public EmergencyOperator authenticate(String identifier, String rawPassword) {
        if (identifier == null || rawPassword == null) {
            return null;
        }

        String sql = "SELECT * FROM emergency_operator WHERE (username = ? OR email = ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, identifier.trim());
            ps.setString(2, identifier.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    String inputHash = hashSha256(rawPassword);

                    if (storedHash != null && storedHash.equalsIgnoreCase(inputHash)) {
                        EmergencyOperator op = new EmergencyOperator();
                        op.setOperatorId(rs.getInt("operator_id"));
                        op.setUsername(rs.getString("username"));
                        op.setFullName(rs.getString("full_name"));
                        op.setEmail(rs.getString("email"));
                        op.setPhone(rs.getString("phone"));
                        op.setDispatchCenter(rs.getString("dispatch_center"));
                        op.setCreatedAt(rs.getTimestamp("created_at"));
                        return op;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public EmergencyOperator getOperatorById(int id) {
        String sql = "SELECT * FROM emergency_operator WHERE operator_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    EmergencyOperator op = new EmergencyOperator();
                    op.setOperatorId(rs.getInt("operator_id"));
                    op.setUsername(rs.getString("username"));
                    op.setFullName(rs.getString("full_name"));
                    op.setEmail(rs.getString("email"));
                    op.setPhone(rs.getString("phone"));
                    op.setDispatchCenter(rs.getString("dispatch_center"));
                    op.setCreatedAt(rs.getTimestamp("created_at"));
                    return op;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(int id, String fullName, String phone, String dispatchCenter) {
        String sql = "UPDATE emergency_operator SET full_name = ?, phone = ?, dispatch_center = ? WHERE operator_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, dispatchCenter);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String hashSha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 error", e);
        }
    }
}
