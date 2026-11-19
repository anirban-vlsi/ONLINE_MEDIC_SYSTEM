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
    <title>Patient Sign In - Online Medical System</title>
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
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_signup.jsp">Sign Up</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header text-center">
                <h1 class="page-title">Welcome Back, Patient!</h1>
                <p class="page-subtitle">Sign in to access your medical account.</p>
            </div>

            <!-- Meaningful error message container -->
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div id="errorMessage" class="alert alert-error">
                    <%= error %>
                </div>
            <% } else { %>
                <div id="errorMessage" class="alert alert-error" style="display: none;"></div>
            <% } %>

            <!-- Informational message for notifications -->
            <div id="infoMessage" class="alert alert-info" style="display: none;"></div>

            <form id="loginForm" action="<%= request.getContextPath() %>/PatientLoginServlet" method="post">

                <!-- Email Address -->
                <div class="form-group">
                    <label for="email" class="form-label">Email Address <span class="required">*</span></label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="Enter your registered email" required autocomplete="email">
                </div>

                <!-- Password -->
                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                        <label for="password" class="form-label" style="margin-bottom: 0;">Password <span class="required">*</span></label>
                        <a href="#forgotPassword" onclick="showForgotPassword(); return false;" style="font-size: 0.85rem; color: var(--primary-color); text-decoration: none;">Forgot Password?</a>
                    </div>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Enter your account password" required autocomplete="current-password">

                    <!-- Show/Hide Password Toggle -->
                    <div class="password-toggle-wrapper">
                        <input type="checkbox" id="showPassToggle" onchange="togglePasswordVisibility()">
                        <label for="showPassToggle" style="cursor: pointer;">Show Password</label>
                    </div>
                </div>

                <!-- Submit Button Group -->
                <div class="btn-group">
                    <button type="submit" id="signInSubmit" class="btn btn-primary btn-block">Sign In</button>
                </div>

                <!-- Auxiliary Navigation Links -->
                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <span>Don't have an account? <a href="<%= request.getContextPath() %>/modules/patient/patient_signup.jsp" style="color: var(--primary-color); font-weight: 600;">Create New Account</a></span>
                    <a href="<%= request.getContextPath() %>/index.html" style="color: var(--text-muted); text-decoration: none;">&larr; Back to Home</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <!-- Interactive Client Scripts -->
    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function togglePasswordVisibility() {
            var pass = document.getElementById("password");
            var isChecked = document.getElementById("showPassToggle").checked;
            pass.type = isChecked ? "text" : "password";
        }

        function showForgotPassword() {
            var infoEl = document.getElementById("infoMessage");
            infoEl.innerText = "Notice: Automated password recovery is not yet implemented. Please contact the clinic administrator at support@onlinemedic.local to reset your credentials.";
            infoEl.style.display = "block";
            window.scrollTo({ top: infoEl.offsetTop - 80, behavior: 'smooth' });
        }

        document.getElementById("loginForm").addEventListener("submit", function(event) {
            var email = document.getElementById("email").value.trim();
            var password = document.getElementById("password").value;
            var errDiv = document.getElementById("errorMessage");

            if (email === "") {
                errDiv.innerText = "Please enter your email address.";
                errDiv.style.display = "block";
                document.getElementById("email").focus();
                event.preventDefault();
                return;
            }

            if (password === "") {
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
