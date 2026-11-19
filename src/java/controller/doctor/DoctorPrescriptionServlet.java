package controller.doctor;

import model.appointment.Appointment;
import model.prescription.Prescription;
import service.appointment.AppointmentService;
import service.doctor.DoctorService;
import service.prescription.PrescriptionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "DoctorPrescriptionServlet", urlPatterns = {"/DoctorPrescriptionServlet", "/modules/doctor/DoctorPrescriptionServlet"})
public class DoctorPrescriptionServlet extends HttpServlet {

    private final PrescriptionService prescriptionService = new PrescriptionService();
    private final AppointmentService appointmentService = new AppointmentService();
    private final DoctorService doctorService = new DoctorService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("doctorRegistrationNumber") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        String regNo = (String) session.getAttribute("doctorRegistrationNumber");
        String status = doctorService.getDoctorVerificationStatus(regNo);

        // Strict Server-Side Check
        if (!"VERIFIED".equalsIgnoreCase(status)) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
            return;
        }

        String apptIdParam = request.getParameter("appointmentId");
        if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
            try {
                int apptId = Integer.parseInt(apptIdParam.trim());
                Appointment appt = appointmentService.getAppointmentById(apptId);
                if (appt != null && regNo.equalsIgnoreCase(appt.getDoctorRegNo())) {
                    request.setAttribute("appointment", appt);
                    request.getRequestDispatcher("/modules/doctor/issue_prescription.jsp").forward(request, response);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Default: List doctor's issued prescriptions
        List<Prescription> prescriptions = prescriptionService.getPrescriptionsByDoctor(regNo);
        request.setAttribute("prescriptions", prescriptions);
        request.getRequestDispatcher("/modules/doctor/doctor_prescriptions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("doctorRegistrationNumber") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        String regNo = (String) session.getAttribute("doctorRegistrationNumber");
        String status = doctorService.getDoctorVerificationStatus(regNo);

        // Strict Server-Side Check
        if (!"VERIFIED".equalsIgnoreCase(status)) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
            return;
        }

        String apptIdStr = request.getParameter("appointmentId");
        String patientIdStr = request.getParameter("patientId");
        String diagnosis = request.getParameter("diagnosis");
        String medicines = request.getParameter("medicines");
        String dosage = request.getParameter("dosageInstructions");
        String notes = request.getParameter("notes");
        String followUpStr = request.getParameter("followUpDate");

        if (apptIdStr == null || patientIdStr == null || diagnosis == null || medicines == null) {
            response.sendRedirect(request.getContextPath() + "/DoctorPrescriptionServlet?error="
                    + URLEncoder.encode("Missing required prescription fields.", "UTF-8"));
            return;
        }

        try {
            int apptId = Integer.parseInt(apptIdStr.trim());
            int patientId = Integer.parseInt(patientIdStr.trim());

            Prescription rx = new Prescription();
            rx.setAppointmentId(apptId);
            rx.setPatientId(patientId);
            rx.setDoctorRegNo(regNo);
            rx.setDiagnosis(diagnosis.trim());
            rx.setMedicines(medicines.trim());
            rx.setDosageInstructions(dosage != null ? dosage.trim() : "");
            rx.setNotes(notes != null ? notes.trim() : "");
            rx.setPrescribedDate(new Date(System.currentTimeMillis()));

            if (followUpStr != null && !followUpStr.trim().isEmpty()) {
                rx.setFollowUpDate(Date.valueOf(followUpStr.trim()));
            }

            boolean ok = prescriptionService.createPrescription(rx);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/DoctorPrescriptionServlet?success="
                        + URLEncoder.encode("Prescription issued successfully and appointment marked as COMPLETED.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/DoctorPrescriptionServlet?error="
                        + URLEncoder.encode("Failed to issue prescription. Please check details.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/DoctorPrescriptionServlet?error="
                    + URLEncoder.encode("Error processing prescription: " + e.getMessage(), "UTF-8"));
        }
    }
}
