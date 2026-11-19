package controller.pharmacist;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "PharmacistLogoutServlet", urlPatterns = {"/PharmacistLogoutServlet", "/modules/pharmacist/PharmacistLogoutServlet"})
public class PharmacistLogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("loggedInPharmacist");
            session.removeAttribute("pharmacistId");
            session.removeAttribute("pharmacistName");
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/modules/pharmacist/pharmacist_login.jsp?logout=true");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
