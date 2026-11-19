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
    <title>Create Your Patient Account - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/index.html" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/index.html">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_login.jsp">Sign In</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Create Your Patient Account</h1>
                <p class="page-subtitle">Please provide your details to create your account.</p>
            </div>

            <!-- Error message container -->
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div id="errorMessage" class="alert alert-error">
                    <%= error %>
                </div>
            <% } else { %>
                <div id="errorMessage" class="alert alert-error" style="display: none;"></div>
            <% } %>

            <form id="patientForm" action="<%= request.getContextPath() %>/PatientRegistrationServlet" method="post">

                <!-- 1. Personal Information Section -->
                <div class="form-section">
                    <h2 class="form-section-title">Personal Information</h2>

                    <!-- Full Name -->
                    <div class="form-group">
                        <label for="patientName" class="form-label">Full Name <span class="required">*</span></label>
                        <input type="text" id="patientName" name="name" class="form-control" placeholder="e.g. John Doe" required>
                    </div>

                    <!-- Email Address -->
                    <div class="form-group">
                        <label for="email" class="form-label">Email Address <span class="required">*</span></label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="e.g. john@example.com" required>
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

                    <!-- Mobile Number -->
                    <div class="form-group">
                        <label for="mobile" class="form-label">Mobile Number <span class="required">*</span></label>
                        <input type="tel" id="mobile" name="mobile_no" class="form-control" placeholder="e.g. 9876543210" required>
                    </div>
                </div>

                <!-- 2. Account Information Section -->
                <div class="form-section">
                    <h2 class="form-section-title">Account Security</h2>

                    <!-- Password -->
                    <div class="form-group">
                        <label for="password" class="form-label">Password <span class="required">*</span></label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="Enter a secure password" required>
                    </div>

                    <!-- Confirm Password -->
                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Confirm Password <span class="required">*</span></label>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" placeholder="Re-enter your password" required>
                    </div>

                    <!-- Show/Hide Password Toggle -->
                    <div class="password-toggle-wrapper">
                        <input type="checkbox" id="showPasswordToggle" onchange="togglePasswordVisibility()">
                        <label for="showPasswordToggle" style="cursor: pointer;">Show Password</label>
                    </div>
                </div>

                <!-- 3. Terms & Conditions Section -->
                <div class="checkbox-wrapper">
                    <input type="checkbox" id="terms" name="terms" value="accepted" required>
                    <label for="terms">
                        I agree to the <a href="#termsModal" onclick="alert('Terms: All medical records are kept strictly confidential under institutional health privacy guidelines.'); return false;">Terms and Conditions</a> and Patient Privacy Policy. <span class="required">*</span>
                    </label>
                </div>

                <!-- Submit / Action Buttons -->
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary" id="submitBtn">Create Account</button>
                    <button type="button" class="btn btn-secondary" onclick="resetForm()">Reset Form</button>
                </div>

                <!-- Auxiliary Navigation Links -->
                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <span>Already have an account? <a href="<%= request.getContextPath() %>/modules/patient/patient_login.jsp" style="color: var(--primary-color); font-weight: 600;">Sign In</a></span>
                    <a href="<%= request.getContextPath() %>/index.html" style="color: var(--text-muted); text-decoration: none;">&larr; Back to Home</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <!-- Form Validation & Interactive Scripts -->
    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function togglePasswordVisibility() {
            var pass = document.getElementById("password");
            var confirmPass = document.getElementById("confirmPassword");
            var isChecked = document.getElementById("showPasswordToggle").checked;
            pass.type = isChecked ? "text" : "password";
            confirmPass.type = isChecked ? "text" : "password";
        }

        document.getElementById("patientForm").addEventListener("submit", function(event) {
            var name = document.getElementById("patientName").value.trim();
            var email = document.getElementById("email").value.trim();
            var mobile = document.getElementById("mobile").value.trim();
            var password = document.getElementById("password").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            var terms = document.getElementById("terms").checked;
            var gender = document.querySelector('input[name="gender"]:checked');

            if (name === "") {
                showError("Please enter your full name.");
                document.getElementById("patientName").focus();
                event.preventDefault();
                return;
            }

            if (email === "") {
                showError("Please enter your email address.");
                document.getElementById("email").focus();
                event.preventDefault();
                return;
            }

            if (!gender) {
                showError("Please select your gender.");
                event.preventDefault();
                return;
            }

            if (mobile === "") {
                showError("Please enter your mobile phone number.");
                document.getElementById("mobile").focus();
                event.preventDefault();
                return;
            }

            if (password === "") {
                showError("Please enter a password.");
                document.getElementById("password").focus();
                event.preventDefault();
                return;
            }

            if (confirmPassword === "") {
                showError("Please confirm your password.");
                document.getElementById("confirmPassword").focus();
                event.preventDefault();
                return;
            }

            if (password !== confirmPassword) {
                showError("Password and Confirm Password do not match.");
                document.getElementById("confirmPassword").focus();
                event.preventDefault();
                return;
            }

            if (!terms) {
                showError("You must accept the Terms and Conditions to proceed.");
                event.preventDefault();
                return;
            }
        });

        function showError(msg) {
            var el = document.getElementById("errorMessage");
            el.innerText = msg;
            el.style.display = "block";
            window.scrollTo({ top: el.offsetTop - 80, behavior: 'smooth' });
        }

        function resetForm() {
            document.getElementById("patientForm").reset();
            var el = document.getElementById("errorMessage");
            if (el) el.style.display = "none";
            document.getElementById("password").type = "password";
            document.getElementById("confirmPassword").type = "password";
        }
    </script>
</body>
</html>
