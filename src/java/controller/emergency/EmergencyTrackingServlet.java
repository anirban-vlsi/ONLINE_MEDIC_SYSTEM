package controller.emergency;

import model.emergency.EmergencyRequest;
import service.emergency.EmergencyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EmergencyTrackingServlet", urlPatterns = {"/EmergencyTrackingServlet", "/modules/emergency/EmergencyTrackingServlet"})
public class EmergencyTrackingServlet extends HttpServlet {

    private final EmergencyService emergencyService = new EmergencyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String reqIdParam = request.getParameter("requestId");

        EmergencyRequest emergencyRequest = null;
        if (reqIdParam != null && !reqIdParam.trim().isEmpty()) {
            try {
                int reqId = Integer.parseInt(reqIdParam.trim());
                emergencyRequest = emergencyService.getRequestById(reqId);
            } catch (NumberFormatException ignored) {}
        }

        if (emergencyRequest == null) {
            List<EmergencyRequest> userRequests = emergencyService.getRequestsByUserId(userId);
            if (!userRequests.isEmpty()) {
                emergencyRequest = userRequests.get(0);
            }
        }

        request.setAttribute("request", emergencyRequest);
        request.getRequestDispatcher("/modules/emergency/emergency_tracking.jsp").forward(request, response);
    }
}
