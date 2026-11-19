<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session != null && session.getAttribute("loggedInPharmacist") != null) {
        response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet");
        return;
    }

    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pharmacist Login - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/index.html" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Pharmacy Portal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/index.html">Home</a></li>
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_login.jsp">Patient</a></li>
                <li><a href="<%= request.getContextPath() %>/modules/doctor/doctor_login.jsp">Doctor</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow" style="padding-top: 50px;">
        <div class="card" style="margin-top: 20px;">
            <div class="card-header text-center">
                <span style="font-size: 2.5rem; color: #0284c7;">&#128138;</span>
                <h1 class="page-title" style="margin-top: 8px;">Pharmacy Operator Portal</h1>
                <p class="page-subtitle">Sign in to manage pharmaceutical inventory, dispense orders, and monitor earnings.</p>
            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Authentication Failed:</strong> <%= error %>
                </div>
            <% } %>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Notice:</strong> <%= msg %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/PharmacistLoginServlet" method="post">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="identifier" class="form-label">Username or Registered Email <span class="required">*</span></label>
                    <input type="text" name="identifier" id="identifier" class="form-control" placeholder="Enter username or email" required autofocus>
                </div>

                <div class="form-group" style="margin-bottom: 20px;">
                    <label for="password" class="form-label">Password <span class="required">*</span></label>
                    <input type="password" name="password" id="password" class="form-control" placeholder="Enter your operator password" required>
                </div>

                <button type="submit" class="btn btn-primary btn-block" style="padding: 12px; font-size: 1rem;">
                    Sign In to Pharmacy Desk &rarr;
                </button>
            </form>

            <div style="margin-top: 24px; text-align: center;">
                <a href="<%= request.getContextPath() %>/index.html" style="color: var(--text-muted); text-decoration: none; font-size: 0.9rem;">
                    &larr; Return to Main Homepage
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Pharmacy Management Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
