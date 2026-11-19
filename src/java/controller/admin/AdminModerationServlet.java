package controller.admin;

import dao.emergency.AmbulanceDAO;
import dao.moderation.FeedbackReportDAO;
import dao.pharmacy.MedicineDAO;
import model.admin.Admin;
import model.emergency.Ambulance;
import model.moderation.FeedbackReport;
import model.pharmacy.Medicine;
import service.admin.ActivityLogService;
import service.admin.AdminService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "AdminModerationServlet", urlPatterns = {"/AdminModerationServlet", "/modules/admin/AdminModerationServlet"})
public class AdminModerationServlet extends HttpServlet {

    private final FeedbackReportDAO feedbackDAO = new FeedbackReportDAO();
    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();
    private final ActivityLogService logService = new ActivityLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/modules/admin/admin_login.jsp");
            return;
        }

        String statusFilter = request.getParameter("status");
        String targetFilter = request.getParameter("targetType");
        String medSearch = request.getParameter("medSearch");
        String ambSearch = request.getParameter("ambSearch");

        List<FeedbackReport> reports = feedbackDAO.getAllReports(statusFilter, targetFilter);
        List<Medicine> medicines = medicineDAO.getAllMedicinesForManagement(medSearch, null);
        List<Ambulance> ambulances = ambulanceDAO.getAllAmbulances();

        request.setAttribute("admin", admin);
        request.setAttribute("reports", reports);
        request.setAttribute("medicines", medicines);
        request.setAttribute("ambulances", ambulances);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
        request.setAttribute("targetFilter", targetFilter != null ? targetFilter : "ALL");

        request.getRequestDispatcher("/modules/admin/admin_moderation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/modules/admin/admin_login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String clientIp = request.getRemoteAddr();

        if ("UPDATE_REPORT_STATUS".equalsIgnoreCase(action)) {
            String reportIdStr = request.getParameter("reportId");
            String newStatus = request.getParameter("status"); // OPEN, REVIEWED, ACTION_TAKEN

            if (reportIdStr != null && newStatus != null) {
                int reportId = Integer.parseInt(reportIdStr.trim());
                feedbackDAO.updateReportStatus(reportId, newStatus);
                logService.log(String.valueOf(admin.getAdminId()), admin.getFullName(), "ADMIN", "REPORT_STATUS_UPDATE",
                        "Updated Feedback Report #" + reportId + " status to " + newStatus, "FEEDBACK_REPORT",
                        String.valueOf(reportId), "SUCCESS", clientIp);
                response.sendRedirect(request.getContextPath() + "/AdminModerationServlet?success="
                        + URLEncoder.encode("Report #" + reportId + " marked as " + newStatus, "UTF-8"));
                return;
            }

        } else if ("TOGGLE_MEDICINE".equalsIgnoreCase(action)) {
            String medIdStr = request.getParameter("medicineId");
            String targetStatus = request.getParameter("targetStatus"); // ACTIVE or BLOCKED

            if (medIdStr != null && targetStatus != null) {
                int medId = Integer.parseInt(medIdStr.trim());
                medicineDAO.updateModerationStatus(medId, targetStatus);
                logService.log(String.valueOf(admin.getAdminId()), admin.getFullName(), "ADMIN", "MEDICINE_MODERATION",
                        "Set Medicine #" + medId + " moderation status to " + targetStatus, "MEDICINE",
                        String.valueOf(medId), "SUCCESS", clientIp);
                response.sendRedirect(request.getContextPath() + "/AdminModerationServlet?success="
                        + URLEncoder.encode("Medicine #" + medId + " status updated to " + targetStatus, "UTF-8"));
                return;
            }

        } else if ("TOGGLE_AMBULANCE".equalsIgnoreCase(action)) {
            String ambIdStr = request.getParameter("ambulanceId");
            String targetStatus = request.getParameter("targetStatus"); // ACTIVE or BLOCKED

            if (ambIdStr != null && targetStatus != null) {
                int ambId = Integer.parseInt(ambIdStr.trim());
                ambulanceDAO.updateModerationStatus(ambId, targetStatus);
                logService.log(String.valueOf(admin.getAdminId()), admin.getFullName(), "ADMIN", "AMBULANCE_MODERATION",
                        "Set Ambulance #" + ambId + " moderation status to " + targetStatus, "AMBULANCE",
                        String.valueOf(ambId), "SUCCESS", clientIp);
                response.sendRedirect(request.getContextPath() + "/AdminModerationServlet?success="
                        + URLEncoder.encode("Ambulance #" + ambId + " status updated to " + targetStatus, "UTF-8"));
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/AdminModerationServlet");
    }
}
