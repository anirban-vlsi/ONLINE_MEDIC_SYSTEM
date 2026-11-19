package controller.patient;

import dao.patient.UserDAO;
import model.patient.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;

@WebServlet(name = "UpdatePatientProfileServlet", urlPatterns = {"/UpdatePatientProfileServlet", "/modules/patient/UpdatePatientProfileServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 2 * 1024 * 1024,         // 2 MB max image size
    maxRequestSize = 5 * 1024 * 1024       // 5 MB max request
)
public class UpdatePatientProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_profile.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("userId") == null && session.getAttribute("loggedInUser") == null)) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId;
        Object uidObj = session.getAttribute("userId");
        if (uidObj instanceof Integer) {
            userId = (Integer) uidObj;
        } else {
            User u = (User) session.getAttribute("loggedInUser");
            userId = u.getUserId();
        }

        String name = request.getParameter("name");
        String gender = request.getParameter("gender");
        String mobileNo = request.getParameter("mobile_no");

        if (name == null || name.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_profile.jsp?error="
                    + URLEncoder.encode("Name cannot be empty.", "UTF-8"));
            return;
        }

        byte[] pictureBytes = null;
        try {
            Part filePart = request.getPart("profilePicture");
            if (filePart != null && filePart.getSize() > 0) {
                String submittedName = filePart.getSubmittedFileName();
                String ext = (submittedName != null && submittedName.contains("."))
                        ? submittedName.substring(submittedName.lastIndexOf('.')).toLowerCase()
                        : "";

                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png")) {
                    response.sendRedirect(request.getContextPath() + "/modules/patient/patient_profile.jsp?error="
                            + URLEncoder.encode("Invalid photo format. Only JPG, JPEG, and PNG are allowed.", "UTF-8"));
                    return;
                }

                try (InputStream is = filePart.getInputStream(); ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = is.read(buffer)) != -1) {
                        baos.write(buffer, 0, bytesRead);
                    }
                    pictureBytes = baos.toByteArray();
                }
            }
        } catch (Exception ex) {
            // No picture or multi-part read error
        }

        boolean updated = userDAO.updateProfile(userId, name.trim(), gender != null ? gender.trim() : null,
                mobileNo != null ? mobileNo.trim() : null, pictureBytes);

        if (updated) {
            User refreshedUser = userDAO.getUserById(userId);
            if (refreshedUser != null) {
                session.setAttribute("loggedInUser", refreshedUser);
                session.setAttribute("userId", refreshedUser.getUserId());
                session.setAttribute("userName", refreshedUser.getName());
                session.setAttribute("userEmail", refreshedUser.getEmail());
                session.setAttribute("userStatus", refreshedUser.getStatus());
                session.setAttribute("user", refreshedUser);
            }

            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_profile.jsp?success="
                    + URLEncoder.encode("Profile updated successfully! Status: " + (refreshedUser != null ? refreshedUser.getStatus() : ""), "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_profile.jsp?error="
                    + URLEncoder.encode("Failed to update profile. Please try again.", "UTF-8"));
        }
    }
}
