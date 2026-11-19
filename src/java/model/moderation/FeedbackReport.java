package model.moderation;

import java.io.Serializable;
import java.sql.Timestamp;

public class FeedbackReport implements Serializable {
    private static final long serialVersionUID = 1L;

    private int reportId;
    private String reporterRole; // PATIENT or DOCTOR
    private String reporterId; // user_id or doctor_reg_no
    private String targetType; // DOCTOR, PATIENT, PHARMACY, AMBULANCE
    private String targetId;
    private Integer referenceId;
    private String reportCategory; // FEEDBACK or COMPLAINT
    private Integer rating; // 1-5
    private String comments;
    private String status = "OPEN"; // OPEN, REVIEWED, ACTION_TAKEN
    private Timestamp createdAt;

    // View presentation helpers
    private String reporterName;
    private String targetName;

    public FeedbackReport() {}

    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }

    public String getReporterRole() { return reporterRole; }
    public void setReporterRole(String reporterRole) { this.reporterRole = reporterRole; }

    public String getReporterId() { return reporterId; }
    public void setReporterId(String reporterId) { this.reporterId = reporterId; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public String getTargetId() { return targetId; }
    public void setTargetId(String targetId) { this.targetId = targetId; }

    public Integer getReferenceId() { return referenceId; }
    public void setReferenceId(Integer referenceId) { this.referenceId = referenceId; }

    public String getReportCategory() { return reportCategory; }
    public void setReportCategory(String reportCategory) { this.reportCategory = reportCategory; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getTargetName() { return targetName; }
    public void setTargetName(String targetName) { this.targetName = targetName; }
}
