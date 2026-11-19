<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="model.appointment.Appointment" %>
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

    Appointment appt = (Appointment) request.getAttribute("appointment");
    if (appt == null) {
        response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issue Electronic Prescription - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Issue Prescription</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorAppointmentServlet">Appointments</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorPrescriptionServlet">Prescriptions</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">&#128392; Issue Clinical Prescription</h1>
                <p class="page-subtitle">Prescribe medications and record diagnoses for Appointment #<%= appt.getAppointmentId() %>.</p>
            </div>

            <!-- Patient Information Summary Card -->
            <div class="alert alert-info" style="margin-bottom: 24px;">
                <div style="font-size: 1.05rem; font-weight: 700; color: #0369a1; margin-bottom: 6px;">
                    Patient: <%= appt.getPatientName() %>
                </div>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 8px; font-size: 0.9rem;">
                    <div><strong>Gender:</strong> <%= appt.getPatientGender() %></div>
                    <div><strong>Relation:</strong> <%= appt.getPatientRelation() %></div>
                    <div><strong>Appointment Date:</strong> <%= appt.getAppointmentDate() %></div>
                    <div><strong>Consultation Reason:</strong> <%= (appt.getReason() != null && !appt.getReason().isEmpty()) ? appt.getReason() : "General" %></div>
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/DoctorPrescriptionServlet" method="post" id="rxForm">
                <input type="hidden" name="appointmentId" value="<%= appt.getAppointmentId() %>">
                <input type="hidden" name="patientId" value="<%= appt.getPatientId() %>">

                <!-- 1. Clinical Diagnosis -->
                <div class="form-group">
                    <label for="diagnosis" class="form-label">Clinical Diagnosis <span class="required">*</span></label>
                    <input type="text" name="diagnosis" id="diagnosis" class="form-control" placeholder="e.g. Acute Bronchitis, Hypertension Stage 1, Seasonal Allergic Rhinitis" required>
                </div>

                <!-- 2. Prescribed Medicines -->
                <div class="form-group">
                    <label for="medicines" class="form-label">Prescribed Medicines & Dosages <span class="required">*</span></label>
                    <textarea name="medicines" id="medicines" class="form-control" rows="4" placeholder="e.g.&#10;1. Paracetamol 500mg - 1 tablet three times daily after food for 5 days&#10;2. Cetirizine 10mg - 1 tablet at night for 3 days&#10;3. Omeprazole 20mg - 1 capsule once daily before breakfast" required></textarea>
                    <small style="color: var(--text-muted); font-size: 0.85rem; display: block; margin-top: 4px;">
                        List each medication clearly along with dosage timing.
                    </small>
                </div>

                <!-- 3. Dosage Instructions / Dietary Remarks -->
                <div class="form-group">
                    <label for="dosageInstructions" class="form-label">Patient Instructions & Precautions</label>
                    <textarea name="dosageInstructions" id="dosageInstructions" class="form-control" rows="2" placeholder="e.g. Drink plenty of warm fluids, rest adequately, avoid cold food."></textarea>
                </div>

                <!-- 4. Follow-up Date -->
                <div class="form-group">
                    <label for="followUpDate" class="form-label">Follow-up Visit Date (Optional)</label>
                    <input type="date" name="followUpDate" id="followUpDate" class="form-control">
                </div>

                <!-- 5. Physician Notes (Internal) -->
                <div class="form-group">
                    <label for="notes" class="form-label">Physician Remarks</label>
                    <textarea name="notes" id="notes" class="form-control" rows="2" placeholder="Additional observations or notes..."></textarea>
                </div>

                <!-- Submit / Actions -->
                <div class="btn-group" style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary">
                        &#10003; Sign & Issue Digital Prescription
                    </button>
                    <a href="<%= request.getContextPath() %>/DoctorAppointmentServlet" class="btn btn-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        var today = new Date().toISOString().split('T')[0];
        var followUp = document.getElementById("followUpDate");
        if (followUp) {
            followUp.min = today;
        }
        function confirmLogout() {
            return confirm("Are you sure you want to log out?");
        }
    </script>
</body>
</html>
