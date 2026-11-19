<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.prescription.Prescription" %>
<%@ page import="service.prescription.PrescriptionService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    List<Prescription> prescriptions = (List<Prescription>) request.getAttribute("prescriptions");
    if (prescriptions == null) {
        PrescriptionService prescriptionService = new PrescriptionService();
        prescriptions = prescriptionService.getPrescriptionsByUserId(userId);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Prescriptions - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Prescriptions</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientAppointmentsServlet">My Appointments</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientProfileServlet">My Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">My Digital Prescriptions</h1>
                    <p class="page-subtitle">Official doctor-signed medical prescriptions and dosage guidelines.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-outline">
                        &#128138; Order Medicines
                    </a>
                </div>
            </div>

            <% if (prescriptions == null || prescriptions.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128196;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem; margin-bottom: 8px;">No prescriptions found.</h2>
                    <p class="empty-state-text" style="max-width: 580px; margin: 0 auto 20px auto;">
                        After your doctor completes an appointment consultation, your electronic prescriptions will appear here.
                    </p>
                    <a href="<%= request.getContextPath() %>/PatientAppointmentsServlet" class="btn btn-secondary">
                        View Scheduled Appointments &rarr;
                    </a>
                </div>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 20px; margin-top: 14px;">
                    <% for (Prescription rx : prescriptions) { %>
                        <div class="card" style="border-left: 4px solid var(--primary-color); background: #fafafa; margin-bottom: 0;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                                <div>
                                    <div style="font-size: 1.15rem; font-weight: 700; color: var(--primary-color);">
                                        Prescription #RX-<%= rx.getPrescriptionId() %>
                                    </div>
                                    <div style="font-size: 0.88rem; color: var(--text-muted);">
                                        Issued by <strong>Dr. <%= rx.getDoctorName() %></strong> (<%= rx.getDoctorSpecialization() %> &bull; Lic: <%= rx.getDoctorRegNo() %>)
                                    </div>
                                </div>
                                <div style="text-align: right;">
                                    <span class="badge badge-verified" style="display: inline-block; margin-bottom: 4px;">&#10003; DOCTOR SIGNED</span>
                                    <div style="font-size: 0.85rem; color: var(--text-muted);">Date: <%= rx.getPrescribedDate() %></div>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 14px;">
                                <div>
                                    <span style="font-size: 0.82rem; text-transform: uppercase; color: var(--text-muted); font-weight: 600;">Patient:</span>
                                    <div style="font-weight: 600;"><%= rx.getPatientName() %></div>
                                </div>
                                <div>
                                    <span style="font-size: 0.82rem; text-transform: uppercase; color: var(--text-muted); font-weight: 600;">Diagnosis:</span>
                                    <div style="font-weight: 600; color: #b45309;"><%= rx.getDiagnosis() %></div>
                                </div>
                                <% if (rx.getFollowUpDate() != null) { %>
                                    <div>
                                        <span style="font-size: 0.82rem; text-transform: uppercase; color: var(--text-muted); font-weight: 600;">Follow-up Visit:</span>
                                        <div style="font-weight: 600; color: var(--primary-color);"><%= rx.getFollowUpDate() %></div>
                                    </div>
                                <% } %>
                            </div>

                            <div style="background: #ffffff; padding: 14px; border-radius: 6px; border: 1px solid var(--border-color); margin-bottom: 12px;">
                                <div style="font-size: 0.85rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-bottom: 6px;">
                                    &#128138; Prescribed Medications & Dosage:
                                </div>
                                <div style="font-size: 0.95rem; white-space: pre-wrap; font-family: monospace; color: #1e293b; background: #f8fafc; padding: 10px; border-radius: 4px;"><%= rx.getMedicines() %></div>

                                <% if (rx.getDosageInstructions() != null && !rx.getDosageInstructions().trim().isEmpty()) { %>
                                    <div style="font-size: 0.85rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-top: 10px; margin-bottom: 4px;">
                                        Instructions:
                                    </div>
                                    <div style="font-size: 0.92rem; color: var(--text-main);"><%= rx.getDosageInstructions() %></div>
                                <% } %>

                                <% if (rx.getNotes() != null && !rx.getNotes().trim().isEmpty()) { %>
                                    <div style="font-size: 0.85rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-top: 10px; margin-bottom: 4px;">
                                        Physician Remarks:
                                    </div>
                                    <div style="font-size: 0.92rem; color: var(--text-muted); font-style: italic;"><%= rx.getNotes() %></div>
                                <% } %>
                            </div>

                            <div style="text-align: right;">
                                <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet?rxId=<%= rx.getPrescriptionId() %>" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.88rem;">
                                    &#128722; Order Medications via Pharmacy &rarr;
                                </a>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/PatientAppointmentsServlet" class="btn btn-outline">
                    View Appointments &rarr;
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
