<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="service.patient.UserService" %>
<%@ page import="model.patient.User" %>

<%
    // Prevent browser caching of protected pages
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Strict session validation
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        userName = "Patient";
    }

    // Always fetch authoritative verification status directly from the database
    UserService userService = new UserService();
    String authoritativeStatus = userService.getUserStatus(userId);
    boolean isVerified = "VERIFIED".equalsIgnoreCase(authoritativeStatus);
    boolean hasProfilePicture = userService.hasProfilePicture(userId);

    // Keep session in sync with database status
    session.setAttribute("userStatus", authoritativeStatus);

    String uploadSuccess = request.getParameter("uploadSuccess");
    String errorMessage = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Dashboard - Online Medical System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="<%= request.getContextPath() %>/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Patient Dashboard</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li>
                    <span style="display: flex; align-items: center; gap: 8px; font-weight: 600; color: var(--text-main);">
                        <img src="<%= request.getContextPath() %>/ProfilePictureServlet" alt="Avatar" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; border: 1px solid var(--border-color);">
                        <%= userName %>
                    </span>
                </li>
                <li>
                    <a href="<%= request.getContextPath() %>/PatientLogoutServlet" class="btn btn-outline" style="padding: 6px 14px; color: #dc2626; border-color: #dc2626;" onclick="return confirmLogout();">
                        Logout
                    </a>
                </li>
            </ul>
        </nav>
    </header>

    <main class="main-content">

        <!-- Upload Notification Banners -->
        <% if (uploadSuccess != null && !uploadSuccess.trim().isEmpty()) { %>
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <strong>&#10003; Success:</strong> <%= uploadSuccess %>
            </div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="alert alert-error" style="margin-bottom: 20px;">
                <strong>&#9888; Notice:</strong> <%= errorMessage %>
            </div>
        <% } %>

        <!-- Welcome Hero / Overview Card -->
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 18px;">
                    <div class="avatar-preview-box">
                        <img src="<%= request.getContextPath() %>/ProfilePictureServlet" alt="<%= userName %>">
                    </div>
                    <div>
                        <h1 class="page-title" style="margin-bottom: 4px;">Welcome, <%= userName %>!</h1>
                        <p class="page-subtitle">Manage your medical information and access your healthcare services from here.</p>
                    </div>
                </div>
                <div style="text-align: right;">
                    <div style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 4px;">Account Status: <strong><%= authoritativeStatus %></strong></div>
                    <% if (isVerified) { %>
                        <span class="badge badge-verified">&#10003; VERIFIED</span>
                    <% } else { %>
                        <span class="badge badge-unverified">&#9888; NOT VERIFIED</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- ========================================================================== -->
        <!-- PART D1: UNVERIFIED ACCOUNT NOTIFICATION & VERIFICATION SECTION            -->
        <!-- ========================================================================== -->
        <% if (!isVerified) { %>
            <div class="alert alert-warning" style="margin-bottom: 24px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; width: 100%;">
                    <div>
                        <h3 style="color: #92400e; font-size: 1.15rem; margin-bottom: 4px;">Your account is not verified yet.</h3>
                        <p style="color: #78350f; font-size: 0.95rem; margin: 0;">
                            Please upload your profile picture to complete your account verification. Once your picture is successfully uploaded, your account will be marked as VERIFIED.
                        </p>
                    </div>
                    <div>
                        <a href="#verificationSection" class="btn btn-primary" style="white-space: nowrap; font-weight: 700;">
                            UPLOAD PROFILE PICTURE
                        </a>
                    </div>
                </div>
            </div>

            <!-- Profile Picture Upload Section (Requirement D2) -->
            <section class="card verification-card" id="verificationSection">
                <div class="verification-header">
                    <div class="verification-badge-icon">&#128247;</div>
                    <div>
                        <h2 class="page-title" style="font-size: 1.35rem; margin-bottom: 2px;">Complete Your Profile Verification</h2>
                        <p class="page-subtitle">Upload your profile picture to verify your account and unlock patient management features.</p>
                    </div>
                </div>

                <div class="alert alert-info" style="margin-bottom: 20px;">
                    <strong>Instructions:</strong>
                    <ul style="margin-left: 20px; margin-top: 4px;">
                        <li>Allowed formats: <strong>JPG, JPEG, PNG</strong></li>
                        <li>Maximum file size: <strong>2 MB</strong></li>
                        <li><strong>One-Time Upload:</strong> Once uploaded, your profile picture cannot be re-uploaded or replaced.</li>
                    </ul>
                </div>

                <form id="uploadPictureForm" action="<%= request.getContextPath() %>/UploadProfilePictureServlet" method="post" enctype="multipart/form-data">
                    <div class="profile-avatar-wrapper">
                        <!-- Image Preview Box -->
                        <div class="avatar-preview-box" id="avatarPreviewContainer">
                            <img id="previewImg" src="<%= request.getContextPath() %>/ProfilePictureServlet" alt="Profile Preview">
                        </div>

                        <!-- File Input and Selected Filename -->
                        <div style="flex: 1; min-width: 240px;">
                            <label for="profilePictureInput" class="form-label">Select Profile Picture (JPG / PNG, Max 2MB) <span class="required">*</span></label>
                            <input type="file" id="profilePictureInput" name="profilePicture" accept=".jpg,.jpeg,.png,image/jpeg,image/png" class="form-control" required onchange="handleFileSelected(this)">
                            <div id="fileInfoDisplay" style="font-size: 0.88rem; color: var(--text-muted); margin-top: 6px;">No file chosen yet.</div>
                        </div>
                    </div>

                    <div id="uploadClientError" class="alert alert-error" style="display: none; margin-top: 14px;"></div>

                    <div class="btn-group" style="margin-top: 18px;">
                        <button type="submit" id="uploadSubmitBtn" class="btn btn-upload">
                            &#128392; Upload Profile Picture
                        </button>
                    </div>
                </form>
            </section>
        <% } %>

        <!-- Dashboard Navigation Services Grid -->
        <div class="dashboard-grid">
            <!-- 1. Book Appointment (Strict Lockout for Unverified Patients) -->
            <div class="dash-card" style="<%= !isVerified ? "border: 2px dashed #fcd34d; background: #fffdfa;" : "border-top: 4px solid var(--primary-color);" %>">
                <div>
                    <div class="dash-card-icon" style="<%= !isVerified ? "color: #d97706;" : "color: var(--primary-color);" %>">&#128197;</div>
                    <h2 class="dash-card-title">Book Appointment</h2>
                    <% if (isVerified) { %>
                        <p class="dash-card-desc">
                            Schedule a clinical consultation with our verified doctors based on live availability.
                        </p>
                    <% } else { %>
                        <div style="margin-bottom: 14px;">
                            <span class="badge badge-unverified" style="display: inline-block; margin-bottom: 8px;">Verification Required</span>
                            <p class="dash-card-desc" style="color: #92400e; font-size: 0.88rem; margin-bottom: 0;">
                                Please upload your profile picture to verify your profile before booking appointments.
                            </p>
                        </div>
                    <% } %>
                </div>
                <div>
                    <% if (isVerified) { %>
                        <a href="<%= request.getContextPath() %>/BookAppointmentServlet" class="btn btn-primary btn-block">
                            Book Consultation &rarr;
                        </a>
                    <% } else { %>
                        <a href="#verificationSection" class="btn btn-primary btn-block" style="background-color: #d97706; border-color: #d97706;">
                            &#128247; Verify Profile to Book
                        </a>
                    <% } %>
                </div>
            </div>

            <!-- 2. My Appointments -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#128340;</div>
                    <h2 class="dash-card-title">My Appointments</h2>
                    <p class="dash-card-desc">
                        Review scheduled appointments, doctor consultation statuses, and consultation notes.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/PatientAppointmentsServlet" class="btn btn-secondary btn-block">
                    View Appointments &rarr;
                </a>
            </div>

            <!-- 3. My Prescriptions -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#128196;</div>
                    <h2 class="dash-card-title">My Prescriptions</h2>
                    <p class="dash-card-desc">
                        Access official digital prescriptions, medications, dosages, and doctor advice.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/PatientPrescriptionsServlet" class="btn btn-secondary btn-block">
                    View Prescriptions &rarr;
                </a>
            </div>

            <!-- 4. Online Pharmacy Shop -->
            <div class="dash-card" style="border-top: 4px solid #059669;">
                <div>
                    <div class="dash-card-icon" style="color: #059669;">&#128138;</div>
                    <h2 class="dash-card-title">Pharmacy Shop</h2>
                    <p class="dash-card-desc">
                        Browse our in-stock medicine inventory, search therapeutic categories, and place orders.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/PharmacyCatalogServlet" class="btn btn-primary btn-block" style="background-color: #059669; border-color: #059669;">
                    Browse Medicines &rarr;
                </a>
            </div>

            <!-- 5. My Pharmacy Orders -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#128230;</div>
                    <h2 class="dash-card-title">My Orders</h2>
                    <p class="dash-card-desc">
                        Track placed medicine deliveries, live fulfillment status, items, and cost receipts.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/MyPharmacyOrdersServlet" class="btn btn-secondary btn-block">
                    Track Orders &rarr;
                </a>
            </div>

            <!-- 6. Emergency Ambulance Service -->
            <div class="dash-card" style="border-top: 4px solid #dc2626;">
                <div>
                    <div class="dash-card-icon" style="color: #dc2626;">&#128657;</div>
                    <h2 class="dash-card-title" style="color: #dc2626;">Emergency Service</h2>
                    <p class="dash-card-desc">
                        Instant 24/7 ambulance dispatch, critical emergency response, and live fleet tracking.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/EmergencyRequestServlet" class="btn btn-primary btn-block" style="background-color: #dc2626; border-color: #dc2626;">
                    Request Ambulance &rarr;
                </a>
            </div>

            <!-- 7. My Patients -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#128101;</div>
                    <h2 class="dash-card-title">My Dependents</h2>
                    <p class="dash-card-desc">
                        View and manage patient profiles and family members linked to your primary account.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/PatientProfileServlet" class="btn btn-secondary btn-block">
                    View Dependents &rarr;
                </a>
            </div>

            <!-- 8. Add Patient (Restricted when NOT VERIFIED) -->
            <div class="dash-card" style="<%= !isVerified ? "border: 2px dashed #fcd34d; background: #fffdfa;" : "" %>">
                <div>
                    <div class="dash-card-icon" style="<%= !isVerified ? "color: #d97706;" : "" %>">&#10133;</div>
                    <h2 class="dash-card-title">Add Patient</h2>
                    <% if (isVerified) { %>
                        <p class="dash-card-desc">
                            Register a new family member or add another patient dependent to your medical account.
                        </p>
                    <% } else { %>
                        <div style="margin-bottom: 14px;">
                            <span class="badge badge-unverified" style="display: inline-block; margin-bottom: 8px;">Verification Required</span>
                            <p class="dash-card-desc" style="color: #92400e; font-size: 0.88rem; margin-bottom: 0;">
                                Please upload your profile picture to verify your account before adding dependents.
                            </p>
                        </div>
                    <% } %>
                </div>
                <div>
                    <% if (isVerified) { %>
                        <a href="<%= request.getContextPath() %>/modules/patient/add_patient.jsp" class="btn btn-outline btn-block">
                            Add Dependent &rarr;
                        </a>
                    <% } else { %>
                        <a href="#verificationSection" class="btn btn-primary btn-block" style="background-color: #d97706; border-color: #d97706;">
                            &#128247; Verify to Add
                        </a>
                    <% } %>
                </div>
            </div>

            <!-- 9. My Account Profile -->
            <div class="dash-card">
                <div>
                    <div class="dash-card-icon">&#9881;</div>
                    <h2 class="dash-card-title">Account Profile</h2>
                    <p class="dash-card-desc">
                        Check your registered contact information, phone number, and verification status.
                    </p>
                </div>
                <a href="<%= request.getContextPath() %>/modules/patient/patient_profile.jsp" class="btn btn-secondary btn-block">
                    View Profile &rarr;
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved. Patient Portal.</p>
    </footer>

    <script src="<%= request.getContextPath() %>/js/common.js"></script>
    <script>
        function handleFileSelected(input) {
            var errorEl = document.getElementById("uploadClientError");
            var displayEl = document.getElementById("fileInfoDisplay");
            var preview = document.getElementById("previewImg");

            errorEl.style.display = "none";
            errorEl.innerText = "";

            if (!input.files || !input.files[0]) {
                displayEl.innerText = "No file chosen yet.";
                return;
            }

            var file = input.files[0];
            var fileName = file.name;
            var fileSize = file.size;
            var extension = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();

            // Client-side extension validation
            if (extension !== ".jpg" && extension !== ".jpeg" && extension !== ".png") {
                errorEl.innerText = "Invalid file type (" + extension + "). Only JPG, JPEG, and PNG images are allowed.";
                errorEl.style.display = "block";
                input.value = "";
                displayEl.innerText = "Selected file rejected.";
                return;
            }

            // Client-side size validation (2 MB)
            var maxBytes = 2 * 1024 * 1024;
            if (fileSize > maxBytes) {
                errorEl.innerText = "File size (" + (fileSize / (1024 * 1024)).toFixed(2) + " MB) exceeds maximum allowed limit of 2 MB.";
                errorEl.style.display = "block";
                input.value = "";
                displayEl.innerText = "Selected file rejected.";
                return;
            }

            var sizeKb = (fileSize / 1024).toFixed(1);
            displayEl.innerHTML = "<strong>Selected:</strong> " + fileName + " (" + sizeKb + " KB)";

            // Show client-side live preview using FileReader
            var reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }

        // Form submit validation
        var uploadForm = document.getElementById("uploadPictureForm");
        if (uploadForm) {
            uploadForm.addEventListener("submit", function(event) {
                var input = document.getElementById("profilePictureInput");
                var errorEl = document.getElementById("uploadClientError");

                if (!input.files || input.files.length === 0) {
                    errorEl.innerText = "Please select a valid image file before uploading.";
                    errorEl.style.display = "block";
                    event.preventDefault();
                    return false;
                }
            });
        }
    </script>
</body>
</html>
