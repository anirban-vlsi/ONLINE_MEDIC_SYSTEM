package controller.admin;

import service.admin.AdminManagementService;
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
 * Handles administration of admin user accounts (list, create, role/status updates).
 * URL mapping: /AdminUserManagementServlet
 */
@WebServlet(name = "AdminUserManagementServlet", urlPatterns = {"/AdminUserManagementServlet"})
public class AdminUserManagementServlet extends HttpServlet {
    private final AdminManagementService adminService = new AdminManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        // List all admins (only visible to those with permission)
        List<Admin> admins = adminService.getAllAdmins(admin);
        request.setAttribute("admin", admin);
        request.setAttribute("admins", admins);
        request.getRequestDispatcher("/modules/admin/admin_management.jsp").forward(request, response);
    }

    // Simple POST handling for creating a new admin (role & status are set in service)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin actingAdmin = AdminService.getAuthenticatedAdmin(request);
        if (actingAdmin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String rawPassword = request.getParameter("password");
            String role = request.getParameter("role");
            Admin newAdmin = new Admin();
            newAdmin.setFullName(fullName);
            newAdmin.setEmail(email);
            newAdmin.setRole(role);
            // other fields (phone, etc.) can be set similarly if needed
            boolean ok = adminService.createAdministrator(newAdmin, rawPassword, actingAdmin,
                    request.getRemoteAddr());
            request.setAttribute("creationSuccess", ok);
        }
        // After handling POST, fall back to GET to refresh the view
        doGet(request, response);
    }
}
