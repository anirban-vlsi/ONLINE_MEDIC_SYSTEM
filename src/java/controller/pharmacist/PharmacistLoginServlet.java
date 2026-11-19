package controller.pharmacist;

import dao.pharmacist.PharmacistDAO;
import model.pharmacist.Pharmacist;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "PharmacistLoginServlet", urlPatterns = {"/PharmacistLoginServlet", "/modules/pharmacist/PharmacistLoginServlet"})
public class PharmacistLoginServlet extends HttpServlet {
    private final PharmacistDAO pharmacistDAO = new PharmacistDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String loginPage = request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp";

        if (identifier == null || identifier.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(loginPage + "?error=" + URLEncoder.encode("Please enter both Username/Email and Password.", "UTF-8"));
            return;
        }

        Pharmacist pharmacist = pharmacistDAO.authenticate(identifier.trim(), password);
        if (pharmacist != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("loggedInPharmacist", pharmacist);
            session.setAttribute("pharmacistId", pharmacist.getPharmacistId());
            session.setAttribute("pharmacistName", pharmacist.getFullName());
            session.setAttribute("pharmacyName", pharmacist.getPharmacyName());
            session.setMaxInactiveInterval(60 * 60);

            response.sendRedirect(request.getContextPath() + "/PharmacistDashboardServlet");
        } else {
            response.sendRedirect(loginPage + "?error=" + URLEncoder.encode("Invalid operator credentials.", "UTF-8"));
        }
    }
}
