<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.patient.Patient" %>
<%@ page import="dao.patient.PatientDAO" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    if (patients == null) {
        PatientDAO patientDAO = new PatientDAO();
        patients = patientDAO.getPatientsByUserId(userId);
    }

    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Emergency Medical Assistance & Ambulance - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar" style="background: #991b1b; color: white;">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand" style="color: white;">
            <span class="cross-icon" style="color: #fecaca;">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: #fecaca; margin-left: 8px;">| 24/7 Emergency Services</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" style="color: white;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/EmergencyTrackingServlet" style="color: #fef08a; font-weight: 700;">&#128657; Track Ambulance</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #fecaca;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <!-- Emergency Hotline Callout Banner -->
        <div class="alert" style="background: #fee2e2; border: 2px solid #ef4444; color: #991b1b; margin-bottom: 24px; padding: 18px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h2 style="font-size: 1.3rem; margin-bottom: 4px; color: #991b1b;">&#128680; Critical Medical Emergency?</h2>
                    <p style="margin: 0; font-size: 0.95rem;">For immediate life-threatening situations, call national emergency hotlines directly.</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="tel:108" class="btn" style="background: #dc2626; color: white; font-size: 1.1rem; font-weight: 700; padding: 10px 18px;">
                        &#128222; Call 108
                    </a>
                    <a href="tel:112" class="btn" style="background: #1e293b; color: white; font-size: 1.1rem; font-weight: 700; padding: 10px 18px;">
                        &#128222; Call 112
                    </a>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h1 class="page-title">&#128657; Request Immediate Ambulance Dispatch</h1>
                <p class="page-subtitle">Submit your emergency details for prompt response from our active hospital vehicle fleet.</p>
            </div>

            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= errorMsg %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/EmergencyRequestServlet" method="post" id="emergencyForm">
                <!-- 1. Patient Selection -->
                <div class="form-group">
                    <label for="patientId" class="form-label">Patient in Need (Optional)</label>
                    <select name="patientId" id="patientId" class="form-control">
                        <option value="">-- Self / Unknown Emergency Case --</option>
                        <% if (patients != null) {
                            for (Patient p : patients) { %>
                                <option value="<%= p.getPatientId() %>"><%= p.getPatientName() %> (<%= p.getRelation() %>)</option>
                        <%  }
                        } %>
                    </select>
                </div>

                <!-- 2. Emergency Type -->
                <div class="form-group">
                    <label for="emergencyType" class="form-label">Type of Medical Emergency <span class="required">*</span></label>
                    <select name="emergencyType" id="emergencyType" class="form-control" required>
                        <option value="GENERAL">General Medical Emergency</option>
                        <option value="CARDIAC">Cardiac Arrest / Chest Pain</option>
                        <option value="ACCIDENT">Road / Physical Trauma Accident</option>
                        <option value="MATERNITY">Labor / Maternity Emergency</option>
                        <option value="RESPIRATORY">Severe Breathing Distress</option>
                        <option value="STROKE">Suspected Stroke / Unconscious</option>
                        <option value="OTHER">Other Emergency</option>
                    </select>
                </div>

                <!-- 3. Priority -->
                <div class="form-group">
                    <label for="priority" class="form-label">Severity Level <span class="required">*</span></label>
                    <select name="priority" id="priority" class="form-control" required>
                        <option value="CRITICAL">Critical &bull; Immediate ICU response needed</option>
                        <option value="HIGH" selected>High &bull; Advanced Life Support</option>
                        <option value="MEDIUM">Medium &bull; Standard ambulance transfer</option>
                    </select>
                </div>

                <!-- 4. Pickup Address -->
                <div class="form-group">
                    <label for="pickupAddress" class="form-label">Pickup Location / Exact Address <span class="required">*</span></label>
                    <textarea name="pickupAddress" id="pickupAddress" class="form-control" rows="3" placeholder="Enter landmark, street name, house number, area, and city..." required></textarea>
                </div>

                <!-- 5. Contact Phone -->
                <div class="form-group">
                    <label for="contactPhone" class="form-label">Caller Phone Number <span class="required">*</span></label>
                    <input type="tel" name="contactPhone" id="contactPhone" class="form-control" placeholder="e.g. 9876543210" required>
                </div>

                <!-- 6. Additional Situation Notes -->
                <div class="form-group">
                    <label for="description" class="form-label">Situation Description (Brief)</label>
                    <textarea name="description" id="description" class="form-control" rows="2" placeholder="State patient's current symptoms or situation (e.g., patient is conscious, bleeding, breathing difficulty)..."></textarea>
                </div>

                <!-- Dispatch Button -->
                <div style="margin-top: 24px;">
                    <button type="submit" class="btn btn-block" style="background: #dc2626; color: white; font-size: 1.15rem; font-weight: 700; padding: 14px;">
                        &#128680; Dispatch Nearest Ambulance Now
                    </button>
                </div>
            </form>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/EmergencyTrackingServlet" class="btn btn-outline">
                    View Dispatched Requests &rarr;
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Emergency Services Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
