package model.admin;

import java.io.Serializable;
import java.sql.Timestamp;

public class Admin implements Serializable {

    private static final long serialVersionUID = 1L;

    private int adminId;
    private String fullName;
    private String email;
    private String phone;
    private String passwordHash;
    private String role;
    private String accountStatus;
    private Timestamp createdAt;
    private Timestamp lastLogin;
    private Timestamp lastActivity;

    public Admin() {
    }

    public Admin(int adminId, String fullName, String email, String phone,
                 String passwordHash, String role, String accountStatus,
                 Timestamp createdAt, Timestamp lastLogin, Timestamp lastActivity) {
        this.adminId = adminId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.role = role;
        this.accountStatus = accountStatus;
        this.createdAt = createdAt;
        this.lastLogin = lastLogin;
        this.lastActivity = lastActivity;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }

    public Timestamp getLastActivity() {
        return lastActivity;
    }

    public void setLastActivity(Timestamp lastActivity) {
        this.lastActivity = lastActivity;
    }

    public boolean isSuperAdmin() {
        return AdminRole.SUPER_ADMIN.equalsIgnoreCase(this.role);
    }

    public boolean isAdmin() {
        return AdminRole.ADMIN.equalsIgnoreCase(this.role) || isSuperAdmin();
    }

    public boolean isModerator() {
        return AdminRole.MODERATOR.equalsIgnoreCase(this.role);
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.accountStatus);
    }
}
