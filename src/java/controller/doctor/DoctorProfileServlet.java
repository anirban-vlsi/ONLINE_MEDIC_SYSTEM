package controller.doctor;

import dao.doctor.DoctorDAO;
import model.doctor.Doctor;
import service.doctor.DoctorService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;

@WebServlet(name = "DoctorProfileServlet", urlPatterns = {"/DoctorProfileServlet", "/modules/doctor/DoctorProfileServlet"})
public class DoctorProfileServlet extends HttpServlet {

    private DoctorService doctorService;
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        doctorService = new DoctorService();
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String regNo = null;
        if (session != null) {
            regNo = (String) session.getAttribute("doctorRegistrationNumber");
            if (regNo == null) {
                regNo = (String) session.getAttribute("doctorRegNo");
            }
            if (regNo == null && session.getAttribute("loggedInDoctor") != null) {
                regNo = ((Doctor) session.getAttribute("loggedInDoctor")).getRegistrationNumber();
            }
        }

        if (regNo == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        Doctor doctor = doctorDAO.getDoctorByRegistrationNumber(regNo);
        if (doctor == null || !"VERIFIED".equalsIgnoreCase(doctor.getVerificationStatus())) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        request.setAttribute("doctor", doctor);
        request.getRequestDispatcher("/modules/doctor/doctor_profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String regNo = null;
        if (session != null) {
            regNo = (String) session.getAttribute("doctorRegistrationNumber");
            if (regNo == null) {
                regNo = (String) session.getAttribute("doctorRegNo");
            }
            if (regNo == null && session.getAttribute("loggedInDoctor") != null) {
                regNo = ((Doctor) session.getAttribute("loggedInDoctor")).getRegistrationNumber();
            }
        }

        if (regNo == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        String doctorName = request.getParameter("doctor_name");
        String ageStr = request.getParameter("age");
        String city = request.getParameter("city");
        String address = request.getParameter("address");
        String specialization = request.getParameter("specialization");
        String feeStr = request.getParameter("consultation_fee");
        String homeVisitAvailableStr = request.getParameter("home_visit_available");
        String homeVisitFeeStr = request.getParameter("home_visit_fee");
        String serviceAreas = request.getParameter("service_areas");

        if (doctorName == null || doctorName.trim().isEmpty() || city == null || city.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_profile.jsp?error="
                    + URLEncoder.encode("Doctor name and City are required.", "UTF-8"));
            return;
        }

        int age = 30;
        try {
            age = Integer.parseInt(ageStr.trim());
        } catch (Exception ignored) {}

        BigDecimal fee = new BigDecimal("500.00");
        try {
            fee = new BigDecimal(feeStr.trim());
        } catch (Exception ignored) {}

        boolean homeVisit = "on".equalsIgnoreCase(homeVisitAvailableStr) || "true".equalsIgnoreCase(homeVisitAvailableStr) || "1".equals(homeVisitAvailableStr);
        BigDecimal homeFee = null;
        if (homeVisit && homeVisitFeeStr != null && !homeVisitFeeStr.trim().isEmpty()) {
            try {
                homeFee = new BigDecimal(homeVisitFeeStr.trim());
            } catch (Exception ignored) {}
        }

        Doctor doc = doctorDAO.getDoctorByRegistrationNumber(regNo);
        if (doc == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        doc.setDoctorName(doctorName.trim());
        doc.setAge(age);
        doc.setCity(city.trim());
        doc.setAddress(address != null ? address.trim() : "");
        if (specialization != null && !specialization.trim().isEmpty()) {
            doc.setSpecialization(specialization.trim());
        }
        doc.setConsultationFee(fee);
        doc.setHomeVisitAvailable(homeVisit);
        doc.setHomeVisitFee(homeFee);
        doc.setServiceAreas(serviceAreas != null ? serviceAreas.trim() : null);

        boolean updated = doctorDAO.updateDoctorProfile(doc);
        if (updated) {
            Doctor refreshed = doctorDAO.getDoctorByRegistrationNumber(regNo);
            session.setAttribute("loggedInDoctor", refreshed);
            session.setAttribute("doctor", refreshed);
            session.setAttribute("doctorName", refreshed.getDoctorName());
            session.setAttribute("doctorCity", refreshed.getCity());
            session.setAttribute("doctorSpecialization", refreshed.getSpecialization());

            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_profile.jsp?success="
                    + URLEncoder.encode("Profile updated successfully!", "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_profile.jsp?error="
                    + URLEncoder.encode("Failed to update profile. Please try again.", "UTF-8"));
        }
    }
}
