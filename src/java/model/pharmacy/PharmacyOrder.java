package model.pharmacy;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class PharmacyOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    private int orderId;
    private int userId;
    private Integer prescriptionId;
    private String orderStatus; // PENDING, PROCESSING, READY, DISPENSED, CANCELLED
    private BigDecimal totalAmount;
    private String paymentMethod; // CASH, ONLINE, CARD, UPI
    private String paymentStatus; // PENDING, PAID, REFUNDED
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // View presentation helpers
    private String userName;
    private String userEmail;
    private List<PharmacyOrderItem> items = new ArrayList<>();

    public PharmacyOrder() {}

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(Integer prescriptionId) { this.prescriptionId = prescriptionId; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public List<PharmacyOrderItem> getItems() { return items; }
    public void setItems(List<PharmacyOrderItem> items) { this.items = items; }

    // Compatibility getters
    public Timestamp getOrderDate() { return createdAt; }
    public String getShippingCity() { return null; }
    public String getShippingAddress() { return userEmail != null ? userEmail : "Online Order"; }
}
