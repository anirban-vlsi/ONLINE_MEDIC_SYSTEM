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
    <title>Administrator Sign In - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="background-color: #0f172a;">

    <!-- Header Navigation -->
    <header class="navbar" style="background-color: #1e293b; border-bottom-color: #334155;">
        <a href="<%= request.getContextPath() %>/admin.html" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Admin Terminal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/index.html" style="color: #94a3b8;">Main Website</a></li>
                <li><a href="<%= request.getContextPath() %>/admin.html" style="color: #cbd5e1;">Admin Home</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow" style="margin-top: 50px;">
        <div class="card" style="box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5);">
            <div class="card-header text-center" style="border-bottom: 2px solid #ef4444;">
                <div style="font-size: 2.2rem; color: #dc2626; margin-bottom: 8px;">&#128272;</div>
                <h1 class="page-title" style="color: #1e293b;">Administrator Authentication</h1>
                <p class="page-subtitle">Authorized personnel login. All access is audited.</p>
            </div>

            <!-- Error message container -->
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div id="errorMessage" class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Security Alert:</strong> <%= error %>
                </div>
            <% } %>

            <!-- Info message container -->
            <% if (info != null && !info.trim().isEmpty()) { %>
                <div id="infoMessage" class="alert alert-info" style="margin-bottom: 20px;">
                    <%= info %>
                </div>
            <% } %>

            <!-- Client validation error -->
            <div id="clientError" class="alert alert-error" style="display: none; margin-bottom: 20px;"></div>

            <form id="adminLoginForm" action="<%= request.getContextPath() %>/AdminLoginServlet" method="post">

                <!-- Admin Email Address -->
                <div class="form-group">
                    <label for="adminEmail" class="form-label">Administrator Email <span class="required">*</span></label>
                    <input type="email" id="adminEmail" name="email" class="form-control" placeholder="Enter administrator email" required autocomplete="username">
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="adminPassword" class="form-label">Password <span class="required">*</span></label>
                    <input type="password" id="adminPassword" name="password" class="form-control" placeholder="Enter administrative password" required autocomplete="current-password">

                    <!-- Password Toggle -->
                    <div class="password-toggle-wrapper">
                        <input type="checkbox" id="showPassToggle" onchange="togglePasswordVisibility()">
                        <label for="showPassToggle" style="cursor: pointer;">Show Password</label>
                    </div>
                </div>

                <!-- Submit Button -->
                <div class="btn-group" style="margin-top: 24px;">
                    <button type="submit" id="adminLoginSubmit" class="btn btn-primary btn-block" style="background: #dc2626; border-color: #dc2626; font-weight: 700;">
                        &#128273; Authenticate & Open Terminal
                    </button>
                </div>

                <!-- Navigation Links -->
                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 0.92rem;">
                    <a href="<%= request.getContextPath() %>/admin.html" style="color: var(--text-muted); text-decoration: none;">&larr; Back to Admin Portal</a>
                    <a href="<%= request.getContextPath() %>/index.html" style="color: var(--text-muted); text-decoration: none;">Public Home</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer" style="background-color: #1e293b; border-top-color: #334155; color: #94a3b8;">
        <p>&copy; 2026 Online Medical System. All rights reserved. System Administration Terminal.</p>
    </footer>

    <!-- Interactive Client Scripts -->
    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function togglePasswordVisibility() {
            var pass = document.getElementById("adminPassword");
            var isChecked = document.getElementById("showPassToggle").checked;
            pass.type = isChecked ? "text" : "password";
        }

        document.getElementById("adminLoginForm").addEventListener("submit", function(event) {
            var email = document.getElementById("adminEmail").value.trim();
            var pass = document.getElementById("adminPassword").value;
            var errDiv = document.getElementById("clientError");

            if (email === "") {
                errDiv.innerText = "Please enter your administrator email address.";
                errDiv.style.display = "block";
                document.getElementById("adminEmail").focus();
                event.preventDefault();
                return;
            }

            if (pass === "") {
                errDiv.innerText = "Please enter your administrative password.";
                errDiv.style.display = "block";
                document.getElementById("adminPassword").focus();
                event.preventDefault();
                return;
            }
        });
    </script>
</body>
</html>
