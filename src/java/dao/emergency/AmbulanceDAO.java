package dao.emergency;

import dao.common.DBConnection;
import model.emergency.Ambulance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AmbulanceDAO {

    // Exclude BLOCKED ambulances from availability and dispatch
    public List<Ambulance> getAvailableAmbulances() {
        List<Ambulance> list = new ArrayList<>();
        String sql = "SELECT * FROM ambulance WHERE current_status = 'AVAILABLE' AND moderation_status = 'ACTIVE' ORDER BY ambulance_type ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapAmbulance(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Ambulance> getAllAmbulances() {
        List<Ambulance> list = new ArrayList<>();
        String sql = "SELECT * FROM ambulance ORDER BY ambulance_id ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapAmbulance(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Ambulance getAmbulanceById(int id) {
        String sql = "SELECT * FROM ambulance WHERE ambulance_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAmbulance(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveAmbulance(Ambulance amb) {
        String sql;
        if (amb.getAmbulanceId() > 0) {
            sql = "UPDATE ambulance SET vehicle_number = ?, ambulance_type = ?, driver_name = ?, "
                + "driver_phone = ?, base_hospital = ?, current_status = ?, location = ?, moderation_status = ? "
                + "WHERE ambulance_id = ?";
        } else {
            sql = "INSERT INTO ambulance (vehicle_number, ambulance_type, driver_name, driver_phone, "
                + "base_hospital, current_status, location, moderation_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, amb.getVehicleNumber());
            ps.setString(2, amb.getAmbulanceType());
            ps.setString(3, amb.getDriverName());
            ps.setString(4, amb.getDriverPhone());
            ps.setString(5, amb.getBaseHospital() != null ? amb.getBaseHospital() : "Central Hospital");
            ps.setString(6, amb.getCurrentStatus() != null ? amb.getCurrentStatus() : "AVAILABLE");
            ps.setString(7, amb.getLocation());
            ps.setString(8, amb.getModerationStatus() != null ? amb.getModerationStatus() : "ACTIVE");

            if (amb.getAmbulanceId() > 0) {
                ps.setInt(9, amb.getAmbulanceId());
            }

            int rows = ps.executeUpdate();
            if (rows > 0 && amb.getAmbulanceId() == 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        amb.setAmbulanceId(rs.getInt(1));
                    }
                }
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAmbulanceStatus(Connection con, int ambulanceId, String status) throws Exception {
        String sql = "UPDATE ambulance SET current_status = ? WHERE ambulance_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, ambulanceId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateAmbulanceStatus(int ambulanceId, String status) {
        try (Connection con = DBConnection.getConnection()) {
            return updateAmbulanceStatus(con, ambulanceId, status);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateModerationStatus(int ambulanceId, String status) {
        String sql = "UPDATE ambulance SET moderation_status = ? WHERE ambulance_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, ambulanceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Ambulance mapAmbulance(ResultSet rs) throws Exception {
        Ambulance a = new Ambulance();
        a.setAmbulanceId(rs.getInt("ambulance_id"));
        a.setVehicleNumber(rs.getString("vehicle_number"));
        a.setAmbulanceType(rs.getString("ambulance_type"));
        a.setDriverName(rs.getString("driver_name"));
        a.setDriverPhone(rs.getString("driver_phone"));
        try { a.setBaseHospital(rs.getString("base_hospital")); } catch (Exception ignored) {}
        a.setCurrentStatus(rs.getString("current_status"));
        try { a.setModerationStatus(rs.getString("moderation_status")); } catch (Exception ignored) {}
        a.setLocation(rs.getString("location"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        return a;
    }
}
