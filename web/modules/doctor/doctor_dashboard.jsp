<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="service.doctor.DoctorService" %>
<%@ page import="model.doctor.Doctor" %>
<%@ page import="dao.doctor.DoctorDAO" %>
<%@ page import="java.math.BigDecimal" %>

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
    DoctorDAO doctorDAO = new DoctorDAO();
    String authoritativeStatus = doctorService.getDoctorVerificationStatus(regNo);
    if (authoritativeStatus == null) {
        authoritativeStatus = "NOT VERIFIED";
    }

    boolean isVerified = "VERIFIED".equalsIgnoreCase(authoritativeStatus);
    boolean isPending = "NOT VERIFIED".equalsIgnoreCase(authoritativeStatus) || "PENDING".equalsIgnoreCase(authoritativeStatus);
    boolean isRejected = "REJECTED".equalsIgnoreCase(authoritativeStatus);
    boolean isBlocked = "BLOCKED".equalsIgnoreCase(authoritativeStatus);

    Doctor doctor = doctorDAO.getDoctorByRegistrationNumber(regNo);

    String doctorName = (doctor != null && doctor.getDoctorName() != null) ? doctor.getDoctorName() : "Doctor";
    String email = (doctor != null && doctor.getEmail() != null) ? doctor.getEmail() : "";
    String specialization = (doctor != null && doctor.getSpecialization() != null) ? doctor.getSpecialization() : "";
    String city = (doctor != null && doctor.getCity() != null) ? doctor.getCity() : "";

    BigDecimal totalEarnings = doctorDAO.getTotalEarnings(regNo);

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Clinical Dashboard - Online Medical System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Doctor Portal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><span style="color: var(--text-main); font-weight: 600;">&#9877; <%= doctorName %></span></li>
                <li><a href="${pageContext.request.contextPath}/DoctorProfileServlet">My Profile</a></li>
                <li>
                    <a href="${pageContext.request.contextPath}/DoctorLogoutServlet" class="btn btn-outline" style="padding: 6px 14px; color: #dc2626; border-color: #dc2626;" onclick="return confirmLogout();">
                        Logout
                    </a>
                </li>
            </ul>
        </nav>
    </header>

    <main class="main-content">

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

        <!-- Overview & Verification Summary Card -->
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 18px;">
                    <div style="font-size: 2.8rem; color: #2563eb; background: #eff6ff; width: 75px; height: 75px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                        &#9877;
                    </div>
                    <div>
                        <h1 class="page-title" style="margin-bottom: 4px;">Welcome, <%= doctorName %>!</h1>
                        <p class="page-subtitle">
                            <strong>License:</strong> <%= regNo %> &bull;
                            <strong>Specialty:</strong> <%= specialization %> &bull;
                            <strong>City:</strong> <%= city %>
                        </p>
                    </div>
                </div>
                <div style="text-align: right;">
                    <div style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 4px;">Account Status</div>
                    <% if (isVerified) { %>
                        <span class="badge badge-verified">&#10003; VERIFIED DOCTOR</span>
                    <% } else if (isRejected) { %>
                        <span class="badge badge-unverified" style="background:#fee2e2; color:#dc2626;">&#10007; REJECTED</span>
                    <% } else if (isBlocked) { %>
                        <span class="badge badge-unverified" style="background:#fee2e2; color:#dc2626;">&#128274; BLOCKED</span>
                    <% } else { %>
                        <span class="badge badge-unverified" style="background:#fef3c7; color:#d97706;">&#9888; PENDING VERIFICATION</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Strict Lockout Notice: Displayed when doctor is NOT VERIFIED, REJECTED, or BLOCKED -->
        <% if (!isVerified) { %>
            <div class="alert alert-warning" style="margin-bottom: 24px; border-left: 5px solid #d97706; padding: 20px;">
                <div style="display: flex; gap: 16px; align-items: flex-start;">
                    <div style="font-size: 2rem;">&#128274;</div>
                    <div>
                        <% if (isRejected) { %>
                            <h3 style="color: #991b1b; font-size: 1.25rem; margin-bottom: 6px;">Application Rejected</h3>
                            <p style="color: #7f1d1d; margin: 0; line-height: 1.5;">
                                Your medical registration application (License: <strong><%= regNo %></strong>) was reviewed and rejected by hospital administration.
                            </p>
                        <% } else if (isBlocked) { %>
                            <h3 style="color: #991b1b; font-size: 1.25rem; margin-bottom: 6px;">Account Suspended / Blocked</h3>
                            <p style="color: #7f1d1d; margin: 0; line-height: 1.5;">
                                Your doctor account has been suspended by hospital administration. All clinical access has been temporarily revoked.
                            </p>
                        <% } else { %>
                            <h3 style="color: #92400e; font-size: 1.25rem; margin-bottom: 6px;">Pending Administrator Verification</h3>
                            <p style="color: #78350f; margin: 0; line-height: 1.5;">
                                Your doctor profile with Medical Registration Number <strong><%= regNo %></strong> is currently awaiting administrative credential review.
                                In compliance with medical governance rules, <strong>access to clinical features (appointments, prescriptions, patient health records, and schedule availability) is strictly restricted</strong> until an administrator verifies and approves your account.
                            </p>
                        <% } %>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Requirement 4: Financial Net Earnings Summary -->
        <% if (isVerified) { %>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px;">
                <div class="card" style="margin-bottom: 0; border-left: 4px solid #10b981; padding: 18px;">
                    <div style="font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; font-weight: 600;">Net Consultation Earnings</div>
                    <div style="font-size: 1.8rem; font-weight: 800; color: #047857; margin-top: 4px;">
                        ₹<%= totalEarnings %>
                    </div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 2px;">
                        85% Provider Payout on completed appointments (15% Admin Commission deducted).
                    </div>
                </div>

                <div class="card" style="margin-bottom: 0; border-left: 4px solid #3b82f6; padding: 18px;">
                    <div style="font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; font-weight: 600;">Consultation Fee Rates</div>
                    <div style="font-size: 1.2rem; font-weight: 700; color: #1e40af; margin-top: 6px;">
                        Clinic: ₹<%= doctor != null ? doctor.getConsultationFee() : "500" %> &bull;
                        Home: <%= (doctor != null && doctor.isHomeVisitAvailable()) ? ("₹" + doctor.getHomeVisitFee()) : "Disabled" %>
                    </div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 2px;">
                        Configure via <a href="${pageContext.request.contextPath}/DoctorProfileServlet" style="color: #2563eb;">My Profile</a>.
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Dashboard Navigation Services Grid -->
        <div class="dashboard-grid">

            <!-- 1. My Appointments -->
            <div class="dash-card" style="<%= !isVerified ? "opacity: 0.65; background: #fafafa;" : "" %>">
                <div>
                    <div class="dash-card-icon">&#128197;</div>
                    <h2 class="dash-card-title">My Appointments</h2>
                    <p class="dash-card-desc">
                        Review scheduled patient appointments, manage calendar time slots, propose reschedules, and complete visits.
                    </p>
                </div>
                <% if (isVerified) { %>
                    <a href="${pageContext.request.contextPath}/DoctorAppointmentServlet" class="btn btn-secondary btn-block">
                        View Appointments &rarr;
                    </a>
                <% } else { %>
                    <button type="button" class="btn btn-secondary btn-block" disabled style="cursor: not-allowed;">
                        &#128274; Locked &bull; Pending Verification
                    </button>
                <% } %>
            </div>

            <!-- 2. My Prescriptions -->
            <div class="dash-card" style="<%= !isVerified ? "opacity: 0.65; background: #fafafa;" : "" %>">
                <div>
                    <div class="dash-card-icon">&#128196;</div>
                    <h2 class="dash-card-title">My Prescriptions</h2>
                    <p class="dash-card-desc">
                        Issue electronic doctor-signed prescriptions, recommend pharmaceutical dosages, and write dietary notes.
                    </p>
                </div>
                <% if (isVerified) { %>
                    <a href="${pageContext.request.contextPath}/DoctorPrescriptionServlet" class="btn btn-secondary btn-block">
                        Issue Prescriptions &rarr;
                    </a>
                <% } else { %>
                    <button type="button" class="btn btn-secondary btn-block" disabled style="cursor: not-allowed;">
                        &#128274; Locked &bull; Pending Verification
                    </button>
                <% } %>
            </div>

            <!-- 3. Schedule Availability -->
            <div class="dash-card" style="<%= !isVerified ? "opacity: 0.65; background: #fafafa;" : "" %>">
                <div>
                    <div class="dash-card-icon">&#9200;</div>
                    <h2 class="dash-card-title">Schedules & Quotas</h2>
                    <p class="dash-card-desc">
                        Configure separate weekly hours and daily patient capacity limits for Clinic and Home Visit consultations.
                    </p>
                </div>
                <% if (isVerified) { %>
                    <a href="${pageContext.request.contextPath}/DoctorAvailabilityServlet" class="btn btn-secondary btn-block">
                        Manage Availability &rarr;
                    </a>
                <% } else { %>
                    <button type="button" class="btn btn-secondary btn-block" disabled style="cursor: not-allowed;">
                        &#128274; Locked &bull; Pending Verification
                    </button>
                <% } %>
            </div>

            <!-- 4. Doctor Profile & Fees -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#9881;</div>
                    <h2 class="dash-card-title">Profile & Practice Fees</h2>
                    <p class="dash-card-desc">
                        Update your city, clinic address, specialization, consultation fees, and home visit service areas.
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/DoctorProfileServlet" class="btn btn-primary btn-block">
                    Edit Doctor Profile &rarr;
                </a>
            </div>
        </div>

        <!-- Requirement 6: Trust & Safety - Report Abusive / Fraudulent Patient to Admin -->
        <% if (isVerified) { %>
            <div class="card" style="margin-top: 28px; border-top: 4px solid #dc2626;">
                <div class="card-header">
                    <h2 class="page-title" style="font-size: 1.25rem; color: #dc2626;">&#128680; Clinical Incident & Patient Misconduct Report</h2>
                    <p class="page-subtitle">Report fraudulent accounts, repeated no-shows, or abusive conduct directly to hospital administration.</p>
                </div>

                <form action="${pageContext.request.contextPath}/SubmitFeedbackServlet" method="post">
                    <input type="hidden" name="targetType" value="PATIENT">
                    <input type="hidden" name="reportCategory" value="COMPLAINT">
                    <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/modules/doctor/doctor_dashboard.jsp">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Patient User ID or Name <span class="required">*</span></label>
                            <input type="text" name="targetId" class="form-control" placeholder="e.g. Patient User ID or Name" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Appointment ID (Optional)</label>
                            <input type="number" name="referenceId" class="form-control" placeholder="e.g. 104">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Incident / Misconduct Report Details <span class="required">*</span></label>
                        <textarea name="comments" rows="3" class="form-control" placeholder="Describe the incident, breach of terms, or fraudulent activity for administrative review..." required></textarea>
                    </div>

                    <button type="submit" class="btn btn-outline" style="border-color: #dc2626; color: #dc2626;">
                        Submit Report to Administrator &rarr;
                    </button>
                </form>
            </div>
        <% } %>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out of the Doctor Portal?");
        }
    </script>
</body>
</html>
