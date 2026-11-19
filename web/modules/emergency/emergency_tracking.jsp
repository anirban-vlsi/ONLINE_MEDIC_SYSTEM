<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.emergency.EmergencyRequest" %>
<%@ page import="service.emergency.EmergencyService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    EmergencyRequest emergencyRequest = (EmergencyRequest) request.getAttribute("request");

    if (emergencyRequest == null) {
        EmergencyService service = new EmergencyService();
        List<EmergencyRequest> reqs = service.getRequestsByUserId(userId);
        if (!reqs.isEmpty()) {
            emergencyRequest = reqs.get(0);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Ambulance Dispatch - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .tracker-step {
            flex: 1;
            text-align: center;
            position: relative;
        }
        .tracker-step-circle {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            margin: 0 auto 8px auto;
        }
        .step-active {
            background: #16a34a;
            color: white;
            box-shadow: 0 0 0 4px #bbf7d0;
        }
        .step-pending {
            background: #e2e8f0;
            color: #64748b;
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar" style="background: #991b1b; color: white;">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand" style="color: white;">
            <span class="cross-icon" style="color: #fecaca;">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: #fecaca; margin-left: 8px;">| Ambulance Dispatch Tracking</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" style="color: white;">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/EmergencyRequestServlet" style="color: #fef08a;">+ New Request</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #fecaca;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">&#128657; Real-Time Emergency Tracking</h1>
                    <p class="page-subtitle">Track the status of your ambulance request and vehicle dispatch.</p>
                </div>
                <div>
                    <a href="tel:108" class="btn" style="background: #dc2626; color: white; padding: 6px 14px; font-weight: 700;">
                        &#128222; Call Control: 108
                    </a>
                </div>
            </div>

            <% if (emergencyRequest == null) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128657;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem;">No active emergency dispatches found.</h2>
                    <p class="empty-state-text" style="max-width: 500px; margin: 0 auto 20px auto;">
                        If you need urgent medical transit, request an ambulance immediately.
                    </p>
                    <a href="<%= request.getContextPath() %>/EmergencyRequestServlet" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;">
                        Request Ambulance Now &rarr;
                    </a>
                </div>
            <% } else { %>
                <%
                    String st = emergencyRequest.getRequestStatus();
                    boolean isPending = "PENDING".equalsIgnoreCase(st);
                    boolean isDispatched = "DISPATCHED".equalsIgnoreCase(st);
                    boolean isEnRoute = "EN_ROUTE".equalsIgnoreCase(st) || isDispatched;
                    boolean isArrived = "ARRIVED".equalsIgnoreCase(st);
                    boolean isCompleted = "COMPLETED".equalsIgnoreCase(st);
                %>

                <!-- Status Progress Stepper -->
                <div style="display: flex; justify-content: space-between; margin: 24px 0 32px 0; position: relative;">
                    <div class="tracker-step">
                        <div class="tracker-step-circle step-active">&#10003;</div>
                        <div style="font-size: 0.82rem; font-weight: 700;">REQUESTED</div>
                    </div>
                    <div class="tracker-step">
                        <div class="tracker-step-circle <%= (isDispatched || isEnRoute || isArrived || isCompleted) ? "step-active" : "step-pending" %>">
                            <%= (isDispatched || isEnRoute || isArrived || isCompleted) ? "&#10003;" : "2" %>
                        </div>
                        <div style="font-size: 0.82rem; font-weight: 700;">DISPATCHED</div>
                    </div>
                    <div class="tracker-step">
                        <div class="tracker-step-circle <%= (isArrived || isCompleted) ? "step-active" : "step-pending" %>">
                            <%= (isArrived || isCompleted) ? "&#10003;" : "3" %>
                        </div>
                        <div style="font-size: 0.82rem; font-weight: 700;">EN ROUTE</div>
                    </div>
                    <div class="tracker-step">
                        <div class="tracker-step-circle <%= isCompleted ? "step-active" : "step-pending" %>">
                            <%= isCompleted ? "&#10003;" : "4" %>
                        </div>
                        <div style="font-size: 0.82rem; font-weight: 700;">ARRIVED</div>
                    </div>
                </div>

                <!-- Emergency Case Details Card -->
                <div class="card" style="background: #f8fafc; border: 1px solid var(--border-color); margin-bottom: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; margin-bottom: 12px;">
                        <span style="font-size: 1.1rem; font-weight: 700; color: var(--text-main);">
                            Request #EMG-<%= emergencyRequest.getRequestId() %>
                        </span>
                        <span class="badge" style="background: #fee2e2; color: #dc2626; font-weight: 700;">
                            <%= emergencyRequest.getPriority() %> PRIORITY
                        </span>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 12px;">
                        <div>
                            <span style="font-size: 0.82rem; color: var(--text-muted); display: block;">Emergency Type:</span>
                            <strong><%= emergencyRequest.getEmergencyType() %></strong>
                        </div>
                        <div>
                            <span style="font-size: 0.82rem; color: var(--text-muted); display: block;">Contact Phone:</span>
                            <strong><%= emergencyRequest.getContactPhone() %></strong>
                        </div>
                        <div>
                            <span style="font-size: 0.82rem; color: var(--text-muted); display: block;">Requested At:</span>
                            <span><%= emergencyRequest.getCreatedAt() %></span>
                        </div>
                    </div>

                    <div style="margin-top: 8px;">
                        <span style="font-size: 0.82rem; color: var(--text-muted); display: block;">Pickup Address:</span>
                        <div style="background: white; padding: 10px; border-radius: 6px; border: 1px solid var(--border-color); font-weight: 500;">
                            &#128205; <%= emergencyRequest.getPickupAddress() %>
                        </div>
                    </div>
                </div>

                <!-- Assigned Ambulance & Driver Details -->
                <% if (emergencyRequest.getAmbulanceVehicle() != null) { %>
                    <div class="card" style="border-left: 5px solid #16a34a; background: #f0fdf4; margin-bottom: 20px;">
                        <h2 style="font-size: 1.15rem; color: #166534; margin-bottom: 10px;">
                            &#128657; Assigned Vehicle & Crew Contact
                        </h2>
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px;">
                            <div>
                                <span style="font-size: 0.82rem; color: #166534; display: block;">Vehicle Plate:</span>
                                <strong style="font-size: 1.1rem;"><%= emergencyRequest.getAmbulanceVehicle() %></strong>
                                <span class="badge" style="background: #bbf7d0; color: #166534; margin-left: 6px;"><%= emergencyRequest.getAmbulanceType() %></span>
                            </div>
                            <div>
                                <span style="font-size: 0.82rem; color: #166534; display: block;">Driver / Paramedic:</span>
                                <strong><%= emergencyRequest.getDriverName() != null ? emergencyRequest.getDriverName() : "On-Duty Driver" %></strong>
                            </div>
                            <div>
                                <span style="font-size: 0.82rem; color: #166534; display: block;">Direct Call:</span>
                                <% if (emergencyRequest.getDriverPhone() != null) { %>
                                    <a href="tel:<%= emergencyRequest.getDriverPhone() %>" class="btn btn-primary" style="padding: 4px 12px; font-size: 0.85rem; background: #16a34a; border-color: #16a34a;">
                                        &#128222; <%= emergencyRequest.getDriverPhone() %>
                                    </a>
                                <% } else { %>
                                    <span>Contacting Base...</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } else { %>
                    <div class="alert alert-warning">
                        <strong>Locating Nearest Ambulance:</strong> Our emergency dispatch center is currently matching your request with the closest unit in your area.
                    </div>
                <% } %>
            <% } %>

            <!-- Navigation Links -->
            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/EmergencyRequestServlet" class="btn btn-outline" style="color: #dc2626; border-color: #dc2626;">
                    + Request Another Dispatch
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Emergency Services Module.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
</body>
</html>
