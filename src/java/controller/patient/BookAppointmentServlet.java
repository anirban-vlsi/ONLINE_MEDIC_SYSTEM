package controller.patient;

import dao.appointment.AppointmentDAO;
import dao.doctor.DoctorAvailabilityDAO;
import dao.doctor.DoctorDAO;
import dao.finance.FinancialTransactionDAO;
import dao.patient.PatientDAO;
import model.appointment.Appointment;
import model.doctor.Doctor;
import model.doctor.DoctorAvailability;
import model.finance.FinancialTransaction;
import model.patient.Patient;
import model.patient.User;
import service.patient.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/BookAppointmentServlet", "/modules/patient/BookAppointmentServlet"})
public class BookAppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DoctorAvailabilityDAO availabilityDAO = new DoctorAvailabilityDAO();
    private final FinancialTransactionDAO financialDAO = new FinancialTransactionDAO();
    private final UserService userService = new UserService();
    private final PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = getUserId(session);

        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        String authoritativeStatus = userService.getUserStatus(userId);
        if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
            String notice = "Account verification required! You must upload your profile picture and complete your profile details before booking an appointment.";
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp?error="
                    + URLEncoder.encode(notice, "UTF-8"));
            return;
        }

        String specialization = request.getParameter("specialization");
        String city = request.getParameter("city");
        String visitMode = request.getParameter("visitMode");
        String sortBy = request.getParameter("sortBy");

        if (visitMode == null || visitMode.trim().isEmpty()) {
            visitMode = "ALL";
        }
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "NAME_ASC";
        }

        boolean filterApplied = (specialization != null && !specialization.trim().isEmpty()
                                && city != null && !city.trim().isEmpty());

        List<Doctor> doctors = null;
        Map<String, List<DoctorAvailability>> doctorSchedules = new HashMap<>();

        if (filterApplied) {
            doctors = doctorDAO.findDoctors(specialization.trim(), city.trim(), visitMode.trim(), sortBy.trim());
            for (Doctor d : doctors) {
                List<DoctorAvailability> daList = availabilityDAO.getAvailabilityByDoctor(d.getRegistrationNumber());
                doctorSchedules.put(d.getRegistrationNumber(), daList);
            }
        }

        List<Patient> patients = patientDAO.getPatientsByUserId(userId);

        request.setAttribute("filterApplied", filterApplied);
        request.setAttribute("specialization", specialization);
        request.setAttribute("city", city);
        request.setAttribute("visitMode", visitMode);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("doctors", doctors);
        request.setAttribute("doctorSchedules", doctorSchedules);
        request.setAttribute("patients", patients);

        request.getRequestDispatcher("/modules/patient/book_appointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = getUserId(session);

        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        String authoritativeStatus = userService.getUserStatus(userId);
        if (!"VERIFIED".equalsIgnoreCase(authoritativeStatus)) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp?error="
                    + URLEncoder.encode("Unverified accounts cannot book appointments.", "UTF-8"));
            return;
        }

        String patientIdStr = request.getParameter("patientId");
        String doctorRegNo = request.getParameter("doctorRegNo");
        String visitType = request.getParameter("visitType");
        String patientCity = request.getParameter("patientCity");
        String patientHomeAddress = request.getParameter("patientHomeAddress");
        String apptDateStr = request.getParameter("appointmentDate");
        String reason = request.getParameter("reason");
        String paymentMethod = request.getParameter("paymentMethod");

        if (visitType == null || visitType.trim().isEmpty()) {
            visitType = "CLINIC";
        }

        if (patientIdStr == null || doctorRegNo == null || apptDateStr == null) {
            redirectWithError(request, response, "Please fill in all required appointment fields.");
            return;
        }

        try {
            int patientId = Integer.parseInt(patientIdStr.trim());
            Date apptDate = Date.valueOf(apptDateStr.trim());

            // 1. Verify doctor exists and is verified
            Doctor doctor = doctorDAO.getDoctorByRegistrationNumber(doctorRegNo.trim());
            if (doctor == null || !"VERIFIED".equalsIgnoreCase(doctor.getVerificationStatus())) {
                redirectWithError(request, response, "Selected doctor is not available for appointments.");
                return;
            }

            // 2. Location & Home Visit checks
            BigDecimal feeCharged = doctor.getConsultationFee();
            if ("HOME_VISIT".equalsIgnoreCase(visitType)) {
                if (!doctor.isHomeVisitAvailable()) {
                    redirectWithError(request, response, "Doctor does not offer home visits.");
                    return;
                }
                if (patientHomeAddress == null || patientHomeAddress.trim().isEmpty()) {
                    redirectWithError(request, response, "Home street address is required for Home Visit consultations.");
                    return;
                }
                if (patientCity == null || patientCity.trim().isEmpty()) {
                    redirectWithError(request, response, "Patient city is required for Home Visit consultations.");
                    return;
                }

                String cleanPatientCity = patientCity.trim().toLowerCase();
                boolean cityMatches = cleanPatientCity.equalsIgnoreCase(doctor.getCity().trim())
                        || (doctor.getServiceAreas() != null && doctor.getServiceAreas().toLowerCase().contains(cleanPatientCity));

                if (!cityMatches) {
                    redirectWithError(request, response, "Doctor does not cover home visits in " + patientCity + ". Covered areas: " + (doctor.getServiceAreas() != null ? doctor.getServiceAreas() : doctor.getCity()));
                    return;
                }

                feeCharged = doctor.getHomeVisitFee() != null ? doctor.getHomeVisitFee() : doctor.getConsultationFee();
            }

            // 3. Day of week & Availability Window Check
            LocalDate localDate = LocalDate.parse(apptDateStr.trim());
            String dayOfWeek = localDate.getDayOfWeek().name(); // MONDAY..SUNDAY

            DoctorAvailability avail = availabilityDAO.getAvailabilityForSlot(doctorRegNo.trim(), visitType.trim().toUpperCase(), dayOfWeek);
            if (avail == null || !avail.isActive()) {
                redirectWithError(request, response, "Doctor has no active " + visitType + " schedule on " + dayOfWeek + "s. Please choose another date.");
                return;
            }

            // 4. Daily Quota Check (Max patients per day per mode)
            int bookedCount = appointmentDAO.countAppointmentsOnDate(doctorRegNo.trim(), apptDate, visitType.trim().toUpperCase());
            int quota = avail.getMaxPatientsPerDay() > 0 ? avail.getMaxPatientsPerDay() : 20;
            if (bookedCount >= quota) {
                redirectWithError(request, response, "Daily quota full for " + dayOfWeek + " (" + apptDateStr + ") — please select another date.");
                return;
            }

            // 5. Save Appointment (Time is assigned by doctor upon confirmation)
            Appointment appt = new Appointment();
            appt.setUserId(userId);
            appt.setPatientId(patientId);
            appt.setDoctorRegNo(doctorRegNo.trim());
            appt.setVisitType(visitType.trim().toUpperCase());
            appt.setPatientCity(patientCity != null ? patientCity.trim() : doctor.getCity());
            appt.setPatientHomeAddress(patientHomeAddress != null ? patientHomeAddress.trim() : null);
            appt.setFeeCharged(feeCharged);
            appt.setAppointmentDate(apptDate);
            appt.setAppointmentTime(null);
            appt.setReason(reason != null ? reason.trim() : "");
            appt.setStatus("PENDING");
            appt.setPaymentStatus("UNPAID");

            boolean booked = appointmentDAO.bookAppointment(appt);
            if (!booked) {
                redirectWithError(request, response, "Failed to book appointment. Please try again.");
                return;
            }

            // 7. Simulated Payment Gateway & 15% Admin Commission Split
            FinancialTransaction tx = financialDAO.processAppointmentPayment(
                    appt.getAppointmentId(), userId, doctorRegNo.trim(), feeCharged, paymentMethod);

            String successMsg = "Appointment booked and paid successfully via " + (paymentMethod != null ? paymentMethod.toUpperCase() : "UPI")
                    + "! Transaction ID: " + (tx != null ? tx.getTransactionId() : "N/A");

            response.sendRedirect(request.getContextPath() + "/PatientAppointmentsServlet?success="
                    + URLEncoder.encode(successMsg, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(request, response, "Error processing appointment request: " + e.getMessage());
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String error) throws IOException {
        response.sendRedirect(request.getContextPath() + "/BookAppointmentServlet?error=" + URLEncoder.encode(error, "UTF-8"));
    }

    private int getUserId(HttpSession session) {
        if (session == null) return -1;
        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) return (Integer) uid;
        Object u = session.getAttribute("loggedInUser");
        if (u instanceof User) return ((User) u).getUserId();
        return -1;
    }
}
