package controller.patient;

import model.patient.Patient;
import service.patient.PatientService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PatientProfileServlet", urlPatterns = {"/PatientProfileServlet", "/modules/patient/PatientProfileServlet"})
public class PatientProfileServlet extends HttpServlet {

    private PatientService patientService;

    @Override
    public void init() throws ServletException {
        patientService = new PatientService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the current user's session
        HttpSession session = request.getSession(false);

        // If user is not logged in, redirect to login
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        // Get logged-in user's ID
        int userId = (Integer) session.getAttribute("userId");

        // Get patients belonging to this user
        List<Patient> patients = patientService.getPatientsByUserId(userId);

        // Send the patient list to the JSP page
        request.setAttribute("patients", patients);

        request.getRequestDispatcher("/modules/patient/my_patients.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
