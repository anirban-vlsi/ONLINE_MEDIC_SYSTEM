package model.finance;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class FinancialTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private String transactionId;
    private String serviceType; // APPOINTMENT or PHARMACY
    private int referenceId; // appointment_id or order_id
    private int patientUserId;
    private String providerId; // doctor_reg_no or PHARMACY
    private BigDecimal grossAmount = BigDecimal.ZERO;
    private BigDecimal commissionRate = new BigDecimal("15.00");
    private BigDecimal adminCommission = BigDecimal.ZERO;
    private BigDecimal providerPayout = BigDecimal.ZERO;
    private String paymentMethod = "UPI"; // UPI, CARD, NET_BANKING
    private String transactionStatus = "SUCCESS";
    private Timestamp transactionDate;

    // View presentation helpers
    private String patientName;
    private String providerName;

    public FinancialTransaction() {}

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public int getReferenceId() { return referenceId; }
    public void setReferenceId(int referenceId) { this.referenceId = referenceId; }

    public int getPatientUserId() { return patientUserId; }
    public void setPatientUserId(int patientUserId) { this.patientUserId = patientUserId; }

    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }

    public BigDecimal getGrossAmount() { return grossAmount; }
    public void setGrossAmount(BigDecimal grossAmount) { this.grossAmount = grossAmount; }

    public BigDecimal getCommissionRate() { return commissionRate; }
    public void setCommissionRate(BigDecimal commissionRate) { this.commissionRate = commissionRate; }

    public BigDecimal getAdminCommission() { return adminCommission; }
    public void setAdminCommission(BigDecimal adminCommission) { this.adminCommission = adminCommission; }

    public BigDecimal getProviderPayout() { return providerPayout; }
    public void setProviderPayout(BigDecimal providerPayout) { this.providerPayout = providerPayout; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getTransactionStatus() { return transactionStatus; }
    public void setTransactionStatus(String transactionStatus) { this.transactionStatus = transactionStatus; }

    public Timestamp getTransactionDate() { return transactionDate; }
    public void setTransactionDate(Timestamp transactionDate) { this.transactionDate = transactionDate; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getProviderName() { return providerName; }
    public void setProviderName(String providerName) { this.providerName = providerName; }
}
