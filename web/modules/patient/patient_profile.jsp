<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%@ page import="model.patient.User" %>
<%@ page import="service.patient.UserService" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || (session.getAttribute("userId") == null && session.getAttribute("loggedInUser") == null)) {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
        return;
    }

    int userId = -1;
    Object uidObj = session.getAttribute("userId");
    if (uidObj instanceof Integer) {
        userId = (Integer) uidObj;
    } else {
        User su = (User) session.getAttribute("loggedInUser");
        if (su != null) userId = su.getUserId();
    }

    UserService userService = new UserService();
    User userObj = userService.getUserById(userId);

    String userName = (userObj != null && userObj.getName() != null) ? userObj.getName() : "Patient";
    String userEmail = (userObj != null && userObj.getEmail() != null) ? userObj.getEmail() : "";
    String gender = (userObj != null && userObj.getGender() != null) ? userObj.getGender() : "";
    String mobile = (userObj != null && userObj.getMobileNo() != null) ? userObj.getMobileNo() : "";
    String userStatus = (userObj != null && userObj.getStatus() != null) ? userObj.getStatus() : "NOT VERIFIED";
    boolean isVerified = "VERIFIED".equalsIgnoreCase(userStatus);

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Account Profile - Online Medical System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="navbar">
        <a href="${pageContext.request.contextPath}/modules/patient/patient_dashboard.jsp" class="navbar-brand">
            <span class="cross-icon">&#10010;</span> Online Medical System
            <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-left: 8px;">| Account Profile</span>
        </a>
        <nav>
            <ul class="navbar-nav">
                <li><a href="${pageContext.request.contextPath}/modules/patient/patient_dashboard.jsp">Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/PatientProfileServlet">My Dependents</a></li>
                <li><a href="${pageContext.request.contextPath}/PatientLogoutServlet" style="color: #dc2626;" onclick="return confirmLogout();">Logout</a></li>
            </ul>
        </nav>
    </header>

    <main class="main-content main-content-narrow">

        <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
            <div class="alert alert-success" style="margin-bottom: 20px;">
                <strong>&#10003; Success:</strong> <%= successMsg %>
            </div>
        <% } %>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error" style="margin-bottom: 20px;">
                <strong>&#9888; Error:</strong> <%= errorMsg %>
            </div>
        <% } %>

        <!-- Profile Overview Card -->
        <div class="card">
            <div class="card-header" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 20px;">
                    <div class="avatar-preview-box">
                        <img src="${pageContext.request.contextPath}/ProfilePictureServlet" alt="<%= userName %>">
                    </div>
                    <div>
                        <h1 class="page-title" style="margin-bottom: 2px;"><%= userName %></h1>
                        <p class="page-subtitle"><%= userEmail %></p>
                    </div>
                </div>
                <div>
                    <% if (isVerified) { %>
                        <span class="badge badge-verified" style="font-size: 0.95rem; padding: 6px 14px;">&#10003; VERIFIED PATIENT</span>
                    <% } else { %>
                        <span class="badge badge-unverified" style="font-size: 0.95rem; padding: 6px 14px;">&#9888; NOT VERIFIED</span>
                    <% } %>
                </div>
            </div>

            <!-- Profile Edit Form (Requirement 2) -->
            <form action="${pageContext.request.contextPath}/UpdatePatientProfileServlet" method="post" enctype="multipart/form-data" style="margin-top: 10px;">
                <h3 style="font-size: 1.15rem; margin-bottom: 14px; border-bottom: 1px solid var(--border-color); padding-bottom: 6px;">
                    &#9998; Edit Account Details
                </h3>

                <div class="form-group">
                    <label class="form-label">Full Name <span class="required">*</span></label>
                    <input type="text" name="name" class="form-control" value="<%= userName %>" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Email Address (Read-only)</label>
                    <input type="email" class="form-control" value="<%= userEmail %>" disabled style="background: #f3f4f6;">
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Gender <span class="required">*</span></label>
                        <select name="gender" class="form-control" required>
                            <option value="MALE" <%= "MALE".equalsIgnoreCase(gender) ? "selected" : "" %>>Male</option>
                            <option value="FEMALE" <%= "FEMALE".equalsIgnoreCase(gender) ? "selected" : "" %>>Female</option>
                            <option value="OTHER" <%= "OTHER".equalsIgnoreCase(gender) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mobile Number <span class="required">*</span></label>
                        <input type="tel" name="mobile_no" class="form-control" value="<%= mobile %>" placeholder="10-digit mobile number" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Re-upload / Change Profile Picture (JPG / PNG, Max 2MB)</label>
                    <input type="file" name="profilePicture" accept=".jpg,.jpeg,.png,image/jpeg,image/png" class="form-control">
                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 4px;">
                        Note: Uploading a complete profile picture with all fields non-empty will auto-trigger DBMS verification.
                    </div>
                </div>

                <div class="btn-group" style="margin-top: 20px;">
                    <button type="submit" class="btn btn-primary">
                        Save Profile Changes
                    </button>
                    <a href="${pageContext.request.contextPath}/modules/patient/patient_dashboard.jsp" class="btn btn-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>

        <!-- Trust & Safety: Submit Grievance / Feedback (Requirement 6) -->
        <div class="card" style="margin-top: 24px; border-top: 4px solid #f59e0b;">
            <div class="card-header">
                <h2 class="page-title" style="font-size: 1.25rem; color: #b45309;">&#128227; Submit Service Feedback or Incident Report</h2>
                <p class="page-subtitle">Report clinical issues, pharmacy disputes, or ambulance feedback directly to Hospital Administration.</p>
            </div>

            <form action="${pageContext.request.contextPath}/SubmitFeedbackServlet" method="post">
                <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/modules/patient/patient_profile.jsp">

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select name="reportCategory" class="form-control" required>
                            <option value="FEEDBACK">Positive Feedback / Review</option>
                            <option value="COMPLAINT">Formal Complaint / Dispute</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Target Service</label>
                        <select name="targetType" class="form-control" required>
                            <option value="DOCTOR">Doctor Consultation</option>
                            <option value="PHARMACY">Pharmacy / Medicine Delivery</option>
                            <option value="AMBULANCE">Ambulance / Emergency Service</option>
                        </select>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label">Doctor Reg No / Pharmacy / Vehicle ID <span class="required">*</span></label>
                        <input type="text" name="targetId" class="form-control" placeholder="e.g. DOC-101, Central Pharmacy, KA-01-AB-1234" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Rating (Optional)</label>
                        <select name="rating" class="form-control">
                            <option value="">No Rating</option>
                            <option value="5">&#9733;&#9733;&#9733;&#9733;&#9733; 5 Stars (Excellent)</option>
                            <option value="4">&#9733;&#9733;&#9733;&#9733; 4 Stars (Good)</option>
                            <option value="3">&#9733;&#9733;&#9733; 3 Stars (Average)</option>
                            <option value="2">&#9733;&#9733; 2 Stars (Poor)</option>
                            <option value="1">&#9733; 1 Star (Unsatisfactory)</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Comments & Incident Details <span class="required">*</span></label>
                    <textarea name="comments" rows="3" class="form-control" placeholder="Describe your experience or incident for administrative review..." required></textarea>
                </div>

                <button type="submit" class="btn btn-outline" style="border-color: #b45309; color: #b45309;">
                    Submit to Moderation Team &rarr;
                </button>
            </form>
        </div>
    </main>

    <footer class="footer">
        <p>&copy; 2026 Online Medical System. All rights reserved.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/common.js"></script>
</body>
</html>
