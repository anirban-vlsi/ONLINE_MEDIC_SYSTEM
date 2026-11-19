package dao.emergency;

import dao.common.DBConnection;
import model.emergency.EmergencyRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class EmergencyRequestDAO {

    public boolean createEmergencyRequest(EmergencyRequest req) {
        String sql = "INSERT INTO emergency_request (user_id, patient_id, ambulance_id, emergency_type, description, pickup_address, contact_phone, request_status, priority) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, req.getUserId());
            if (req.getPatientId() != null && req.getPatientId() > 0) {
                ps.setInt(2, req.getPatientId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            if (req.getAmbulanceId() != null && req.getAmbulanceId() > 0) {
                ps.setInt(3, req.getAmbulanceId());
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            ps.setString(4, req.getEmergencyType() != null ? req.getEmergencyType() : "GENERAL");
            ps.setString(5, req.getDescription());
            ps.setString(6, req.getPickupAddress());
            ps.setString(7, req.getContactPhone());
            ps.setString(8, req.getRequestStatus() != null ? req.getRequestStatus() : "PENDING");
            ps.setString(9, req.getPriority() != null ? req.getPriority() : "MEDIUM");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        req.setRequestId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<EmergencyRequest> getRequestsByUserId(int userId) {
        List<EmergencyRequest> list = new ArrayList<>();
        String sql = "SELECT er.*, p.patient_name, amb.vehicle_number, amb.ambulance_type, amb.driver_name, amb.driver_phone "
                   + "FROM emergency_request er "
                   + "LEFT JOIN patient p ON er.patient_id = p.patient_id "
                   + "LEFT JOIN ambulance amb ON er.ambulance_id = amb.ambulance_id "
                   + "WHERE er.user_id = ? "
                   + "ORDER BY er.created_at DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmergencyRequest(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public EmergencyRequest getRequestById(int requestId) {
        String sql = "SELECT er.*, p.patient_name, amb.vehicle_number, amb.ambulance_type, amb.driver_name, amb.driver_phone "
                   + "FROM emergency_request er "
                   + "LEFT JOIN patient p ON er.patient_id = p.patient_id "
                   + "LEFT JOIN ambulance amb ON er.ambulance_id = amb.ambulance_id "
                   + "WHERE er.request_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEmergencyRequest(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<EmergencyRequest> getAllRequests(String statusFilter) {
        List<EmergencyRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT er.*, p.patient_name, amb.vehicle_number, amb.ambulance_type, amb.driver_name, amb.driver_phone "
          + "FROM emergency_request er "
          + "LEFT JOIN patient p ON er.patient_id = p.patient_id "
          + "LEFT JOIN ambulance amb ON er.ambulance_id = amb.ambulance_id "
        );
        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE er.request_status = ? ");
            params.add(statusFilter.trim());
        }
        sql.append("ORDER BY er.created_at DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEmergencyRequest(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean dispatchAmbulance(int requestId, int ambulanceId) {
        String reqSql = "UPDATE emergency_request SET ambulance_id = ?, request_status = 'DISPATCHED' WHERE request_id = ?";
        String ambSql = "UPDATE ambulance SET current_status = 'ON_DUTY' WHERE ambulance_id = ?";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            if (con == null) return false;
            con.setAutoCommit(false);

            try (PreparedStatement psReq = con.prepareStatement(reqSql)) {
                psReq.setInt(1, ambulanceId);
                psReq.setInt(2, requestId);
                psReq.executeUpdate();
            }

            try (PreparedStatement psAmb = con.prepareStatement(ambSql)) {
                psAmb.setInt(1, ambulanceId);
                psAmb.executeUpdate();
            }

            con.commit();
            return true;
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

    public boolean updateRequestStatus(int requestId, String status) {
        String sql = "UPDATE emergency_request SET request_status = ? WHERE request_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private EmergencyRequest mapEmergencyRequest(ResultSet rs) throws Exception {
        EmergencyRequest r = new EmergencyRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setUserId(rs.getInt("user_id"));
        int pid = rs.getInt("patient_id");
        if (!rs.wasNull()) r.setPatientId(pid);
        int aid = rs.getInt("ambulance_id");
        if (!rs.wasNull()) r.setAmbulanceId(aid);

        r.setEmergencyType(rs.getString("emergency_type"));
        r.setDescription(rs.getString("description"));
        r.setPickupAddress(rs.getString("pickup_address"));
        r.setContactPhone(rs.getString("contact_phone"));
        r.setLatitude(rs.getBigDecimal("latitude"));
        r.setLongitude(rs.getBigDecimal("longitude"));
        r.setRequestStatus(rs.getString("request_status"));
        r.setPriority(rs.getString("priority"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));

        r.setPatientName(rs.getString("patient_name"));
        r.setAmbulanceVehicle(rs.getString("vehicle_number"));
        r.setAmbulanceType(rs.getString("ambulance_type"));
        r.setDriverName(rs.getString("driver_name"));
        r.setDriverPhone(rs.getString("driver_phone"));
        return r;
    }
}
