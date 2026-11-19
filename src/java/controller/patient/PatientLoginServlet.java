package controller.patient;

import model.patient.User;
import service.patient.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "PatientLoginServlet", urlPatterns = {"/PatientLoginServlet", "/modules/patient/PatientLoginServlet"})
public class PatientLoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String loginPage = request.getContextPath() + "/modules/patient/patient_login.jsp";

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode("Please enter both email and password.", "UTF-8"));
            return;
        }

        User user = userService.loginUser(email.trim(), password);

        if (user != null) {
            HttpSession session = request.getSession(true);

            String currentStatus = userService.getUserStatus(user.getUserId());
            user.setStatus(currentStatus);

            // Standardized session attribute key
            session.setAttribute("loggedInUser", user);

            // Backwards compatibility attributes
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userStatus", user.getStatus());
            session.setAttribute("user", user);

            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp");
        } else {
            response.sendRedirect(loginPage + "?error="
                    + URLEncoder.encode("Invalid email or password.", "UTF-8"));
        }
    }
}
