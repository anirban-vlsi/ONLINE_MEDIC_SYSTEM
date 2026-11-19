<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.appointment.Appointment" %>
<%@ page import="model.patient.User" %>
<%@ page import="service.appointment.AppointmentService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || (session.getAttribute("userId") == null && session.getAttribute("loggedInUser") == null)) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = -1;
    if (session.getAttribute("userId") != null) {
        userId = (Integer) session.getAttribute("userId");
    } else if (session.getAttribute("loggedInUser") != null) {
        userId = ((User) session.getAttribute("loggedInUser")).getUserId();
    }

    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) {
        AppointmentService appointmentService = new AppointmentService();
        appointments = appointmentService.getAppointmentsByUserId(userId);
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    String infoMsg = request.getParameter("info");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Appointments - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Appointments</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientProfileServlet">My Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-primary" style="padding: 6px 12px; font-size: 0.88rem;">+ Book Appointment</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">My Appointments & Consultations</h1>
                    <p class="page-subtitle">Track your upcoming doctor visits, accept reschedule proposals, and review past visits.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-primary">
                        &#10133; Book New Appointment
                    </a>
                </div>
            </div>

            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= successMsg %>
                </div>
            <% } %>

            <% if (infoMsg != null && !infoMsg.trim().isEmpty()) { %>
                <div class="alert alert-info" style="margin-bottom: 20px;">
                    <strong>Notice:</strong> <%= infoMsg %>
                </div>
            <% } %>

            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= errorMsg %>
                </div>
            <% } %>

            <% if (appointments == null || appointments.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128197;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem; margin-bottom: 8px;">No appointments found.</h2>
                    <p class="empty-state-text" style="max-width: 580px; margin: 0 auto 20px auto;">
                        You have not scheduled any doctor consultations yet.
                    </p>
                    <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-primary">
                        Book Your First Consultation &rarr;
                    </a>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Appt ID</th>
                                <th style="padding: 12px;">Mode & Location</th>
                                <th style="padding: 12px;">Date & Time</th>
                                <th style="padding: 12px;">Patient</th>
                                <th style="padding: 12px;">Doctor & Specialty</th>
                                <th style="padding: 12px;">Fee & Payment</th>
                                <th style="padding: 12px;">Status & Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Appointment a : appointments) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= a.getAppointmentId() %></td>
                                    <td style="padding: 12px;">
                                        <% if ("HOME_VISIT".equalsIgnoreCase(a.getVisitType())) { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309; font-weight: 600;">&#127968; HOME VISIT</span>
                                            <% if (a.getPatientHomeAddress() != null) { %>
                                                <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px;">
                                                    <%= a.getPatientHomeAddress() %>, <%= a.getPatientCity() %>
                                                </div>
                                            <% } %>
                                        <% } else { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1; font-weight: 600;">&#127973; CLINIC</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong><%= a.getAppointmentDate() %></strong><br>
                                        <% if (a.getAppointmentTime() != null) { %>
                                            <span style="font-size: 0.85rem; color: #1e293b; font-weight: 600;"><%= a.getAppointmentTime() %></span>
                                        <% } else { %>
                                            <span style="font-size: 0.82rem; color: #b45309; font-style: italic;">&#9203; To be assigned by Doctor</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong><%= a.getPatientName() %></strong><br>
                                        <span style="font-size: 0.85rem; color: var(--text-muted);">(<%= a.getPatientRelation() %>)</span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong>Dr. <%= a.getDoctorName() %></strong><br>
                                        <span class="badge" style="background: #e0f2fe; color: #0369a1; font-size: 0.8rem;"><%= a.getDoctorSpecialization() %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong>&#8377;<%= a.getFeeCharged() != null ? a.getFeeCharged() : "500.00" %></strong><br>
                                        <span class="badge badge-verified" style="font-size: 0.75rem;"><%= a.getPaymentStatus() != null ? a.getPaymentStatus() : "PAID" %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("RESCHEDULE_PROPOSED".equalsIgnoreCase(a.getStatus())) { %>
                                            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 6px; padding: 10px; margin-bottom: 8px;">
                                                <span class="badge" style="background: #fef3c7; color: #b45309; font-weight: 700;">&#9201; DOCTOR RESCHEDULE PROPOSAL</span>
                                                <div style="font-size: 0.85rem; color: #78350f; margin-top: 6px;">
                                                    <strong>New Date:</strong> <%= a.getProposedDate() %><br>
                                                    <strong>New Time:</strong> <%= a.getProposedTime() %><br>
                                                    <% if (a.getDoctorRemarks() != null && !a.getDoctorRemarks().isEmpty()) { %>
                                                        <em>Doctor Remarks: "<%= a.getDoctorRemarks() %>"</em>
                                                    <% } %>
                                                </div>
                                                <div style="display: flex; gap: 6px; margin-top: 8px;">
                                                    <form action="<%= request.getContextPath() %>/PatientAppointmentsServlet" method="post" style="display:inline;">
                                                        <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                        <input type="hidden" name="action" value="ACCEPT_RESCHEDULE">
                                                        <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.8rem; background: #16a34a; border-color: #16a34a;">
                                                            &#10003; Accept New Time
                                                        </button>
                                                    </form>
                                                    <form action="<%= request.getContextPath() %>/PatientAppointmentsServlet" method="post" style="display:inline;" onsubmit="return confirm('Decline this proposal and cancel appointment?');">
                                                        <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                        <input type="hidden" name="action" value="CANCEL">
                                                        <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.8rem; color: #dc2626; border-color: #dc2626;">
                                                            &#10007; Decline & Cancel
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        <% } else if ("CONFIRMED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge badge-verified">&#10003; CONFIRMED</span>
                                        <% } else if ("COMPLETED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge" style="background: #dbeafe; color: #1e40af;">&#10003; COMPLETED</span>
                                        <% } else if ("CANCELLED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#10007; CANCELLED</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">&#9203; PENDING</span>
                                            <form action="<%= request.getContextPath() %>/PatientAppointmentsServlet" method="post" style="display:inline; margin-left: 6px;" onsubmit="return confirm('Cancel this appointment request?');">
                                                <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                <input type="hidden" name="action" value="CANCEL">
                                                <button type="submit" class="btn btn-outline" style="padding: 2px 8px; font-size: 0.75rem; color: #dc2626; border-color: #dc2626;">
                                                    Cancel
                                                </button>
                                            </form>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/PatientPrescriptionsServlet" class="btn btn-outline">
                    View My Prescriptions &rarr;
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out?");
        }
    </script>
</body>
</html>
