package controller.emergency;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "EmergencyOperatorLogoutServlet", urlPatterns = {"/EmergencyOperatorLogoutServlet", "/modules/emergency/EmergencyOperatorLogoutServlet"})
public class EmergencyOperatorLogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("loggedInEmergencyOp");
            session.removeAttribute("operatorId");
            session.removeAttribute("operatorName");
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/modules/emergency/emergency_login.jsp?logout=true");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
