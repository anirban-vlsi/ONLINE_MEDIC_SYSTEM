<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.doctor.Doctor" %>
<%@ page import="model.doctor.DoctorAvailability" %>
<%@ page import="dao.doctor.DoctorAvailabilityDAO" %>
<%@ page import="service.doctor.DoctorService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String regNo = null;
    if (session != null) {
        regNo = (String) session.getAttribute("doctorRegistrationNumber");
        if (regNo == null) regNo = (String) session.getAttribute("doctorRegNo");
        if (regNo == null && session.getAttribute("loggedInDoctor") != null) {
            regNo = ((Doctor) session.getAttribute("loggedInDoctor")).getRegistrationNumber();
        }
    }

    if (regNo == null) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
        return;
    }

    DoctorService doctorService = new DoctorService();
    String authoritativeStatus = doctorService.getDoctorVerificationStatus(regNo);

    if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
        return;
    }

    DoctorAvailabilityDAO dao = new DoctorAvailabilityDAO();
    String activeMode = request.getParameter("visitMode");
    if (activeMode == null || activeMode.trim().isEmpty()) {
        activeMode = "ALL";
    }

    List<DoctorAvailability> schedule = dao.getAvailabilityByDoctorAndMode(regNo, activeMode);

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultation Schedule Availability - Doctor Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Consultation Schedules</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/DoctorAppointmentServlet">Appointments</a></li>
                <li><a href="${pageContext.request.contextPath}/DoctorProfileServlet">Profile</a></li>
                <li><a href="${pageContext.request.contextPath}/DoctorLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Manage Clinic & Home Visit Schedules</h1>
                <p class="page-subtitle">Configure separate working hours and daily patient capacity limits for Clinic and Home Visit consultations.</p>
            </div>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= msg %>
                </div>
            <% } %>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= error %>
                </div>
            <% } %>

            <!-- Add / Update Slot Form -->
            <div style="background: #f8fafc; padding: 22px; border-radius: 8px; border: 1px solid var(--border-color); margin-bottom: 28px;">
                <h2 style="font-size: 1.15rem; color: var(--primary-color); margin-bottom: 14px;">+ Add or Update Consultation Slot</h2>
                <form action="${pageContext.request.contextPath}/DoctorAvailabilityServlet" method="post" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; align-items: flex-end;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="visitMode" class="form-label">Visit Mode <span class="required">*</span></label>
                        <select name="visitMode" id="visitMode" class="form-control" required>
                            <option value="CLINIC">Clinic Consultation</option>
                            <option value="HOME_VISIT">Home Visit Consultation</option>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="dayOfWeek" class="form-label">Day of Week <span class="required">*</span></label>
                        <select name="dayOfWeek" id="dayOfWeek" class="form-control" required>
                            <option value="MONDAY">Monday</option>
                            <option value="TUESDAY">Tuesday</option>
                            <option value="WEDNESDAY">Wednesday</option>
                            <option value="THURSDAY">Thursday</option>
                            <option value="FRIDAY">Friday</option>
                            <option value="SATURDAY">Saturday</option>
                            <option value="SUNDAY">Sunday</option>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="startTime" class="form-label">Starts At <span class="required">*</span></label>
                        <input type="time" name="startTime" id="startTime" class="form-control" value="09:00" required>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="endTime" class="form-label">Ends At <span class="required">*</span></label>
                        <input type="time" name="endTime" id="endTime" class="form-control" value="17:00" required>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="maxPatients" class="form-label">Max Patients / Day <span class="required">*</span></label>
                        <input type="number" name="maxPatientsPerDay" id="maxPatients" class="form-control" value="20" min="1" max="100" required>
                    </div>

                    <div>
                        <button type="submit" class="btn btn-primary btn-block" style="padding: 10px;">
                            Save Schedule Slot
                        </button>
                    </div>
                </form>
            </div>

            <!-- Filter Tabs -->
            <div style="display: flex; gap: 10px; margin-bottom: 16px;">
                <a href="${pageContext.request.contextPath}/DoctorAvailabilityServlet?visitMode=ALL"
                   class="btn <%= "ALL".equalsIgnoreCase(activeMode) ? "btn-primary" : "btn-outline" %>" style="padding: 6px 14px; font-size: 0.88rem;">
                    All Schedules
                </a>
                <a href="${pageContext.request.contextPath}/DoctorAvailabilityServlet?visitMode=CLINIC"
                   class="btn <%= "CLINIC".equalsIgnoreCase(activeMode) ? "btn-primary" : "btn-outline" %>" style="padding: 6px 14px; font-size: 0.88rem;">
                    🏥 Clinic Consultations
                </a>
                <a href="${pageContext.request.contextPath}/DoctorAvailabilityServlet?visitMode=HOME_VISIT"
                   class="btn <%= "HOME_VISIT".equalsIgnoreCase(activeMode) ? "btn-primary" : "btn-outline" %>" style="padding: 6px 14px; font-size: 0.88rem;">
                    🏠 Home Visits
                </a>
            </div>

            <!-- Existing Schedule Table -->
            <h2 style="font-size: 1.15rem; color: var(--text-main); margin-bottom: 10px;">Active Consultation Hours</h2>
            <% if (schedule == null || schedule.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#9200;</div>
                    <p style="color: var(--text-muted);">No availability slots configured for this mode. Use the form above to add your working slots.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Visit Mode</th>
                                <th style="padding: 12px;">Day of Week</th>
                                <th style="padding: 12px;">Consultation Window</th>
                                <th style="padding: 12px;">Daily Patient Quota</th>
                                <th style="padding: 12px;">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (DoctorAvailability da : schedule) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px;">
                                        <% if ("HOME_VISIT".equalsIgnoreCase(da.getVisitMode())) { %>
                                            <span style="display: inline-block; padding: 3px 8px; border-radius: 4px; background: #fef3c7; color: #92400e; font-weight: 600; font-size: 0.85rem;">
                                                🏠 Home Visit
                                            </span>
                                        <% } else { %>
                                            <span style="display: inline-block; padding: 3px 8px; border-radius: 4px; background: #dbeafe; color: #1e40af; font-weight: 600; font-size: 0.85rem;">
                                                🏥 Clinic Visit
                                            </span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; font-weight: 700; color: var(--primary-color);"><%= da.getDayOfWeek() %></td>
                                    <td style="padding: 12px;"><%= da.getStartTime() %> &ndash; <%= da.getEndTime() %></td>
                                    <td style="padding: 12px;"><strong><%= da.getMaxPatientsPerDay() %></strong> patients / day</td>
                                    <td style="padding: 12px;">
                                        <% if (da.isActive()) { %>
                                            <span class="badge badge-verified">Active</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">Inactive</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Doctor Dashboard
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out?");
        }
    </script>
</body>
</html>
