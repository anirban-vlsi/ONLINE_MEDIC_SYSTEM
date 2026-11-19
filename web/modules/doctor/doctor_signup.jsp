<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
    if (error == null || error.trim().isEmpty()) {
        error = request.getParameter("error");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Registration - Online Medical System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="${pageContext.request.contextPath}/index.html" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Doctor Portal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="${pageContext.request.contextPath}/index.html">Home</a></li>
                <li><a href="${pageContext.request.contextPath}/modules/doctor/doctor_login.jsp">Doctor Sign In</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Doctor Portal Registration</h1>
                <p class="page-subtitle">Register your medical credentials to join our verified clinical healthcare network.</p>
            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div id="serverErrorMessage" class="alert alert-error">
                    <strong>&#9888; Error:</strong> <%= error %>
                </div>
            <% } %>

            <div id="clientErrorMessage" class="alert alert-error" style="display: none;"></div>

            <div class="alert alert-info" style="margin-bottom: 20px;">
                <strong>&#128203; Administrator Verification Notice:</strong>
                All doctor registrations start as <strong>NOT VERIFIED</strong>. An administrator must review and verify your license credentials before clinical features and patient bookings are unlocked.
            </div>

            <form id="doctorSignupForm" action="${pageContext.request.contextPath}/DoctorRegistrationServlet" method="post">

                <!-- 1. Professional Credentials Section -->
                <div class="form-section">
                    <h2 class="form-section-title">1. Professional Credentials</h2>

                    <div class="form-group">
                        <label for="doctorName" class="form-label">Doctor's Full Name (with Title) <span class="required">*</span></label>
                        <input type="text" id="doctorName" name="doctor_name" class="form-control" placeholder="e.g. Dr. Robert Vance" required>
                    </div>

                    <div class="form-group">
                        <label for="regNo" class="form-label">Medical Registration License Number <span class="required">*</span></label>
                        <input type="text" id="regNo" name="registration_number" class="form-control" placeholder="e.g. MCI-2024-89710" required>
                        <small style="color: var(--text-muted); font-size: 0.82rem;">As issued by State Medical Council / National Medical Commission.</small>
                    </div>

                    <div class="form-group">
                        <label for="specializationSelect" class="form-label">Medical Specialization <span class="required">*</span></label>
                        <select id="specializationSelect" name="specialization" class="form-control" required>
                            <option value="">-- Select Your Primary Specialization --</option>
                            <option value="General Physician">General Physician</option>
                            <option value="Cardiologist">Cardiologist</option>
                            <option value="Dermatologist">Dermatologist</option>
                            <option value="Dentist">Dentist</option>
                            <option value="ENT Specialist">ENT Specialist</option>
                            <option value="Ophthalmologist (Eye)">Ophthalmologist (Eye)</option>
                            <option value="Psychiatrist">Psychiatrist</option>
                            <option value="Orthopedic">Orthopedic</option>
                            <option value="Pediatrician">Pediatrician</option>
                            <option value="Neurologist">Neurologist</option>
                        </select>
                    </div>
                </div>

                <!-- 2. Practice Location & Fees Section -->
                <div class="form-section">
                    <h2 class="form-section-title">2. Practice Location & Fees</h2>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label for="city" class="form-label">Primary Practice City <span class="required">*</span></label>
                            <input type="text" id="city" name="city" class="form-control" placeholder="e.g. Bangalore" required>
                        </div>

                        <div class="form-group">
                            <label for="consultationFee" class="form-label">Clinic Consultation Fee (₹) <span class="required">*</span></label>
                            <input type="number" id="consultationFee" name="consultation_fee" class="form-control" value="500.00" step="0.50" min="0" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address" class="form-label">Clinic / Chamber Street Address <span class="required">*</span></label>
                        <textarea id="address" name="address" class="form-control" rows="2" placeholder="Street, clinic name, locality" required></textarea>
                    </div>

                    <!-- Home Visits Section -->
                    <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; margin: 16px 0;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
                            <input type="checkbox" id="homeVisitToggle" name="home_visit_available" value="true" onchange="toggleHomeVisit(this.checked)">
                            <label for="homeVisitToggle" style="font-weight: 600; cursor: pointer; color: #1e293b; margin: 0;">
                                &#127969; Enable Home Visit Consultations (Optional)
                            </label>
                        </div>

                        <div id="homeVisitFields" style="display: none;">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                <div class="form-group">
                                    <label class="form-label">Home Visit Fee (₹)</label>
                                    <input type="number" name="home_visit_fee" class="form-control" placeholder="e.g. 800.00" step="0.50" min="0">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Covered Cities / Localities</label>
                                    <input type="text" name="service_areas" class="form-control" placeholder="e.g. Bangalore, Indiranagar, Whitefield">
                                </div>
                            </div>
                            <small style="color: var(--text-muted); font-size: 0.82rem;">Only patients located in these cities/localities can book home visits.</small>
                        </div>
                    </div>
                </div>

                <!-- 3. Personal & Contact Details Section -->
                <div class="form-section">
                    <h2 class="form-section-title">3. Personal & Contact Details</h2>

                    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 16px;">
                        <div class="form-group">
                            <label for="age" class="form-label">Age (Years) <span class="required">*</span></label>
                            <input type="number" id="age" name="age" class="form-control" min="21" max="100" placeholder="e.g. 35" required>
                        </div>

                        <div class="form-group">
                            <label for="email" class="form-label">Professional Email Address <span class="required">*</span></label>
                            <input type="email" id="email" name="email" class="form-control" placeholder="doctor.vance@clinic.org" required autocomplete="email">
                        </div>
                    </div>
                </div>

                <!-- 4. Account Security Section -->
                <div class="form-section">
                    <h2 class="form-section-title">4. Account Security</h2>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label for="password" class="form-label">Account Password <span class="required">*</span></label>
                            <input type="password" id="password" name="password" class="form-control" placeholder="Create a secure password" required autocomplete="new-password">
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">Confirm Password <span class="required">*</span></label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" placeholder="Re-enter password" required autocomplete="new-password">
                        </div>
                    </div>

                    <div class="password-toggle-wrapper">
                        <input type="checkbox" id="showPasswordToggle" onchange="togglePasswords()">
                        <label for="showPasswordToggle" style="cursor: pointer;">Show Passwords</label>
                    </div>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-primary" id="doctorRegisterSubmit">Register as Doctor</button>
                    <button type="button" class="btn btn-secondary" onclick="resetDoctorForm()">Reset Form</button>
                </div>

                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <span>Already registered? <a href="${pageContext.request.contextPath}/modules/doctor/doctor_login.jsp" style="color: var(--primary-color); font-weight: 600;">Doctor Sign In</a></span>
                    <a href="${pageContext.request.contextPath}/index.html" style="color: var(--text-muted); text-decoration: none;">&larr; Back to Home</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/common.js"></script>
    <script>
        function toggleHomeVisit(checked) {
            document.getElementById("homeVisitFields").style.display = checked ? "block" : "none";
        }

        function togglePasswords() {
            var pass = document.getElementById("password");
            var confirmPass = document.getElementById("confirmPassword");
            var isChecked = document.getElementById("showPasswordToggle").checked;
            pass.type = isChecked ? "text" : "password";
            confirmPass.type = isChecked ? "text" : "password";
        }

        function resetDoctorForm() {
            document.getElementById("doctorSignupForm").reset();
            document.getElementById("homeVisitFields").style.display = "none";
        }
    </script>
</body>
</html>
