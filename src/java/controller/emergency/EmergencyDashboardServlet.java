package controller.emergency;

import dao.emergency.AmbulanceDAO;
import dao.emergency.EmergencyOperatorDAO;
import dao.emergency.EmergencyRequestDAO;
import model.emergency.Ambulance;
import model.emergency.EmergencyOperator;
import model.emergency.EmergencyRequest;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "EmergencyDashboardServlet", urlPatterns = {"/EmergencyDashboardServlet", "/modules/emergency/EmergencyDashboardServlet"})
public class EmergencyDashboardServlet extends HttpServlet {

    private final EmergencyOperatorDAO operatorDAO = new EmergencyOperatorDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();
    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        EmergencyOperator operator = getAuthenticatedOperator(session);

        if (operator == null) {
            response.sendRedirect(request.getContextPath() + "/modules/emergency/emergency_login.jsp");
            return;
        }

        List<Ambulance> fleet = ambulanceDAO.getAllAmbulances();
        List<EmergencyRequest> activeRequests = requestDAO.getAllRequests("ALL");

        request.setAttribute("operator", operator);
        request.setAttribute("fleet", fleet);
        request.setAttribute("activeRequests", activeRequests);

        request.getRequestDispatcher("/modules/emergency/emergency_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        EmergencyOperator operator = getAuthenticatedOperator(session);

        if (operator == null) {
            response.sendRedirect(request.getContextPath() + "/modules/emergency/emergency_login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("UPDATE_PROFILE".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String dispatchCenter = request.getParameter("dispatchCenter");

            boolean ok = operatorDAO.updateProfile(operator.getOperatorId(), fullName, phone, dispatchCenter);
            if (ok) {
                EmergencyOperator refreshed = operatorDAO.getOperatorById(operator.getOperatorId());
                session.setAttribute("loggedInEmergencyOp", refreshed);
                session.setAttribute("operatorName", refreshed.getFullName());
                session.setAttribute("dispatchCenter", refreshed.getDispatchCenter());
                response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?success="
                        + URLEncoder.encode("Operator profile updated successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?error="
                        + URLEncoder.encode("Failed to update profile.", "UTF-8"));
            }
            return;

        } else if ("SAVE_AMBULANCE".equalsIgnoreCase(action)) {
            String ambIdStr = request.getParameter("ambulanceId");
            String vehicleNumber = request.getParameter("vehicleNumber");
            String driverName = request.getParameter("driverName");
            String driverPhone = request.getParameter("driverPhone");
            String ambulanceType = request.getParameter("ambulanceType");
            String baseHospital = request.getParameter("baseHospital");
            String currentStatus = request.getParameter("currentStatus");
            String location = request.getParameter("location");
            String moderationStatus = request.getParameter("moderationStatus");

            if (vehicleNumber == null || vehicleNumber.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?error="
                        + URLEncoder.encode("Vehicle number is required.", "UTF-8"));
                return;
            }

            int ambId = 0;
            if (ambIdStr != null && !ambIdStr.trim().isEmpty()) {
                try { ambId = Integer.parseInt(ambIdStr.trim()); } catch (Exception ignored) {}
            }

            Ambulance a = new Ambulance();
            a.setAmbulanceId(ambId);
            a.setVehicleNumber(vehicleNumber.trim());
            a.setDriverName(driverName != null ? driverName.trim() : "");
            a.setDriverPhone(driverPhone != null ? driverPhone.trim() : "");
            a.setAmbulanceType(ambulanceType != null ? ambulanceType.trim() : "BASIC");
            a.setBaseHospital(baseHospital != null ? baseHospital.trim() : "Central Hospital");
            a.setCurrentStatus(currentStatus != null ? currentStatus.trim() : "AVAILABLE");
            a.setLocation(location != null ? location.trim() : "");
            a.setModerationStatus(moderationStatus != null ? moderationStatus.trim().toUpperCase() : "ACTIVE");

            boolean saved = ambulanceDAO.saveAmbulance(a);
            String msg = saved ? (ambId > 0 ? "Ambulance updated successfully!" : "New ambulance registered to fleet!") : "Failed to save ambulance.";
            response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?" + (saved ? "success=" : "error=")
                    + URLEncoder.encode(msg, "UTF-8"));
            return;

        } else if ("DISPATCH_AMBULANCE".equalsIgnoreCase(action)) {
            String reqIdStr = request.getParameter("requestId");
            String ambIdStr = request.getParameter("ambulanceId");

            if (reqIdStr != null && ambIdStr != null) {
                try {
                    int reqId = Integer.parseInt(reqIdStr.trim());
                    int ambId = Integer.parseInt(ambIdStr.trim());
                    requestDAO.dispatchAmbulance(reqId, ambId);

                    response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?success="
                            + URLEncoder.encode("Ambulance dispatched to Emergency Request #" + reqId, "UTF-8"));
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else if ("COMPLETE_REQUEST".equalsIgnoreCase(action)) {
            String reqIdStr = request.getParameter("requestId");
            String ambIdStr = request.getParameter("ambulanceId");
            if (reqIdStr != null) {
                try {
                    int reqId = Integer.parseInt(reqIdStr.trim());
                    requestDAO.updateRequestStatus(reqId, "COMPLETED");
                    if (ambIdStr != null && !ambIdStr.trim().isEmpty()) {
                        int ambId = Integer.parseInt(ambIdStr.trim());
                        ambulanceDAO.updateAmbulanceStatus(ambId, "AVAILABLE");
                    }
                    response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet?success="
                            + URLEncoder.encode("Emergency Request #" + reqId + " marked as COMPLETED.", "UTF-8"));
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet");
    }

    private EmergencyOperator getAuthenticatedOperator(HttpSession session) {
        if (session == null) return null;
        Object op = session.getAttribute("loggedInEmergencyOp");
        if (op instanceof EmergencyOperator) return (EmergencyOperator) op;
        Object opId = session.getAttribute("operatorId");
        if (opId instanceof Integer) {
            return operatorDAO.getOperatorById((Integer) opId);
        }
        return null;
    }
}
