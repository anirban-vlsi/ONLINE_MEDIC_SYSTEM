package controller.patient;

import model.patient.Patient;
import service.patient.PatientService;
import service.patient.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;

@WebServlet(name = "AddPatientServlet", urlPatterns = {"/AddPatientServlet", "/modules/patient/AddPatientServlet"})
public class AddPatientServlet extends HttpServlet {

    private PatientService patientService;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        patientService = new PatientService();
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/patient/add_patient.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Check whether an authenticated session exists
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        // 2. Retrieve the userId securely from the session
        int userId = (Integer) session.getAttribute("userId");

        // 3. MANDATORY SECURITY CHECK: Fetch authoritative account verification status from the database
        // Do not rely solely on session attributes, as database status might be out of sync.
        boolean isVerified = userService.isUserVerified(userId);

        if (!isVerified) {
            // Reject operation immediately! Do not insert any patient record.
            String errorMsg = "Account verification required. Please upload your profile picture to verify your account before adding patients.";
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp?error="
                    + URLEncoder.encode(errorMsg, "UTF-8"));
            return;
        }

        // 4. Get patient details from the form
        String patientName = request.getParameter("patient_name");
        String dobText = request.getParameter("date_of_birth");
        String gender = request.getParameter("gender");
        String relation = request.getParameter("relation");
        String mobileNo = request.getParameter("mobile_no");
        String bloodGroup = request.getParameter("blood_group");
        String allergies = request.getParameter("allergies");
        String medicalConditions = request.getParameter("medical_conditions");

        if (patientName == null || patientName.trim().isEmpty() || relation == null || relation.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/add_patient.html?error="
                    + URLEncoder.encode("Patient name and relationship are required.", "UTF-8"));
            return;
        }

        // 5. Create Patient Bean (Notice: No patient_picture or status fields per Part F)
        Patient patient = new Patient();

        // Always associate with the authenticated session's userId
        patient.setUserId(userId);
        patient.setPatientName(patientName.trim());
        patient.setGender(gender != null ? gender.trim() : "");
        patient.setRelation(relation.trim());
        patient.setMobileNo(mobileNo != null ? mobileNo.trim() : "");
        patient.setBloodGroup(bloodGroup != null ? bloodGroup.trim() : "");
        patient.setAllergies(allergies != null ? allergies.trim() : "");
        patient.setMedicalConditions(medicalConditions != null ? medicalConditions.trim() : "");

        // Convert date text into SQL Date
        if (dobText != null && !dobText.trim().isEmpty()) {
            try {
                patient.setDateOfBirth(Date.valueOf(dobText.trim()));
            } catch (IllegalArgumentException e) {
                response.sendRedirect(request.getContextPath() + "/modules/patient/add_patient.html?error="
                        + URLEncoder.encode("Invalid date of birth format.", "UTF-8"));
                return;
            }
        }

        // 6. Save patient through Service
        boolean success = patientService.addPatient(patient);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/PatientProfileServlet");
        } else {
            response.sendRedirect(request.getContextPath() + "/modules/patient/add_patient.html?error="
                    + URLEncoder.encode("Unable to add patient record. Please check the details and try again.", "UTF-8"));
        }
    }
}
