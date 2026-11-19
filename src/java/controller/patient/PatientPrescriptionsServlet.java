package controller.patient;

import model.prescription.Prescription;
import service.prescription.PrescriptionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PatientPrescriptionsServlet", urlPatterns = {"/PatientPrescriptionsServlet", "/modules/patient/PatientPrescriptionsServlet"})
public class PatientPrescriptionsServlet extends HttpServlet {

    private final PrescriptionService prescriptionService = new PrescriptionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        List<Prescription> prescriptions = prescriptionService.getPrescriptionsByUserId(userId);

        request.setAttribute("prescriptions", prescriptions);
        request.getRequestDispatcher("/modules/patient/my_prescriptions.jsp").forward(request, response);
    }
}
