package dao.pharmacy;

import dao.common.DBConnection;
import model.pharmacy.Medicine;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MedicineDAO {

    // Patient Catalog: Only active and NON-BLOCKED medicines
    public List<Medicine> getAllActiveMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicine WHERE is_active = 1 AND moderation_status = 'ACTIVE' ORDER BY category ASC, medicine_name ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapMedicine(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Medicine> searchMedicines(String query, String category) {
        List<Medicine> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM medicine WHERE is_active = 1 AND moderation_status = 'ACTIVE' ");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND category = ? ");
            params.add(category.trim());
        }

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (medicine_name LIKE ? OR manufacturer LIKE ? OR description LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY category ASC, medicine_name ASC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMedicine(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Management query (Pharmacist / Admin)
    public List<Medicine> getAllMedicinesForManagement(String search, String moderationFilter) {
        List<Medicine> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM medicine WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (moderationFilter != null && !moderationFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(moderationFilter)) {
            sql.append("AND moderation_status = ? ");
            params.add(moderationFilter.trim().toUpperCase());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (medicine_name LIKE ? OR category LIKE ? OR manufacturer LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY medicine_id DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMedicine(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<String> getCategories() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM medicine WHERE is_active = 1 AND moderation_status = 'ACTIVE' ORDER BY category ASC";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(rs.getString("category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Medicine getMedicineById(int medicineId) {
        String sql = "SELECT * FROM medicine WHERE medicine_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, medicineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMedicine(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStock(Connection con, int medicineId, int quantityDeducted) throws Exception {
        String sql = "UPDATE medicine SET stock_quantity = stock_quantity - ? WHERE medicine_id = ? AND stock_quantity >= ? AND moderation_status = 'ACTIVE'";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantityDeducted);
            ps.setInt(2, medicineId);
            ps.setInt(3, quantityDeducted);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean saveMedicine(Medicine med) {
        String sql;
        if (med.getMedicineId() > 0) {
            sql = "UPDATE medicine SET medicine_name = ?, category = ?, manufacturer = ?, unit_price = ?, "
                + "stock_quantity = ?, requires_prescription = ?, description = ?, moderation_status = ? WHERE medicine_id = ?";
        } else {
            sql = "INSERT INTO medicine (medicine_name, category, manufacturer, unit_price, stock_quantity, "
                + "requires_prescription, description, moderation_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, med.getMedicineName());
            ps.setString(2, med.getCategory());
            ps.setString(3, med.getManufacturer());
            ps.setBigDecimal(4, med.getUnitPrice());
            ps.setInt(5, med.getStockQuantity());
            ps.setBoolean(6, med.isRequiresPrescription());
            ps.setString(7, med.getDescription());
            ps.setString(8, med.getModerationStatus() != null ? med.getModerationStatus() : "ACTIVE");

            if (med.getMedicineId() > 0) {
                ps.setInt(9, med.getMedicineId());
            }

            int rows = ps.executeUpdate();
            if (rows > 0 && med.getMedicineId() == 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        med.setMedicineId(rs.getInt(1));
                    }
                }
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateModerationStatus(int medicineId, String status) {
        String sql = "UPDATE medicine SET moderation_status = ? WHERE medicine_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, medicineId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteMedicine(int medicineId) {
        String sql = "UPDATE medicine SET is_active = 0 WHERE medicine_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, medicineId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Medicine mapMedicine(ResultSet rs) throws Exception {
        Medicine m = new Medicine();
        m.setMedicineId(rs.getInt("medicine_id"));
        m.setMedicineName(rs.getString("medicine_name"));
        m.setCategory(rs.getString("category"));
        m.setManufacturer(rs.getString("manufacturer"));
        m.setUnitPrice(rs.getBigDecimal("unit_price"));
        m.setStockQuantity(rs.getInt("stock_quantity"));
        m.setRequiresPrescription(rs.getBoolean("requires_prescription"));
        m.setDescription(rs.getString("description"));
        m.setActive(rs.getBoolean("is_active"));
        try { m.setModerationStatus(rs.getString("moderation_status")); } catch (Exception ignored) {}
        m.setCreatedAt(rs.getTimestamp("created_at"));
        return m;
    }
}
