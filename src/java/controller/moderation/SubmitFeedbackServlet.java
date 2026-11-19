package controller.moderation;

import dao.moderation.FeedbackReportDAO;
import model.doctor.Doctor;
import model.moderation.FeedbackReport;
import model.patient.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "SubmitFeedbackServlet", urlPatterns = {"/SubmitFeedbackServlet", "/modules/moderation/SubmitFeedbackServlet"})
public class SubmitFeedbackServlet extends HttpServlet {

    private final FeedbackReportDAO feedbackDAO = new FeedbackReportDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String reporterRole = null;
        String reporterId = null;

        // Check if patient
        Object userObj = session.getAttribute("loggedInUser");
        Object uidObj = session.getAttribute("userId");
        if (userObj instanceof User) {
            reporterRole = "PATIENT";
            reporterId = String.valueOf(((User) userObj).getUserId());
        } else if (uidObj instanceof Integer) {
            reporterRole = "PATIENT";
            reporterId = String.valueOf(uidObj);
        }

        // Check if doctor
        Object docObj = session.getAttribute("loggedInDoctor");
        Object regObj = session.getAttribute("doctorRegistrationNumber");
        if (docObj instanceof Doctor) {
            reporterRole = "DOCTOR";
            reporterId = ((Doctor) docObj).getRegistrationNumber();
        } else if (regObj instanceof String) {
            reporterRole = "DOCTOR";
            reporterId = (String) regObj;
        }

        if (reporterRole == null || reporterId == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String targetType = request.getParameter("targetType"); // DOCTOR, PATIENT, PHARMACY, AMBULANCE
        String targetId = request.getParameter("targetId");
        String refIdStr = request.getParameter("referenceId");
        String category = request.getParameter("reportCategory"); // FEEDBACK or COMPLAINT
        String ratingStr = request.getParameter("rating");
        String comments = request.getParameter("comments");
        String redirectUrl = request.getParameter("redirectUrl");

        if (targetType == null || targetId == null || comments == null || comments.trim().isEmpty()) {
            String backUrl = (redirectUrl != null && !redirectUrl.trim().isEmpty()) ? redirectUrl : request.getContextPath() + "/index.html";
            response.sendRedirect(backUrl + (backUrl.contains("?") ? "&" : "?") + "error="
                    + URLEncoder.encode("Please enter feedback comments.", "UTF-8"));
            return;
        }

        Integer refId = null;
        if (refIdStr != null && !refIdStr.trim().isEmpty()) {
            try { refId = Integer.parseInt(refIdStr.trim()); } catch (Exception ignored) {}
        }

        Integer rating = null;
        if (ratingStr != null && !ratingStr.trim().isEmpty()) {
            try { rating = Integer.parseInt(ratingStr.trim()); } catch (Exception ignored) {}
        }

        FeedbackReport report = new FeedbackReport();
        report.setReporterRole(reporterRole);
        report.setReporterId(reporterId);
        report.setTargetType(targetType.trim().toUpperCase());
        report.setTargetId(targetId.trim());
        report.setReferenceId(refId);
        report.setReportCategory(category != null ? category.trim().toUpperCase() : "FEEDBACK");
        report.setRating(rating);
        report.setComments(comments.trim());
        report.setStatus("OPEN");

        boolean ok = feedbackDAO.submitReport(report);

        String defaultRedirect = "PATIENT".equals(reporterRole)
                ? request.getContextPath() + "/modules/patient/patient_dashboard.jsp"
                : request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp";

        String targetRedirect = (redirectUrl != null && !redirectUrl.trim().isEmpty()) ? redirectUrl : defaultRedirect;
        String msg = ok ? "Thank you! Your " + report.getReportCategory().toLowerCase() + " has been submitted to the moderation team."
                        : "Failed to submit report. Please try again.";

        response.sendRedirect(targetRedirect + (targetRedirect.contains("?") ? "&" : "?")
                + (ok ? "success=" : "error=") + URLEncoder.encode(msg, "UTF-8"));
    }
}
