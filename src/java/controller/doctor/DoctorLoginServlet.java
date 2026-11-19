package controller.doctor;

import model.doctor.Doctor;
import service.doctor.DoctorService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "DoctorLoginServlet", urlPatterns = {"/DoctorLoginServlet", "/modules/doctor/DoctorLoginServlet"})
public class DoctorLoginServlet extends HttpServlet {

    private DoctorService doctorService;

    @Override
    public void init() throws ServletException {
        doctorService = new DoctorService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String regNo = request.getParameter("registration_number");
        String password = request.getParameter("password");
        String loginPage = request.getContextPath() + "/modules/doctor/doctor_login.jsp";

        if (regNo == null || regNo.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode("Please enter both Registration Number and Password.", "UTF-8"));
            return;
        }

        Doctor doctor = doctorService.authenticateDoctor(regNo.trim(), password);

        if (doctor == null) {
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode("Invalid Medical Registration Number or Password.", "UTF-8"));
            return;
        }

        String authoritativeStatus = doctorService.getDoctorVerificationStatus(doctor.getRegistrationNumber());
        if (authoritativeStatus == null) {
            authoritativeStatus = doctor.getVerificationStatus();
        }

        if ("NOT VERIFIED".equalsIgnoreCase(authoritativeStatus) || "PENDING".equalsIgnoreCase(authoritativeStatus)) {
            String pendingNotice = "Your account is awaiting administrator verification. You will be able to access the Doctor Portal after approval.";
            response.sendRedirect(loginPage + "?info="
                    + URLEncoder.encode(pendingNotice, "UTF-8"));
            return;
        }

        if ("REJECTED".equalsIgnoreCase(authoritativeStatus)) {
            String rejectedNotice = "Your registration has been rejected by administrator. Please contact support.";
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode(rejectedNotice, "UTF-8"));
            return;
        }

        if ("BLOCKED".equalsIgnoreCase(authoritativeStatus)) {
            String blockedNotice = "Your doctor account has been blocked by administrator. Access to clinical features is restricted.";
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode(blockedNotice, "UTF-8"));
            return;
        }

        if ("VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
            HttpSession session = request.getSession(true);

            // Standardized session attribute key
            session.setAttribute("loggedInDoctor", doctor);

            // Backwards compatibility keys
            session.setAttribute("doctorRegistrationNumber", doctor.getRegistrationNumber());
            session.setAttribute("doctorRegNo", doctor.getRegistrationNumber());
            session.setAttribute("doctorName", doctor.getDoctorName());
            session.setAttribute("doctorEmail", doctor.getEmail());
            session.setAttribute("doctorCity", doctor.getCity());
            session.setAttribute("doctorSpecialization", doctor.getSpecialization());
            session.setAttribute("doctorVerificationStatus", "VERIFIED");
            session.setAttribute("verificationStatus", "VERIFIED");
            session.setAttribute("doctor", doctor);

            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
            return;
        }

        response.sendRedirect(loginPage + "?error="
                + URLEncoder.encode("Account cannot be accessed with current verification status: " + authoritativeStatus, "UTF-8"));
    }
}
