<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="model.doctor.Doctor" %>
<%@ page import="dao.doctor.DoctorDAO" %>

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

    DoctorDAO doctorDAO = new DoctorDAO();
    Doctor doctor = (Doctor) request.getAttribute("doctor");
    if (doctor == null) {
        doctor = doctorDAO.getDoctorByRegistrationNumber(regNo);
    }

    if (doctor == null || !"VERIFIED".equalsIgnoreCase(doctor.getVerificationStatus())) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
        return;
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    String[] specializations = {
        "General Physician", "Cardiologist", "Dermatologist", "Dentist", "ENT Specialist",
        "Ophthalmologist (Eye)", "Psychiatrist", "Orthopedic", "Pediatrician", "Neurologist"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Profile - Online Medical System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Doctor Profile</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/DoctorAppointmentServlet">Appointments</a></li>
                <li><a href="${pageContext.request.contextPath}/DoctorAvailabilityServlet">Schedule</a></li>
                <li>
                    <a href="${pageContext.request.contextPath}/DoctorLogoutServlet" class="btn btn-outline" style="padding: 6px 14px; color: #dc2626; border-color: #dc2626;" onclick="return confirmLogout();">
                        Logout
                    </a>
                </li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">

        <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <strong>&#10003; Success:</strong> <%= successMsg %>
            </div>
        <% } %>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error" style="margin-bottom: 20px;">
                <strong>&#9888; Error:</strong> <%= errorMsg %>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 18px;">
                    <div style="font-size: 2.5rem; color: #2563eb; background: #eff6ff; width: 68px; height: 68px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                        &#9877;
                    </div>
                    <div>
                        <h1 class="page-title" style="margin-bottom: 2px;"><%= doctor.getDoctorName() %></h1>
                        <p class="page-subtitle"><%= doctor.getSpecialization() %> &bull; <%= doctor.getCity() %></p>
                    </div>
                </div>
                <div>
                    <span class="badge badge-verified" style="font-size: 0.95rem; padding: 6px 14px;">&#10003; VERIFIED DOCTOR</span>
                </div>
            </div>

            <!-- Profile Edit Form (Requirement 2 & 3) -->
            <form action="${pageContext.request.contextPath}/DoctorProfileServlet" method="post" style="margin-top: 10px;">
                <h3 style="font-size: 1.15rem; margin-bottom: 14px; border-bottom: 1px solid var(--border-color); padding-bottom: 6px;">
                    &#9998; Edit Practice & Clinical Information
                </h3>

                <div class="form-group">
                    <label class="form-label">Full Doctor Name <span class="required">*</span></label>
                    <input type="text" name="doctor_name" class="form-control" value="<%= doctor.getDoctorName() %>" required>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Registration License (Immutable)</label>
                        <input type="text" class="form-control" value="<%= doctor.getRegistrationNumber() %>" disabled style="background: #f3f4f6;">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Professional Email (Immutable)</label>
                        <input type="email" class="form-control" value="<%= doctor.getEmail() %>" disabled style="background: #f3f4f6;">
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Specialization <span class="required">*</span></label>
                        <select name="specialization" class="form-control" required>
                            <% for (String spec : specializations) { %>
                                <option value="<%= spec %>" <%= spec.equalsIgnoreCase(doctor.getSpecialization()) ? "selected" : "" %>><%= spec %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Age (Years) <span class="required">*</span></label>
                        <input type="number" name="age" class="form-control" value="<%= doctor.getAge() %>" min="21" max="100" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Primary Practice City <span class="required">*</span></label>
                        <input type="text" name="city" class="form-control" value="<%= doctor.getCity() %>" placeholder="e.g. Bangalore" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Clinic Consultation Fee (₹) <span class="required">*</span></label>
                        <input type="number" name="consultation_fee" class="form-control" value="<%= doctor.getConsultationFee() %>" step="0.50" min="0" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Clinic / Chamber Street Address <span class="required">*</span></label>
                    <textarea name="address" rows="2" class="form-control" required><%= doctor.getAddress() %></textarea>
                </div>

                <!-- Home Visits Configuration Section -->
                <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; margin: 18px 0;">
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <input type="checkbox" id="homeVisitToggle" name="home_visit_available" value="true" <%= doctor.isHomeVisitAvailable() ? "checked" : "" %> onchange="toggleHomeVisitFields(this.checked)">
                        <label for="homeVisitToggle" style="font-weight: 600; cursor: pointer; color: #1e293b; margin: 0;">
                            &#127969; Enable Home Visit Consultations
                        </label>
                    </div>

                    <div id="homeVisitDetails" style="<%= doctor.isHomeVisitAvailable() ? "" : "display: none;" %>">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                            <div class="form-group">
                                <label class="form-label">Home Visit Consultation Fee (₹)</label>
                                <input type="number" name="home_visit_fee" class="form-control" value="<%= doctor.getHomeVisitFee() != null ? doctor.getHomeVisitFee() : "" %>" step="0.50" min="0" placeholder="e.g. 800.00">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Covered Service Cities / Localities</label>
                                <input type="text" name="service_areas" class="form-control" value="<%= doctor.getServiceAreas() != null ? doctor.getServiceAreas() : "" %>" placeholder="e.g. Bangalore, Indiranagar, Koramangala, Whitefield">
                            </div>
                        </div>
                        <div style="font-size: 0.82rem; color: var(--text-muted);">
                            Comma-separated list of cities or districts where you provide home consultations.
                        </div>
                    </div>
                </div>

                <div class="btn-group" style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary">
                        Save Doctor Profile Changes
                    </button>
                    <a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp" class="btn btn-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/common.js"></script>
    <script>
        function toggleHomeVisitFields(checked) {
            var container = document.getElementById("homeVisitDetails");
            container.style.display = checked ? "block" : "none";
        }
        function confirmLogout() {
            return confirm("Are you sure you want to log out of the Doctor Portal?");
        }
    </script>
</body>
</html>
