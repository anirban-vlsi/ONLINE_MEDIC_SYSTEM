<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
    if (error == null || error.trim().isEmpty()) {
        error = request.getParameter("error");
    }

    String info = (String) request.getAttribute("info");
    if (info == null || info.trim().isEmpty()) {
        info = request.getParameter("info");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Sign In - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/index.html" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Doctor Portal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/index.html">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/modules/doctor/doctor_signup.jsp">Doctor Registration</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header text-center">
                <h1 class="page-title">Doctor Portal Sign In</h1>
                <p class="page-subtitle">Access your clinical dashboard, consultations, and patient records.</p>
            </div>

            <!-- Error message container -->
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div id="errorMessage" class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Access Alert:</strong> <%= error %>
                </div>
            <% } %>

            <!-- Info / Verification Status container -->
            <% if (info != null && !info.trim().isEmpty()) { %>
                <div id="infoMessage" class="alert alert-warning" style="margin-bottom: 20px;">
                    <strong>&#128274; Account Status Notice:</strong><br>
                    <%= info %>
                </div>
            <% } %>

            <!-- Client validation error -->
            <div id="clientError" class="alert alert-error" style="display: none; margin-bottom: 20px;"></div>

            <form id="doctorLoginForm" action="<%= request.getContextPath() %>/DoctorLoginServlet" method="post">

                <!-- Medical Registration Number -->
                <div class="form-group">
                    <label for="regNo" class="form-label">Medical Registration License Number <span class="required">*</span></label>
                    <input type="text" id="regNo" name="registration_number" class="form-control" placeholder="e.g. MCI-2024-89710" required autocomplete="username">
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="password" class="form-label">Account Password <span class="required">*</span></label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Enter your password" required autocomplete="current-password">

                    <!-- Password Toggle -->
                    <div class="password-toggle-wrapper">
                        <input type="checkbox" id="showPassToggle" onchange="togglePasswordVisibility()">
                        <label for="showPassToggle" style="cursor: pointer;">Show Password</label>
                    </div>
                </div>

                <!-- Submit Button -->
                <div class="btn-group">
                    <button type="submit" id="doctorLoginSubmit" class="btn btn-primary btn-block">
                        Sign In to Doctor Portal
                    </button>
                </div>

                <!-- Auxiliary Navigation Links -->
                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <span>New doctor? <a href="<%= request.getContextPath() %>/modules/doctor/doctor_signup.jsp" style="color: var(--primary-color); font-weight: 600;">Register as Doctor</a></span>
                    <a href="<%= request.getContextPath() %>/index.html" style="color: var(--text-muted); text-decoration: none;">&larr; Back to Home</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <!-- Interactive Client Validation -->
    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function togglePasswordVisibility() {
            var pass = document.getElementById("password");
            var isChecked = document.getElementById("showPassToggle").checked;
            pass.type = isChecked ? "text" : "password";
        }

        document.getElementById("doctorLoginForm").addEventListener("submit", function(event) {
            var regNo = document.getElementById("regNo").value.trim();
            var pass = document.getElementById("password").value;
            var errDiv = document.getElementById("clientError");

            if (regNo === "") {
                errDiv.innerText = "Please enter your medical registration number.";
                errDiv.style.display = "block";
                document.getElementById("regNo").focus();
                event.preventDefault();
                return;
            }

            if (pass === "") {
                errDiv.innerText = "Please enter your password.";
                errDiv.style.display = "block";
                document.getElementById("password").focus();
                event.preventDefault();
                return;
            }
        });
    </script>
</body>
</html>
