package model.pharmacy;

import java.io.Serializable;
import java.math.BigDecimal;

public class PharmacyOrderItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int itemId;
    private int orderId;
    private int medicineId;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;

    // View helper
    private String medicineName;

    public PharmacyOrderItem() {}

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getMedicineId() { return medicineId; }
    public void setMedicineId(int medicineId) { this.medicineId = medicineId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public String getMedicineName() { return medicineName; }
    public void setMedicineName(String medicineName) { this.medicineName = medicineName; }
}
