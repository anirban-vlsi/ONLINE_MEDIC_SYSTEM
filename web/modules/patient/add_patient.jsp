<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="service.patient.UserService" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // Prevent browser caching of protected form
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Strict session validation
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    UserService userService = new UserService();
    String authoritativeStatus = userService.getUserStatus(userId);

    // Rule: Only VERIFIED accounts may add patient profiles
    if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp?error="
                + URLEncoder.encode("You must verify your profile picture and account before adding patients.", "UTF-8"));
        return;
    }

    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Patient - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Add Patient</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientProfileServlet">My Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Add Patient / Family Member</h1>
                <p class="page-subtitle">Enter the information of the patient you want to add to your account.</p>
            </div>

            <!-- Error container -->
            <% if (errorParam != null && !errorParam.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Error:</strong> <%= errorParam %>
                </div>
            <% } %>

            <div id="addPatientError" class="alert alert-error" style="display: none; margin-bottom: 20px;"></div>

            <form id="addPatientForm" action="<%= request.getContextPath() %>/AddPatientServlet" method="post" onsubmit="return validatePatientForm();">

                <!-- 1. Personal Details -->
                <div class="form-section">
                    <h2 class="form-section-title">Personal Details</h2>

                    <!-- Patient Name -->
                    <div class="form-group">
                        <label for="patient_name" class="form-label">Patient Name <span class="required">*</span></label>
                        <input type="text" id="patient_name" name="patient_name" class="form-control" placeholder="e.g. Mary Doe" required>
                    </div>

                    <!-- Date of Birth -->
                    <div class="form-group">
                        <label for="date_of_birth" class="form-label">Date of Birth</label>
                        <input type="date" id="date_of_birth" name="date_of_birth" class="form-control">
                    </div>

                    <!-- Gender -->
                    <div class="form-group">
                        <label class="form-label">Gender <span class="required">*</span></label>
                        <div class="radio-group">
                            <label class="radio-label">
                                <input type="radio" id="male" name="gender" value="Male" required> Male
                            </label>
                            <label class="radio-label">
                                <input type="radio" id="female" name="gender" value="Female"> Female
                            </label>
                            <label class="radio-label">
                                <input type="radio" id="other" name="gender" value="Other"> Other
                            </label>
                        </div>
                    </div>

                    <!-- Relationship -->
                    <div class="form-group">
                        <label for="relation" class="form-label">Relationship to Account Holder <span class="required">*</span></label>
                        <select id="relation" name="relation" class="form-control" required>
                            <option value="">-- Select Relationship --</option>
                            <option value="Self">Self (Account Holder)</option>
                            <option value="Mother">Mother</option>
                            <option value="Father">Father</option>
                            <option value="Son">Son</option>
                            <option value="Daughter">Daughter</option>
                            <option value="Spouse">Spouse</option>
                            <option value="Sibling">Sibling</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>

                    <!-- Mobile Number -->
                    <div class="form-group">
                        <label for="mobile_no" class="form-label">Mobile Number</label>
                        <input type="tel" id="mobile_no" name="mobile_no" class="form-control" placeholder="e.g. 9876543210">
                    </div>
                </div>

                <!-- 2. Medical Details -->
                <div class="form-section">
                    <h2 class="form-section-title">Medical Details</h2>

                    <!-- Blood Group -->
                    <div class="form-group">
                        <label for="blood_group" class="form-label">Blood Group</label>
                        <select id="blood_group" name="blood_group" class="form-control">
                            <option value="">-- Select Blood Group --</option>
                            <option value="A+">A+</option>
                            <option value="A-">A-</option>
                            <option value="B+">B+</option>
                            <option value="B-">B-</option>
                            <option value="AB+">AB+</option>
                            <option value="AB-">AB-</option>
                            <option value="O+">O+</option>
                            <option value="O-">O-</option>
                            <option value="Unknown">Unknown</option>
                        </select>
                    </div>

                    <!-- Allergies -->
                    <div class="form-group">
                        <label for="allergies" class="form-label">Known Allergies</label>
                        <input type="text" id="allergies" name="allergies" class="form-control" placeholder="e.g. Penicillin, Peanuts (or None)">
                    </div>

                    <!-- Medical Conditions -->
                    <div class="form-group">
                        <label for="medical_conditions" class="form-label">Existing Medical Conditions</label>
                        <textarea id="medical_conditions" name="medical_conditions" class="form-control" rows="3" placeholder="e.g. Hypertension, Asthma, Diabetes (or None)"></textarea>
                    </div>
                </div>

                <!-- Submit / Action Buttons -->
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">Save Patient</button>
                    <button type="reset" class="btn btn-secondary">Reset</button>
                </div>

                <!-- Navigation Links -->
                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <a href="<%= request.getContextPath() %>/PatientProfileServlet" style="color: var(--primary-color); font-weight: 600;">&larr; View My Patients</a>
                    <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" style="color: var(--text-muted); text-decoration: none;">Back to Dashboard</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <!-- Form Validation Script -->
    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function validatePatientForm() {
            var patientName = document.getElementById("patient_name").value.trim();
            var relation = document.getElementById("relation").value;
            var gender = document.querySelector('input[name="gender"]:checked');
            var errEl = document.getElementById("addPatientError");

            if (patientName === "") {
                errEl.innerText = "Please enter the patient's full name.";
                errEl.style.display = "block";
                document.getElementById("patient_name").focus();
                return false;
            }

            if (!gender) {
                errEl.innerText = "Please select the patient's gender.";
                errEl.style.display = "block";
                return false;
            }

            if (relation === "") {
                errEl.innerText = "Please select the relationship with the account holder.";
                errEl.style.display = "block";
                document.getElementById("relation").focus();
                return false;
            }

            errEl.style.display = "none";
            return true;
        }
    </script>
</body>
</html>
