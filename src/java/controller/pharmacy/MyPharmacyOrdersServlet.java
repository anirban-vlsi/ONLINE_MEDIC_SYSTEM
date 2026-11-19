package controller.pharmacy;

import model.pharmacy.PharmacyOrder;
import service.pharmacy.PharmacyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "MyPharmacyOrdersServlet", urlPatterns = {"/MyPharmacyOrdersServlet", "/modules/patient/MyPharmacyOrdersServlet"})
public class MyPharmacyOrdersServlet extends HttpServlet {

    private final PharmacyService pharmacyService = new PharmacyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        List<PharmacyOrder> orders = pharmacyService.getOrdersByUserId(userId);

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/modules/patient/my_pharmacy_orders.jsp").forward(request, response);
    }
}
