package controller.patient;

import model.patient.User;
import service.patient.UserService;

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

@WebServlet(name = "UploadProfilePictureServlet", urlPatterns = {"/UploadProfilePictureServlet", "/modules/patient/UploadProfilePictureServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 2 * 1024 * 1024,         // 2 MB max file size
    maxRequestSize = 4 * 1024 * 1024       // 4 MB max total request size
)
public class UploadProfilePictureServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/modules/patient/patient_dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session check - identify authenticated user from session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/modules/patient/patient_login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String dashboardUrl = request.getContextPath() + "/modules/patient/patient_dashboard.jsp";

        // 2. Strict One-Time Upload Check (Requirement D3)
        // Check authoritative database state before accepting another upload
        if (userService.hasProfilePicture(userId)) {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("Your profile picture has already been uploaded.", "UTF-8"));
            return;
        }

        // 3. Retrieve uploaded Part
        Part filePart = null;
        try {
            filePart = request.getPart("profilePicture");
        } catch (Exception ex) {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("File upload error or file size exceeds 2 MB limit.", "UTF-8"));
            return;
        }

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("Please select an image file to upload.", "UTF-8"));
            return;
        }

        // 4. Validate file size (max 2 MB = 2,097,152 bytes)
        long fileSize = filePart.getSize();
        if (fileSize > 2 * 1024 * 1024) {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("Image size exceeds the maximum limit of 2 MB.", "UTF-8"));
            return;
        }

        // 5. Read file bytes into memory
        byte[] imageBytes;
        try (InputStream inputStream = filePart.getInputStream();
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
            imageBytes = outputStream.toByteArray();
        }

        // 6. Validate image content (Requirement D2 & D4: reject non-image uploads)
        if (!UserService.isValidImage(imageBytes)) {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("Invalid image file. Only valid JPG, JPEG, and PNG files are accepted.", "UTF-8"));
            return;
        }

        // 7. Save image in user table and update status to VERIFIED in a single transaction (Requirement D4)
        boolean updated = userService.uploadProfilePictureAndVerify(userId, imageBytes);

        if (updated) {
            // Update session attributes immediately so dashboard reflects new status without re-login
            session.setAttribute("userStatus", "VERIFIED");

            User updatedUser = userService.getUserById(userId);
            if (updatedUser != null) {
                session.setAttribute("user", updatedUser);
            }

            response.sendRedirect(dashboardUrl + "?uploadSuccess="
                    + URLEncoder.encode("Profile picture uploaded successfully! Your account is now VERIFIED.", "UTF-8"));
        } else {
            response.sendRedirect(dashboardUrl + "?error="
                    + URLEncoder.encode("Failed to save profile picture. Upload might already exist.", "UTF-8"));
        }
    }
}
