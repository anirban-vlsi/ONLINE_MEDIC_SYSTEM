package service.patient;

import dao.patient.UserDAO;
import model.patient.User;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.security.MessageDigest;

public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    // Constructor injection for testability
    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    // Helper method to hash passwords using standard Java Cryptographic API (SHA-256)
    public static String hashPassword(String password) {
        if (password == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return password;
        }
    }

    // Find user by email
    public User getUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        return userDAO.getUserByEmail(email.trim());
    }

    // Find user by user ID
    public User getUserById(int userId) {
        if (userId <= 0) {
            return null;
        }
        return userDAO.getUserById(userId);
    }

    // Register a new patient account
    public boolean registerUser(User user) {

        if (user == null) {
            return false;
        }

        if (user.getName() == null || user.getName().trim().isEmpty()) {
            return false;
        }

        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            return false;
        }

        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            return false;
        }

        // Email uniqueness check
        User existingUser = userDAO.getUserByEmail(user.getEmail().trim());
        if (existingUser != null) {
            return false;
        }

        // Secure password hashing
        user.setPassword(hashPassword(user.getPassword()));

        // Enforce initial unverified state and null profile picture (Requirement D1)
        user.setStatus("NOT VERIFIED");
        user.setProfilePicture(null);

        return userDAO.registerUser(user);
    }

    // Login user with password matching
    public User loginUser(String email, String password) {

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return null;
        }

        User user = userDAO.getUserByEmail(email.trim());

        if (user != null) {
            String storedPassword = user.getPassword();
            String hashedInput = hashPassword(password);

            // Backward-compatible verification: matches legacy plain text or SHA-256 hash
            if (storedPassword != null &&
               (storedPassword.equals(password) || storedPassword.equalsIgnoreCase(hashedInput))) {
                return user;
            }
        }

        return null;
    }

    // Direct authoritative check of account verification status from database
    public String getUserStatus(int userId) {
        if (userId <= 0) {
            return "NOT VERIFIED";
        }
        String status = userDAO.getUserStatusById(userId);
        return status != null ? status : "NOT VERIFIED";
    }

    // Returns true only if account status is VERIFIED in database
    public boolean isUserVerified(int userId) {
        String status = getUserStatus(userId);
        return "VERIFIED".equalsIgnoreCase(status);
    }

    // Check if user already uploaded a profile picture
    public boolean hasProfilePicture(int userId) {
        if (userId <= 0) {
            return false;
        }
        return userDAO.isProfilePictureUploaded(userId);
    }

    // Retrieve user profile picture bytes
    public byte[] getProfilePicture(int userId) {
        if (userId <= 0) {
            return null;
        }
        return userDAO.getProfilePictureByUserId(userId);
    }

    /**
     * Validates and processes the profile picture upload.
     * Enforces size restriction (max 2 MB), image format validation (JPG/PNG),
     * one-time upload rule, and atomic status update to VERIFIED.
     */
    public boolean uploadProfilePictureAndVerify(int userId, byte[] imageBytes) {

        if (userId <= 0 || imageBytes == null || imageBytes.length == 0) {
            return false;
        }

        // 1. Enforce size limit: 2 MB maximum (2 * 1024 * 1024 bytes)
        int maxBytes = 2 * 1024 * 1024;
        if (imageBytes.length > maxBytes) {
            return false;
        }

        // 2. Validate image content: check magic bytes and ImageIO decoding
        if (!isValidImage(imageBytes)) {
            return false;
        }

        // 3. Enforce one-time upload rule: reject if already uploaded
        if (userDAO.isProfilePictureUploaded(userId)) {
            return false;
        }

        // 4. Update image in database and set status to VERIFIED in a single transaction
        return userDAO.updateProfilePictureAndVerify(userId, imageBytes);
    }

    /**
     * Validates that the byte array represents a legitimate JPEG or PNG image.
     * Performs magic byte inspection and standard Java ImageIO decode test.
     */
    public static boolean isValidImage(byte[] data) {
        if (data == null || data.length < 8) {
            return false;
        }

        // Check JPEG magic bytes: FF D8 FF
        boolean isJpeg = (data[0] == (byte) 0xFF) &&
                         (data[1] == (byte) 0xD8) &&
                         (data[2] == (byte) 0xFF);

        // Check PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
        boolean isPng = (data[0] == (byte) 0x89) &&
                        (data[1] == (byte) 0x50) &&
                        (data[2] == (byte) 0x4E) &&
                        (data[3] == (byte) 0x47) &&
                        (data[4] == (byte) 0x0D) &&
                        (data[5] == (byte) 0x0A) &&
                        (data[6] == (byte) 0x1A) &&
                        (data[7] == (byte) 0x0A);

        if (!isJpeg && !isPng) {
            return false;
        }

        // Further verify image can be decoded by standard Java ImageIO
        try {
            ByteArrayInputStream bais = new ByteArrayInputStream(data);
            BufferedImage img = ImageIO.read(bais);
            return img != null && img.getWidth() > 0 && img.getHeight() > 0;
        } catch (Exception e) {
            return false;
        }
    }
}
