package controller.emergency;

import dao.emergency.EmergencyOperatorDAO;
import model.emergency.EmergencyOperator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "EmergencyOperatorLoginServlet", urlPatterns = {"/EmergencyOperatorLoginServlet", "/modules/emergency/EmergencyOperatorLoginServlet"})
public class EmergencyOperatorLoginServlet extends HttpServlet {
    private final EmergencyOperatorDAO operatorDAO = new EmergencyOperatorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/emergency/emergency_login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String loginPage = request.getContextPath() + "/modules/emergency/emergency_login.jsp";

        if (identifier == null || identifier.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(loginPage + "?error=" + URLEncoder.encode("Please enter both Username/Email and Password.", "UTF-8"));
            return;
        }

        EmergencyOperator op = operatorDAO.authenticate(identifier.trim(), password);
        if (op != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("loggedInEmergencyOp", op);
            session.setAttribute("operatorId", op.getOperatorId());
            session.setAttribute("operatorName", op.getFullName());
            session.setAttribute("dispatchCenter", op.getDispatchCenter());
            session.setMaxInactiveInterval(60 * 60);

            response.sendRedirect(request.getContextPath() + "/EmergencyDashboardServlet");
        } else {
            response.sendRedirect(loginPage + "?error=" + URLEncoder.encode("Invalid emergency operator credentials.", "UTF-8"));
        }
    }
}
