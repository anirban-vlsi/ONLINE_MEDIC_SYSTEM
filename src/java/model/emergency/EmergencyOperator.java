package model.emergency;

import java.io.Serializable;
import java.sql.Timestamp;

public class EmergencyOperator implements Serializable {
    private static final long serialVersionUID = 1L;

    private int operatorId;
    private String username;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String dispatchCenter = "City Emergency Control 108";
    private Timestamp createdAt;

    public EmergencyOperator() {}

    public EmergencyOperator(int operatorId, String username, String fullName, String email, String password, String phone, String dispatchCenter) {
        this.operatorId = operatorId;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.dispatchCenter = dispatchCenter;
    }

    public int getOperatorId() { return operatorId; }
    public void setOperatorId(int operatorId) { this.operatorId = operatorId; }

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

    public String getDispatchCenter() { return dispatchCenter; }
    public void setDispatchCenter(String dispatchCenter) { this.dispatchCenter = dispatchCenter; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
