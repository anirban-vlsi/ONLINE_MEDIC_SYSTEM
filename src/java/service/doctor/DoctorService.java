package service.doctor;

import dao.doctor.DoctorDAO;
import model.doctor.Doctor;

import java.security.MessageDigest;

public class DoctorService {

    private final DoctorDAO doctorDAO;

    public DoctorService() {
        this.doctorDAO = new DoctorDAO();
    }

    public DoctorService(DoctorDAO doctorDAO) {
        this.doctorDAO = doctorDAO;
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

    // Validate and register a new doctor
    public boolean registerDoctor(Doctor doctor) {

        if (doctor == null) {
            return false;
        }

        // 1. Mandatory field checks
        if (doctor.getRegistrationNumber() == null || doctor.getRegistrationNumber().trim().isEmpty() ||
            doctor.getDoctorName() == null || doctor.getDoctorName().trim().isEmpty() ||
            doctor.getEmail() == null || doctor.getEmail().trim().isEmpty() ||
            doctor.getPassword() == null || doctor.getPassword().trim().isEmpty() ||
            doctor.getAddress() == null || doctor.getAddress().trim().isEmpty() ||
            doctor.getSpecialization() == null || doctor.getSpecialization().trim().isEmpty()) {
            return false;
        }

        // 2. Age validation (sensible physician age: 21 to 100)
        if (doctor.getAge() < 21 || doctor.getAge() > 100) {
            return false;
        }

        // 3. Email format validation
        String email = doctor.getEmail().trim();
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            return false;
        }

        String regNo = doctor.getRegistrationNumber().trim();

        // 4. Unique Registration Number check
        if (doctorDAO.isRegistrationNumberExists(regNo)) {
            return false;
        }

        // 5. Unique Email check
        if (doctorDAO.isEmailExists(email)) {
            return false;
        }

        // 6. Secure password hashing
        doctor.setRegistrationNumber(regNo);
        doctor.setDoctorName(doctor.getDoctorName().trim());
        doctor.setEmail(email);
        doctor.setAddress(doctor.getAddress().trim());
        doctor.setSpecialization(doctor.getSpecialization().trim());
        doctor.setPassword(hashPassword(doctor.getPassword()));

        // 7. Enforce initial PENDING status (Requirement: newly registered doctors must be PENDING)
        doctor.setVerificationStatus("PENDING");

        return doctorDAO.registerDoctor(doctor);
    }

    // Authenticate doctor credentials (matches registration number & password)
    public Doctor authenticateDoctor(String regNo, String rawPassword) {

        if (regNo == null || regNo.trim().isEmpty() || rawPassword == null || rawPassword.trim().isEmpty()) {
            return null;
        }

        Doctor doctor = doctorDAO.getDoctorByRegistrationNumber(regNo.trim());

        if (doctor != null) {
            String storedPassword = doctor.getPassword();
            String hashedInput = hashPassword(rawPassword);

            // Backward-compatible check: matches legacy plain text or SHA-256 hash
            if (storedPassword != null &&
               (storedPassword.equals(rawPassword) || storedPassword.equalsIgnoreCase(hashedInput))) {
                return doctor;
            }
        }

        return null;
    }

    // Retrieve doctor profile by registration number
    public Doctor getDoctorByRegistrationNumber(String regNo) {
        if (regNo == null || regNo.trim().isEmpty()) {
            return null;
        }
        return doctorDAO.getDoctorByRegistrationNumber(regNo.trim());
    }

    // Query authoritative verification status directly from database
    public String getDoctorVerificationStatus(String regNo) {
        if (regNo == null || regNo.trim().isEmpty()) {
            return null;
        }
        return doctorDAO.getDoctorVerificationStatus(regNo.trim());
    }

    // Check if doctor is verified in database
    public boolean isDoctorVerified(String regNo) {
        String status = getDoctorVerificationStatus(regNo);
        return "VERIFIED".equalsIgnoreCase(status);
    }

    // Check whether registration number already exists
    public boolean isRegistrationNumberExists(String regNo) {
        return doctorDAO.isRegistrationNumberExists(regNo);
    }

    // Check whether email already exists
    public boolean isEmailExists(String email) {
        return doctorDAO.isEmailExists(email);
    }

    // Update status (e.g. for testing / admin verification)
    public boolean updateVerificationStatus(String regNo, String status) {
        return doctorDAO.updateVerificationStatus(regNo, status);
    }
}
