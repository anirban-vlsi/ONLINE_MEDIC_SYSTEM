package dao.admin;

import dao.common.DBConnection;
import model.admin.ActivityLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAO {

    // Record an audit log entry
    public boolean logActivity(ActivityLog log) {
        if (log == null) {
            return false;
        }

        String sql = "INSERT INTO activity_log "
                   + "(actor_id, actor_name, actor_type, activity_type, action_description, "
                   + "target_entity_type, target_entity_id, result, ip_address) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, log.getActorId() != null ? log.getActorId() : "SYSTEM");
            ps.setString(2, log.getActorName());
            ps.setString(3, log.getActorType() != null ? log.getActorType() : "SYSTEM");
            ps.setString(4, log.getActivityType() != null ? log.getActivityType() : "GENERAL");
            ps.setString(5, log.getActionDescription() != null ? log.getActionDescription() : "");
            ps.setString(6, log.getTargetEntityType());
            ps.setString(7, log.getTargetEntityId());
            ps.setString(8, log.getResult() != null ? log.getResult() : "SUCCESS");
            ps.setString(9, log.getIpAddress());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        log.setActivityId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            // Logging failure should be output to stderr but never crash user operations
            System.err.println("Activity logging error: " + e.getMessage());
        }
        return false;
    }

    // Retrieve filtered activity logs with pagination
    public List<ActivityLog> getFilteredActivityLogs(String actorType, String activityType,
                                                     String result, String search,
                                                     String startDate, String endDate,
                                                     int offset, int limit) {
        List<ActivityLog> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT activity_id, actor_id, actor_name, actor_type, activity_type, "
                + "action_description, target_entity_type, target_entity_id, result, ip_address, created_at "
                + "FROM activity_log WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (actorType != null && !actorType.trim().isEmpty() && !"ALL".equalsIgnoreCase(actorType)) {
            sql.append("AND actor_type = ? ");
            params.add(actorType.trim());
        }

        if (activityType != null && !activityType.trim().isEmpty() && !"ALL".equalsIgnoreCase(activityType)) {
            sql.append("AND activity_type = ? ");
            params.add(activityType.trim());
        }

        if (result != null && !result.trim().isEmpty() && !"ALL".equalsIgnoreCase(result)) {
            sql.append("AND result = ? ");
            params.add(result.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (action_description LIKE ? OR actor_name LIKE ? OR actor_id LIKE ? OR target_entity_id LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND created_at <= ? ");
            params.add(endDate.trim() + " 23:59:59");
        }

        sql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(limit <= 0 ? 25 : limit);
        params.add(Math.max(0, offset));

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

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

    // Count filtered activity logs for pagination
    public int getFilteredLogsCount(String actorType, String activityType, String result,
                                   String search, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM activity_log WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (actorType != null && !actorType.trim().isEmpty() && !"ALL".equalsIgnoreCase(actorType)) {
            sql.append("AND actor_type = ? ");
            params.add(actorType.trim());
        }

        if (activityType != null && !activityType.trim().isEmpty() && !"ALL".equalsIgnoreCase(activityType)) {
            sql.append("AND activity_type = ? ");
            params.add(activityType.trim());
        }

        if (result != null && !result.trim().isEmpty() && !"ALL".equalsIgnoreCase(result)) {
            sql.append("AND result = ? ");
            params.add(result.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (action_description LIKE ? OR actor_name LIKE ? OR actor_id LIKE ? OR target_entity_id LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND created_at <= ? ");
            params.add(endDate.trim() + " 23:59:59");
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
