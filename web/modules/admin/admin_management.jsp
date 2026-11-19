<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
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
    if (admin == null || !admin.isSuperAdmin()) {
        response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        return;
    }

    List<Admin> admins = (List<Admin>) request.getAttribute("admins");
    Boolean creationSuccess = (Boolean) request.getAttribute("creationSuccess");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Staff Management - Super Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="background-color: #f1f5f9;">

    <!-- Admin Header -->
    <header class="navbar" style="background-color: #1e293b; border-bottom: 2px solid #ef4444;">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Staff Governance</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #cbd5e1;">Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminFinancialServlet" style="color: #cbd5e1;">Financials</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminModerationServlet" style="color: #cbd5e1;">Moderation</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminActivityLogServlet" style="color: #cbd5e1;">Audit Logs</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminUserManagementServlet" style="color: #fef08a; font-weight: 700;">Staff Admins</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminLogoutServlet" style="color: #ef4444; font-weight: 600;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">&#128272; Administrator Staff Management</h1>
                <p class="page-subtitle">Provision, inspect, and configure access permissions for platform administrators.</p>
            </div>

            <% if (creationSuccess != null) { %>
                <% if (creationSuccess) { %>
                    <div class="alert alert-success" style="margin-bottom: 20px;">
                        <strong>&#10003; Success:</strong> New administrator staff account was provisioned successfully.
                    </div>
                <% } else { %>
                    <div class="alert alert-error" style="margin-bottom: 20px;">
                        <strong>&#9888; Error:</strong> Failed to create admin account. The email might already be registered.
                    </div>
                <% } %>
            <% } %>

            <!-- Add Admin Form -->
            <div style="background: #f8fafc; padding: 20px; border-radius: 8px; border: 1px solid var(--border-color); margin-bottom: 28px;">
                <h2 style="font-size: 1.15rem; color: #1e293b; margin-bottom: 12px;">+ Provision New Administrator Account</h2>
                <form action="<%= request.getContextPath() %>/AdminUserManagementServlet" method="post" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; align-items: flex-end;">
                    <input type="hidden" name="action" value="create">

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="fullName" class="form-label">Full Name <span class="required">*</span></label>
                        <input type="text" name="fullName" id="fullName" class="form-control" placeholder="e.g. John Doe" required>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="email" class="form-label">Email Address <span class="required">*</span></label>
                        <input type="email" name="email" id="email" class="form-control" placeholder="e.g. admin@medic.local" required>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="password" class="form-label">Temporary Password <span class="required">*</span></label>
                        <input type="password" name="password" id="password" class="form-control" placeholder="Min 8 characters" required>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="role" class="form-label">RBAC Role <span class="required">*</span></label>
                        <select name="role" id="role" class="form-control" required>
                            <option value="ADMIN">ADMIN &bull; Standard Operations</option>
                            <option value="MODERATOR">MODERATOR &bull; Read-Only Audit</option>
                            <option value="SUPER_ADMIN">SUPER_ADMIN &bull; Full Permissions</option>
                        </select>
                    </div>

                    <div>
                        <button type="submit" class="btn btn-primary btn-block" style="padding: 10px;">
                            Provision Staff Admin
                        </button>
                    </div>
                </form>
            </div>

            <!-- Administrators Table -->
            <h2 style="font-size: 1.15rem; color: #1e293b; margin-bottom: 12px;">Existing Administrator Accounts</h2>
            <% if (admins == null || admins.isEmpty()) { %>
                <div class="empty-state">
                    <p style="color: var(--text-muted);">No staff administrators found.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Admin ID</th>
                                <th style="padding: 12px;">Full Name</th>
                                <th style="padding: 12px;">Email Address</th>
                                <th style="padding: 12px;">Role</th>
                                <th style="padding: 12px;">Status</th>
                                <th style="padding: 12px;">Created</th>
                                <th style="padding: 12px;">Last Login</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Admin a : admins) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700;">#<%= a.getAdminId() %></td>
                                    <td style="padding: 12px;"><strong><%= a.getFullName() %></strong></td>
                                    <td style="padding: 12px;"><%= a.getEmail() %></td>
                                    <td style="padding: 12px;">
                                        <% if (a.isSuperAdmin()) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626; font-weight: 700;">SUPER_ADMIN</span>
                                        <% } else if (a.isAdmin()) { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1; font-weight: 600;">ADMIN</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">MODERATOR</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if (a.isActive()) { %>
                                            <span class="badge badge-verified">ACTIVE</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">INACTIVE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; font-size: 0.85rem; color: var(--text-muted);"><%= a.getCreatedAt() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem; color: var(--text-muted);"><%= a.getLastLogin() != null ? a.getLastLogin() : "Never" %></td>
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
