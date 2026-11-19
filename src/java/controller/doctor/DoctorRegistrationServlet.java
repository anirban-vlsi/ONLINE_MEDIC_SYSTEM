package controller.doctor;

import model.doctor.Doctor;
import service.doctor.DoctorService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;

@WebServlet(name = "DoctorRegistrationServlet", urlPatterns = {"/DoctorRegistrationServlet", "/modules/doctor/DoctorRegistrationServlet"})
public class DoctorRegistrationServlet extends HttpServlet {

    private DoctorService doctorService;

    @Override
    public void init() throws ServletException {
        doctorService = new DoctorService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_signup.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String signupPage = request.getContextPath() + "/modules/doctor/doctor_signup.jsp";

        String doctorName = request.getParameter("doctor_name");
        String ageStr = request.getParameter("age");
        String regNo = request.getParameter("registration_number");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String city = request.getParameter("city");
        String address = request.getParameter("address");
        String specialization = request.getParameter("specialization");
        String feeStr = request.getParameter("consultation_fee");
        String homeVisitStr = request.getParameter("home_visit_available");
        String homeFeeStr = request.getParameter("home_visit_fee");
        String serviceAreas = request.getParameter("service_areas");

        if (doctorName == null || doctorName.trim().isEmpty() ||
            ageStr == null || ageStr.trim().isEmpty() ||
            regNo == null || regNo.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty() ||
            city == null || city.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            specialization == null || specialization.trim().isEmpty()) {

            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Please fill in all required fields, including City.", "UTF-8"));
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Password and Confirm Password do not match.", "UTF-8"));
            return;
        }

        int age;
        try {
            age = Integer.parseInt(ageStr.trim());
            if (age < 21 || age > 100) {
                response.sendRedirect(signupPage + "?error="
                        + URLEncoder.encode("Please enter a valid age between 21 and 100.", "UTF-8"));
                return;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Age must be a valid number.", "UTF-8"));
            return;
        }

        if (!email.trim().matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Please provide a valid email address.", "UTF-8"));
            return;
        }

        if (doctorService.isRegistrationNumberExists(regNo.trim())) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Medical Registration Number is already registered.", "UTF-8"));
            return;
        }

        if (doctorService.isEmailExists(email.trim())) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Email address is already registered.", "UTF-8"));
            return;
        }

        BigDecimal fee = new BigDecimal("500.00");
        if (feeStr != null && !feeStr.trim().isEmpty()) {
            try {
                fee = new BigDecimal(feeStr.trim());
            } catch (Exception ignored) {}
        }

        boolean homeVisit = "on".equalsIgnoreCase(homeVisitStr) || "true".equalsIgnoreCase(homeVisitStr) || "1".equals(homeVisitStr);
        BigDecimal homeFee = null;
        if (homeVisit && homeFeeStr != null && !homeFeeStr.trim().isEmpty()) {
            try {
                homeFee = new BigDecimal(homeFeeStr.trim());
            } catch (Exception ignored) {}
        }

        Doctor doctor = new Doctor();
        doctor.setRegistrationNumber(regNo.trim());
        doctor.setDoctorName(doctorName.trim());
        doctor.setAge(age);
        doctor.setEmail(email.trim());
        doctor.setPassword(password);
        doctor.setCity(city.trim());
        doctor.setAddress(address.trim());
        doctor.setSpecialization(specialization.trim());
        doctor.setConsultationFee(fee);
        doctor.setHomeVisitAvailable(homeVisit);
        doctor.setHomeVisitFee(homeFee);
        doctor.setServiceAreas(serviceAreas != null ? serviceAreas.trim() : null);
        doctor.setVerificationStatus("NOT VERIFIED");

        boolean success = doctorService.registerDoctor(doctor);

        if (success) {
            String msg = "Registration successful! Your account is awaiting administrator verification. You will be able to access the Doctor Portal after approval.";
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp?info="
                    + URLEncoder.encode(msg, "UTF-8"));
        } else {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Registration failed. Please try again or check details.", "UTF-8"));
        }
    }
}
