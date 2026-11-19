<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.patient.Patient" %>
<%@ page import="service.patient.PatientService" %>

<%
    // Prevent browser caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Check login session
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");

    // Fallback: If accessed directly rather than forwarded via PatientProfileServlet, load automatically
    if (patients == null) {
        int userId = (Integer) session.getAttribute("userId");
        PatientService ps = new PatientService();
        patients = ps.getPatientsByUserId(userId);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Patients - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| My Patients</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="add_patient.html" class="btn btn-primary" style="padding: 6px 14px;">+ Add New Patient</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 20px;">
                <div>
                    <h1 class="page-title">My Patients</h1>
                    <p class="page-subtitle">View the patient profiles associated with your account.</p>
                </div>
                <div>
                    <a href="add_patient.html" class="btn btn-primary">+ Add New Patient</a>
                </div>
            </div>

            <% if (patients == null || patients.isEmpty()) { %>
                <!-- Empty State Message -->
                <div class="empty-state">
                    <div class="empty-state-icon">&#128101;</div>
                    <h3 style="color: var(--primary-color); margin-bottom: 8px;">No Patient Profiles Found</h3>
                    <p class="empty-state-text">You have not added any patient profiles yet. You can register yourself or your family members to start managing health records.</p>
                    <a href="add_patient.html" class="btn btn-primary">+ Add Your First Patient Profile</a>
                </div>
            <% } else { %>
                <!-- Structured Patient Data Table (without patient_picture or separate patient status) -->
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Patient ID</th>
                                <th>Name</th>
                                <th>Relationship</th>
                                <th>Date of Birth</th>
                                <th>Gender</th>
                                <th>Mobile Number</th>
                                <th>Blood Group</th>
                                <th>Allergies</th>
                                <th>Medical Conditions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Patient patient : patients) { %>
                                <tr>
                                    <td><strong>#<%= patient.getPatientId() %></strong></td>
                                    <td><strong><%= patient.getPatientName() %></strong></td>
                                    <td><%= patient.getRelation() != null ? patient.getRelation() : "-" %></td>
                                    <td><%= patient.getDateOfBirth() != null ? patient.getDateOfBirth().toString() : "-" %></td>
                                    <td><%= patient.getGender() != null ? patient.getGender() : "-" %></td>
                                    <td><%= patient.getMobileNo() != null && !patient.getMobileNo().isEmpty() ? patient.getMobileNo() : "-" %></td>
                                    <td><span style="font-weight: 600; color: #b91c1c;"><%= patient.getBloodGroup() != null && !patient.getBloodGroup().isEmpty() ? patient.getBloodGroup() : "-" %></span></td>
                                    <td><%= patient.getAllergies() != null && !patient.getAllergies().isEmpty() ? patient.getAllergies() : "None" %></td>
                                    <td><%= patient.getMedicalConditions() != null && !patient.getMedicalConditions().isEmpty() ? patient.getMedicalConditions() : "None" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Dashboard
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
