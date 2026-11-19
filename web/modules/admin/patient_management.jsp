<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.patient.User" %>
<%@ page import="model.admin.Admin" %>
<%@ page import="service.admin.AdminService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Admin admin = (Admin) request.getAttribute("admin");
    if (admin == null) {
        admin = AdminService.getAuthenticatedAdmin(request);
    }
    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/admin.html");
        return;
    }

    List<User> patients = (List<User>) request.getAttribute("patients");
    String searchParam = request.getParameter("search");
    String statusParam = request.getParameter("status");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Moderation - Admin Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="background-color: #f1f5f9;">

    <!-- Admin Header -->
    <header class="navbar" style="background-color: #1e293b; border-bottom: 2px solid #ef4444;">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Patient Moderation</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #f8fafc; font-weight: 700;">Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminFinancialServlet" style="color: #cbd5e1;">Financials</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminModerationServlet" style="color: #cbd5e1;">Moderation</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminActivityLogServlet" style="color: #cbd5e1;">Audit Logs</a></li>
                <% if (admin.isSuperAdmin()) { %>
                    <li><a href="<%= request.getContextPath() %>/AdminUserManagementServlet" style="color: #fef08a;">Staff Admins</a></li>
                <% } %>
                <li><a href="<%= request.getContextPath() %>/AdminLogoutServlet" style="color: #ef4444; font-weight: 600;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Patient Account Moderation & Verification</h1>
                <p class="page-subtitle">Inspect registered patient user profiles, verify identity status, and manage security blocks.</p>
            </div>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Action Executed:</strong> <%= msg %>
                </div>
            <% } %>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= error %>
                </div>
            <% } %>

            <!-- Search & Filters -->
            <form action="<%= request.getContextPath() %>/AdminPatientServlet" method="get" style="display: flex; gap: 12px; flex-wrap: wrap; background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid var(--border-color); margin-bottom: 20px;">
                <div style="flex: 2; min-width: 220px;">
                    <input type="text" name="search" class="form-control" placeholder="Search by patient name, email, phone, or User ID..." value="<%= searchParam != null ? searchParam : "" %>">
                </div>
                <div style="flex: 1; min-width: 160px;">
                    <select name="status" class="form-control">
                        <option value="ALL">All Statuses</option>
                        <option value="VERIFIED" <%= "VERIFIED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>VERIFIED</option>
                        <option value="NOT VERIFIED" <%= "NOT VERIFIED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>NOT VERIFIED</option>
                        <option value="BLOCKED" <%= "BLOCKED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>BLOCKED</option>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn btn-primary" style="padding: 10px 18px;">Filter Patients</button>
                    <a href="<%= request.getContextPath() %>/AdminPatientServlet" class="btn btn-secondary" style="padding: 10px 14px;">Reset</a>
                </div>
            </form>

            <!-- Patients Table -->
            <% if (patients == null || patients.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128101;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No patient accounts found.</h2>
                    <p class="empty-state-text">No registered patient accounts match the current filter.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">User ID</th>
                                <th style="padding: 12px;">Full Name</th>
                                <th style="padding: 12px;">Email Address</th>
                                <th style="padding: 12px;">Gender & Phone</th>
                                <th style="padding: 12px;">Account Status</th>
                                <th style="padding: 12px; text-align: right;">Moderation Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User p : patients) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700;">#<%= p.getUserId() %></td>
                                    <td style="padding: 12px;">
                                        <strong><%= p.getName() %></strong>
                                    </td>
                                    <td style="padding: 12px;"><%= p.getEmail() %></td>
                                    <td style="padding: 12px; font-size: 0.88rem;">
                                        <%= p.getGender() != null ? p.getGender() : "N/A" %><br>
                                        <span style="color: var(--text-muted); font-size: 0.82rem;"><%= p.getMobileNo() != null ? p.getMobileNo() : "N/A" %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("VERIFIED".equalsIgnoreCase(p.getStatus())) { %>
                                            <span class="badge badge-verified">&#10003; VERIFIED</span>
                                        <% } else if ("BLOCKED".equalsIgnoreCase(p.getStatus())) { %>
                                            <span class="badge" style="background:#fee2e2; color:#dc2626;">&#128274; BLOCKED</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">&#9888; NOT VERIFIED</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <div style="display: flex; gap: 6px; justify-content: flex-end; flex-wrap: wrap;">
                                            <% if ("BLOCKED".equalsIgnoreCase(p.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/AdminPatientServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="userId" value="<%= p.getUserId() %>">
                                                    <input type="hidden" name="action" value="unblock">
                                                    <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem;">
                                                        Unblock Account
                                                    </button>
                                                </form>
                                            <% } else { %>
                                                <form action="<%= request.getContextPath() %>/AdminPatientServlet" method="post" style="display:inline;" onsubmit="return confirm('Block patient #<%= p.getUserId() %>?');">
                                                    <input type="hidden" name="userId" value="<%= p.getUserId() %>">
                                                    <input type="hidden" name="action" value="block">
                                                    <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem; color: #dc2626; border-color: #dc2626;">
                                                        &#128274; Block
                                                    </button>
                                                </form>
                                            <% } %>

                                            <% if (admin.isSuperAdmin()) { %>
                                                <form action="<%= request.getContextPath() %>/AdminPatientServlet" method="post" style="display:inline;" onsubmit="return confirm('PERMANENT DELETION: Are you sure you want to permanently delete patient #<%= p.getUserId() %>? This cannot be undone.');">
                                                    <input type="hidden" name="userId" value="<%= p.getUserId() %>">
                                                    <input type="hidden" name="action" value="delete">
                                                    <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem; color: #991b1b; border-color: #fca5a5;">
                                                        Delete
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="btn btn-secondary">
                    &larr; Back to Dashboard
                </a>
            </div>
        </div>
    </main>

    <footer class="footer" style="background: #1e293b; color: #94a3b8; border-top: 1px solid #334155;">
        <p>&copy; 2026 Online Medical System. Centralized Administration Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
