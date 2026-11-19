package dao.admin;

import dao.common.DBConnection;
import model.admin.FinancialTransaction;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FinancialTransactionDAO {

    // Retrieve filtered financial transactions
    public List<FinancialTransaction> getFilteredTransactions(String statusFilter, String search,
                                                              int offset, int limit) {
        List<FinancialTransaction> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.transaction_id, t.patient_user_id, u.name AS patient_name, "
            + "t.doctor_reg_no, d.doctor_name, t.amount, t.payment_method, "
            + "t.transaction_status, t.payment_reference, t.transaction_date "
            + "FROM financial_transaction t "
            + "LEFT JOIN user u ON t.patient_user_id = u.user_id "
            + "LEFT JOIN doctor d ON t.doctor_reg_no = d.registration_number "
            + "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND t.transaction_status = ? ");
            params.add(statusFilter.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.transaction_id LIKE ? OR u.name LIKE ? OR d.doctor_name LIKE ? OR t.payment_reference LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY t.transaction_date DESC LIMIT ? OFFSET ?");
        params.add(limit <= 0 ? 25 : limit);
        params.add(Math.max(0, offset));

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FinancialTransaction txn = new FinancialTransaction();
                    txn.setTransactionId(rs.getString("transaction_id"));
                    txn.setPatientUserId(rs.getInt("patient_user_id"));
                    txn.setPatientName(rs.getString("patient_name") != null ? rs.getString("patient_name") : "Patient #" + txn.getPatientUserId());
                    txn.setDoctorRegNo(rs.getString("doctor_reg_no"));
                    txn.setDoctorName(rs.getString("doctor_name") != null ? rs.getString("doctor_name") : "General Clinic");
                    txn.setAmount(rs.getDouble("amount"));
                    txn.setPaymentMethod(rs.getString("payment_method"));
                    txn.setTransactionStatus(rs.getString("transaction_status"));
                    txn.setPaymentReference(rs.getString("payment_reference"));
                    txn.setTransactionDate(rs.getTimestamp("transaction_date"));
                    list.add(txn);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Count filtered transactions for pagination
    public int getFilteredTransactionsCount(String statusFilter, String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM financial_transaction t "
            + "LEFT JOIN user u ON t.patient_user_id = u.user_id "
            + "LEFT JOIN doctor d ON t.doctor_reg_no = d.registration_number "
            + "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND t.transaction_status = ? ");
            params.add(statusFilter.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.transaction_id LIKE ? OR u.name LIKE ? OR d.doctor_name LIKE ? OR t.payment_reference LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Record a new transaction (for billing / payment simulation)
    public boolean recordTransaction(FinancialTransaction txn) {
        if (txn == null) {
            return false;
        }

        String sql = "INSERT INTO financial_transaction "
                   + "(transaction_id, patient_user_id, doctor_reg_no, amount, payment_method, transaction_status, payment_reference) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, txn.getTransactionId());
            ps.setInt(2, txn.getPatientUserId());
            ps.setString(3, txn.getDoctorRegNo());
            ps.setDouble(4, txn.getAmount());
            ps.setString(5, txn.getPaymentMethod() != null ? txn.getPaymentMethod() : "ONLINE");
            ps.setString(6, txn.getTransactionStatus() != null ? txn.getTransactionStatus() : "SUCCESS");
            ps.setString(7, txn.getPaymentReference());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
