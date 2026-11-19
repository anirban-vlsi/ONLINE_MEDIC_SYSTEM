package controller.admin;

import dao.admin.AdminStatsDAO;
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
import java.util.HashMap;
import java.util.Map;

/**
 * Admin Dashboard – shows KPI statistics.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/AdminDashboardServlet"})
public class AdminDashboardServlet extends HttpServlet {
    private final AdminService adminService = new AdminService();
    private final AdminStatsDAO statsDAO = new AdminStatsDAO();
    private final ActivityLogService activityLogService = new ActivityLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/admin.html");
            return;
        }
        // Gather statistics using correct DAO method names
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalPatients", statsDAO.getTotalPatientsCount());
        stats.put("totalDoctors", statsDAO.getTotalDoctorsCount());
        stats.put("verifiedDoctors", statsDAO.getAuthorizedDoctorsCount());
        stats.put("pendingDoctors", statsDAO.getPendingDoctorsCount());
        stats.put("blockedPatients", statsDAO.getBlockedPatientsCount());
        stats.put("blockedDoctors", statsDAO.getBlockedDoctorsCount());
        // Optional stats – safe if tables exist
        stats.put("totalAppointments", statsDAO.getTotalAppointmentsCount());
        stats.put("totalTransactions", statsDAO.getTotalTransactionsCount());
        stats.put("revenue", statsDAO.getTotalRevenue());

        request.setAttribute("admin", admin);
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/modules/admin/admin_dashboard.jsp").forward(request, response);
    }
}
