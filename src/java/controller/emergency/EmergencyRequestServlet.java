package controller.emergency;

import dao.patient.PatientDAO;
import model.emergency.EmergencyRequest;
import model.patient.Patient;
import service.admin.ActivityLogService;
import service.emergency.EmergencyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "EmergencyRequestServlet", urlPatterns = {"/EmergencyRequestServlet", "/modules/emergency/EmergencyRequestServlet"})
public class EmergencyRequestServlet extends HttpServlet {

    private final EmergencyService emergencyService = new EmergencyService();
    private final PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        List<Patient> patients = patientDAO.getPatientsByUserId(userId);

        request.setAttribute("patients", patients);
        request.getRequestDispatcher("/modules/emergency/emergency_request.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");

        String patientIdStr = request.getParameter("patientId");
        String emergencyType = request.getParameter("emergencyType");
        String pickupAddress = request.getParameter("pickupAddress");
        String contactPhone = request.getParameter("contactPhone");
        String priority = request.getParameter("priority");
        String description = request.getParameter("description");

        if (pickupAddress == null || contactPhone == null || pickupAddress.trim().isEmpty() || contactPhone.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/EmergencyRequestServlet?error="
                    + URLEncoder.encode("Pickup address and contact phone are mandatory for emergency response.", "UTF-8"));
            return;
        }

        Integer patientId = null;
        if (patientIdStr != null && !patientIdStr.trim().isEmpty()) {
            try {
                patientId = Integer.parseInt(patientIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        EmergencyRequest req = new EmergencyRequest();
        req.setUserId(userId);
        req.setPatientId(patientId);
        req.setEmergencyType(emergencyType != null ? emergencyType.trim() : "GENERAL");
        req.setPickupAddress(pickupAddress.trim());
        req.setContactPhone(contactPhone.trim());
        req.setPriority(priority != null ? priority.trim() : "HIGH");
        req.setDescription(description != null ? description.trim() : "");

        boolean ok = emergencyService.requestEmergencyAssistance(req);
        if (ok) {
            ActivityLogService.log(
                String.valueOf(userId), userName, "PATIENT", "EMERGENCY_REQUEST",
                "Dispatched emergency assistance for " + req.getEmergencyType() + " at " + req.getPickupAddress(),
                "EMERGENCY_REQUEST", String.valueOf(req.getRequestId()), "SUCCESS", request.getRemoteAddr()
            );
            response.sendRedirect(request.getContextPath() + "/EmergencyTrackingServlet?requestId=" + req.getRequestId());
        } else {
            response.sendRedirect(request.getContextPath() + "/EmergencyRequestServlet?error="
                    + URLEncoder.encode("Failed to dispatch emergency request. Please call 108 immediately.", "UTF-8"));
        }
    }
}
