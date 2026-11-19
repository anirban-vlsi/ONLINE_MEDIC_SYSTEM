package controller.patient;

import dao.appointment.AppointmentDAO;
import model.appointment.Appointment;
import model.patient.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "PatientAppointmentsServlet", urlPatterns = {"/PatientAppointmentsServlet", "/modules/patient/PatientAppointmentsServlet"})
public class PatientAppointmentsServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        int userId = getUserId(session);

        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        List<Appointment> appointments = appointmentDAO.getAppointmentsByUserId(userId);
        request.setAttribute("appointments", appointments);
        request.getRequestDispatcher("/modules/patient/my_appointments.jsp").forward(request, response);
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

        String apptIdStr = request.getParameter("appointmentId");
        String action = request.getParameter("action"); // ACCEPT_RESCHEDULE or CANCEL

        if (apptIdStr != null && action != null) {
            try {
                int apptId = Integer.parseInt(apptIdStr.trim());
                if ("ACCEPT_RESCHEDULE".equalsIgnoreCase(action)) {
                    boolean ok = appointmentDAO.acceptReschedule(apptId, userId);
                    String msg = ok ? "New appointment time accepted! Consultation is now confirmed." : "Failed to accept reschedule.";
                    response.sendRedirect(request.getContextPath() + "/PatientAppointmentsServlet?success="
                            + URLEncoder.encode(msg, "UTF-8"));
                    return;
                } else if ("CANCEL".equalsIgnoreCase(action)) {
                    boolean ok = appointmentDAO.cancelAppointmentByPatient(apptId, userId);
                    String msg = ok ? "Appointment has been cancelled." : "Failed to cancel appointment.";
                    response.sendRedirect(request.getContextPath() + "/PatientAppointmentsServlet?info="
                            + URLEncoder.encode(msg, "UTF-8"));
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/PatientAppointmentsServlet");
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
