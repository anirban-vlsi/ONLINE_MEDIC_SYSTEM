<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.Map" %>
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

    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Dashboard - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .kpi-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 18px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .kpi-title {
            font-size: 0.85rem;
            text-transform: uppercase;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
        }
        .kpi-value {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--text-main);
        }
    </style>
</head>
<body style="background-color: #f1f5f9;">

    <!-- Admin Header -->
    <header class="navbar" style="background-color: #1e293b; border-bottom: 2px solid #ef4444;">
        <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="navbar-brand" style="color: #f8fafc;">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Admin Oversight Terminal</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><span style="color: #cbd5e1; font-weight: 500;">&#128100; <%= admin.getFullName() %> (<%= admin.getRole() %>)</span></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
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
        <!-- Welcome Hero -->
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">System Overview & Governance</h1>
                    <p class="page-subtitle">Centralized moderation across Patient, Doctor, Pharmacy, Emergency, and Financial operations.</p>
                </div>
                <div>
                    <span class="badge" style="background: #1e293b; color: #f8fafc; padding: 8px 14px; font-size: 0.85rem;">
                        &#128272; Role: <strong><%= admin.getRole() %></strong>
                    </span>
                </div>
            </div>
        </div>

        <!-- KPI Metrics Grid -->
        <div class="kpi-grid">
            <div class="kpi-card" style="border-left: 4px solid #0284c7;">
                <div class="kpi-title">Total Patients</div>
                <div class="kpi-value"><%= stats != null ? stats.get("totalPatients") : 0 %></div>
                <div style="font-size: 0.82rem; color: #dc2626; margin-top: 4px;">
                    Blocked: <strong><%= stats != null ? stats.get("blockedPatients") : 0 %></strong>
                </div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #16a34a;">
                <div class="kpi-title">Verified Doctors</div>
                <div class="kpi-value" style="color: #16a34a;"><%= stats != null ? stats.get("verifiedDoctors") : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">
                    Total Registered: <%= stats != null ? stats.get("totalDoctors") : 0 %>
                </div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #d97706; background: #fffdf5;">
                <div class="kpi-title">Pending Doctor Approvals</div>
                <div class="kpi-value" style="color: #d97706;"><%= stats != null ? stats.get("pendingDoctors") : 0 %></div>
                <div style="font-size: 0.82rem; margin-top: 4px;">
                    <a href="<%= request.getContextPath() %>/AdminDoctorServlet?status=NOT+VERIFIED" style="color: #b45309; font-weight: 600;">
                        Review Pending &rarr;
                    </a>
                </div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #8b5cf6;">
                <div class="kpi-title">Total Appointments</div>
                <div class="kpi-value"><%= stats != null ? stats.get("totalAppointments") : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Cross-module clinical visits</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #059669;">
                <div class="kpi-title">Total Revenue</div>
                <div class="kpi-value" style="color: #059669;">&#8377;<%= stats != null ? stats.get("revenue") : "0.00" %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">
                    Transactions: <%= stats != null ? stats.get("totalTransactions") : 0 %>
                </div>
            </div>
        </div>

        <!-- Management Navigation Hub -->
        <h2 style="font-size: 1.25rem; color: #1e293b; margin-bottom: 14px;">Administrative Management Modules</h2>
        <div class="dashboard-grid">
            <!-- 1. Doctor Management -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon" style="color: #0284c7;">&#9877;</div>
                    <h2 class="dash-card-title">Doctor Verification & Moderation</h2>
                    <p class="dash-card-desc">
                        Review medical license credentials, approve unverified doctors, or suspend clinical access.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/AdminDoctorServlet" class="btn btn-primary btn-block">
                    Manage Doctors &rarr;
                </a>
            </div>

            <!-- 2. Patient Management -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon" style="color: #16a34a;">&#128101;</div>
                    <h2 class="dash-card-title">Patient Account Moderation</h2>
                    <p class="dash-card-desc">
                        Audit registered patient accounts, investigate suspicious profiles, and manage block statuses.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/AdminPatientServlet" class="btn btn-primary btn-block">
                    Manage Patients &rarr;
                </a>
            </div>

            <!-- 3. Security & Activity Logs -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon" style="color: #d97706;">&#128220;</div>
                    <h2 class="dash-card-title">Audit & Activity Logs</h2>
                    <p class="dash-card-desc">
                        Examine immutable security event logs tracking logins, doctor approvals, and patient blocks.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/AdminActivityLogServlet" class="btn btn-primary btn-block">
                    View Audit Logs &rarr;
                </a>
            </div>

            <!-- 4. Financial & Commission Ledger -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon" style="color: #059669;">&#128179;</div>
                    <h2 class="dash-card-title">Financial & Commission Ledger</h2>
                    <p class="dash-card-desc">
                        Review automated 15% doctor consultation and 10% pharmacy fulfillment revenue splits and provider payouts.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/AdminFinancialServlet" class="btn btn-primary btn-block" style="background: #059669; border-color: #059669;">
                    View Financials &rarr;
                </a>
            </div>

            <!-- 5. Trust, Safety & Moderation Hub -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon" style="color: #dc2626;">&#128737;</div>
                    <h2 class="dash-card-title">Trust, Safety & Moderation Hub</h2>
                    <p class="dash-card-desc">
                        Resolve patient-doctor misconduct reports, audit pharmacy catalog compliance, and moderate emergency fleet.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/AdminModerationServlet" class="btn btn-primary btn-block" style="background: #dc2626; border-color: #dc2626;">
                    Open Moderation Center &rarr;
                </a>
            </div>

            <!-- 4. Staff Admin Accounts (Super Admin) -->
            <% if (admin.isSuperAdmin()) { %>
                <div class="dash-card">
                    <div>
                        <div class="dash-card-icon" style="color: #ef4444;">&#128272;</div>
                        <h2 class="dash-card-title">Administrator Accounts</h2>
                        <p class="dash-card-desc">
                            Provision and manage internal admin accounts, assign RBAC permissions, and adjust roles.
                        </p>
                    </div>
                    <a href="<%= request.getContextPath() %>/AdminUserManagementServlet" class="btn btn-primary btn-block">
                        Manage Staff Admins &rarr;
                    </a>
                </div>
            <% } %>
        </div>
    </main>

    <footer class="footer" style="background: #1e293b; color: #94a3b8; border-top: 1px solid #334155;">
        <p>&copy; 2026 Online Medical System. Centralized Administration Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
