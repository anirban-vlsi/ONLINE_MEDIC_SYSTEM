package dao.moderation;

import dao.common.DBConnection;
import model.moderation.FeedbackReport;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class FeedbackReportDAO {

    public boolean submitReport(FeedbackReport report) {
        String sql = "INSERT INTO feedback_report "
                   + "(reporter_role, reporter_id, target_type, target_id, reference_id, "
                   + "report_category, rating, comments, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, report.getReporterRole().toUpperCase());
            ps.setString(2, report.getReporterId());
            ps.setString(3, report.getTargetType().toUpperCase());
            ps.setString(4, report.getTargetId());
            if (report.getReferenceId() != null) {
                ps.setInt(5, report.getReferenceId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setString(6, report.getReportCategory().toUpperCase());
            if (report.getRating() != null) {
                ps.setInt(7, report.getRating());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            ps.setString(8, report.getComments());
            ps.setString(9, report.getStatus() != null ? report.getStatus() : "OPEN");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        report.setReportId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<FeedbackReport> getAllReports(String statusFilter, String targetTypeFilter) {
        List<FeedbackReport> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM feedback_report WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (targetTypeFilter != null && !targetTypeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(targetTypeFilter)) {
            sql.append("AND target_type = ? ");
            params.add(targetTypeFilter.trim().toUpperCase());
        }

        sql.append("ORDER BY created_at DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FeedbackReport r = new FeedbackReport();
                    r.setReportId(rs.getInt("report_id"));
                    r.setReporterRole(rs.getString("reporter_role"));
                    r.setReporterId(rs.getString("reporter_id"));
                    r.setTargetType(rs.getString("target_type"));
                    r.setTargetId(rs.getString("target_id"));
                    int refId = rs.getInt("reference_id");
                    if (!rs.wasNull()) {
                        r.setReferenceId(refId);
                    }
                    r.setReportCategory(rs.getString("report_category"));
                    int rating = rs.getInt("rating");
                    if (!rs.wasNull()) {
                        r.setRating(rating);
                    }
                    r.setComments(rs.getString("comments"));
                    r.setStatus(rs.getString("status"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateReportStatus(int reportId, String status) {
        String sql = "UPDATE feedback_report SET status = ? WHERE report_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, reportId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
