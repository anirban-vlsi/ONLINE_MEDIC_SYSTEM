package controller.doctor;

import dao.doctor.DoctorAvailabilityDAO;
import model.doctor.Doctor;
import model.doctor.DoctorAvailability;
import service.doctor.DoctorService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Time;
import java.util.List;

@WebServlet(name = "DoctorAvailabilityServlet", urlPatterns = {"/DoctorAvailabilityServlet", "/modules/doctor/DoctorAvailabilityServlet"})
public class DoctorAvailabilityServlet extends HttpServlet {

    private final DoctorAvailabilityDAO availabilityDAO = new DoctorAvailabilityDAO();
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

        String modeFilter = request.getParameter("visitMode");
        List<DoctorAvailability> schedule = availabilityDAO.getAvailabilityByDoctorAndMode(regNo, modeFilter);
        request.setAttribute("schedule", schedule);
        request.setAttribute("activeMode", modeFilter != null ? modeFilter : "ALL");

        Doctor doctor = doctorService.getDoctorByRegistrationNumber(regNo);
        request.setAttribute("doctor", doctor);

        request.getRequestDispatcher("/modules/doctor/doctor_availability.jsp").forward(request, response);
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

        String visitMode = request.getParameter("visitMode");
        if (visitMode == null || visitMode.trim().isEmpty()) {
            visitMode = "CLINIC";
        }
        String day = request.getParameter("dayOfWeek");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String maxPatientsStr = request.getParameter("maxPatientsPerDay");
        if (maxPatientsStr == null || maxPatientsStr.trim().isEmpty()) {
            maxPatientsStr = request.getParameter("maxPatients");
        }

        if (day == null || startTimeStr == null || endTimeStr == null) {
            response.sendRedirect(request.getContextPath() + "/DoctorAvailabilityServlet?error="
                    + URLEncoder.encode("Please enter all required schedule fields.", "UTF-8"));
            return;
        }

        try {
            Time startTime = Time.valueOf(startTimeStr.trim().length() == 5 ? startTimeStr.trim() + ":00" : startTimeStr.trim());
            Time endTime = Time.valueOf(endTimeStr.trim().length() == 5 ? endTimeStr.trim() + ":00" : endTimeStr.trim());
            int maxPatients = (maxPatientsStr != null && !maxPatientsStr.trim().isEmpty())
                    ? Integer.parseInt(maxPatientsStr.trim()) : 20;

            DoctorAvailability da = new DoctorAvailability();
            da.setDoctorRegNo(regNo);
            da.setVisitMode(visitMode.trim().toUpperCase());
            da.setDayOfWeek(day.trim().toUpperCase());
            da.setStartTime(startTime);
            da.setEndTime(endTime);
            da.setMaxPatientsPerDay(maxPatients);
            da.setMaxPatients(maxPatients);
            da.setActive(true);

            boolean saved = availabilityDAO.saveOrUpdateAvailability(da);
            String param = saved ? "msg=" : "error=";
            String msg = saved ? visitMode.toUpperCase() + " schedule for " + day + " updated successfully." : "Failed to update schedule.";
            response.sendRedirect(request.getContextPath() + "/DoctorAvailabilityServlet?" + param + URLEncoder.encode(msg, "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/DoctorAvailabilityServlet?error="
                    + URLEncoder.encode("Invalid time or number format.", "UTF-8"));
        }
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
