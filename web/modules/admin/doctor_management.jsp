<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.doctor.Doctor" %>
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

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
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
    <title>Doctor Verification & Management - Admin Portal</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="background-color: #f1f5f9;">

    <!-- Admin Header -->
    <header class="navbar" style="background-color: #1e293b; border-bottom: 2px solid #ef4444;">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Doctor Moderation</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #f8fafc; font-weight: 700;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #cbd5e1;">Patients</a></li>
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
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Doctor Credentials & Verification Moderation</h1>
                    <p class="page-subtitle">Review practitioner medical licenses, authorize pending profiles, and enforce clinical restrictions.</p>
                </div>
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

            <!-- Search & Filter Controls -->
            <form action="<%= request.getContextPath() %>/AdminDoctorServlet" method="get" style="display: flex; gap: 12px; flex-wrap: wrap; background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid var(--border-color); margin-bottom: 20px;">
                <div style="flex: 2; min-width: 220px;">
                    <input type="text" name="search" class="form-control" placeholder="Search by doctor name, license number, email, specialty..." value="<%= searchParam != null ? searchParam : "" %>">
                </div>
                <div style="flex: 1; min-width: 160px;">
                    <select name="status" class="form-control">
                        <option value="ALL">All Statuses</option>
                        <option value="NOT VERIFIED" <%= "NOT VERIFIED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>NOT VERIFIED (Pending)</option>
                        <option value="VERIFIED" <%= "VERIFIED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>VERIFIED</option>
                        <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>REJECTED</option>
                        <option value="BLOCKED" <%= "BLOCKED".equalsIgnoreCase(statusParam) ? "selected" : "" %>>BLOCKED</option>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn btn-primary" style="padding: 10px 18px;">Filter Doctors</button>
                    <a href="<%= request.getContextPath() %>/AdminDoctorServlet" class="btn btn-secondary" style="padding: 10px 14px;">Reset</a>
                </div>
            </form>

            <!-- Doctors Table -->
            <% if (doctors == null || doctors.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#9877;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No doctors found.</h2>
                    <p class="empty-state-text">No registered doctor accounts matched the query or filter criteria.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">License / Reg No</th>
                                <th style="padding: 12px;">Doctor Name</th>
                                <th style="padding: 12px;">Specialization</th>
                                <th style="padding: 12px;">Email & Contact</th>
                                <th style="padding: 12px;">Verification Status</th>
                                <th style="padding: 12px; text-align: right;">Admin Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Doctor d : doctors) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700; color: #1e293b;">
                                        <%= d.getRegistrationNumber() %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong>Dr. <%= d.getDoctorName() %></strong><br>
                                        <span style="font-size: 0.82rem; color: var(--text-muted);">Age: <%= d.getAge() %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <span class="badge" style="background: #e0f2fe; color: #0369a1; font-weight: 600;"><%= d.getSpecialization() %></span>
                                    </td>
                                    <td style="padding: 12px; font-size: 0.88rem;">
                                        <%= d.getEmail() %><br>
                                        <span style="color: var(--text-muted); font-size: 0.82rem;"><%= d.getAddress() %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("VERIFIED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                            <span class="badge badge-verified">&#10003; VERIFIED</span>
                                        <% } else if ("REJECTED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                            <span class="badge" style="background:#fee2e2; color:#dc2626;">&#10007; REJECTED</span>
                                        <% } else if ("BLOCKED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                            <span class="badge" style="background:#fee2e2; color:#dc2626;">&#128274; BLOCKED</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">&#9888; NOT VERIFIED</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <div style="display: flex; gap: 6px; justify-content: flex-end; flex-wrap: wrap;">
                                            <% if (!"VERIFIED".equalsIgnoreCase(d.getVerificationStatus()) && !"BLOCKED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                                <!-- Verify/Approve Doctor -->
                                                <form action="<%= request.getContextPath() %>/AdminDoctorServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="registrationNumber" value="<%= d.getRegistrationNumber() %>">
                                                    <input type="hidden" name="action" value="verify">
                                                    <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem; background: #16a34a; border-color: #16a34a;">
                                                        &#10003; Verify & Approve
                                                    </button>
                                                </form>
                                                <!-- Reject Doctor -->
                                                <form action="<%= request.getContextPath() %>/AdminDoctorServlet" method="post" style="display:inline;" onsubmit="return confirm('Reject this doctor application?');">
                                                    <input type="hidden" name="registrationNumber" value="<%= d.getRegistrationNumber() %>">
                                                    <input type="hidden" name="action" value="reject">
                                                    <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem; color: #dc2626; border-color: #dc2626;">
                                                        &#10007; Reject
                                                    </button>
                                                </form>
                                            <% } else if ("VERIFIED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                                <!-- Block Doctor -->
                                                <form action="<%= request.getContextPath() %>/AdminDoctorServlet" method="post" style="display:inline;" onsubmit="return confirm('Block clinical access for Dr. <%= d.getDoctorName() %>?');">
                                                    <input type="hidden" name="registrationNumber" value="<%= d.getRegistrationNumber() %>">
                                                    <input type="hidden" name="action" value="block">
                                                    <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem; color: #dc2626; border-color: #dc2626;">
                                                        &#128274; Block Access
                                                    </button>
                                                </form>
                                            <% } else if ("BLOCKED".equalsIgnoreCase(d.getVerificationStatus())) { %>
                                                <!-- Unblock Doctor -->
                                                <form action="<%= request.getContextPath() %>/AdminDoctorServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="registrationNumber" value="<%= d.getRegistrationNumber() %>">
                                                    <input type="hidden" name="action" value="unblock">
                                                    <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem;">
                                                        Restore & Unblock
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
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
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
