<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.pharmacy.Medicine" %>
<%@ page import="service.pharmacy.PharmacyService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<String> categories = (List<String>) request.getAttribute("categories");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    String searchQuery = (String) request.getAttribute("searchQuery");

    if (medicines == null) {
        PharmacyService pharmacyService = new PharmacyService();
        medicines = pharmacyService.getAllActiveMedicines();
        categories = pharmacyService.getCategories();
    }

    String rxIdParam = request.getParameter("rxId");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pharmacy Medicine Catalog - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .med-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .med-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 18px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .med-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }
        .med-price {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary-color);
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/index.html" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Pharmacy Shop</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <% if (session != null && session.getAttribute("userId") != null) { %>
                    <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/MyPharmacyOrdersServlet">My Orders</a></li>
                    <li><a href="<%= request.getContextPath() %>/PatientPrescriptionsServlet">My Prescriptions</a></li>
                    <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
                <% } else { %>
                    <li><a href="<%= request.getContextPath() %>/index.html">Home</a></li>
                    <li><a href="<%= request.getContextPath() %>/modules/patient/patient_login.jsp">Sign In</a></li>
                <% } %>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title">&#128138; Pharmacy & Medicine Inventory</h1>
                    <p class="page-subtitle">Order genuine prescription medications, healthcare supplements, and OTC remedies.</p>
                </div>
                <% if (session != null && session.getAttribute("userId") != null) { %>
                    <div>
                        <a href="<%= request.getContextPath() %>/MyPharmacyOrdersServlet" class="btn btn-outline">
                            &#128230; My Past Orders
                        </a>
                    </div>
                <% } %>
            </div>

            <% if (rxIdParam != null && !rxIdParam.trim().isEmpty()) { %>
                <div class="alert alert-info" style="margin-bottom: 20px;">
                    <strong>&#128196; Linked Prescription #RX-<%= rxIdParam %>:</strong>
                    Browse or search the medications recommended on your doctor's prescription below and click <strong>Order Now</strong> to request immediate fulfillment.
                </div>
            <% } %>

            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= successMsg %>
                </div>
            <% } %>

            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= errorMsg %>
                </div>
            <% } %>

            <!-- Search & Filter Bar -->
            <form action="<%= request.getContextPath() %>/PharmacyCatalogServlet" method="get" style="display: flex; gap: 12px; flex-wrap: wrap; background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid var(--border-color);">
                <% if (rxIdParam != null) { %>
                    <input type="hidden" name="rxId" value="<%= rxIdParam %>">
                <% } %>
                <div style="flex: 2; min-width: 220px;">
                    <input type="text" name="query" class="form-control" placeholder="Search medicines by name, manufacturer, or ailment..." value="<%= searchQuery != null ? searchQuery : "" %>">
                </div>
                <div style="flex: 1; min-width: 160px;">
                    <select name="category" class="form-control">
                        <option value="ALL">All Categories</option>
                        <% if (categories != null) {
                            for (String cat : categories) { %>
                                <option value="<%= cat %>" <%= cat.equalsIgnoreCase(selectedCategory) ? "selected" : "" %>><%= cat %></option>
                        <%  }
                        } %>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn btn-primary" style="padding: 10px 20px;">Filter Catalog</button>
                    <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-secondary" style="padding: 10px 14px;">Reset</a>
                </div>
            </form>

            <!-- Medicines Grid -->
            <% if (medicines == null || medicines.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128138;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No medicines found matching criteria.</h2>
                    <p class="empty-state-text">Try searching with a different medication name or clearing filters.</p>
                </div>
            <% } else { %>
                <div class="med-grid">
                    <% for (Medicine med : medicines) { %>
                        <div class="med-card">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; margin-bottom: 8px;">
                                    <span class="badge" style="background: #e0f2fe; color: #0369a1; font-size: 0.8rem;"><%= med.getCategory() %></span>
                                    <% if (med.isRequiresPrescription()) { %>
                                        <span class="badge" style="background: #fef3c7; color: #92400e; font-size: 0.75rem;">Rx Required</span>
                                    <% } else { %>
                                        <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.75rem;">OTC</span>
                                    <% } %>
                                </div>
                                <h3 style="font-size: 1.15rem; color: var(--text-main); margin-bottom: 4px;"><%= med.getMedicineName() %></h3>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 8px;">
                                    Mfg: <strong><%= med.getManufacturer() != null ? med.getManufacturer() : "Certified Pharma" %></strong>
                                </p>
                                <p style="font-size: 0.88rem; color: #475569; margin-bottom: 12px; min-height: 40px;">
                                    <%= med.getDescription() != null ? med.getDescription() : "Essential pharmaceutical product." %>
                                </p>
                            </div>

                            <div style="border-top: 1px solid var(--border-color); padding-top: 12px; margin-top: 8px;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                    <div>
                                        <span style="font-size: 0.8rem; color: var(--text-muted); display: block;">Unit Price:</span>
                                        <span class="med-price">&#8377;<%= med.getUnitPrice() %></span>
                                    </div>
                                    <div style="text-align: right;">
                                        <% if (med.getStockQuantity() > 0) { %>
                                            <span style="color: #16a34a; font-size: 0.85rem; font-weight: 600;">In Stock (<%= med.getStockQuantity() %>)</span>
                                        <% } else { %>
                                            <span style="color: #dc2626; font-size: 0.85rem; font-weight: 600;">Out of Stock</span>
                                        <% } %>
                                    </div>
                                </div>

                                <% if (session != null && session.getAttribute("userId") != null) { %>
                                    <% if (med.getStockQuantity() > 0) { %>
                                        <form action="<%= request.getContextPath() %>/PlacePharmacyOrderServlet" method="post" style="display: flex; gap: 8px; align-items: center;">
                                            <input type="hidden" name="medicineId" value="<%= med.getMedicineId() %>">
                                            <% if (rxIdParam != null) { %>
                                                <input type="hidden" name="prescriptionId" value="<%= rxIdParam %>">
                                            <% } %>
                                            <input type="number" name="quantity" value="1" min="1" max="<%= Math.min(10, med.getStockQuantity()) %>" class="form-control" style="width: 70px; padding: 6px;">
                                            <select name="paymentMethod" class="form-control" style="flex: 1; padding: 6px; font-size: 0.85rem;">
                                                <option value="CASH">Cash on Delivery</option>
                                                <option value="UPI">UPI Payment</option>
                                                <option value="CARD">Card Payment</option>
                                            </select>
                                            <button type="submit" class="btn btn-primary" style="padding: 6px 12px; font-size: 0.88rem; white-space: nowrap;">
                                                Order Now
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <button type="button" class="btn btn-secondary btn-block" disabled>Temporarily Unavailable</button>
                                    <% } %>
                                <% } else { %>
                                    <a href="<%= request.getContextPath() %>/modules/patient/patient_login.jsp" class="btn btn-outline btn-block" style="padding: 6px 12px; font-size: 0.88rem;">
                                        Sign In to Order
                                    </a>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <% if (session != null && session.getAttribute("userId") != null) { %>
                    <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                        &larr; Back to Patient Dashboard
                    </a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/index.html" class="btn btn-secondary">
                        &larr; Back to Home
                    </a>
                <% } %>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Pharmacy Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
