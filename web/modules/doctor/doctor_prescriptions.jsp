<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.prescription.Prescription" %>
<%@ page import="service.prescription.PrescriptionService" %>
<%@ page import="service.doctor.DoctorService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("doctorRegistrationNumber") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
        return;
    }

    String regNo = (String) session.getAttribute("doctorRegistrationNumber");
    DoctorService doctorService = new DoctorService();
    String authoritativeStatus = doctorService.getDoctorVerificationStatus(regNo);

    // Strict Lockout
    if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
        return;
    }

    List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
    if (prescriptions == null) {
        PrescriptionService prescriptionService = new PrescriptionService();
        prescriptions = prescriptionService.getPrescriptionsByDoctor(regNo);
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issued Prescriptions - Doctor Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Issued Prescriptions</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorAppointmentServlet">Appointments</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorAvailabilityServlet">Availability</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorProfileServlet">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Issued Prescriptions</h1>
                    <p class="page-subtitle">Historical records of clinical prescriptions signed by Dr. <%= session.getAttribute("doctorName") %>.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/DoctorAppointmentServlet" class="btn btn-primary">
                        View Appointments &rarr;
                    </a>
                </div>
            </div>

            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= successMsg %>
                </div>
            <% } %>

            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= errorMsg %>
                </div>
            <% } %>

            <% if (prescriptions == null || prescriptions.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128196;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem; margin-bottom: 8px;">No prescriptions issued yet.</h2>
                    <p class="empty-state-text" style="max-width: 580px; margin: 0 auto 20px auto;">
                        When you complete an appointment consultation and issue an electronic prescription, it will be catalogued here.
                    </p>
                    <a href="<%= request.getContextPath() %>/DoctorAppointmentServlet" class="btn btn-secondary">
                        View Patient Appointments &rarr;
                    </a>
                </div>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 16px; margin-top: 14px;">
                    <% for (Prescription rx : prescriptions) { %>
                        <div class="card" style="border-left: 4px solid var(--primary-color); background: #fafafa; margin-bottom: 0;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; margin-bottom: 10px;">
                                <div>
                                    <span style="font-weight: 700; color: var(--primary-color); font-size: 1.1rem;">#RX-<%= rx.getPrescriptionId() %></span>
                                    <span style="color: var(--text-muted); font-size: 0.9rem; margin-left: 8px;">(Appt #<%= rx.getAppointmentId() %>)</span>
                                    <div style="font-size: 0.95rem; margin-top: 4px;">
                                        Patient: <strong><%= rx.getPatientName() %></strong>
                                    </div>
                                </div>
                                <div style="text-align: right;">
                                    <span class="badge badge-verified">&#10003; SIGNED</span>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 4px;"><%= rx.getPrescribedDate() %></div>
                                </div>
                            </div>

                            <div style="margin-bottom: 8px;">
                                <span style="font-size: 0.82rem; text-transform: uppercase; color: var(--text-muted); font-weight: 600;">Diagnosis:</span>
                                <span style="font-weight: 600; color: #b45309; margin-left: 6px;"><%= rx.getDiagnosis() %></span>
                            </div>

                            <div style="background: #ffffff; padding: 12px; border-radius: 6px; border: 1px solid var(--border-color);">
                                <div style="font-size: 0.82rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-bottom: 4px;">Medicines:</div>
                                <div style="white-space: pre-wrap; font-family: monospace; font-size: 0.9rem; color: #1e293b;"><%= rx.getMedicines() %></div>
                            </div>

                            <% if (rx.getFollowUpDate() != null) { %>
                                <div style="margin-top: 8px; font-size: 0.85rem; color: var(--text-muted);">
                                    Follow-up scheduled: <strong><%= rx.getFollowUpDate() %></strong>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Doctor Dashboard
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out?");
        }
    </script>
</body>
</html>
