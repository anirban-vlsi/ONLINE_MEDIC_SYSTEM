package controller.admin;

import dao.admin.AdminStatsDAO;
import model.admin.Admin;
import model.admin.ActivityLog;
import service.admin.AdminService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Displays activity logs for administrators.
 * URL mapping: /AdminActivityLogServlet
 */
@WebServlet(name = "AdminActivityLogServlet", urlPatterns = {"/AdminActivityLogServlet"})
public class AdminActivityLogServlet extends HttpServlet {
    private final AdminStatsDAO statsDAO = new AdminStatsDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        // Pagination parameters (optional)
        String startParam = request.getParameter("start");
        String limitParam = request.getParameter("limit");
        int start = 0;
        int limit = 25;
        try {
            if (startParam != null && !startParam.trim().isEmpty()) {
                start = Math.max(0, Integer.parseInt(startParam.trim()));
            }
        } catch (NumberFormatException ignored) {}
        try {
            if (limitParam != null && !limitParam.trim().isEmpty()) {
                limit = Math.min(100, Math.max(1, Integer.parseInt(limitParam.trim())));
            }
        } catch (NumberFormatException ignored) {}

        // Retrieve logs using ActivityLogDAO via service (direct call for simplicity)
        List<ActivityLog> logs = statsDAO.getRecentActivities(limit);
        request.setAttribute("admin", admin);
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/modules/admin/activity_logs.jsp").forward(request, response);
    }
}
