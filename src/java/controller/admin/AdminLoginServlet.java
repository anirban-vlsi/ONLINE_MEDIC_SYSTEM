package controller.admin;

import model.admin.Admin;
import service.admin.AdminService;
import service.admin.ActivityLogService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminLoginServlet", urlPatterns = {"/AdminLoginServlet"})
public class AdminLoginServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();
    private final ActivityLogService activityLogService = new ActivityLogService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String clientIp = request.getRemoteAddr();

        Admin admin = adminService.authenticateAdmin(email, password);
        if (admin != null && admin.isActive()) {
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = request.getSession(true);

            // Standardized session attribute key
            session.setAttribute("loggedInAdmin", admin);

            // Backwards compatibility attributes
            session.setAttribute("adminId", admin.getAdminId());
            session.setAttribute("adminName", admin.getFullName());
            session.setAttribute("adminEmail", admin.getEmail());
            session.setAttribute("adminRole", admin.getRole());
            session.setMaxInactiveInterval(60 * 60); // 60 minutes

            activityLogService.log(String.valueOf(admin.getAdminId()), admin.getFullName(), "ADMIN",
                    "ADMIN_LOGIN", "Administrator logged in", "ADMIN", String.valueOf(admin.getAdminId()), "SUCCESS", clientIp);

            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } else {
            activityLogService.log(null, null, "ADMIN", "ADMIN_LOGIN_FAILED",
                    "Failed admin login attempt for email: " + (email != null ? email : "null"),
                    "ADMIN", null, "FAILURE", clientIp);
            request.setAttribute("error", "Invalid credentials or account inactive.");
            request.getRequestDispatcher("/modules/admin/admin_login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/modules/admin/admin_login.jsp").forward(request, response);
    }
}
