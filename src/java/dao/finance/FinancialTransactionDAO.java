package dao.finance;

import dao.common.DBConnection;
import model.finance.FinancialTransaction;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class FinancialTransactionDAO {

    public boolean recordTransaction(FinancialTransaction tx) {
        String sql = "INSERT INTO financial_transaction "
                   + "(transaction_id, service_type, reference_id, patient_user_id, provider_id, "
                   + "gross_amount, commission_rate, admin_commission, provider_payout, payment_method, "
                   + "transaction_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, tx.getTransactionId());
            ps.setString(2, tx.getServiceType());
            ps.setInt(3, tx.getReferenceId());
            ps.setInt(4, tx.getPatientUserId());
            ps.setString(5, tx.getProviderId());
            ps.setBigDecimal(6, tx.getGrossAmount());
            ps.setBigDecimal(7, tx.getCommissionRate());
            ps.setBigDecimal(8, tx.getAdminCommission());
            ps.setBigDecimal(9, tx.getProviderPayout());
            ps.setString(10, tx.getPaymentMethod());
            ps.setString(11, tx.getTransactionStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Process simulated checkout for appointment (15% platform commission)
    public FinancialTransaction processAppointmentPayment(int appointmentId, int userId, String doctorRegNo, BigDecimal grossAmount, String paymentMethod) {
        BigDecimal gross = (grossAmount != null && grossAmount.compareTo(BigDecimal.ZERO) > 0) ? grossAmount : new BigDecimal("500.00");
        BigDecimal rate = new BigDecimal("15.00");
        BigDecimal adminComm = gross.multiply(new BigDecimal("0.15")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal providerPay = gross.subtract(adminComm);
        String txnId = "TXN-APT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        FinancialTransaction tx = new FinancialTransaction();
        tx.setTransactionId(txnId);
        tx.setServiceType("APPOINTMENT");
        tx.setReferenceId(appointmentId);
        tx.setPatientUserId(userId);
        tx.setProviderId(doctorRegNo);
        tx.setGrossAmount(gross);
        tx.setCommissionRate(rate);
        tx.setAdminCommission(adminComm);
        tx.setProviderPayout(providerPay);
        tx.setPaymentMethod(paymentMethod != null ? paymentMethod.toUpperCase() : "UPI");
        tx.setTransactionStatus("SUCCESS");

        if (recordTransaction(tx)) {
            // Update appointment payment status to PAID
            String updateSql = "UPDATE appointment SET payment_status = 'PAID' WHERE appointment_id = ?";
            try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, appointmentId);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return tx;
        }
        return null;
    }

    // Process simulated checkout for pharmacy order (10% platform commission)
    public FinancialTransaction processPharmacyPayment(int orderId, int userId, BigDecimal grossAmount, String paymentMethod) {
        BigDecimal gross = (grossAmount != null) ? grossAmount : BigDecimal.ZERO;
        BigDecimal rate = new BigDecimal("10.00");
        BigDecimal adminComm = gross.multiply(new BigDecimal("0.10")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal providerPay = gross.subtract(adminComm);
        String txnId = "TXN-PHM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        FinancialTransaction tx = new FinancialTransaction();
        tx.setTransactionId(txnId);
        tx.setServiceType("PHARMACY");
        tx.setReferenceId(orderId);
        tx.setPatientUserId(userId);
        tx.setProviderId("PHARMACY");
        tx.setGrossAmount(gross);
        tx.setCommissionRate(rate);
        tx.setAdminCommission(adminComm);
        tx.setProviderPayout(providerPay);
        tx.setPaymentMethod(paymentMethod != null ? paymentMethod.toUpperCase() : "UPI");
        tx.setTransactionStatus("SUCCESS");

        if (recordTransaction(tx)) {
            // Update pharmacy_order payment status to PAID
            String updateSql = "UPDATE pharmacy_order SET payment_status = 'PAID' WHERE order_id = ?";
            try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return tx;
        }
        return null;
    }

    // Admin Metrics
    public BigDecimal getTotalGrossRevenue() {
        return querySingleDecimal("SELECT COALESCE(SUM(gross_amount), 0) FROM financial_transaction WHERE transaction_status = 'SUCCESS'");
    }

    public BigDecimal getTotalAdminCommission() {
        return querySingleDecimal("SELECT COALESCE(SUM(admin_commission), 0) FROM financial_transaction WHERE transaction_status = 'SUCCESS'");
    }

    public BigDecimal getTotalDoctorPayouts() {
        return querySingleDecimal("SELECT COALESCE(SUM(provider_payout), 0) FROM financial_transaction WHERE service_type = 'APPOINTMENT' AND transaction_status = 'SUCCESS'");
    }

    public BigDecimal getTotalPharmacyPayouts() {
        return querySingleDecimal("SELECT COALESCE(SUM(provider_payout), 0) FROM financial_transaction WHERE service_type = 'PHARMACY' AND transaction_status = 'SUCCESS'");
    }

    private BigDecimal querySingleDecimal(String sql) {
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public List<FinancialTransaction> getAllTransactions(String serviceFilter) {
        List<FinancialTransaction> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ft.*, u.name AS patient_name, "
          + "CASE WHEN ft.service_type = 'APPOINTMENT' THEN d.doctor_name ELSE 'Central Pharmacy' END AS provider_name "
          + "FROM financial_transaction ft "
          + "LEFT JOIN user u ON ft.patient_user_id = u.user_id "
          + "LEFT JOIN doctor d ON ft.provider_id = d.registration_number "
        );
        if (serviceFilter != null && !serviceFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(serviceFilter)) {
            sql.append("WHERE ft.service_type = ? ");
        }
        sql.append("ORDER BY ft.transaction_date DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            if (serviceFilter != null && !serviceFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(serviceFilter)) {
                ps.setString(1, serviceFilter.trim().toUpperCase());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FinancialTransaction tx = new FinancialTransaction();
                    tx.setTransactionId(rs.getString("transaction_id"));
                    tx.setServiceType(rs.getString("service_type"));
                    tx.setReferenceId(rs.getInt("reference_id"));
                    tx.setPatientUserId(rs.getInt("patient_user_id"));
                    tx.setProviderId(rs.getString("provider_id"));
                    tx.setGrossAmount(rs.getBigDecimal("gross_amount"));
                    tx.setCommissionRate(rs.getBigDecimal("commission_rate"));
                    tx.setAdminCommission(rs.getBigDecimal("admin_commission"));
                    tx.setProviderPayout(rs.getBigDecimal("provider_payout"));
                    tx.setPaymentMethod(rs.getString("payment_method"));
                    tx.setTransactionStatus(rs.getString("transaction_status"));
                    tx.setTransactionDate(rs.getTimestamp("transaction_date"));
                    tx.setPatientName(rs.getString("patient_name"));
                    tx.setProviderName(rs.getString("provider_name"));
                    list.add(tx);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
