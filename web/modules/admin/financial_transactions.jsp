<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="model.admin.Admin" %>
<%@ page import="model.finance.FinancialTransaction" %>
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

    BigDecimal grossRevenue = (BigDecimal) request.getAttribute("grossRevenue");
    BigDecimal adminProfit = (BigDecimal) request.getAttribute("adminProfit");
    BigDecimal doctorPayouts = (BigDecimal) request.getAttribute("doctorPayouts");
    BigDecimal pharmacyPayouts = (BigDecimal) request.getAttribute("pharmacyPayouts");
    List<FinancialTransaction> transactions = (List<FinancialTransaction>) request.getAttribute("transactions");
    String serviceFilter = (String) request.getAttribute("serviceFilter");
    if (serviceFilter == null) serviceFilter = "ALL";

    if (grossRevenue == null) grossRevenue = BigDecimal.ZERO;
    if (adminProfit == null) adminProfit = BigDecimal.ZERO;
    if (doctorPayouts == null) doctorPayouts = BigDecimal.ZERO;
    if (pharmacyPayouts == null) pharmacyPayouts = BigDecimal.ZERO;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Management & Commission Ledger - Admin Portal</title>
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
            <span style="font-size: 0.88rem; font-weight: 600; color: #ef4444; margin-left: 8px;">| Financial Ledger</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/AdminDashboardServlet" style="color: #cbd5e1;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminDoctorServlet" style="color: #cbd5e1;">Doctors</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminPatientServlet" style="color: #cbd5e1;">Patients</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminFinancialServlet" style="color: #f8fafc; font-weight: 700;">Financials</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminModerationServlet" style="color: #cbd5e1;">Moderation</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminActivityLogServlet" style="color: #cbd5e1;">Audit Logs</a></li>
                <li><a href="<%= request.getContextPath() %>/AdminLogoutServlet" style="color: #ef4444; font-weight: 600;">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">Platform Financial Ledger & Commission Settlement</h1>
                    <p class="page-subtitle">Track automated 15% doctor consultation and 10% pharmacy fulfillment revenue splits.</p>
                </div>
            </div>
        </div>

        <!-- Financial KPI Metrics -->
        <div class="kpi-grid">
            <div class="kpi-card" style="border-left: 4px solid #0284c7;">
                <div class="kpi-title">Total Gross Volume</div>
                <div class="kpi-value" style="color: #0284c7;">&#8377;<%= grossRevenue.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Total patient payments received</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #16a34a; background: #f0fdf4;">
                <div class="kpi-title">Platform Commission Profit</div>
                <div class="kpi-value" style="color: #16a34a;">&#8377;<%= adminProfit.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
                <div style="font-size: 0.82rem; color: #15803d; margin-top: 4px; font-weight: 600;">15% Doctor + 10% Pharmacy cut</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #8b5cf6;">
                <div class="kpi-title">Doctor Payouts (85%)</div>
                <div class="kpi-value" style="color: #8b5cf6;">&#8377;<%= doctorPayouts.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Net clinical practitioner disbursements</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #d97706;">
                <div class="kpi-title">Pharmacy Payouts (90%)</div>
                <div class="kpi-value" style="color: #d97706;">&#8377;<%= pharmacyPayouts.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Net medication fulfillment disbursements</div>
            </div>
        </div>

        <!-- Filter Controls -->
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 16px;">
                <h2 style="font-size: 1.2rem; color: #1e293b; margin: 0;">Transaction Settlement History</h2>
                <form action="<%= request.getContextPath() %>/AdminFinancialServlet" method="get" style="display: flex; gap: 8px;">
                    <select name="serviceType" class="form-control" onchange="this.form.submit()">
                        <option value="ALL" <%= "ALL".equalsIgnoreCase(serviceFilter) ? "selected" : "" %>>All Services</option>
                        <option value="APPOINTMENT" <%= "APPOINTMENT".equalsIgnoreCase(serviceFilter) ? "selected" : "" %>>Doctor Appointments (15% split)</option>
                        <option value="PHARMACY" <%= "PHARMACY".equalsIgnoreCase(serviceFilter) ? "selected" : "" %>>Pharmacy Orders (10% split)</option>
                    </select>
                </form>
            </div>

            <% if (transactions == null || transactions.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128179;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No financial transactions found.</h2>
                    <p class="empty-state-text">No payment records exist for the selected filter.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Tx ID</th>
                                <th style="padding: 12px;">Timestamp</th>
                                <th style="padding: 12px;">Service</th>
                                <th style="padding: 12px;">Reference</th>
                                <th style="padding: 12px;">Patient ID</th>
                                <th style="padding: 12px;">Provider</th>
                                <th style="padding: 12px;">Gross Paid</th>
                                <th style="padding: 12px;">Admin Rate</th>
                                <th style="padding: 12px;">Admin Profit</th>
                                <th style="padding: 12px;">Provider Payout</th>
                                <th style="padding: 12px;">Method</th>
                                <th style="padding: 12px;">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (FinancialTransaction tx : transactions) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700;">#<%= tx.getTransactionId() %></td>
                                    <td style="padding: 12px; font-size: 0.82rem;"><%= tx.getTransactionDate() %></td>
                                    <td style="padding: 12px;">
                                        <% if ("APPOINTMENT".equalsIgnoreCase(tx.getServiceType())) { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1;">APPOINTMENT</span>
                                        <% } else { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309;">PHARMACY</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; font-weight: 600;">Ref #<%= tx.getReferenceId() %></td>
                                    <td style="padding: 12px;">User #<%= tx.getPatientUserId() %></td>
                                    <td style="padding: 12px; font-weight: 500;"><%= tx.getProviderId() %></td>
                                    <td style="padding: 12px; font-weight: 700;">&#8377;<%= tx.getGrossAmount() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem;"><%= tx.getCommissionRate().multiply(new BigDecimal(100)).intValue() %>%</td>
                                    <td style="padding: 12px; font-weight: 700; color: #16a34a;">+&#8377;<%= tx.getAdminCommission() %></td>
                                    <td style="padding: 12px; font-weight: 600; color: #0284c7;">&#8377;<%= tx.getProviderPayout() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem;"><%= tx.getPaymentMethod() %></td>
                                    <td style="padding: 12px;">
                                        <span class="badge badge-verified" style="font-size: 0.75rem;"><%= tx.getTransactionStatus() %></span>
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
        <p>&copy; 2026 Online Medical System. Financial Settlement Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
