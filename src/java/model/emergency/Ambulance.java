package model.emergency;

import java.io.Serializable;
import java.sql.Timestamp;

public class Ambulance implements Serializable {
    private static final long serialVersionUID = 1L;

    private int ambulanceId;
    private String vehicleNumber;
    private String ambulanceType; // BASIC, ADVANCED, ICU
    private String driverName;
    private String driverPhone;
    private String baseHospital = "Central Hospital";
    private String currentStatus; // AVAILABLE, ON_DUTY, MAINTENANCE
    private String moderationStatus = "ACTIVE"; // ACTIVE or BLOCKED
    private String location;
    private Timestamp createdAt;

    public Ambulance() {}

    public int getAmbulanceId() { return ambulanceId; }
    public void setAmbulanceId(int ambulanceId) { this.ambulanceId = ambulanceId; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getAmbulanceType() { return ambulanceType; }
    public void setAmbulanceType(String ambulanceType) { this.ambulanceType = ambulanceType; }

    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }

    public String getDriverPhone() { return driverPhone; }
    public void setDriverPhone(String driverPhone) { this.driverPhone = driverPhone; }

    public String getBaseHospital() { return baseHospital; }
    public void setBaseHospital(String baseHospital) { this.baseHospital = baseHospital; }

    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }

    public String getModerationStatus() { return moderationStatus; }
    public void setModerationStatus(String moderationStatus) { this.moderationStatus = moderationStatus; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
