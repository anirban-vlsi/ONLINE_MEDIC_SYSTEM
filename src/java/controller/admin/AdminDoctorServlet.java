package controller.admin;

import service.admin.AdminManagementService;
import model.doctor.Doctor;
import model.admin.Admin;
import service.admin.AdminService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Handles administrative doctor management.
 * URL mapping: /AdminDoctorServlet
 */
@WebServlet(name = "AdminDoctorServlet", urlPatterns = {"/AdminDoctorServlet"})
public class AdminDoctorServlet extends HttpServlet {
    private final AdminManagementService adminService = new AdminManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        List<Doctor> doctors = adminService.getDoctors(search, status);
        request.setAttribute("admin", admin);
        request.setAttribute("doctors", doctors);
        request.getRequestDispatcher("/modules/admin/doctor_management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }

        String action = request.getParameter("action");
        String regNo = request.getParameter("registrationNumber");
        String reason = request.getParameter("reason");
        String clientIp = request.getRemoteAddr();

        if (regNo == null || regNo.trim().isEmpty() || action == null) {
            response.sendRedirect(request.getContextPath() + "/AdminDoctorServlet?error="
                    + java.net.URLEncoder.encode("Missing required doctor registration number or action.", "UTF-8"));
            return;
        }

        boolean success = false;
        String msg = "";

        if ("verify".equalsIgnoreCase(action) || "approve".equalsIgnoreCase(action)) {
            success = adminService.authorizeDoctor(regNo.trim(), true, admin, reason, clientIp);
            msg = success ? "Doctor successfully verified and approved." : "Failed to approve doctor or insufficient permissions.";
        } else if ("reject".equalsIgnoreCase(action)) {
            success = adminService.authorizeDoctor(regNo.trim(), false, admin, reason, clientIp);
            msg = success ? "Doctor registration rejected." : "Failed to reject doctor or insufficient permissions.";
        } else if ("block".equalsIgnoreCase(action)) {
            success = adminService.setDoctorBlockStatus(regNo.trim(), true, admin, reason, clientIp);
            msg = success ? "Doctor account blocked." : "Failed to block doctor or insufficient permissions.";
        } else if ("unblock".equalsIgnoreCase(action)) {
            success = adminService.setDoctorBlockStatus(regNo.trim(), false, admin, reason, clientIp);
            msg = success ? "Doctor account unblocked and restored to VERIFIED." : "Failed to unblock doctor or insufficient permissions.";
        } else {
            msg = "Unknown action requested.";
        }

        String param = success ? "msg=" : "error=";
        response.sendRedirect(request.getContextPath() + "/AdminDoctorServlet?" + param + java.net.URLEncoder.encode(msg, "UTF-8"));
    }
}
