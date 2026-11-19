<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.pharmacy.PharmacyOrder" %>
<%@ page import="model.pharmacy.PharmacyOrderItem" %>
<%@ page import="service.pharmacy.PharmacyService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    List<PharmacyOrder> orders = (List<PharmacyOrder>) request.getAttribute("orders");
    if (orders == null) {
        PharmacyService pharmacyService = new PharmacyService();
        orders = pharmacyService.getOrdersByUserId(userId);
    }

    String successMsg = request.getParameter("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Pharmacy Orders - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Pharmacy Orders</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/PharmacyCatalogServlet">Pharmacy Shop</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientPrescriptionsServlet">My Prescriptions</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">&#128230; My Pharmacy Orders</h1>
                    <p class="page-subtitle">Track your medication orders, payment statuses, and fulfillment timeline.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-primary">
                        + Browse Medicine Shop
                    </a>
                </div>
            </div>

            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= successMsg %>
                </div>
            <% } %>

            <% if (orders == null || orders.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128230;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No orders placed yet.</h2>
                    <p class="empty-state-text" style="max-width: 520px; margin: 0 auto 20px auto;">
                        Order genuine pharmaceutical products and doorstep prescription supplies from our catalog.
                    </p>
                    <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-primary">
                        Browse Medicines &rarr;
                    </a>
                </div>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 20px; margin-top: 14px;">
                    <% for (PharmacyOrder o : orders) { %>
                        <div class="card" style="border: 1px solid var(--border-color); background: #fafafa; margin-bottom: 0;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px; margin-bottom: 12px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px;">
                                <div>
                                    <span style="font-weight: 700; color: var(--primary-color); font-size: 1.15rem;">
                                        Order #ORD-<%= o.getOrderId() %>
                                    </span>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 2px;">
                                        Placed: <%= o.getCreatedAt() %> &bull; Payment: <strong><%= o.getPaymentMethod() %></strong> (<%= o.getPaymentStatus() %>)
                                    </div>
                                </div>
                                <div style="text-align: right;">
                                    <% if ("DISPENSED".equalsIgnoreCase(o.getOrderStatus())) { %>
                                        <span class="badge badge-verified">&#10003; DISPENSED</span>
                                    <% } else if ("CANCELLED".equalsIgnoreCase(o.getOrderStatus())) { %>
                                        <span class="badge" style="background:#fee2e2; color:#dc2626;">&#10007; CANCELLED</span>
                                    <% } else { %>
                                        <span class="badge" style="background:#dbeafe; color:#1e40af;">&#9203; <%= o.getOrderStatus() %></span>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Items List -->
                            <div style="margin-bottom: 12px;">
                                <table style="width: 100%; border-collapse: collapse; font-size: 0.92rem; background: #ffffff; border-radius: 6px; overflow: hidden; border: 1px solid var(--border-color);">
                                    <thead>
                                        <tr style="background: #f1f5f9; text-align: left;">
                                            <th style="padding: 8px 12px;">Item</th>
                                            <th style="padding: 8px 12px; text-align: center;">Qty</th>
                                            <th style="padding: 8px 12px; text-align: right;">Unit Price</th>
                                            <th style="padding: 8px 12px; text-align: right;">Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (PharmacyOrderItem item : o.getItems()) { %>
                                            <tr style="border-bottom: 1px solid var(--border-color);">
                                                <td style="padding: 8px 12px; font-weight: 600;"><%= item.getMedicineName() %></td>
                                                <td style="padding: 8px 12px; text-align: center;"><%= item.getQuantity() %></td>
                                                <td style="padding: 8px 12px; text-align: right;">&#8377;<%= item.getUnitPrice() %></td>
                                                <td style="padding: 8px 12px; text-align: right; font-weight: 600;">&#8377;<%= item.getSubtotal() %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-color); padding-top: 10px;">
                                <div style="font-size: 0.88rem; color: var(--text-muted);">
                                    <% if (o.getPrescriptionId() != null) { %>
                                        Prescription Reference: <strong>#RX-<%= o.getPrescriptionId() %></strong>
                                    <% } else { %>
                                        Direct Pharmacy Purchase
                                    <% } %>
                                </div>
                                <div style="font-size: 1.15rem; font-weight: 700; color: var(--primary-color);">
                                    Total Amount: &#8377;<%= o.getTotalAmount() %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Patient Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-outline">
                    Browse More Medicines &rarr;
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
