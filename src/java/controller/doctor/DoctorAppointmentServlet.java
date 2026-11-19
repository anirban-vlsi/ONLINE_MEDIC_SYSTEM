package controller.doctor;

import dao.appointment.AppointmentDAO;
import model.appointment.Appointment;
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
import java.sql.Date;
import java.sql.Time;
import java.util.List;

@WebServlet(name = "DoctorAppointmentServlet", urlPatterns = {"/DoctorAppointmentServlet", "/modules/doctor/DoctorAppointmentServlet"})
public class DoctorAppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorService doctorService = new DoctorService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String regNo = getDoctorRegNo(session);

        if (regNo == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        String status = doctorService.getDoctorVerificationStatus(regNo);
        if (!"VERIFIED".equalsIgnoreCase(status)) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
            return;
        }

        List<Appointment> appointments = appointmentDAO.getAppointmentsByDoctor(regNo);
        request.setAttribute("appointments", appointments);
        request.getRequestDispatcher("/modules/doctor/doctor_appointments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String regNo = getDoctorRegNo(session);

        if (regNo == null) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_login.jsp");
            return;
        }

        String status = doctorService.getDoctorVerificationStatus(regNo);
        if (!"VERIFIED".equalsIgnoreCase(status)) {
            response.sendRedirect(request.getContextPath() + "/modules/doctor/doctor_dashboard.jsp");
            return;
        }

        String apptIdStr = request.getParameter("appointmentId");
        String action = request.getParameter("action"); // CONFIRM, COMPLETE, CANCEL, PROPOSE_RESCHEDULE

        if (apptIdStr != null && action != null) {
            try {
                int apptId = Integer.parseInt(apptIdStr.trim());

                if ("PROPOSE_RESCHEDULE".equalsIgnoreCase(action)) {
                    String propDateStr = request.getParameter("proposedDate");
                    String propTimeStr = request.getParameter("proposedTime");
                    String remarks = request.getParameter("doctorRemarks");

                    if (propDateStr == null || propTimeStr == null || propDateStr.trim().isEmpty() || propTimeStr.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?error="
                                + URLEncoder.encode("Proposed Date and Time are required.", "UTF-8"));
                        return;
                    }

                    Date propDate = Date.valueOf(propDateStr.trim());
                    Time propTime = Time.valueOf(propTimeStr.trim().length() == 5 ? propTimeStr.trim() + ":00" : propTimeStr.trim());

                    boolean ok = appointmentDAO.proposeReschedule(apptId, regNo, propDate, propTime, remarks);
                    String msg = ok ? "Reschedule proposed to patient successfully." : "Failed to propose reschedule.";
                    response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?msg="
                            + URLEncoder.encode(msg, "UTF-8"));
                    return;

                } else if ("CONFIRM".equalsIgnoreCase(action)) {
                    String timeStr = request.getParameter("appointmentTime");
                    if (timeStr == null || timeStr.trim().isEmpty()) {
                        Appointment existingAppt = appointmentDAO.getAppointmentById(apptId);
                        if (existingAppt != null && existingAppt.getAppointmentTime() != null) {
                            timeStr = existingAppt.getAppointmentTime().toString();
                        } else {
                            response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?error="
                                    + URLEncoder.encode("Please assign an exact appointment time to approve this booking.", "UTF-8"));
                            return;
                        }
                    }

                    Time apptTime = Time.valueOf(timeStr.trim().length() == 5 ? timeStr.trim() + ":00" : timeStr.trim());
                    boolean ok = appointmentDAO.confirmAppointmentWithTime(apptId, regNo, apptTime);
                    if (ok) {
                        response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?msg="
                                + URLEncoder.encode("Appointment approved and scheduled for " + timeStr + ".", "UTF-8"));
                    } else {
                        response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?error="
                                + URLEncoder.encode("Time conflict: You already have another confirmed appointment scheduled for " + timeStr + " on that date. Please choose a different time.", "UTF-8"));
                    }
                    return;

                } else if ("COMPLETE".equalsIgnoreCase(action)) {
                    boolean ok = appointmentDAO.updateAppointmentStatusByDoctor(apptId, regNo, "COMPLETED", null);
                    response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?msg="
                            + URLEncoder.encode(ok ? "Appointment marked as completed." : "Update failed.", "UTF-8"));
                    return;

                } else if ("CANCEL".equalsIgnoreCase(action)) {
                    String remarks = request.getParameter("doctorRemarks");
                    boolean ok = appointmentDAO.updateAppointmentStatusByDoctor(apptId, regNo, "CANCELLED", remarks);
                    response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet?msg="
                            + URLEncoder.encode(ok ? "Appointment cancelled." : "Update failed.", "UTF-8"));
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/DoctorAppointmentServlet");
    }

    private String getDoctorRegNo(HttpSession session) {
        if (session == null) return null;
        Object reg = session.getAttribute("doctorRegistrationNumber");
        if (reg != null) return (String) reg;
        reg = session.getAttribute("doctorRegNo");
        if (reg != null) return (String) reg;
        Object doc = session.getAttribute("loggedInDoctor");
        if (doc instanceof Doctor) {
            return ((Doctor) doc).getRegistrationNumber();
        }
        return null;
    }
}
