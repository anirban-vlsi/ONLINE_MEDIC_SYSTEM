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

@WebServlet(name = "PatientRegistrationServlet", urlPatterns = {"/PatientRegistrationServlet", "/modules/patient/PatientRegistrationServlet"})
public class PatientRegistrationServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_signup.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get data from registration form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String gender = request.getParameter("gender");
        String mobileNo = request.getParameter("mobile_no");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String terms = request.getParameter("terms");

        String signupPage = request.getContextPath() + "/modules/patient/patient_signup.jsp";

        // 1. Server-side validation of required fields
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Please fill in all required fields.", "UTF-8"));
            return;
        }

        // 2. Validate passwords match
        if (confirmPassword == null || !password.equals(confirmPassword)) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Password and Confirm Password do not match.", "UTF-8"));
            return;
        }

        // 3. Validate terms agreement
        if (terms == null) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("You must agree to the Terms and Conditions.", "UTF-8"));
            return;
        }

        // 4. Check whether email already exists
        if (userService.getUserByEmail(email.trim()) != null) {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Registration failed. Email is already registered.", "UTF-8"));
            return;
        }

        // Create User Bean
        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setGender(gender != null ? gender.trim() : "");
        user.setMobileNo(mobileNo != null ? mobileNo.trim() : "");
        user.setPassword(password);
        user.setStatus("NOT VERIFIED");
        user.setProfilePicture(null);

        // Register user through Service
        boolean success = userService.registerUser(user);

        if (success) {
            // Retrieve newly registered user details (including generated user_id)
            User registeredUser = userService.getUserByEmail(email.trim());
            if (registeredUser == null) {
                registeredUser = user;
            }

            // Create new HttpSession
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", registeredUser.getUserId());
            session.setAttribute("userName", registeredUser.getName());
            session.setAttribute("userEmail", registeredUser.getEmail());
            session.setAttribute("userStatus", registeredUser.getStatus());
            session.setAttribute("user", registeredUser);

            // Redirect to Patient Dashboard
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp");

        } else {
            response.sendRedirect(signupPage + "?error="
                    + URLEncoder.encode("Registration failed. Please try again.", "UTF-8"));
        }
    }
}
