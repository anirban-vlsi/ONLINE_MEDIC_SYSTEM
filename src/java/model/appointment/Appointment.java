package model.appointment;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class Appointment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int appointmentId;
    private int patientId;
    private int userId;
    private String doctorRegNo;
    private String visitType = "CLINIC"; // CLINIC or HOME_VISIT
    private String patientCity;
    private String patientHomeAddress;
    private BigDecimal feeCharged = new BigDecimal("500.00");
    private Date appointmentDate;
    private Time appointmentTime;
    private String reason;
    private Date proposedDate;
    private Time proposedTime;
    private String doctorRemarks;
    private String status = "PENDING"; // PENDING, CONFIRMED, RESCHEDULE_PROPOSED, COMPLETED, CANCELLED
    private String paymentStatus = "UNPAID"; // UNPAID, PAID
    private String adminRemarks;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // View presentation helpers
    private String patientName;
    private String doctorName;
    private String doctorSpecialization;
    private String patientGender;
    private String patientRelation;

    public Appointment() {}

    public int getAppointmentId() { return appointmentId; }
    public void setAppointmentId(int appointmentId) { this.appointmentId = appointmentId; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getDoctorRegNo() { return doctorRegNo; }
    public void setDoctorRegNo(String doctorRegNo) { this.doctorRegNo = doctorRegNo; }

    public String getVisitType() { return visitType; }
    public void setVisitType(String visitType) { this.visitType = visitType; }

    public String getPatientCity() { return patientCity; }
    public void setPatientCity(String patientCity) { this.patientCity = patientCity; }

    public String getPatientHomeAddress() { return patientHomeAddress; }
    public void setPatientHomeAddress(String patientHomeAddress) { this.patientHomeAddress = patientHomeAddress; }

    public BigDecimal getFeeCharged() { return feeCharged; }
    public void setFeeCharged(BigDecimal feeCharged) { this.feeCharged = feeCharged; }

    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }

    public Time getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(Time appointmentTime) { this.appointmentTime = appointmentTime; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public Date getProposedDate() { return proposedDate; }
    public void setProposedDate(Date proposedDate) { this.proposedDate = proposedDate; }

    public Time getProposedTime() { return proposedTime; }
    public void setProposedTime(Time proposedTime) { this.proposedTime = proposedTime; }

    public String getDoctorRemarks() { return doctorRemarks; }
    public void setDoctorRemarks(String doctorRemarks) { this.doctorRemarks = doctorRemarks; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getAdminRemarks() { return adminRemarks; }
    public void setAdminRemarks(String adminRemarks) { this.adminRemarks = adminRemarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public String getDoctorSpecialization() { return doctorSpecialization; }
    public void setDoctorSpecialization(String doctorSpecialization) { this.doctorSpecialization = doctorSpecialization; }

    public String getPatientGender() { return patientGender; }
    public void setPatientGender(String patientGender) { this.patientGender = patientGender; }

    public String getPatientRelation() { return patientRelation; }
    public void setPatientRelation(String patientRelation) { this.patientRelation = patientRelation; }
}
