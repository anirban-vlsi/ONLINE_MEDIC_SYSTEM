package dao.pharmacist;

import dao.common.DBConnection;
import model.pharmacist.Pharmacist;

import java.math.BigDecimal;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PharmacistDAO {

    public Pharmacist authenticate(String identifier, String rawPassword) {
        if (identifier == null || rawPassword == null) {
            return null;
        }

        String sql = "SELECT * FROM pharmacist WHERE (username = ? OR email = ?)";
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
                        Pharmacist p = new Pharmacist();
                        p.setPharmacistId(rs.getInt("pharmacist_id"));
                        p.setUsername(rs.getString("username"));
                        p.setFullName(rs.getString("full_name"));
                        p.setEmail(rs.getString("email"));
                        p.setPhone(rs.getString("phone"));
                        p.setPharmacyName(rs.getString("pharmacy_name"));
                        p.setCreatedAt(rs.getTimestamp("created_at"));
                        return p;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Pharmacist getPharmacistById(int id) {
        String sql = "SELECT * FROM pharmacist WHERE pharmacist_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Pharmacist p = new Pharmacist();
                    p.setPharmacistId(rs.getInt("pharmacist_id"));
                    p.setUsername(rs.getString("username"));
                    p.setFullName(rs.getString("full_name"));
                    p.setEmail(rs.getString("email"));
                    p.setPhone(rs.getString("phone"));
                    p.setPharmacyName(rs.getString("pharmacy_name"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(int id, String fullName, String phone, String pharmacyName) {
        String sql = "UPDATE pharmacist SET full_name = ?, phone = ?, pharmacy_name = ? WHERE pharmacist_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, pharmacyName);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public BigDecimal getTotalPharmacyEarnings() {
        String sql = "SELECT COALESCE(SUM(provider_payout), 0) FROM financial_transaction "
                   + "WHERE service_type = 'PHARMACY' AND transaction_status = 'SUCCESS'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
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
