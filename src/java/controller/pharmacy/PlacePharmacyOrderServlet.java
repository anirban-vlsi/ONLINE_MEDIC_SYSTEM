package controller.pharmacy;

import dao.finance.FinancialTransactionDAO;
import dao.pharmacy.MedicineDAO;
import dao.pharmacy.PharmacyOrderDAO;
import model.finance.FinancialTransaction;
import model.patient.User;
import model.pharmacy.Medicine;
import model.pharmacy.PharmacyOrder;
import model.pharmacy.PharmacyOrderItem;
import service.admin.ActivityLogService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PlacePharmacyOrderServlet", urlPatterns = {"/PlacePharmacyOrderServlet", "/modules/pharmacy/PlacePharmacyOrderServlet"})
public class PlacePharmacyOrderServlet extends HttpServlet {

    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final PharmacyOrderDAO orderDAO = new PharmacyOrderDAO();
    private final FinancialTransactionDAO financialDAO = new FinancialTransactionDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = getUserId(session);
        String userName = getUserName(session);

        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        String medicineIdStr = request.getParameter("medicineId");
        String quantityStr = request.getParameter("quantity");
        String paymentMethod = request.getParameter("paymentMethod");
        String rxIdStr = request.getParameter("prescriptionId");

        if (medicineIdStr == null || quantityStr == null) {
            response.sendRedirect(request.getContextPath() + "/PharmacyCatalogServlet?error="
                    + URLEncoder.encode("Missing medicine or quantity.", "UTF-8"));
            return;
        }

        try {
            int medId = Integer.parseInt(medicineIdStr.trim());
            int qty = Math.max(1, Integer.parseInt(quantityStr.trim()));
            Integer rxId = (rxIdStr != null && !rxIdStr.trim().isEmpty()) ? Integer.parseInt(rxIdStr.trim()) : null;

            Medicine med = medicineDAO.getMedicineById(medId);
            if (med == null || !"ACTIVE".equalsIgnoreCase(med.getModerationStatus())) {
                response.sendRedirect(request.getContextPath() + "/PharmacyCatalogServlet?error="
                        + URLEncoder.encode("Selected medicine is not available.", "UTF-8"));
                return;
            }

            if (med.getStockQuantity() < qty) {
                response.sendRedirect(request.getContextPath() + "/PharmacyCatalogServlet?error="
                        + URLEncoder.encode("Insufficient stock. Only " + med.getStockQuantity() + " units available.", "UTF-8"));
                return;
            }

            PharmacyOrderItem item = new PharmacyOrderItem();
            item.setMedicineId(medId);
            item.setQuantity(qty);
            item.setUnitPrice(med.getUnitPrice());
            BigDecimal itemTotal = med.getUnitPrice().multiply(BigDecimal.valueOf(qty));
            item.setSubtotal(itemTotal);

            List<PharmacyOrderItem> items = new ArrayList<>();
            items.add(item);

            PharmacyOrder order = new PharmacyOrder();
            order.setUserId(userId);
            order.setPrescriptionId(rxId);
            order.setTotalAmount(itemTotal);
            order.setPaymentMethod(paymentMethod != null ? paymentMethod.toUpperCase() : "UPI");
            order.setPaymentStatus("PAID");

            boolean placed = orderDAO.createOrder(order, items);
            if (placed) {
                // Record simulated financial transaction (10% platform commission)
                FinancialTransaction tx = financialDAO.processPharmacyPayment(
                        order.getOrderId(), userId, itemTotal, paymentMethod != null ? paymentMethod : "UPI");

                ActivityLogService.log(
                    String.valueOf(userId), userName, "PATIENT", "PHARMACY_ORDER",
                    "Placed & paid order #" + order.getOrderId() + " for " + med.getMedicineName() + " (Qty: " + qty + ") via " + paymentMethod,
                    "PHARMACY_ORDER", String.valueOf(order.getOrderId()), "SUCCESS", request.getRemoteAddr()
                );

                String msg = "Order #" + order.getOrderId() + " placed and paid successfully! Total: ₹" + itemTotal
                        + " (Transaction ID: " + (tx != null ? tx.getTransactionId() : "N/A") + ")";
                response.sendRedirect(request.getContextPath() + "/MyPharmacyOrdersServlet?success="
                        + URLEncoder.encode(msg, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/PharmacyCatalogServlet?error="
                        + URLEncoder.encode("Order failed. Insufficient stock or invalid item.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/PharmacyCatalogServlet?error="
                    + URLEncoder.encode("Error processing order: " + e.getMessage(), "UTF-8"));
        }
    }

    private int getUserId(HttpSession session) {
        if (session == null) return -1;
        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) return (Integer) uid;
        Object u = session.getAttribute("loggedInUser");
        if (u instanceof User) return ((User) u).getUserId();
        return -1;
    }

    private String getUserName(HttpSession session) {
        if (session == null) return "Patient";
        Object uname = session.getAttribute("userName");
        if (uname instanceof String) return (String) uname;
        Object u = session.getAttribute("loggedInUser");
        if (u instanceof User) return ((User) u).getName();
        return "Patient";
    }
}
