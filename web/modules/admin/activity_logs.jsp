<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.admin.ActivityLog" %>
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

    List<ActivityLog> logs = (List<ActivityLog>) request.getAttribute("logs");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Centralized Activity & Audit Logs - Admin Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="background-color: #f1f5f9;">

    <!-- Admin Header -->
    <header class="navbar" style="background-color: #1e293b; border-bottom: 2px solid #ef4444;">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Audit Trail</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #cbd5e1;">Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminFinancialServlet" style="color: #cbd5e1;">Financials</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminModerationServlet" style="color: #cbd5e1;">Moderation</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminActivityLogServlet" style="color: #f8fafc; font-weight: 700;">Audit Logs</a></li>
                <% if (admin.isSuperAdmin()) { %>
                    <li><a href="<%= request.getContextPath() %>/AdminUserManagementServlet" style="color: #fef08a;">Staff Admins</a></li>
                <% } %>
                <li><a href="<%= request.getContextPath() %>/AdminLogoutServlet" style="color: #ef4444; font-weight: 600;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">&#128220; Security & Audit Trail</h1>
                    <p class="page-subtitle">Immutable chronological audit log capturing system operations, logins, doctor approvals, and clinical actions.</p>
                </div>
            </div>

            <% if (logs == null || logs.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128220;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No activity log records found.</h2>
                    <p class="empty-state-text">System events and admin operations will be recorded here.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto; margin-top: 14px;">
                    <table class="table" style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 10px;">ID</th>
                                <th style="padding: 10px;">Timestamp</th>
                                <th style="padding: 10px;">Actor Type & Name</th>
                                <th style="padding: 10px;">Action Event</th>
                                <th style="padding: 10px;">Description</th>
                                <th style="padding: 10px;">Target</th>
                                <th style="padding: 10px;">Result</th>
                                <th style="padding: 10px;">IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ActivityLog l : logs) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 10px; font-weight: 600;">#<%= l.getActivityId() %></td>
                                    <td style="padding: 10px; font-size: 0.82rem; color: var(--text-muted); white-space: nowrap;">
                                        <%= l.getCreatedAt() %>
                                    </td>
                                    <td style="padding: 10px;">
                                        <strong><%= l.getActorName() != null ? l.getActorName() : l.getActorId() %></strong><br>
                                        <span class="badge" style="font-size: 0.72rem; background: #e2e8f0; color: #475569;"><%= l.getActorType() %></span>
                                    </td>
                                    <td style="padding: 10px; font-weight: 600; color: var(--primary-color);">
                                        <%= l.getActivityType() %>
                                    </td>
                                    <td style="padding: 10px; max-width: 280px; font-size: 0.85rem; color: #334155;">
                                        <%= l.getActionDescription() %>
                                    </td>
                                    <td style="padding: 10px; font-size: 0.82rem;">
                                        <%= l.getTargetEntityType() != null ? l.getTargetEntityType() : "SYSTEM" %>
                                        <%= l.getTargetEntityId() != null ? "#" + l.getTargetEntityId() : "" %>
                                    </td>
                                    <td style="padding: 10px;">
                                        <% if ("SUCCESS".equalsIgnoreCase(l.getResult())) { %>
                                            <span class="badge badge-verified" style="font-size: 0.75rem;">SUCCESS</span>
                                        <% } else { %>
                                            <span class="badge" style="background:#fee2e2; color:#dc2626; font-size: 0.75rem;">FAILURE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 10px; font-size: 0.82rem; font-family: monospace; color: var(--text-muted);">
                                        <%= l.getIpAddress() != null ? l.getIpAddress() : "N/A" %>
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
