package controller.pharmacist;

import dao.pharmacy.MedicineDAO;
import dao.pharmacy.PharmacyOrderDAO;
import dao.pharmacist.PharmacistDAO;
import model.pharmacy.Medicine;
import model.pharmacy.PharmacyOrder;
import model.pharmacist.Pharmacist;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "PharmacistDashboardServlet", urlPatterns = {"/PharmacistDashboardServlet", "/modules/pharmacist/PharmacistDashboardServlet"})
public class PharmacistDashboardServlet extends HttpServlet {

    private final PharmacistDAO pharmacistDAO = new PharmacistDAO();
    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final PharmacyOrderDAO orderDAO = new PharmacyOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pharmacist pharmacist = getAuthenticatedPharmacist(session);

        if (pharmacist == null) {
            response.sendRedirect(request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp");
            return;
        }

        String search = request.getParameter("search");
        String modFilter = request.getParameter("moderationFilter");

        List<Medicine> medicines = medicineDAO.getAllMedicinesForManagement(search, modFilter);
        List<PharmacyOrder> recentOrders = orderDAO.getAllOrders(null);
        BigDecimal earnings = pharmacistDAO.getTotalPharmacyEarnings();

        request.setAttribute("pharmacist", pharmacist);
        request.setAttribute("medicines", medicines);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("totalEarnings", earnings);

        request.getRequestDispatcher("/modules/pharmacist/pharmacist_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pharmacist pharmacist = getAuthenticatedPharmacist(session);

        if (pharmacist == null) {
            response.sendRedirect(request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("UPDATE_PROFILE".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String pharmacyName = request.getParameter("pharmacyName");

            boolean ok = pharmacistDAO.updateProfile(pharmacist.getPharmacistId(), fullName, phone, pharmacyName);
            if (ok) {
                Pharmacist refreshed = pharmacistDAO.getPharmacistById(pharmacist.getPharmacistId());
                session.setAttribute("loggedInPharmacist", refreshed);
                session.setAttribute("pharmacistName", refreshed.getFullName());
                session.setAttribute("pharmacyName", refreshed.getPharmacyName());
                response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet?success="
                        + URLEncoder.encode("Operator profile updated successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet?error="
                        + URLEncoder.encode("Failed to update profile.", "UTF-8"));
            }
            return;

        } else if ("SAVE_MEDICINE".equalsIgnoreCase(action)) {
            String medIdStr = request.getParameter("medicineId");
            String name = request.getParameter("medicineName");
            String category = request.getParameter("category");
            String manufacturer = request.getParameter("manufacturer");
            String priceStr = request.getParameter("unitPrice");
            String stockStr = request.getParameter("stockQuantity");
            String rxRequiredStr = request.getParameter("requiresPrescription");
            String description = request.getParameter("description");
            String moderationStatus = request.getParameter("moderationStatus");

            if (name == null || name.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet?error="
                        + URLEncoder.encode("Medicine name is required.", "UTF-8"));
                return;
            }

            int medId = 0;
            if (medIdStr != null && !medIdStr.trim().isEmpty()) {
                try { medId = Integer.parseInt(medIdStr.trim()); } catch (Exception ignored) {}
            }

            BigDecimal price = new BigDecimal("10.00");
            try { price = new BigDecimal(priceStr.trim()); } catch (Exception ignored) {}

            int stock = 0;
            try { stock = Integer.parseInt(stockStr.trim()); } catch (Exception ignored) {}

            boolean rxRequired = "on".equalsIgnoreCase(rxRequiredStr) || "true".equalsIgnoreCase(rxRequiredStr) || "1".equals(rxRequiredStr);

            Medicine m = new Medicine();
            m.setMedicineId(medId);
            m.setMedicineName(name.trim());
            m.setCategory(category != null ? category.trim() : "General");
            m.setManufacturer(manufacturer != null ? manufacturer.trim() : "");
            m.setUnitPrice(price);
            m.setStockQuantity(stock);
            m.setRequiresPrescription(rxRequired);
            m.setDescription(description != null ? description.trim() : "");
            m.setModerationStatus(moderationStatus != null ? moderationStatus.trim().toUpperCase() : "ACTIVE");

            boolean saved = medicineDAO.saveMedicine(m);
            String msg = saved ? (medId > 0 ? "Medicine updated successfully!" : "New medicine registered successfully!") : "Failed to save medicine.";
            response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet?" + (saved ? "success=" : "error=")
                    + URLEncoder.encode(msg, "UTF-8"));
            return;

        } else if ("UPDATE_ORDER_STATUS".equalsIgnoreCase(action)) {
            String orderIdStr = request.getParameter("orderId");
            String status = request.getParameter("orderStatus");

            if (orderIdStr != null && status != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr.trim());
                    orderDAO.updateOrderStatus(orderId, status.trim().toUpperCase(), null);
                    response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet?success="
                            + URLEncoder.encode("Order #" + orderId + " status updated to " + status.toUpperCase(), "UTF-8"));
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet");
    }

    private Pharmacist getAuthenticatedPharmacist(HttpSession session) {
        if (session == null) return null;
        Object p = session.getAttribute("loggedInPharmacist");
        if (p instanceof Pharmacist) return (Pharmacist) p;
        Object pid = session.getAttribute("pharmacistId");
        if (pid instanceof Integer) {
            return pharmacistDAO.getPharmacistById((Integer) pid);
        }
        return null;
    }
}
