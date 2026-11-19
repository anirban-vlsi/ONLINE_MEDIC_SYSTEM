package controller.admin;

import service.admin.AdminService;
import service.admin.ActivityLogService;
import model.admin.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Handles admin logout.
 */
@WebServlet(name = "AdminLogoutServlet", urlPatterns = {"/AdminLogoutServlet"})
public class AdminLogoutServlet extends HttpServlet {
    private final ActivityLogService activityLogService = new ActivityLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer adminId = (Integer) session.getAttribute("adminId");
            String adminName = (String) session.getAttribute("adminName");
            String clientIp = request.getRemoteAddr();
            // Log logout activity
            activityLogService.log(adminId != null ? String.valueOf(adminId) : null,
                    adminName, "ADMIN", "ADMIN_LOGOUT", "Administrator logged out",
                    "ADMIN", adminId != null ? String.valueOf(adminId) : null, "SUCCESS", clientIp);
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/admin.html");
    }
}
