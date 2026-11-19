package controller.admin;

import dao.finance.FinancialTransactionDAO;
import model.admin.Admin;
import model.finance.FinancialTransaction;
import service.admin.AdminService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdminFinancialServlet", urlPatterns = {"/AdminFinancialServlet", "/modules/admin/AdminFinancialServlet"})
public class AdminFinancialServlet extends HttpServlet {

    private final FinancialTransactionDAO financialDAO = new FinancialTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Admin admin = AdminService.getAuthenticatedAdmin(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/modules/admin/admin_login.jsp");
            return;
        }

        String serviceFilter = request.getParameter("serviceType");

        BigDecimal grossRevenue = financialDAO.getTotalGrossRevenue();
        BigDecimal adminProfit = financialDAO.getTotalAdminCommission();
        BigDecimal doctorPayouts = financialDAO.getTotalDoctorPayouts();
        BigDecimal pharmacyPayouts = financialDAO.getTotalPharmacyPayouts();
        List<FinancialTransaction> transactions = financialDAO.getAllTransactions(serviceFilter);

        request.setAttribute("admin", admin);
        request.setAttribute("grossRevenue", grossRevenue);
        request.setAttribute("adminProfit", adminProfit);
        request.setAttribute("doctorPayouts", doctorPayouts);
        request.setAttribute("pharmacyPayouts", pharmacyPayouts);
        request.setAttribute("transactions", transactions);
        request.setAttribute("serviceFilter", serviceFilter != null ? serviceFilter : "ALL");

        request.getRequestDispatcher("/modules/admin/financial_transactions.jsp").forward(request, response);
    }
}
