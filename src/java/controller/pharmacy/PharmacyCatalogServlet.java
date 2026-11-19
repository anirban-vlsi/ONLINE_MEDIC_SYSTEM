package controller.pharmacy;

import model.pharmacy.Medicine;
import service.pharmacy.PharmacyService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PharmacyCatalogServlet", urlPatterns = {"/PharmacyCatalogServlet", "/modules/pharmacy/PharmacyCatalogServlet"})
public class PharmacyCatalogServlet extends HttpServlet {

    private final PharmacyService pharmacyService = new PharmacyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("query");
        String category = request.getParameter("category");

        List<Medicine> medicines = pharmacyService.searchMedicines(query, category);
        List<String> categories = pharmacyService.getCategories();

        request.setAttribute("medicines", medicines);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("searchQuery", query);

        request.getRequestDispatcher("/modules/pharmacy/pharmacy_catalog.jsp").forward(request, response);
    }
}
