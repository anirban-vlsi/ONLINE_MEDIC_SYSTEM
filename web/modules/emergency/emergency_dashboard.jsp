<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.emergency.EmergencyOperator" %>
<%@ page import="model.emergency.Ambulance" %>
<%@ page import="model.emergency.EmergencyRequest" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    EmergencyOperator operator = (EmergencyOperator) request.getAttribute("operator");
    if (operator == null && session != null) {
        operator = (EmergencyOperator) session.getAttribute("loggedInEmergencyOp");
    }

    if (operator == null) {
        response.sendRedirect(request.getContextPath() + "/modules/emergency/emergency_login.jsp");
        return;
    }

    List<Ambulance> fleet = (List<Ambulance>) request.getAttribute("fleet");
    List<EmergencyRequest> activeRequests = (List<EmergencyRequest>) request.getAttribute("activeRequests");

    int availableCount = 0;
    if (fleet != null) {
        for (Ambulance a : fleet) {
            if ("AVAILABLE".equalsIgnoreCase(a.getCurrentStatus()) && !"BLOCKED".equalsIgnoreCase(a.getModerationStatus())) {
                availableCount++;
            }
        }
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Emergency Dispatch Console - Online Medical System</title>
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
    <header class="navbar" style="border-bottom: 2px solid #dc2626;">
        <a href="<%= request.getContextPath() %>/EmergencyDashboardServlet" class="navbar-brand">
            <span class="cross-icon" style="color: #dc2626;">&#128657;</span> Online Medical System
            <span style="font-size: 0.88rem; font-weight: 600; color: #dc2626; margin-left: 8px;">| <%= operator.getDispatchCenter() %></span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><span style="color: #475569; font-weight: 500;">&#128100; <%= operator.getFullName() %></span></li>
                <li><a href="#requestsSection">Emergency Queue</a></li>
                <li><a href="#fleetSection">Ambulance Fleet</a></li>
                <li><a href="#profileSection">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/EmergencyOperatorLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <!-- Hero Header -->
        <div class="card" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title" style="margin-bottom: 4px;">Rapid Response Dispatch Console</h1>
                    <p class="page-subtitle">Coordinate life-critical transport, triage emergency SOS signals, and manage active fleet.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;" onclick="openAddAmbulanceModal()">
                        + Register Ambulance
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
            <div class="kpi-card" style="border-left: 4px solid #16a34a;">
                <div class="kpi-title">Ambulances Available</div>
                <div class="kpi-value" style="color: #16a34a;"><%= availableCount %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">
                    Total Fleet: <%= fleet != null ? fleet.size() : 0 %> units
                </div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #dc2626;">
                <div class="kpi-title">Active Emergency Incidents</div>
                <div class="kpi-value" style="color: #dc2626;"><%= activeRequests != null ? activeRequests.size() : 0 %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Incoming triage requests</div>
            </div>

            <div class="kpi-card" style="border-left: 4px solid #0284c7;">
                <div class="kpi-title">Command Center</div>
                <div class="kpi-value" style="font-size: 1.25rem; color: #0284c7; padding-top: 6px;"><%= operator.getDispatchCenter() %></div>
                <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 4px;">Operator: <%= operator.getFullName() %></div>
            </div>
        </div>

        <!-- Emergency Requests Queue -->
        <div id="requestsSection" class="card" style="margin-bottom: 24px;">
            <div class="card-header">
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Active Emergency SOS Calls & Transport Requests</h2>
                <p class="page-subtitle">Assign available ambulance units immediately upon distress notification.</p>
            </div>

            <% if (activeRequests == null || activeRequests.isEmpty()) { %>
                <div class="empty-state" style="padding: 30px;">
                    <div class="empty-state-icon" style="color: #16a34a;">&#10003;</div>
                    <p class="empty-state-text">No active emergency requests in the queue right now.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">Req ID</th>
                                <th style="padding: 12px;">Timestamp</th>
                                <th style="padding: 12px;">Patient / Caller</th>
                                <th style="padding: 12px;">Contact Phone</th>
                                <th style="padding: 12px;">Pickup Location</th>
                                <th style="padding: 12px;">Status</th>
                                <th style="padding: 12px; text-align: right;">Dispatch Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (EmergencyRequest reqItem : activeRequests) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 700; color: #dc2626;">#<%= reqItem.getRequestId() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem;"><%= reqItem.getCreatedAt() %></td>
                                    <td style="padding: 12px;"><strong><%= reqItem.getPatientName() != null ? reqItem.getPatientName() : "Emergency Caller" %></strong></td>
                                    <td style="padding: 12px; font-weight: 600;"><%= reqItem.getContactPhone() %></td>
                                    <td style="padding: 12px; font-size: 0.85rem; max-width: 250px;">
                                        <%= reqItem.getPickupAddress() != null ? reqItem.getPickupAddress() : "N/A" %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("PENDING".equalsIgnoreCase(reqItem.getRequestStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626; font-weight: 700;">&#9888; PENDING DISPATCH</span>
                                        <% } else if ("DISPATCHED".equalsIgnoreCase(reqItem.getRequestStatus())) { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309; font-weight: 700;">&#128657; EN ROUTE</span>
                                        <% } else if ("COMPLETED".equalsIgnoreCase(reqItem.getRequestStatus())) { %>
                                            <span class="badge badge-verified">&#10003; COMPLETED</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified"><%= reqItem.getRequestStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <% if ("PENDING".equalsIgnoreCase(reqItem.getRequestStatus())) { %>
                                            <form action="<%= request.getContextPath() %>/EmergencyDashboardServlet" method="post" style="display: inline-flex; gap: 6px; align-items: center;">
                                                <input type="hidden" name="action" value="DISPATCH_AMBULANCE">
                                                <input type="hidden" name="requestId" value="<%= reqItem.getRequestId() %>">
                                                <select name="ambulanceId" class="form-control" style="padding: 4px 8px; font-size: 0.82rem; width: auto;" required>
                                                    <option value="">-- Assign Unit --</option>
                                                    <% if (fleet != null) {
                                                        for (Ambulance amb : fleet) {
                                                            if ("AVAILABLE".equalsIgnoreCase(amb.getCurrentStatus()) && !"BLOCKED".equalsIgnoreCase(amb.getModerationStatus())) { %>
                                                                <option value="<%= amb.getAmbulanceId() %>">
                                                                    <%= amb.getVehicleNumber() %> (<%= amb.getAmbulanceType() %>)
                                                                </option>
                                                            <% }
                                                        }
                                                    } %>
                                                </select>
                                                <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem; background: #dc2626; border-color: #dc2626;">Dispatch</button>
                                            </form>
                                        <% } else if ("DISPATCHED".equalsIgnoreCase(reqItem.getRequestStatus())) { %>
                                            <form action="<%= request.getContextPath() %>/EmergencyDashboardServlet" method="post" style="display: inline;">
                                                <input type="hidden" name="action" value="COMPLETE_REQUEST">
                                                <input type="hidden" name="requestId" value="<%= reqItem.getRequestId() %>">
                                                <input type="hidden" name="ambulanceId" value="<%= reqItem.getAmbulanceId() != null ? reqItem.getAmbulanceId() : "" %>">
                                                <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem; background: #16a34a; border-color: #16a34a;">
                                                    &#10003; Mark Transport Complete
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <span style="color: #059669; font-size: 0.85rem; font-weight: 600;">Resolved</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Ambulance Fleet Management -->
        <div id="fleetSection" class="card" style="margin-bottom: 24px;">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Ambulance Fleet Roster & Hospital Base</h2>
                    <p class="page-subtitle">Track vehicle readiness, assign drivers, and monitor service hospitals.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;" onclick="openAddAmbulanceModal()">
                        + Add Ambulance
                    </button>
                </div>
            </div>

            <% if (fleet == null || fleet.isEmpty()) { %>
                <div class="empty-state" style="padding: 30px;">
                    <div class="empty-state-icon">&#128657;</div>
                    <p class="empty-state-text">No ambulances registered to fleet.</p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Vehicle Plate No</th>
                                <th style="padding: 12px;">Type</th>
                                <th style="padding: 12px;">Driver Name & Phone</th>
                                <th style="padding: 12px;">Base Hospital</th>
                                <th style="padding: 12px;">Current Status</th>
                                <th style="padding: 12px;">Moderation</th>
                                <th style="padding: 12px; text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Ambulance amb : fleet) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= amb.getAmbulanceId() %></td>
                                    <td style="padding: 12px; font-weight: 700; color: #1e293b;"><%= amb.getVehicleNumber() %></td>
                                    <td style="padding: 12px;"><span class="badge" style="background: #e0f2fe; color: #0369a1;"><%= amb.getAmbulanceType() %></span></td>
                                    <td style="padding: 12px; font-size: 0.85rem;">
                                        <strong><%= amb.getDriverName() %></strong><br>
                                        <span style="color: var(--text-muted);"><%= amb.getDriverPhone() %></span>
                                    </td>
                                    <td style="padding: 12px; font-size: 0.85rem;"><%= amb.getBaseHospital() != null ? amb.getBaseHospital() : "Central Hospital" %></td>
                                    <td style="padding: 12px;">
                                        <% if ("AVAILABLE".equalsIgnoreCase(amb.getCurrentStatus())) { %>
                                            <span class="badge badge-verified">&#10003; AVAILABLE</span>
                                        <% } else if ("ON_DUTY".equalsIgnoreCase(amb.getCurrentStatus())) { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309;">&#128657; ON DUTY</span>
                                        <% } else { %>
                                            <span class="badge" style="background: #f1f5f9; color: #475569;"><%= amb.getCurrentStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("BLOCKED".equalsIgnoreCase(amb.getModerationStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#128274; BLOCKED</span>
                                        <% } else { %>
                                            <span class="badge badge-verified">&#10003; ACTIVE</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem;"
                                                onclick="openEditAmbulanceModal(<%= amb.getAmbulanceId() %>, '<%= amb.getVehicleNumber() %>', '<%= amb.getDriverName().replace("'", "\\'") %>', '<%= amb.getDriverPhone() %>', '<%= amb.getAmbulanceType() %>', '<%= (amb.getBaseHospital() != null ? amb.getBaseHospital() : "").replace("'", "\\'") %>', '<%= amb.getCurrentStatus() %>', '<%= amb.getModerationStatus() %>')">
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
                <h2 style="font-size: 1.25rem; color: #1e293b; margin: 0;">Emergency Operator Profile</h2>
                <p class="page-subtitle">Operator credentials and assigned dispatch center jurisdiction.</p>
            </div>
            <form action="<%= request.getContextPath() %>/EmergencyDashboardServlet" method="post" style="max-width: 650px;">
                <input type="hidden" name="action" value="UPDATE_PROFILE">

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label">Full Name <span class="required">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<%= operator.getFullName() %>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Contact Phone</label>
                        <input type="text" name="phone" class="form-control" value="<%= operator.getPhone() != null ? operator.getPhone() : "" %>">
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label">Dispatch Center / Base Jurisdiction <span class="required">*</span></label>
                    <input type="text" name="dispatchCenter" class="form-control" value="<%= operator.getDispatchCenter() %>" required>
                </div>

                <button type="submit" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;">Save Profile Updates</button>
            </form>
        </div>
    </main>

    <!-- Ambulance Modal (Add / Edit) -->
    <div id="ambulanceModal" class="modal">
        <div class="modal-content">
            <h2 id="modalAmbTitle" style="font-size: 1.25rem; color: #1e293b; margin-bottom: 14px;">Register New Ambulance</h2>
            <form action="<%= request.getContextPath() %>/EmergencyDashboardServlet" method="post">
                <input type="hidden" name="action" value="SAVE_AMBULANCE">
                <input type="hidden" name="ambulanceId" id="modalAmbId" value="0">
                <input type="hidden" name="moderationStatus" id="modalModerationStatus" value="ACTIVE">

                <div class="form-group" style="margin-bottom: 12px;">
                    <label class="form-label">Vehicle Plate / Registration Number <span class="required">*</span></label>
                    <input type="text" name="vehicleNumber" id="modalVehicleNumber" class="form-control" placeholder="e.g., WB-01-EM-1100" required>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                    <div class="form-group">
                        <label class="form-label">Ambulance Type <span class="required">*</span></label>
                        <select name="ambulanceType" id="modalAmbType" class="form-control" required>
                            <option value="BASIC">BASIC (Patient Transport)</option>
                            <option value="ADVANCED">ADVANCED (Life Support)</option>
                            <option value="ICU">ICU (Critical Care Ventilator)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Base Hospital <span class="required">*</span></label>
                        <input type="text" name="baseHospital" id="modalBaseHospital" class="form-control" placeholder="e.g., City Central Hospital" required>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label">Driver Name</label>
                        <input type="text" name="driverName" id="modalDriverName" class="form-control" placeholder="Assigned driver name">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Driver Phone</label>
                        <input type="text" name="driverPhone" id="modalDriverPhone" class="form-control" placeholder="Driver mobile phone">
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label">Operational Status</label>
                    <select name="currentStatus" id="modalStatus" class="form-control">
                        <option value="AVAILABLE">AVAILABLE</option>
                        <option value="ON_DUTY">ON_DUTY</option>
                        <option value="MAINTENANCE">MAINTENANCE</option>
                    </select>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-secondary" onclick="closeAmbulanceModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary" id="modalSubmitBtn" style="background: #dc2626; border-color: #dc2626;">Save Ambulance</button>
                </div>
            </form>
        </div>
    </div>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Emergency Response Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out of the Emergency Dispatch Console?");
        }
        function openAddAmbulanceModal() {
            document.getElementById('modalAmbTitle').innerText = "Register New Ambulance";
            document.getElementById('modalSubmitBtn').innerText = "Register Ambulance";
            document.getElementById('modalAmbId').value = "0";
            document.getElementById('modalVehicleNumber').value = "";
            document.getElementById('modalAmbType').value = "BASIC";
            document.getElementById('modalBaseHospital').value = "City General Hospital";
            document.getElementById('modalDriverName').value = "";
            document.getElementById('modalDriverPhone').value = "";
            document.getElementById('modalStatus').value = "AVAILABLE";
            document.getElementById('modalModerationStatus').value = "ACTIVE";
            document.getElementById('ambulanceModal').style.display = 'block';
        }
        function openEditAmbulanceModal(id, plate, driver, phone, type, hospital, status, modStatus) {
            document.getElementById('modalAmbTitle').innerText = "Edit Ambulance #" + id;
            document.getElementById('modalSubmitBtn').innerText = "Update Ambulance";
            document.getElementById('modalAmbId').value = id;
            document.getElementById('modalVehicleNumber').value = plate;
            document.getElementById('modalAmbType').value = type;
            document.getElementById('modalBaseHospital').value = hospital;
            document.getElementById('modalDriverName').value = driver;
            document.getElementById('modalDriverPhone').value = phone;
            document.getElementById('modalStatus').value = status;
            document.getElementById('modalModerationStatus').value = modStatus;
            document.getElementById('ambulanceModal').style.display = 'block';
        }
        function closeAmbulanceModal() {
            document.getElementById('ambulanceModal').style.display = 'none';
        }
        window.onclick = function(e) {
            var modal = document.getElementById('ambulanceModal');
            if (e.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>
