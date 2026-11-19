<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.doctor.Doctor" %>
<%@ page import="model.doctor.DoctorAvailability" %>
<%@ page import="model.patient.Patient" %>
<%@ page import="model.patient.User" %>
<%@ page import="service.patient.UserService" %>
<%@ page import="dao.patient.PatientDAO" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || (session.getAttribute("userId") == null && session.getAttribute("loggedInUser") == null)) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = -1;
    if (session.getAttribute("userId") != null) {
        userId = (Integer) session.getAttribute("userId");
    } else if (session.getAttribute("loggedInUser") != null) {
        userId = ((User) session.getAttribute("loggedInUser")).getUserId();
    }

    UserService userService = new UserService();
    String authoritativeStatus = userService.getUserStatus(userId);

    // Strict Access Restriction Check
    if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp?error="
                + java.net.URLEncoder.encode("You must verify your account with a profile picture and complete your profile details before booking appointments.", "UTF-8"));
        return;
    }

    Boolean filterAppliedObj = (Boolean) request.getAttribute("filterApplied");
    boolean filterApplied = filterAppliedObj != null && filterAppliedObj;

    String specialization = (String) request.getAttribute("specialization");
    String city = (String) request.getAttribute("city");
    String visitMode = (String) request.getAttribute("visitMode");
    String sortBy = (String) request.getAttribute("sortBy");

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    Map<String, List<DoctorAvailability>> doctorSchedules = (Map<String, List<DoctorAvailability>>) request.getAttribute("doctorSchedules");
    List<Patient> patients = (List<Patient>) request.getAttribute("patients");

    if (patients == null) {
        PatientDAO pDao = new PatientDAO();
        patients = pDao.getPatientsByUserId(userId);
    }

    String errorMsg = request.getParameter("error");
    String successMsg = request.getParameter("success");

    String[] specializations = {
        "General Physician", "Cardiologist", "Dermatologist", "Dentist", "ENT Specialist",
        "Ophthalmologist (Eye)", "Psychiatrist", "Orthopedic", "Pediatrician", "Neurologist"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Doctor Appointment - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .filter-box {
            background: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 24px;
        }
        .doctor-card {
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 18px;
            margin-bottom: 16px;
            background: #ffffff;
            transition: box-shadow 0.2s ease;
        }
        .doctor-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        .schedule-chip {
            display: inline-block;
            background: #f1f5f9;
            color: #334155;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            margin-right: 6px;
            margin-bottom: 4px;
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Book Appointment</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientAppointmentsServlet">My Appointments</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientProfileServlet">My Profile</a></li>
                <li><a href="<%= request.getContextPath() %>/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content">
        <div class="card">
            <div class="card-header">
                <h1 class="page-title">Find & Book Clinical Consultation</h1>
                <p class="page-subtitle">Search verified medical specialists by specialty, city location, and visit preference.</p>
            </div>

            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <strong>&#9888; Notice:</strong> <%= errorMsg %>
                </div>
            <% } %>

            <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
                <div class="alert alert-success" style="margin-bottom: 20px;">
                    <strong>&#10003; Success:</strong> <%= successMsg %>
                </div>
            <% } %>

            <!-- 1. Mandatory Choice-First Search & Filter Form -->
            <form action="<%= request.getContextPath() %>/BookAppointmentServlet" method="get" class="filter-box">
                <h2 style="font-size: 1.1rem; color: #1e293b; margin-bottom: 14px;">&#128269; Step 1: Select Specialty & Location</h2>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 14px;">
                    <div class="form-group">
                        <label class="form-label">Specialization <span class="required">*</span></label>
                        <select name="specialization" class="form-control" required>
                            <option value="">-- Select Specialty --</option>
                            <% for (String spec : specializations) { %>
                                <option value="<%= spec %>" <%= spec.equalsIgnoreCase(specialization) ? "selected" : "" %>><%= spec %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">City / Location <span class="required">*</span></label>
                        <input type="text" name="city" class="form-control" placeholder="e.g., Kolkata, Delhi, Mumbai" value="<%= city != null ? city : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Consultation Mode</label>
                        <select name="visitMode" class="form-control">
                            <option value="ALL" <%= "ALL".equalsIgnoreCase(visitMode) ? "selected" : "" %>>All Consultation Modes</option>
                            <option value="CLINIC" <%= "CLINIC".equalsIgnoreCase(visitMode) ? "selected" : "" %>>Clinic Visit Only</option>
                            <option value="HOME_VISIT" <%= "HOME_VISIT".equalsIgnoreCase(visitMode) ? "selected" : "" %>>Home Visit Only</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Sort Doctors By</label>
                        <select name="sortBy" class="form-control">
                            <option value="NAME_ASC" <%= "NAME_ASC".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Doctor Name (A - Z)</option>
                            <option value="NAME_DESC" <%= "NAME_DESC".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Doctor Name (Z - A)</option>
                            <option value="FEE_ASC" <%= "FEE_ASC".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Fee: Low to High</option>
                            <option value="FEE_DESC" <%= "FEE_DESC".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Fee: High to Low</option>
                        </select>
                    </div>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn btn-primary">&#128269; Search Available Doctors</button>
                    <% if (filterApplied) { %>
                        <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-secondary">Clear Filter</a>
                    <% } %>
                </div>
            </form>

            <!-- 2. Choice-First Results Or Step Prompt -->
            <% if (!filterApplied) { %>
                <div class="empty-state" style="padding: 40px 20px;">
                    <div class="empty-state-icon">&#9877;</div>
                    <h2 style="color: var(--primary-color); font-size: 1.2rem; margin-bottom: 8px;">Please select Specialization and City</h2>
                    <p class="empty-state-text" style="max-width: 520px; margin: 0 auto;">
                        To protect doctors from unmanageable scheduling loads and guarantee location-compatible home visits, choose your medical requirement and city above to view verified practitioners.
                    </p>
                </div>
            <% } else if (doctors == null || doctors.isEmpty()) { %>
                <div class="alert alert-warning">
                    <strong>No Doctors Found:</strong> There are no verified doctors matching "<%= specialization %>" in <%= city %> for your selected mode. Try selecting another city or consultation mode.
                </div>
            <% } else { %>
                <h2 style="font-size: 1.15rem; color: #1e293b; margin-bottom: 16px;">
                    Matching Verified Doctors (<%= doctors.size() %> found)
                </h2>

                <% for (Doctor doc : doctors) {
                    List<DoctorAvailability> daList = (doctorSchedules != null) ? doctorSchedules.get(doc.getRegistrationNumber()) : null;
                %>
                    <div class="doctor-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 12px;">
                            <div>
                                <h3 style="margin: 0 0 4px 0; color: #1e293b; font-size: 1.15rem;">
                                    Dr. <%= doc.getDoctorName() %>
                                    <span class="badge badge-verified" style="font-size: 0.75rem; margin-left: 6px;">&#10003; VERIFIED</span>
                                </h3>
                                <p style="margin: 0 0 6px 0; color: var(--text-muted); font-size: 0.9rem;">
                                    <strong><%= doc.getSpecialization() %></strong> &bull; License: <%= doc.getRegistrationNumber() %> &bull; <%= doc.getCity() %>
                                </p>
                                <p style="margin: 0 0 8px 0; font-size: 0.85rem; color: #475569;">
                                    <strong>Clinic:</strong> <%= doc.getAddress() %>
                                </p>
                                <div style="display: flex; gap: 14px; flex-wrap: wrap; font-size: 0.9rem; margin-bottom: 8px;">
                                    <span style="color: #059669; font-weight: 600;">Clinic Fee: &#8377;<%= doc.getConsultationFee() %></span>
                                    <% if (doc.isHomeVisitAvailable()) { %>
                                        <span style="color: #b45309; font-weight: 600;">
                                            &#127968; Home Visit: &#8377;<%= doc.getHomeVisitFee() != null ? doc.getHomeVisitFee() : doc.getConsultationFee() %>
                                            (Areas: <%= doc.getServiceAreas() != null && !doc.getServiceAreas().isEmpty() ? doc.getServiceAreas() : doc.getCity() %>)
                                        </span>
                                    <% } else { %>
                                        <span style="color: #94a3b8;">Home Visit: Not Available</span>
                                    <% } %>
                                </div>
                            </div>
                            <div>
                                <button type="button" class="btn btn-primary" onclick="selectDoctor('<%= doc.getRegistrationNumber() %>', 'Dr. <%= doc.getDoctorName() %>', '<%= doc.getSpecialization() %>', <%= doc.isHomeVisitAvailable() %>, <%= doc.getConsultationFee() %>, <%= doc.getHomeVisitFee() != null ? doc.getHomeVisitFee() : doc.getConsultationFee() %>)">
                                    Book This Doctor &darr;
                                </button>
                            </div>
                        </div>

                        <!-- Active Schedules Chips -->
                        <div style="margin-top: 10px; padding-top: 10px; border-top: 1px dashed var(--border-color);">
                            <span style="font-size: 0.8rem; font-weight: 600; color: #475569; display: block; margin-bottom: 4px;">Available Schedule Windows:</span>
                            <% if (daList != null && !daList.isEmpty()) { %>
                                <% for (DoctorAvailability da : daList) {
                                    if (da.isActive()) { %>
                                        <span class="schedule-chip">
                                            <%= da.getDayOfWeek() %> (<%= da.getVisitMode() %>): <%= da.getStartTime() %> - <%= da.getEndTime() %> (Cap: <%= da.getMaxPatientsPerDay() %>/day)
                                        </span>
                                    <% } %>
                                <% } %>
                            <% } else { %>
                                <span style="font-size: 0.8rem; color: #94a3b8;">Standard hours (Mon-Sat 09:00 - 18:00)</span>
                            <% } %>
                        </div>
                    </div>
                <% } %>

                <!-- 3. Booking Section (Revealed when doctor chosen) -->
                <div id="bookingSection" class="card" style="margin-top: 28px; border: 2px solid #0284c7; background: #f0f9ff; display: none;">
                    <h2 style="font-size: 1.25rem; color: #0369a1; margin-bottom: 12px;">
                        &#128197; Step 2: Finalize Appointment with <span id="selectedDoctorName"></span>
                    </h2>

                    <% if (patients == null || patients.isEmpty()) { %>
                        <div class="alert alert-warning">
                            <strong>Patient Profile Required:</strong> Please <a href="<%= request.getContextPath() %>/modules/patient/add_patient.jsp">add a patient or dependent profile</a> before booking.
                        </div>
                    <% } else { %>
                        <form action="<%= request.getContextPath() %>/BookAppointmentServlet" method="post" id="bookApptForm">
                            <input type="hidden" name="doctorRegNo" id="selectedDoctorRegNo" value="">

                            <!-- 1. Select Patient -->
                            <div class="form-group" style="margin-bottom: 14px;">
                                <label for="patientId" class="form-label">Select Patient / Dependent <span class="required">*</span></label>
                                <select name="patientId" id="patientId" class="form-control" required>
                                    <option value="">-- Choose Patient --</option>
                                    <% for (Patient p : patients) { %>
                                        <option value="<%= p.getPatientId() %>">
                                            <%= p.getPatientName() %> (<%= p.getRelation() %>, <%= p.getGender() %>)
                                        </option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- 2. Visit Mode -->
                            <div class="form-group" style="margin-bottom: 14px;">
                                <label class="form-label">Consultation Mode <span class="required">*</span></label>
                                <select name="visitType" id="visitTypeSelect" class="form-control" required onchange="toggleHomeAddress()">
                                    <option value="CLINIC">Clinic Consultation (At Doctor's Clinic)</option>
                                    <option value="HOME_VISIT" id="homeVisitOption">Home Visit (Doctor visits your residence)</option>
                                </select>
                            </div>

                            <!-- Home Visit Fields -->
                            <div id="homeVisitFields" style="display: none; background: #fff; padding: 14px; border-radius: 6px; border: 1px solid #cbd5e1; margin-bottom: 14px;">
                                <div class="form-group" style="margin-bottom: 10px;">
                                    <label class="form-label">Patient Residence City <span class="required">*</span></label>
                                    <input type="text" name="patientCity" id="patientCityInput" class="form-control" placeholder="Must match doctor's covered areas" value="<%= city != null ? city : "" %>">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Home Street Address & Landmark <span class="required">*</span></label>
                                    <textarea name="patientHomeAddress" id="patientAddressInput" class="form-control" rows="2" placeholder="Full residential address for doctor's arrival..."></textarea>
                                </div>
                            </div>

                            <!-- 3. Appointment Date -->
                            <div class="form-group" style="margin-bottom: 14px;">
                                <label for="appointmentDate" class="form-label">Appointment Date <span class="required">*</span></label>
                                <input type="date" name="appointmentDate" id="appointmentDate" class="form-control" required>
                                <small style="display: block; margin-top: 4px; color: var(--text-muted); font-size: 0.85rem;">
                                    &#9203; <em>The exact appointment time slot will be assigned and confirmed by the doctor upon reviewing your request.</em>
                                </small>
                            </div>

                            <!-- 4. Symptoms / Consultation Reason -->
                            <div class="form-group" style="margin-bottom: 14px;">
                                <label for="reason" class="form-label">Reason for Consultation / Symptoms</label>
                                <textarea name="reason" id="reason" class="form-control" rows="2" placeholder="Describe symptoms or reasons for visit..."></textarea>
                            </div>

                            <!-- 5. Simulated Payment Gateway & 15% Platform Split -->
                            <div style="background: #ffffff; padding: 16px; border-radius: 6px; border: 1px solid #cbd5e1; margin-bottom: 18px;">
                                <h3 style="font-size: 1rem; color: #1e293b; margin: 0 0 10px 0;">&#128179; Simulated Payment Gateway</h3>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                    <span style="font-size: 0.95rem; color: #334155;">Consultation Fee:</span>
                                    <span style="font-size: 1.2rem; font-weight: 700; color: #059669;" id="displayedFee">&#8377;500.00</span>
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 12px;">
                                    (Automated 15% platform commission and 85% practitioner payout calculated instantly upon booking confirmation)
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Payment Method <span class="required">*</span></label>
                                    <select name="paymentMethod" class="form-control" required>
                                        <option value="UPI">UPI / QR Payment (Instant)</option>
                                        <option value="CREDIT_CARD">Credit Card</option>
                                        <option value="DEBIT_CARD">Debit Card</option>
                                        <option value="NET_BANKING">Net Banking</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Submit / Action Buttons -->
                            <div class="btn-group">
                                <button type="submit" class="btn btn-primary" style="padding: 10px 24px; font-size: 1rem;">
                                    &#10003; Pay & Confirm Appointment
                                </button>
                                <button type="button" class="btn btn-secondary" onclick="document.getElementById('bookingSection').style.display='none'">
                                    Cancel
                                </button>
                            </div>
                        </form>
                    <% } %>
                </div>
            <% } %>

            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" style="color: var(--text-muted); text-decoration: none;">
                    &larr; Back to Dashboard
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Patient Portal.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        var currentClinicFee = 500;
        var currentHomeFee = 700;

        function selectDoctor(regNo, name, spec, homeVisitAvailable, clinicFee, homeFee) {
            document.getElementById('selectedDoctorRegNo').value = regNo;
            document.getElementById('selectedDoctorName').innerText = name + " (" + spec + ")";
            currentClinicFee = clinicFee;
            currentHomeFee = homeFee;

            var homeOption = document.getElementById('homeVisitOption');
            if (homeOption) {
                if (homeVisitAvailable) {
                    homeOption.disabled = false;
                    homeOption.innerText = "Home Visit (Doctor visits your residence - \u20B9" + homeFee + ")";
                } else {
                    homeOption.disabled = true;
                    homeOption.innerText = "Home Visit (Not Available)";
                }
            }

            document.getElementById('displayedFee').innerText = "\u20B9" + clinicFee.toFixed(2);
            document.getElementById('visitTypeSelect').value = "CLINIC";
            toggleHomeAddress();

            var bookingSec = document.getElementById('bookingSection');
            bookingSec.style.display = 'block';
            bookingSec.scrollIntoView({ behavior: 'smooth' });
        }

        function toggleHomeAddress() {
            var vType = document.getElementById('visitTypeSelect').value;
            var homeFields = document.getElementById('homeVisitFields');
            var feeDisplay = document.getElementById('displayedFee');

            if (vType === 'HOME_VISIT') {
                homeFields.style.display = 'block';
                document.getElementById('patientAddressInput').required = true;
                feeDisplay.innerText = "\u20B9" + currentHomeFee.toFixed(2);
            } else {
                homeFields.style.display = 'none';
                document.getElementById('patientAddressInput').required = false;
                feeDisplay.innerText = "\u20B9" + currentClinicFee.toFixed(2);
            }
        }

        var today = new Date().toISOString().split('T')[0];
        var dateInput = document.getElementById("appointmentDate");
        if (dateInput) {
            dateInput.min = today;
        }

        function confirmLogout() {
            return confirm("Are you sure you want to log out?");
        }
    </script>
</body>
</html>
