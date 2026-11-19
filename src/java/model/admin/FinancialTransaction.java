package model.admin;

import java.io.Serializable;
import java.sql.Timestamp;

public class FinancialTransaction implements Serializable {

    private static final long serialVersionUID = 1L;

    private String transactionId;
    private int patientUserId;
    private String patientName;
    private String doctorRegNo;
    private String doctorName;
    private double amount;
    private String paymentMethod;
    private String transactionStatus;
    private String paymentReference;
    private Timestamp transactionDate;

    public FinancialTransaction() {
    }

    public FinancialTransaction(String transactionId, int patientUserId, String patientName,
                                String doctorRegNo, String doctorName, double amount,
                                String paymentMethod, String transactionStatus,
                                String paymentReference, Timestamp transactionDate) {
        this.transactionId = transactionId;
        this.patientUserId = patientUserId;
        this.patientName = patientName;
        this.doctorRegNo = doctorRegNo;
        this.doctorName = doctorName;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.transactionStatus = transactionStatus;
        this.paymentReference = paymentReference;
        this.transactionDate = transactionDate;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public int getPatientUserId() {
        return patientUserId;
    }

    public void setPatientUserId(int patientUserId) {
        this.patientUserId = patientUserId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getDoctorRegNo() {
        return doctorRegNo;
    }

    public void setDoctorRegNo(String doctorRegNo) {
        this.doctorRegNo = doctorRegNo;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionStatus() {
        return transactionStatus;
    }

    public void setTransactionStatus(String transactionStatus) {
        this.transactionStatus = transactionStatus;
    }

    public String getPaymentReference() {
        return paymentReference;
    }

    public void setPaymentReference(String paymentReference) {
        this.paymentReference = paymentReference;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }
}
