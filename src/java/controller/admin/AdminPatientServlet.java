package controller.admin;

import model.admin.Admin;
import model.patient.User;
import service.admin.AdminManagementService;
import service.admin.AdminService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

/**
 * Handles administrative patient management.
 * URL mapping: /AdminPatientServlet
 */
@WebServlet(name = "AdminPatientServlet", urlPatterns = {"/AdminPatientServlet"})
public class AdminPatientServlet extends HttpServlet {
    private final AdminManagementService adminService = new AdminManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        // Optional search and status filter parameters
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        List<User> patients = adminService.getPatients(search, status);
        request.setAttribute("admin", admin);
        request.setAttribute("patients", patients);
        request.getRequestDispatcher("/modules/admin/patient_management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        String reason = request.getParameter("reason");
        String clientIp = request.getRemoteAddr();

        if (userIdStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/AdminPatientServlet?error="
                    + URLEncoder.encode("Missing required parameters.", "UTF-8"));
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/AdminPatientServlet?error="
                    + URLEncoder.encode("Invalid patient ID format.", "UTF-8"));
            return;
        }

        boolean success = false;
        String msg = "";

        if ("block".equalsIgnoreCase(action)) {
            success = adminService.setPatientBlockStatus(userId, true, admin, reason, clientIp);
            msg = success ? "Patient successfully blocked." : "Failed to block patient or insufficient permissions.";
        } else if ("unblock".equalsIgnoreCase(action)) {
            success = adminService.setPatientBlockStatus(userId, false, admin, reason, clientIp);
            msg = success ? "Patient successfully unblocked." : "Failed to unblock patient or insufficient permissions.";
        } else if ("delete".equalsIgnoreCase(action)) {
            success = adminService.removePatient(userId, admin, reason, clientIp);
            msg = success ? "Patient account permanently deleted." : "Failed to delete patient (Super Admin required).";
        } else {
            msg = "Unknown action requested.";
        }

        String param = success ? "msg=" : "error=";
        response.sendRedirect(request.getContextPath() + "/AdminPatientServlet?" + param + URLEncoder.encode(msg, "UTF-8"));
    }
}
