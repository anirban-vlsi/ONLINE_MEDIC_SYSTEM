package controller.patient;

import service.patient.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet(name = "ProfilePictureServlet", urlPatterns = {"/ProfilePictureServlet", "/modules/patient/ProfilePictureServlet"})
public class ProfilePictureServlet extends HttpServlet {

    private UserService userService;

    // Clean inline SVG placeholder when no custom profile picture is uploaded
    private static final String DEFAULT_AVATAR_SVG =
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 120 120\" width=\"120\" height=\"120\">"
        + "<rect width=\"120\" height=\"120\" fill=\"#e2e8f0\" rx=\"60\"/>"
        + "<circle cx=\"60\" cy=\"45\" r=\"22\" fill=\"#94a3b8\"/>"
        + "<path d=\"M24 102 c0 -22 18 -36 36 -36 s36 14 36 36 z\" fill=\"#94a3b8\"/>"
        + "</svg>";

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session authentication check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication required.");
            return;
        }

        int sessionUserId = (Integer) session.getAttribute("userId");
        int targetUserId = sessionUserId;

        // Optionally allow target userId if supplied, but default to authenticated session user
        String requestedId = request.getParameter("userId");
        if (requestedId != null && !requestedId.trim().isEmpty()) {
            try {
                int parsed = Integer.parseInt(requestedId.trim());
                if (parsed > 0) {
                    targetUserId = parsed;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        byte[] pictureBytes = userService.getProfilePicture(targetUserId);

        // Prevent client caching so uploaded pictures reflect immediately
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        if (pictureBytes != null && pictureBytes.length > 0) {
            // Determine MIME type by inspecting magic header
            String mimeType = "image/jpeg";
            if (pictureBytes.length > 8 &&
                pictureBytes[0] == (byte) 0x89 &&
                pictureBytes[1] == (byte) 0x50 &&
                pictureBytes[2] == (byte) 0x4E &&
                pictureBytes[3] == (byte) 0x47) {
                mimeType = "image/png";
            }

            response.setContentType(mimeType);
            response.setContentLength(pictureBytes.length);

            try (OutputStream os = response.getOutputStream()) {
                os.write(pictureBytes);
                os.flush();
            }
        } else {
            // Serve clean default avatar placeholder
            byte[] svgBytes = DEFAULT_AVATAR_SVG.getBytes("UTF-8");
            response.setContentType("image/svg+xml");
            response.setContentLength(svgBytes.length);

            try (OutputStream os = response.getOutputStream()) {
                os.write(svgBytes);
                os.flush();
            }
        }
    }
}
