package model.pharmacist;

import java.io.Serializable;
import java.sql.Timestamp;

public class Pharmacist implements Serializable {
    private static final long serialVersionUID = 1L;

    private int pharmacistId;
    private String username;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String pharmacyName = "Central Hospital Pharmacy";
    private Timestamp createdAt;

    public Pharmacist() {}

    public Pharmacist(int pharmacistId, String username, String fullName, String email, String password, String phone, String pharmacyName) {
        this.pharmacistId = pharmacistId;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.pharmacyName = pharmacyName;
    }

    public int getPharmacistId() { return pharmacistId; }
    public void setPharmacistId(int pharmacistId) { this.pharmacistId = pharmacistId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPharmacyName() { return pharmacyName; }
    public void setPharmacyName(String pharmacyName) { this.pharmacyName = pharmacyName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
