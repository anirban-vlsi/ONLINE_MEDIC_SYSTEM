<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="model.appointment.Appointment" %>
<%@ page import="service.appointment.AppointmentService" %>
<%@ page import="service.doctor.DoctorService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || (session.getAttribute("doctorRegistrationNumber") == null && session.getAttribute("loggedInDoctor") == null)) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
        return;
    }

    String regNo = (String) session.getAttribute("doctorRegistrationNumber");
    if (regNo == null && session.getAttribute("loggedInDoctor") != null) {
        regNo = ((model.doctor.Doctor) session.getAttribute("loggedInDoctor")).getRegistrationNumber();
    }

    DoctorService doctorService = new DoctorService();
    String authoritativeStatus = doctorService.getDoctorVerificationStatus(regNo);

    // Strict Lockout: Unverified doctors are blocked from clinical features
    if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
        return;
    }

    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) {
        AppointmentService appointmentService = new AppointmentService();
        appointments = appointmentService.getAppointmentsByDoctor(regNo);
    }

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Appointments - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
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
            margin: 10% auto;
            padding: 24px;
            border-radius: 8px;
            max-width: 500px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Clinical Appointments</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorPrescriptionServlet">Prescriptions</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorAvailabilityServlet">Availability</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorProfileServlet">Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/DoctorLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h1 class="page-title">Patient Consultations & Appointments</h1>
                    <p class="page-subtitle">Manage upcoming patient visits, confirm bookings, propose reschedules, and issue prescriptions.</p>
                </div>
                <div>
                    <span class="badge badge-verified">&#10003; LICENSED DOCTOR: <%= regNo %></span>
                </div>
            </div>

            <% if (msg != null && !msg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= msg %>
                </div>
            <% } %>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= error %>
                </div>
            <% } %>

            <% if (appointments == null || appointments.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">&#128197;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.25rem; margin-bottom: 8px;">No scheduled appointments.</h2>
                    <p class="empty-state-text" style="max-width: 580px; margin: 0 auto 20px auto;">
                        When patients book consultations with you, they will appear in this roster.
                    </p>
                </div>
            <% } else { %>
                <div class="table-container" style="overflow-x: auto;">
                    <table class="table" style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 2px solid var(--border-color); text-align: left;">
                                <th style="padding: 12px;">ID</th>
                                <th style="padding: 12px;">Type & Mode</th>
                                <th style="padding: 12px;">Date & Time</th>
                                <th style="padding: 12px;">Patient Details</th>
                                <th style="padding: 12px;">Fee & Payment</th>
                                <th style="padding: 12px;">Status</th>
                                <th style="padding: 12px; text-align: right;">Clinical Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Appointment a : appointments) { %>
                                <tr style="border-bottom: 1px solid var(--border-color);">
                                    <td style="padding: 12px; font-weight: 600;">#<%= a.getAppointmentId() %></td>
                                    <td style="padding: 12px;">
                                        <% if ("HOME_VISIT".equalsIgnoreCase(a.getVisitType())) { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309; font-weight: 600;">&#127968; HOME VISIT</span>
                                        <% } else { %>
                                            <span class="badge" style="background: #e0f2fe; color: #0369a1; font-weight: 600;">&#127973; CLINIC</span>
                                        <% } %>
                                        <% if ("HOME_VISIT".equalsIgnoreCase(a.getVisitType()) && a.getPatientHomeAddress() != null) { %>
                                            <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 4px;">
                                                <strong>Address:</strong> <%= a.getPatientHomeAddress() %>, <%= a.getPatientCity() %>
                                            </div>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong><%= a.getAppointmentDate() %></strong><br>
                                        <% if (a.getAppointmentTime() != null) { %>
                                            <span style="font-size: 0.85rem; color: #1e293b; font-weight: 600;"><%= a.getAppointmentTime() %></span>
                                        <% } else { %>
                                            <span style="font-size: 0.82rem; color: #b45309; font-style: italic;">&#9203; Time: Pending Assignment</span>
                                        <% } %>
                                        <% if ("RESCHEDULE_PROPOSED".equalsIgnoreCase(a.getStatus())) { %>
                                            <div style="font-size: 0.8rem; color: #d97706; margin-top: 4px;">
                                                <em>Proposed: <%= a.getProposedDate() %> @ <%= a.getProposedTime() %></em>
                                            </div>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong><%= a.getPatientName() %></strong><br>
                                        <span style="font-size: 0.85rem; color: var(--text-muted);"><%= a.getPatientGender() %> (<%= a.getPatientRelation() %>)</span>
                                        <div style="font-size: 0.82rem; color: #475569; margin-top: 2px;">
                                            <em>Symptoms: <%= (a.getReason() != null && !a.getReason().isEmpty()) ? a.getReason() : "General Consultation" %></em>
                                        </div>
                                    </td>
                                    <td style="padding: 12px;">
                                        <strong>&#8377;<%= a.getFeeCharged() != null ? a.getFeeCharged() : "500.00" %></strong><br>
                                        <span class="badge badge-verified" style="font-size: 0.75rem;"><%= a.getPaymentStatus() != null ? a.getPaymentStatus() : "PAID" %></span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("CONFIRMED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge badge-verified">&#10003; CONFIRMED</span>
                                        <% } else if ("COMPLETED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge" style="background: #dbeafe; color: #1e40af;">&#10003; COMPLETED</span>
                                        <% } else if ("CANCELLED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge" style="background: #fee2e2; color: #dc2626;">&#10007; CANCELLED</span>
                                        <% } else if ("RESCHEDULE_PROPOSED".equalsIgnoreCase(a.getStatus())) { %>
                                            <span class="badge" style="background: #fef3c7; color: #b45309;">&#9201; RESCHEDULE PENDING</span>
                                        <% } else { %>
                                            <span class="badge badge-unverified">&#9203; PENDING</span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 12px; text-align: right;">
                                        <div style="display: flex; gap: 6px; justify-content: flex-end; flex-wrap: wrap;">
                                            <% if ("PENDING".equalsIgnoreCase(a.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/DoctorAppointmentServlet" method="post" style="display:inline-flex; gap: 4px; align-items: center;">
                                                    <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                    <input type="hidden" name="action" value="CONFIRM">
                                                    <input type="time" name="appointmentTime" class="form-control" style="padding: 3px 6px; font-size: 0.8rem; width: 105px;" required title="Assign consultation time">
                                                    <button type="submit" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem; background: #16a34a; border-color: #16a34a;" title="Approve booking with assigned time">&#10003; Approve</button>
                                                </form>
                                                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.82rem; color: #b45309; border-color: #b45309;"
                                                        onclick="openRescheduleModal(<%= a.getAppointmentId() %>, '<%= a.getAppointmentDate() %>')">
                                                    Reschedule
                                                </button>
                                                <form action="<%= request.getContextPath() %>/DoctorAppointmentServlet" method="post" style="display:inline;" onsubmit="return confirm('Cancel this appointment?');">
                                                    <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                    <input type="hidden" name="action" value="CANCEL">
                                                    <button type="submit" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.82rem; color: #dc2626; border-color: #dc2626;">Cancel</button>
                                                </form>
                                            <% } else if ("CONFIRMED".equalsIgnoreCase(a.getStatus())) { %>
                                                <a href="<%= request.getContextPath() %>/DoctorPrescriptionServlet?appointmentId=<%= a.getAppointmentId() %>" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.82rem;">
                                                    &#128392; Prescription
                                                </a>
                                                <form action="<%= request.getContextPath() %>/DoctorAppointmentServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="appointmentId" value="<%= a.getAppointmentId() %>">
                                                    <input type="hidden" name="action" value="COMPLETE">
                                                    <button type="submit" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.82rem; background: #059669; color: white;">Mark Done</button>
                                                </form>
                                                <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.82rem; color: #b45309; border-color: #b45309;"
                                                        onclick="openRescheduleModal(<%= a.getAppointmentId() %>, '<%= a.getAppointmentDate() %>')">
                                                    Reschedule
                                                </button>
                                            <% } else if ("RESCHEDULE_PROPOSED".equalsIgnoreCase(a.getStatus())) { %>
                                                <span style="color: #b45309; font-size: 0.82rem; font-weight: 500;">Awaiting Patient Response</span>
                                            <% } else if ("COMPLETED".equalsIgnoreCase(a.getStatus())) { %>
                                                <span style="color: #059669; font-size: 0.85rem; font-weight: 600;">&#10003; Consultation Completed</span>
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
                <a href="<%= request.getContextPath() %>/modules/doctor/doctor_dashboard.jsp" class="btn btn-secondary">
                    &larr; Back to Doctor Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/DoctorPrescriptionServlet" class="btn btn-outline">
                    View Issued Prescriptions &rarr;
                </a>
            </div>
        </div>
    </main>

    <!-- Reschedule Modal -->
    <div id="rescheduleModal" class="modal">
        <div class="modal-content">
            <h2 style="font-size: 1.25rem; color: #1e293b; margin-bottom: 12px;">Propose Appointment Reschedule</h2>
            <p style="font-size: 0.88rem; color: var(--text-muted); margin-bottom: 16px;">
                Specify a new date, time, and clinical reason. The patient will be notified to accept or decline.
            </p>
            <form action="<%= request.getContextPath() %>/DoctorAppointmentServlet" method="post">
                <input type="hidden" name="action" value="PROPOSE_RESCHEDULE">
                <input type="hidden" name="appointmentId" id="modalApptId" value="">

                <div class="form-group" style="margin-bottom: 14px;">
                    <label class="form-label">New Proposed Date <span class="required">*</span></label>
                    <input type="date" name="proposedDate" id="modalProposedDate" class="form-control" required>
                </div>
                <div class="form-group" style="margin-bottom: 14px;">
                    <label class="form-label">New Proposed Time <span class="required">*</span></label>
                    <input type="time" name="proposedTime" id="modalProposedTime" class="form-control" required>
                </div>
                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label">Doctor Remarks / Clinical Reason</label>
                    <textarea name="doctorRemarks" class="form-control" rows="2" placeholder="e.g., Emergency surgery conflict, clinic shift adjustment..."></textarea>
                </div>
                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-secondary" onclick="closeRescheduleModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Send Proposal</button>
                </div>
            </form>
        </div>
    </div>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Doctor Portal.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function confirmLogout() {
            return confirm("Are you sure you want to log out of the Doctor Portal?");
        }
        function openRescheduleModal(apptId, currentDate) {
            document.getElementById('modalApptId').value = apptId;
            var today = new Date().toISOString().split('T')[0];
            var dateInput = document.getElementById('modalProposedDate');
            dateInput.min = today;
            dateInput.value = currentDate;
            document.getElementById('rescheduleModal').style.display = 'block';
        }
        function closeRescheduleModal() {
            document.getElementById('rescheduleModal').style.display = 'none';
        }
        window.onclick = function(event) {
            var modal = document.getElementById('rescheduleModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>
