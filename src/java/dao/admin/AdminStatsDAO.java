package dao.admin;

import dao.common.DBConnection;
import model.admin.ActivityLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminStatsDAO {

    // Total Registered Patients (count of users in user table)
    public int getTotalPatientsCount() {
        String sql = "SELECT COUNT(*) FROM user";
        return executeCountQuery(sql);
    }

    // Total Registered Doctors
    public int getTotalDoctorsCount() {
        String sql = "SELECT COUNT(*) FROM doctor";
        return executeCountQuery(sql);
    }

    // Total Authorized / Verified Doctors
    public int getAuthorizedDoctorsCount() {
        String sql = "SELECT COUNT(*) FROM doctor WHERE verification_status = 'VERIFIED'";
        return executeCountQuery(sql);
    }

    // Pending Doctor Authorizations
    public int getPendingDoctorsCount() {
        String sql = "SELECT COUNT(*) FROM doctor WHERE verification_status IN ('NOT VERIFIED', 'PENDING')";
        return executeCountQuery(sql);
    }

    // Blocked Patients
    public int getBlockedPatientsCount() {
        String sql = "SELECT COUNT(*) FROM user WHERE status = 'BLOCKED'";
        return executeCountQuery(sql);
    }

    // Blocked or Rejected Doctors
    public int getBlockedDoctorsCount() {
        String sql = "SELECT COUNT(*) FROM doctor WHERE verification_status IN ('BLOCKED', 'REJECTED')";
        return executeCountQuery(sql);
    }

    // Total Appointments (from database if table exists, otherwise 0)
    public int getTotalAppointmentsCount() {
        // Safe check: verify if an appointment table exists in the schema
        String checkSql = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'medic' AND table_name = 'appointment'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement psCheck = con.prepareStatement(checkSql);
            ResultSet rsCheck = psCheck.executeQuery()
        ) {
            if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                return executeCountQuery("SELECT COUNT(*) FROM appointment");
            }
        } catch (Exception e) {
            // Table doesn't exist yet
        }
        return 0;
    }

    // Total Transactions
    public int getTotalTransactionsCount() {
        String sql = "SELECT COUNT(*) FROM financial_transaction";
        return executeCountQuery(sql);
    }

    // Total Revenue from successful transactions
    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(amount), 0.0) FROM financial_transaction WHERE transaction_status = 'SUCCESS'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // Recent System Activities from activity_log
    public List<ActivityLog> getRecentActivities(int limit) {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT activity_id, actor_id, actor_name, actor_type, activity_type, "
                   + "action_description, target_entity_type, target_entity_id, result, "
                   + "ip_address, created_at FROM activity_log ORDER BY created_at DESC LIMIT ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, limit <= 0 ? 10 : limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ActivityLog log = new ActivityLog();
                    log.setActivityId(rs.getLong("activity_id"));
                    log.setActorId(rs.getString("actor_id"));
                    log.setActorName(rs.getString("actor_name"));
                    log.setActorType(rs.getString("actor_type"));
                    log.setActivityType(rs.getString("activity_type"));
                    log.setActionDescription(rs.getString("action_description"));
                    log.setTargetEntityType(rs.getString("target_entity_type"));
                    log.setTargetEntityId(rs.getString("target_entity_id"));
                    log.setResult(rs.getString("result"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    logs.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return logs;
    }

    private int executeCountQuery(String sql) {
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
