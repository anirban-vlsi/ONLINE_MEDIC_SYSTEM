package dao.pharmacy;

import dao.common.DBConnection;
import model.pharmacy.PharmacyOrder;
import model.pharmacy.PharmacyOrderItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PharmacyOrderDAO {

    private final MedicineDAO medicineDAO = new MedicineDAO();

    public boolean createOrder(PharmacyOrder order, List<PharmacyOrderItem> items) {
        if (order == null || items == null || items.isEmpty()) {
            return false;
        }

        String orderSql = "INSERT INTO pharmacy_order (user_id, prescription_id, order_status, total_amount, payment_method, payment_status) "
                        + "VALUES (?, ?, ?, ?, ?, ?)";
        String itemSql = "INSERT INTO pharmacy_order_item (order_id, medicine_id, quantity, unit_price, subtotal) "
                       + "VALUES (?, ?, ?, ?, ?)";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            if (con == null) return false;

            con.setAutoCommit(false);

            // 1. Insert order header
            int orderId;
            try (PreparedStatement psOrder = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, order.getUserId());
                if (order.getPrescriptionId() != null && order.getPrescriptionId() > 0) {
                    psOrder.setInt(2, order.getPrescriptionId());
                } else {
                    psOrder.setNull(2, java.sql.Types.INTEGER);
                }
                psOrder.setString(3, "PROCESSING");
                psOrder.setBigDecimal(4, order.getTotalAmount());
                psOrder.setString(5, order.getPaymentMethod() != null ? order.getPaymentMethod() : "CASH");
                psOrder.setString(6, order.getPaymentStatus() != null ? order.getPaymentStatus() : "PENDING");

                int rows = psOrder.executeUpdate();
                if (rows == 0) {
                    con.rollback();
                    return false;
                }

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                        order.setOrderId(orderId);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // 2. Insert items and decrement stock
            try (PreparedStatement psItem = con.prepareStatement(itemSql)) {
                for (PharmacyOrderItem item : items) {
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getMedicineId());
                    psItem.setInt(3, item.getQuantity());
                    psItem.setBigDecimal(4, item.getUnitPrice());
                    psItem.setBigDecimal(5, item.getSubtotal());
                    psItem.addBatch();

                    // Deduct inventory stock
                    boolean stockOk = medicineDAO.updateStock(con, item.getMedicineId(), item.getQuantity());
                    if (!stockOk) {
                        con.rollback();
                        return false; // Out of stock or insufficient stock
                    }
                }
                psItem.executeBatch();
            }

            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public List<PharmacyOrder> getOrdersByUserId(int userId) {
        List<PharmacyOrder> list = new ArrayList<>();
        String sql = "SELECT * FROM pharmacy_order WHERE user_id = ? ORDER BY created_at DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PharmacyOrder o = mapOrder(rs);
                    o.setItems(getOrderItems(o.getOrderId()));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public PharmacyOrder getOrderById(int orderId) {
        String sql = "SELECT po.*, u.name AS user_name, u.email AS user_email "
                   + "FROM pharmacy_order po "
                   + "JOIN user u ON po.user_id = u.user_id "
                   + "WHERE po.order_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PharmacyOrder o = mapOrder(rs);
                    o.setUserName(rs.getString("user_name"));
                    o.setUserEmail(rs.getString("user_email"));
                    o.setItems(getOrderItems(orderId));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<PharmacyOrderItem> getOrderItems(int orderId) {
        List<PharmacyOrderItem> list = new ArrayList<>();
        String sql = "SELECT poi.*, m.medicine_name "
                   + "FROM pharmacy_order_item poi "
                   + "JOIN medicine m ON poi.medicine_id = m.medicine_id "
                   + "WHERE poi.order_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PharmacyOrderItem item = new PharmacyOrderItem();
                    item.setItemId(rs.getInt("item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setMedicineId(rs.getInt("medicine_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setSubtotal(rs.getBigDecimal("subtotal"));
                    item.setMedicineName(rs.getString("medicine_name"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PharmacyOrder> getAllOrders(String statusFilter) {
        List<PharmacyOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT po.*, u.name AS user_name, u.email AS user_email "
          + "FROM pharmacy_order po "
          + "JOIN user u ON po.user_id = u.user_id "
        );
        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE po.order_status = ? ");
            params.add(statusFilter.trim());
        }
        sql.append("ORDER BY po.created_at DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PharmacyOrder o = mapOrder(rs);
                    o.setUserName(rs.getString("user_name"));
                    o.setUserEmail(rs.getString("user_email"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateOrderStatus(int orderId, String orderStatus, String paymentStatus) {
        String sql = "UPDATE pharmacy_order SET order_status = ?, payment_status = ? WHERE order_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, orderStatus.trim().toUpperCase());
            ps.setString(2, paymentStatus.trim().toUpperCase());
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private PharmacyOrder mapOrder(ResultSet rs) throws Exception {
        PharmacyOrder o = new PharmacyOrder();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        int rxId = rs.getInt("prescription_id");
        if (!rs.wasNull()) {
            o.setPrescriptionId(rxId);
        }
        o.setOrderStatus(rs.getString("order_status"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        o.setUpdatedAt(rs.getTimestamp("updated_at"));
        return o;
    }
}
