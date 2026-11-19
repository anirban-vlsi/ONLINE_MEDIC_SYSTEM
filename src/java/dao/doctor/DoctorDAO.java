package dao.doctor;

import dao.common.DBConnection;
import model.doctor.Doctor;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO {

    // Register a new doctor with NOT VERIFIED status
    public boolean registerDoctor(Doctor doctor) {

        String sql = "INSERT INTO doctor "
                   + "(registration_number, doctor_name, age, email, password, "
                   + "address, city, specialization, consultation_fee, home_visit_available, "
                   + "home_visit_fee, service_areas, verification_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, doctor.getRegistrationNumber());
            ps.setString(2, doctor.getDoctorName());
            ps.setInt(3, doctor.getAge());
            ps.setString(4, doctor.getEmail());
            ps.setString(5, doctor.getPassword());
            ps.setString(6, doctor.getAddress());
            ps.setString(7, doctor.getCity() != null ? doctor.getCity() : "Bangalore");
            ps.setString(8, doctor.getSpecialization());
            ps.setBigDecimal(9, doctor.getConsultationFee() != null ? doctor.getConsultationFee() : new BigDecimal("500.00"));
            ps.setBoolean(10, doctor.isHomeVisitAvailable());
            ps.setBigDecimal(11, doctor.getHomeVisitFee());
            ps.setString(12, doctor.getServiceAreas());
            ps.setString(13, "NOT VERIFIED"); // Always enforce NOT VERIFIED upon registration

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Doctor mapDoctor(ResultSet rs) throws Exception {
        Doctor doc = new Doctor();
        doc.setRegistrationNumber(rs.getString("registration_number"));
        doc.setDoctorName(rs.getString("doctor_name"));
        doc.setAge(rs.getInt("age"));
        doc.setEmail(rs.getString("email"));
        try { doc.setPassword(rs.getString("password")); } catch (Exception ignored) {}
        doc.setAddress(rs.getString("address"));
        doc.setCity(rs.getString("city"));
        doc.setSpecialization(rs.getString("specialization"));
        doc.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        doc.setHomeVisitAvailable(rs.getBoolean("home_visit_available"));
        doc.setHomeVisitFee(rs.getBigDecimal("home_visit_fee"));
        doc.setServiceAreas(rs.getString("service_areas"));
        doc.setVerificationStatus(rs.getString("verification_status"));
        doc.setCreatedAt(rs.getTimestamp("created_at"));
        return doc;
    }

    // Retrieve doctor by Medical Registration Number
    public Doctor getDoctorByRegistrationNumber(String regNo) {

        if (regNo == null || regNo.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM doctor WHERE registration_number = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, regNo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoctor(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Retrieve doctor by Email Address
    public Doctor getDoctorByEmail(String email) {

        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM doctor WHERE email = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDoctor(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Update doctor profile
    public boolean updateDoctorProfile(Doctor doc) {
        String sql = "UPDATE doctor SET doctor_name = ?, age = ?, address = ?, city = ?, "
                   + "specialization = ?, consultation_fee = ?, home_visit_available = ?, "
                   + "home_visit_fee = ?, service_areas = ? WHERE registration_number = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doc.getDoctorName());
            ps.setInt(2, doc.getAge());
            ps.setString(3, doc.getAddress());
            ps.setString(4, doc.getCity());
            ps.setString(5, doc.getSpecialization());
            ps.setBigDecimal(6, doc.getConsultationFee() != null ? doc.getConsultationFee() : new BigDecimal("500.00"));
            ps.setBoolean(7, doc.isHomeVisitAvailable());
            ps.setBigDecimal(8, doc.getHomeVisitFee());
            ps.setString(9, doc.getServiceAreas());
            ps.setString(10, doc.getRegistrationNumber());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Check if a registration number already exists
    public boolean isRegistrationNumberExists(String regNo) {

        if (regNo == null || regNo.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM doctor WHERE registration_number = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, regNo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Check if an email address already exists
    public boolean isEmailExists(String email) {

        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM doctor WHERE email = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Query authoritative verification status directly from MySQL
    public String getDoctorVerificationStatus(String regNo) {

        if (regNo == null || regNo.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT verification_status FROM doctor WHERE registration_number = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, regNo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("verification_status");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Update doctor's verification status
    public boolean updateVerificationStatus(String regNo, String status) {

        if (regNo == null || status == null) {
            return false;
        }

        String sql = "UPDATE doctor SET verification_status = ? WHERE registration_number = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, status.trim().toUpperCase());
            ps.setString(2, regNo.trim());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Retrieve only VERIFIED doctors (legacy/general)
    public List<Doctor> getVerifiedDoctors() {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM doctor WHERE verification_status = 'VERIFIED' ORDER BY doctor_name ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapDoctor(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Patient Choice-First Filtering: Specialization (required), City (required), Visit Mode, Sort By
    public List<Doctor> findDoctors(String specialization, String city, String visitMode, String sortBy) {
        List<Doctor> list = new ArrayList<>();
        if (specialization == null || specialization.trim().isEmpty() || city == null || city.trim().isEmpty()) {
            return list;
        }

        StringBuilder sql = new StringBuilder("SELECT * FROM doctor WHERE verification_status = 'VERIFIED' ");
        List<Object> params = new ArrayList<>();

        sql.append("AND LOWER(specialization) = LOWER(?) ");
        params.add(specialization.trim());

        String cleanCity = city.trim();
        String cityPattern = "%" + cleanCity.toLowerCase() + "%";

        if ("HOME_VISIT".equalsIgnoreCase(visitMode)) {
            sql.append("AND home_visit_available = 1 AND (LOWER(city) = LOWER(?) OR LOWER(service_areas) LIKE ?) ");
            params.add(cleanCity);
            params.add(cityPattern);
        } else if ("CLINIC".equalsIgnoreCase(visitMode)) {
            sql.append("AND LOWER(city) = LOWER(?) ");
            params.add(cleanCity);
        } else {
            // ALL: matches clinic city OR home visit service area
            sql.append("AND (LOWER(city) = LOWER(?) OR (home_visit_available = 1 AND LOWER(service_areas) LIKE ?)) ");
            params.add(cleanCity);
            params.add(cityPattern);
        }

        if ("NAME_DESC".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY doctor_name DESC");
        } else if ("FEE_ASC".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY consultation_fee ASC");
        } else if ("FEE_DESC".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY consultation_fee DESC");
        } else {
            sql.append("ORDER BY doctor_name ASC");
        }

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDoctor(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get doctors with search and status filtering (Admin DAO delegation)
    public List<Doctor> getDoctors(String search, String statusFilter) {
        List<Doctor> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM doctor WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND verification_status = ? ");
            params.add(statusFilter.trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (doctor_name LIKE ? OR registration_number LIKE ? OR email LIKE ? OR specialization LIKE ? OR city LIKE ?) ");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY created_at DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDoctor(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Total earnings summary for doctor dashboard
    public BigDecimal getTotalEarnings(String doctorRegNo) {
        String sql = "SELECT COALESCE(SUM(provider_payout), 0) FROM financial_transaction "
                   + "WHERE provider_id = ? AND transaction_status = 'SUCCESS'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }
}
