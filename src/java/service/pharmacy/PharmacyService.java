package service.pharmacy;

import dao.pharmacy.MedicineDAO;
import dao.pharmacy.PharmacyOrderDAO;
import model.pharmacy.Medicine;
import model.pharmacy.PharmacyOrder;
import model.pharmacy.PharmacyOrderItem;

import java.math.BigDecimal;
import java.util.List;

public class PharmacyService {

    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final PharmacyOrderDAO orderDAO = new PharmacyOrderDAO();

    public List<Medicine> getAllActiveMedicines() {
        return medicineDAO.getAllActiveMedicines();
    }

    public List<Medicine> searchMedicines(String query, String category) {
        return medicineDAO.searchMedicines(query, category);
    }

    public List<String> getCategories() {
        return medicineDAO.getCategories();
    }

    public Medicine getMedicineById(int id) {
        return medicineDAO.getMedicineById(id);
    }

    public boolean placeOrder(int userId, Integer prescriptionId, String paymentMethod, List<PharmacyOrderItem> items) {
        if (userId <= 0 || items == null || items.isEmpty()) {
            return false;
        }

        BigDecimal total = BigDecimal.ZERO;
        for (PharmacyOrderItem item : items) {
            Medicine med = medicineDAO.getMedicineById(item.getMedicineId());
            if (med == null || med.getStockQuantity() < item.getQuantity()) {
                return false; // Unavailable or insufficient stock
            }
            item.setUnitPrice(med.getUnitPrice());
            BigDecimal itemSubtotal = med.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            item.setSubtotal(itemSubtotal);
            total = total.add(itemSubtotal);
        }

        PharmacyOrder order = new PharmacyOrder();
        order.setUserId(userId);
        order.setPrescriptionId(prescriptionId);
        order.setTotalAmount(total);
        order.setPaymentMethod(paymentMethod != null ? paymentMethod : "CASH");
        order.setPaymentStatus("CASH".equalsIgnoreCase(paymentMethod) ? "PENDING" : "PAID");

        return orderDAO.createOrder(order, items);
    }

    public List<PharmacyOrder> getOrdersByUserId(int userId) {
        return orderDAO.getOrdersByUserId(userId);
    }

    public PharmacyOrder getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    public List<PharmacyOrder> getAllOrders(String statusFilter) {
        return orderDAO.getAllOrders(statusFilter);
    }

    public boolean updateOrderStatus(int orderId, String orderStatus, String paymentStatus) {
        return orderDAO.updateOrderStatus(orderId, orderStatus, paymentStatus);
    }
}
