package model.emergency;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class EmergencyRequest implements Serializable {
    private static final long serialVersionUID = 1L;

    private int requestId;
    private int userId;
    private Integer patientId;
    private Integer ambulanceId;
    private String emergencyType; // GENERAL, CARDIAC, ACCIDENT, MATERNITY, OTHER
    private String description;
    private String pickupAddress;
    private String contactPhone;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String requestStatus; // PENDING, DISPATCHED, EN_ROUTE, ARRIVED, COMPLETED, CANCELLED
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // View presentation helpers
    private String patientName;
    private String ambulanceVehicle;
    private String ambulanceType;
    private String driverName;
    private String driverPhone;

    public EmergencyRequest() {}

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getPatientId() { return patientId; }
    public void setPatientId(Integer patientId) { this.patientId = patientId; }

    public Integer getAmbulanceId() { return ambulanceId; }
    public void setAmbulanceId(Integer ambulanceId) { this.ambulanceId = ambulanceId; }

    public String getEmergencyType() { return emergencyType; }
    public void setEmergencyType(String emergencyType) { this.emergencyType = emergencyType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getPickupAddress() { return pickupAddress; }
    public void setPickupAddress(String pickupAddress) { this.pickupAddress = pickupAddress; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public String getRequestStatus() { return requestStatus; }
    public void setRequestStatus(String requestStatus) { this.requestStatus = requestStatus; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getAmbulanceVehicle() { return ambulanceVehicle; }
    public void setAmbulanceVehicle(String ambulanceVehicle) { this.ambulanceVehicle = ambulanceVehicle; }

    public String getAmbulanceType() { return ambulanceType; }
    public void setAmbulanceType(String ambulanceType) { this.ambulanceType = ambulanceType; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getDriverPhone() { return driverPhone; }
    public void setDriverPhone(String driverPhone) { this.driverPhone = driverPhone; }

    // Compatibility getters
    public Timestamp getRequestTime() { return createdAt; }
    public String getPickupLocation() { return pickupAddress; }
    public String getStatus() { return requestStatus; }
}
