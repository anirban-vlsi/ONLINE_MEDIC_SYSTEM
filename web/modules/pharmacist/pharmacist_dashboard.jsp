<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="model.pharmacist.Pharmacist" %>
<%@ page import="model.pharmacy.Medicine" %>
<%@ page import="model.pharmacy.PharmacyOrder" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Pharmacist pharmacist = (Pharmacist) request.getAttribute("pharmacist");
    if (pharmacist == null && session != null) {
        pharmacist = (Pharmacist) session.getAttribute("loggedInPharmacist");
    }

    if (pharmacist == null) {
        response.sendRedirect(request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp");
        return;
    }

    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<PharmacyOrder> orders = (List<PharmacyOrder>) request.getAttribute("recentOrders");
    BigDecimal totalEarnings = (BigDecimal) request.getAttribute("totalEarnings");
    if (totalEarnings == null) {
        totalEarnings = BigDecimal.ZERO;
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pharmacist Dashboard - Online Medical System</title>
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
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: #fff;
            margin: 6% auto;
            padding: 24px;
            border-radius: 8px;
            max-width: 600px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body style="background-color: #f8fafc;">

    <!-- Navigation Header -->
    <header class="navbar" style="border-bottom: 2px solid #0284c7;">
        <a href="<%= request.getContextPath() %>/PharmacistDashboardServlet" class="navbar-brand">
            <span class="cross-icon" style="color: #0284c7;">&#128138;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #0284c7; margin-left: 8px;">| <%= pharmacist.getPharmacyName() %></span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><span style="color: #475569; font-weight: 500;">&#128100; <%= pharmacist.getFullName() %></span></li>
                <li><a href="#ordersSection">Orders</a></li>
                <li><a href="#inventorySection">Inventory</a></li>
                <li><a href="#profileSection">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/PharmacistLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <!-- Hero Header -->
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">Pharmacy Operations Desk</h1>
                    <p class="page-subtitle">Manage medicine stocks, dispense prescriptions, and monitor net fulfillment revenue.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" onclick="openAddMedicineModal()">
                        + Add New Medicine
                    </button>
                </div>
            </div>
        </div>

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

        <!-- KPI Metrics Grid -->
        <div class="kpi-grid">
            <div class="kpi-card" style="border-left: 4px solid #059669;">
                <div class="kpi-title">Net Pharmacy Earnings</div>
                <div class="kpi-value" style="color: #059669;">&#8377;<%= totalEarnings.setScale(2, java.math.RoundingMode.HALF_UP) %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">
                    After 10% platform commission deduction
                </div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #0284c7;">
                <div class="kpi-title">Total Medicine Catalog</div>
                <div class="kpi-value" style="color: #0284c7;"><%= medicines != null ? medicines.size() : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Active & cataloged lines</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #d97706;">
                <div class="kpi-title">Fulfillment Orders</div>
                <div class="kpi-value" style="color: #d97706;"><%= orders != null ? orders.size() : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Recent customer prescriptions & orders</div>
            </div>
        </div>

        <!-- Orders Section -->
        <div id="ordersSection" class="card" style="margin-bottom: 24px;">
            <div class="card-header">
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Prescription & Medication Orders</h2>
                <p class="page-subtitle">Review orders and update dispensing pipeline status.</p>
            </div>

            <% if (orders == null || orders.isEmpty()) { %>
                <div class="empty-state" style="padding: 30px;">
                    <div class="empty-state-icon">&#128230;</div>
                    <p class="empty-state-text">No pharmacy orders received yet.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Order ID</th>
                                <th style="padding: 12px;">Order Date</th>
                                <th style="padding: 12px;">Customer Details</th>
                                <th style="padding: 12px;">Total Bill</th>
                                <th style="padding: 12px;">Payment</th>
                                <th style="padding: 12px;">Current Status</th>
                                <th style="padding: 12px; text-align: right;">Update Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (PharmacyOrder ord : orders) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700;">#<%= ord.getOrderId() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem;"><%= ord.getCreatedAt() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem;">
                                        <strong><%= ord.getUserName() != null ? ord.getUserName() : "Customer #" + ord.getUserId() %></strong><br>
                                        <span style="color: var(--text-muted);"><%= ord.getUserEmail() != null ? ord.getUserEmail() : "Online Customer" %></span>
                                    </td>
                                    <td style="padding: 12px; font-weight: 600;">&#8377;<%= ord.getTotalAmount() %></td>
                                    <td style="padding: 12px;">
                                        <span class="badge badge-verified" style="font-size: 0.75rem;"><%= ord.getPaymentStatus() %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("DISPENSED".equalsIgnoreCase(ord.getOrderStatus()) || "DELIVERED".equalsIgnoreCase(ord.getOrderStatus())) { %>
                                            <span class="badge badge-verified">&#10003; <%= ord.getOrderStatus() %></span>
                                        <% } else if ("READY".equalsIgnoreCase(ord.getOrderStatus())) { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1;">READY FOR PICKUP</span>
                                        <% } else if ("CANCELLED".equalsIgnoreCase(ord.getOrderStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#10007; CANCELLED</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">&#9203; <%= ord.getOrderStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <form action="<%= request.getContextPath() %>/PharmacistDashboardServlet" method="post" style="display: inline-flex; gap: 6px; align-items: center;">
                                            <input type="hidden" name="action" value="UPDATE_ORDER_STATUS">
                                            <input type="hidden" name="orderId" value="<%= ord.getOrderId() %>">
                                            <select name="orderStatus" class="form-control" style="padding: 4px 8px; font-size: 0.82rem; width: auto;">
                                                <option value="PROCESSING" <%= "PROCESSING".equalsIgnoreCase(ord.getOrderStatus()) ? "selected" : "" %>>PROCESSING</option>
                                                <option value="READY" <%= "READY".equalsIgnoreCase(ord.getOrderStatus()) ? "selected" : "" %>>READY</option>
                                                <option value="DISPENSED" <%= "DISPENSED".equalsIgnoreCase(ord.getOrderStatus()) ? "selected" : "" %>>DISPENSED</option>
                                                <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(ord.getOrderStatus()) ? "selected" : "" %>>CANCELLED</option>
                                            </select>
                                            <button type="submit" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;">Update</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Inventory Section -->
        <div id="inventorySection" class="card" style="margin-bottom: 24px;">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Medicine Inventory & Pricing Catalog</h2>
                    <p class="page-subtitle">Track stock units, update pricing, and ensure compliance.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" onclick="openAddMedicineModal()">
                        + Add Medicine
                    </button>
                </div>
            </div>

            <% if (medicines == null || medicines.isEmpty()) { %>
                <div class="empty-state" style="padding: 30px;">
                    <div class="empty-state-icon">&#128138;</div>
                    <p class="empty-state-text">No medicines registered in catalog yet.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Medicine Name</th>
                                <th style="padding: 12px;">Category</th>
                                <th style="padding: 12px;">Manufacturer</th>
                                <th style="padding: 12px;">Price</th>
                                <th style="padding: 12px;">Stock Units</th>
                                <th style="padding: 12px;">Rx Required</th>
                                <th style="padding: 12px;">Moderation</th>
                                <th style="padding: 12px; text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Medicine m : medicines) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= m.getMedicineId() %></td>
                                    <td style="padding: 12px;">
                                        <strong><%= m.getMedicineName() %></strong>
                                    </td>
                                    <td style="padding: 12px;"><span class="badge" style="background: #f1f5f9; color: #334155;"><%= m.getCategory() %></span></td>
                                    <td style="padding: 12px; font-size: 0.85rem; color: var(--text-muted);"><%= m.getManufacturer() %></td>
                                    <td style="padding: 12px; font-weight: 700; color: #059669;">&#8377;<%= m.getUnitPrice() %></td>
                                    <td style="padding: 12px;">
                                        <% if (m.getStockQuantity() <= 5) { %>
                                            <span style="color: #dc2626; font-weight: 700;"><%= m.getStockQuantity() %> (Low)</span>
                                        <% } else { %>
                                            <span><%= m.getStockQuantity() %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <%= m.isRequiresPrescription() ? "<span style='color: #b45309; font-weight: 600;'>&#9888; Yes</span>" : "No" %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("BLOCKED".equalsIgnoreCase(m.getModerationStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#128274; BLOCKED</span>
                                        <% } else { %>
                                            <span class="badge badge-verified">&#10003; ACTIVE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem;"
                                                onclick="openEditMedicineModal(<%= m.getMedicineId() %>, '<%= m.getMedicineName().replace("'", "\\'") %>', '<%= m.getCategory().replace("'", "\\'") %>', '<%= m.getManufacturer().replace("'", "\\'") %>', <%= m.getUnitPrice() %>, <%= m.getStockQuantity() %>, <%= m.isRequiresPrescription() %>, '<%= m.getModerationStatus() %>')">
                                            Edit
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Profile Section -->
        <div id="profileSection" class="card">
            <div class="card-header">
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Pharmacist Operator Profile Details</h2>
                <p class="page-subtitle">Keep your dispensary licensing and contact details up-to-date.</p>
            </div>
            <form action="<%= request.getContextPath() %>/PharmacistDashboardServlet" method="post" style="max-width: 650px;">
                <input type="hidden" name="action" value="UPDATE_PROFILE">

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label">Full Name <span class="required">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<%= pharmacist.getFullName() %>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Contact Phone</label>
                        <input type="text" name="phone" class="form-control" value="<%= pharmacist.getPhone() != null ? pharmacist.getPhone() : "" %>">
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label">Pharmacy / Dispensary Name <span class="required">*</span></label>
                    <input type="text" name="pharmacyName" class="form-control" value="<%= pharmacist.getPharmacyName() %>" required>
                </div>

                <button type="submit" class="btn btn-primary">Save Profile Updates</button>
            </form>
        </div>
    </main>

    <!-- Medicine Modal (Add / Edit) -->
    <div id="medicineModal" class="modal">
        <div class="modal-content">
            <h2 id="modalMedTitle" style="font-size: 1.25rem; color: #1e293b; margin-bottom: 14px;">Register New Medicine</h2>
            <form action="<%= request.getContextPath() %>/PharmacistDashboardServlet" method="post">
                <input type="hidden" name="action" value="SAVE_MEDICINE">
                <input type="hidden" name="medicineId" id="modalMedId" value="0">
                <input type="hidden" name="moderationStatus" id="modalModerationStatus" value="ACTIVE">

                <div class="form-group" style="margin-bottom: 12px;">
                    <label class="form-label">Medicine Name <span class="required">*</span></label>
                    <input type="text" name="medicineName" id="modalMedName" class="form-control" required>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <input type="text" name="category" id="modalCategory" class="form-control" placeholder="e.g., Antibiotic, Analgesic">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Manufacturer</label>
                        <input type="text" name="manufacturer" id="modalManufacturer" class="form-control" placeholder="e.g., Sun Pharma">
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label">Unit Price (&#8377;) <span class="required">*</span></label>
                        <input type="number" step="0.01" name="unitPrice" id="modalPrice" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Stock Quantity <span class="required">*</span></label>
                        <input type="number" name="stockQuantity" id="modalStock" class="form-control" required>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 18px;">
                    <label style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                        <input type="checkbox" name="requiresPrescription" id="modalRx" value="true">
                        Requires Doctor Prescription (Rx)
                    </label>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-secondary" onclick="closeMedicineModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="modalSubmitBtn">Save Medicine</button>
                </div>
            </form>
        </div>
    </div>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Pharmacy Management Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out of the Pharmacy Portal?");
        }
        function openAddMedicineModal() {
            document.getElementById('modalMedTitle').innerText = "Register New Medicine";
            document.getElementById('modalSubmitBtn').innerText = "Register Medicine";
            document.getElementById('modalMedId').value = "0";
            document.getElementById('modalMedName').value = "";
            document.getElementById('modalCategory').value = "";
            document.getElementById('modalManufacturer').value = "";
            document.getElementById('modalPrice').value = "50.00";
            document.getElementById('modalStock').value = "100";
            document.getElementById('modalRx').checked = false;
            document.getElementById('modalModerationStatus').value = "ACTIVE";
            document.getElementById('medicineModal').style.display = 'block';
        }
        function openEditMedicineModal(id, name, cat, mfg, price, stock, rx, modStatus) {
            document.getElementById('modalMedTitle').innerText = "Edit Medicine #" + id;
            document.getElementById('modalSubmitBtn').innerText = "Update Medicine";
            document.getElementById('modalMedId').value = id;
            document.getElementById('modalMedName').value = name;
            document.getElementById('modalCategory').value = cat;
            document.getElementById('modalManufacturer').value = mfg;
            document.getElementById('modalPrice').value = price;
            document.getElementById('modalStock').value = stock;
            document.getElementById('modalRx').checked = rx;
            document.getElementById('modalModerationStatus').value = modStatus;
            document.getElementById('medicineModal').style.display = 'block';
        }
        function closeMedicineModal() {
            document.getElementById('medicineModal').style.display = 'none';
        }
        window.onclick = function(e) {
            var modal = document.getElementById('medicineModal');
            if (e.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>
