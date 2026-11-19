<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.admin.Admin" %>
<%@ page import="model.moderation.FeedbackReport" %>
<%@ page import="model.pharmacy.Medicine" %>
<%@ page import="model.emergency.Ambulance" %>
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
        response.sendRedirect(request.getContextPath() + "/modules/admin/admin_login.jsp");
        return;
    }

    List<FeedbackReport> reports = (List<FeedbackReport>) request.getAttribute("reports");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<Ambulance> ambulances = (List<Ambulance>) request.getAttribute("ambulances");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String targetFilter = (String) request.getAttribute("targetFilter");

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    int openCount = 0;
    if (reports != null) {
        for (FeedbackReport r : reports) {
            if ("OPEN".equalsIgnoreCase(r.getStatus()) || "PENDING".equalsIgnoreCase(r.getStatus())) {
                openCount++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trust, Safety & Moderation Hub - Admin Portal</title>
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
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Moderation Center</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #cbd5e1;">Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminFinancialServlet" style="color: #cbd5e1;">Financials</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminModerationServlet" style="color: #f8fafc; font-weight: 700;">Moderation</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminActivityLogServlet" style="color: #cbd5e1;">Audit Logs</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminLogoutServlet" style="color: #ef4444; font-weight: 600;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">Trust, Safety & Moderation Operations</h1>
                    <p class="page-subtitle">Resolve patient and practitioner misconduct reports, audit catalog compliance, and manage restrictions.</p>
                </div>
            </div>
        </div>

        <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <strong>&#10003; Action Executed:</strong> <%= successMsg %>
            </div>
        <% } %>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error" style="margin-bottom: 20px;">
                <strong>&#9888; Notice:</strong> <%= errorMsg %>
            </div>
        <% } %>

        <!-- KPI Grid -->
        <div class="kpi-grid">
            <div class="kpi-card" style="border-left: 4px solid #dc2626; background: #fff5f5;">
                <div class="kpi-title">Open Reports / Grievances</div>
                <div class="kpi-value" style="color: #dc2626;"><%= openCount %></div>
                <div style="font-size: 0.82rem; color: #991b1b; margin-top: 4px;">Requires review or punitive action</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #0284c7;">
                <div class="kpi-title">Total Reports Logged</div>
                <div class="kpi-value" style="color: #0284c7;"><%= reports != null ? reports.size() : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Across all five platform modules</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #16a34a;">
                <div class="kpi-title">Active Catalog Items</div>
                <div class="kpi-value" style="color: #16a34a;"><%= medicines != null ? medicines.size() : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Monitored pharmaceutical products</div>
            </div>
        </div>

        <!-- Feedback & Reports Section -->
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 16px;">
                <div>
                    <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">User Grievances & Misconduct Reports</h2>
                    <p class="page-subtitle">Submitted by patients, doctors, or administrative audits.</p>
                </div>

                <form action="<%= request.getContextPath() %>/AdminModerationServlet" method="get" style="display: flex; gap: 8px;">
                    <select name="status" class="form-control" onchange="this.form.submit()">
                        <option value="ALL" <%= "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>All Statuses</option>
                        <option value="OPEN" <%= "OPEN".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>OPEN</option>
                        <option value="REVIEWED" <%= "REVIEWED".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>REVIEWED</option>
                        <option value="ACTION_TAKEN" <%= "ACTION_TAKEN".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>ACTION_TAKEN</option>
                    </select>
                </form>
            </div>

            <% if (reports == null || reports.isEmpty()) { %>
                <div class="empty-state" style="padding: 30px;">
                    <div class="empty-state-icon">&#128077;</div>
                    <p class="empty-state-text">No reports logged under the selected criteria.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Timestamp</th>
                                <th style="padding: 12px;">Reporter</th>
                                <th style="padding: 12px;">Target Entity</th>
                                <th style="padding: 12px;">Rating / Urgency</th>
                                <th style="padding: 12px;">Grievance Details</th>
                                <th style="padding: 12px;">Status</th>
                                <th style="padding: 12px; text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (FeedbackReport rep : reports) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700;">#<%= rep.getReportId() %></td>
                                    <td style="padding: 12px; font-size: 0.82rem;"><%= rep.getCreatedAt() %></td>
                                    <td style="padding: 12px;">
                                        <span class="badge" style="background: #f1f5f9; color: #334155;"><%= rep.getReporterRole() %></span>
                                        <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 2px;"><%= rep.getReporterIdentifier() %></div>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong><%= rep.getTargetType() %></strong><br>
                                        <span style="font-size: 0.8rem; color: var(--text-muted);">Ref: <%= rep.getTargetIdentifier() %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if (rep.getRating() > 0) { %>
                                            <span style="color: #f59e0b;">&#9733; <%= rep.getRating() %>/5</span>
                                        <% } else { %>
                                            <span style="color: #dc2626; font-weight: 600;">Misconduct Report</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; max-width: 280px; font-size: 0.85rem;">
                                        <%= rep.getComments() %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("OPEN".equalsIgnoreCase(rep.getStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626; font-weight: 700;">&#9888; OPEN</span>
                                        <% } else if ("ACTION_TAKEN".equalsIgnoreCase(rep.getStatus())) { %>
                                            <span class="badge badge-verified">&#10003; ACTION TAKEN</span>
                                        <% } else { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= rep.getStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <% if ("OPEN".equalsIgnoreCase(rep.getStatus())) { %>
                                            <div style="display: flex; gap: 4px; justify-content: flex-end;">
                                                <form action="<%= request.getContextPath() %>/AdminModerationServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="action" value="UPDATE_REPORT_STATUS">
                                                    <input type="hidden" name="reportId" value="<%= rep.getReportId() %>">
                                                    <input type="hidden" name="status" value="REVIEWED">
                                                    <button type="submit" class="btn btn-outline" style="padding: 3px 8px; font-size: 0.78rem;">Mark Reviewed</button>
                                                </form>
                                                <form action="<%= request.getContextPath() %>/AdminModerationServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="action" value="UPDATE_REPORT_STATUS">
                                                    <input type="hidden" name="reportId" value="<%= rep.getReportId() %>">
                                                    <input type="hidden" name="status" value="ACTION_TAKEN">
                                                    <button type="submit" class="btn btn-primary" style="padding: 3px 8px; font-size: 0.78rem; background: #dc2626; border-color: #dc2626;">Enforce Action</button>
                                                </form>
                                            </div>
                                        <% } else { %>
                                            <span style="color: var(--text-muted); font-size: 0.8rem;">Resolved</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Medicine Catalog Moderation Section -->
        <div class="card" style="margin-bottom: 24px;">
            <div class="card-header">
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Medicine Catalog Moderation (Block / Activate)</h2>
                <p class="page-subtitle">Instantly ban counterfeit or flagged medicines from appearing in the patient pharmacy store.</p>
            </div>

            <% if (medicines != null && !medicines.isEmpty()) { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Medicine Name</th>
                                <th style="padding: 12px;">Category</th>
                                <th style="padding: 12px;">Manufacturer</th>
                                <th style="padding: 12px;">Unit Price</th>
                                <th style="padding: 12px;">Moderation Status</th>
                                <th style="padding: 12px; text-align: right;">Moderation Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Medicine med : medicines) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= med.getMedicineId() %></td>
                                    <td style="padding: 12px;"><strong><%= med.getMedicineName() %></strong></td>
                                    <td style="padding: 12px;"><%= med.getCategory() %></td>
                                    <td style="padding: 12px; color: var(--text-muted);"><%= med.getManufacturer() %></td>
                                    <td style="padding: 12px; font-weight: 600;">&#8377;<%= med.getUnitPrice() %></td>
                                    <td style="padding: 12px;">
                                        <% if ("BLOCKED".equalsIgnoreCase(med.getModerationStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#128274; BLOCKED</span>
                                        <% } else { %>
                                            <span class="badge badge-verified">&#10003; ACTIVE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <form action="<%= request.getContextPath() %>/AdminModerationServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="TOGGLE_MEDICINE">
                                            <input type="hidden" name="medicineId" value="<%= med.getMedicineId() %>">
                                            <% if ("BLOCKED".equalsIgnoreCase(med.getModerationStatus())) { %>
                                                <input type="hidden" name="targetStatus" value="ACTIVE">
                                                <button type="submit" class="btn btn-primary" style="padding: 3px 8px; font-size: 0.8rem;">Unblock Item</button>
                                            <% } else { %>
                                                <input type="hidden" name="targetStatus" value="BLOCKED">
                                                <button type="submit" class="btn btn-outline" style="padding: 3px 8px; font-size: 0.8rem; color: #dc2626; border-color: #dc2626;" onclick="return confirm('Block this medicine from pharmacy catalog?');">&#128274; Block Item</button>
                                            <% } %>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Ambulance Fleet Moderation Section -->
        <div class="card">
            <div class="card-header">
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Ambulance Fleet Moderation (Suspend / Activate)</h2>
                <p class="page-subtitle">Restrict vehicles with safety violations from rapid response dispatch.</p>
            </div>

            <% if (ambulances != null && !ambulances.isEmpty()) { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Plate Number</th>
                                <th style="padding: 12px;">Driver Name & Phone</th>
                                <th style="padding: 12px;">Base Hospital</th>
                                <th style="padding: 12px;">Moderation Status</th>
                                <th style="padding: 12px; text-align: right;">Moderation Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Ambulance amb : ambulances) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= amb.getAmbulanceId() %></td>
                                    <td style="padding: 12px; font-weight: 700;"><%= amb.getVehicleNumber() %></td>
                                    <td style="padding: 12px;"><%= amb.getDriverName() %> (<%= amb.getDriverPhone() %>)</td>
                                    <td style="padding: 12px;"><%= amb.getBaseHospital() %></td>
                                    <td style="padding: 12px;">
                                        <% if ("BLOCKED".equalsIgnoreCase(amb.getModerationStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#128274; SUSPENDED</span>
                                        <% } else { %>
                                            <span class="badge badge-verified">&#10003; ACTIVE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <form action="<%= request.getContextPath() %>/AdminModerationServlet" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="TOGGLE_AMBULANCE">
                                            <input type="hidden" name="ambulanceId" value="<%= amb.getAmbulanceId() %>">
                                            <% if ("BLOCKED".equalsIgnoreCase(amb.getModerationStatus())) { %>
                                                <input type="hidden" name="targetStatus" value="ACTIVE">
                                                <button type="submit" class="btn btn-primary" style="padding: 3px 8px; font-size: 0.8rem;">Lift Suspension</button>
                                            <% } else { %>
                                                <input type="hidden" name="targetStatus" value="BLOCKED">
                                                <button type="submit" class="btn btn-outline" style="padding: 3px 8px; font-size: 0.8rem; color: #dc2626; border-color: #dc2626;" onclick="return confirm('Suspend this ambulance unit?');">&#128274; Suspend Unit</button>
                                            <% } %>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>

            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="<%= request.getContextPath() %>/AdminDashboardServlet" class="btn btn-secondary">
                    &larr; Back to Admin Dashboard
                </a>
            </div>
        </div>
    </main>

    <footer class="footer" style="background: #1e293b; color: #94a3b8; border-top: 1px solid #334155;">
        <p>&copy; 2026 Online Medical System. Trust & Safety Moderation Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
