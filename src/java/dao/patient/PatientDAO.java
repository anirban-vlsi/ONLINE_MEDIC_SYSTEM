package dao.patient;

import dao.common.DBConnection;
import model.patient.Patient;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {

    // Add a new patient record (associated with the authenticated user)
    public boolean addPatient(Patient patient) {

        String sql = "INSERT INTO patient "
                   + "(user_id, patient_name, date_of_birth, gender, relation, "
                   + "mobile_no, blood_group, allergies, medical_conditions) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, patient.getUserId());
            ps.setString(2, patient.getPatientName());

            if (patient.getDateOfBirth() != null) {
                ps.setDate(3, new java.sql.Date(patient.getDateOfBirth().getTime()));
            } else {
                ps.setDate(3, null);
            }

            ps.setString(4, patient.getGender());
            ps.setString(5, patient.getRelation());
            ps.setString(6, patient.getMobileNo());
            ps.setString(7, patient.getBloodGroup());
            ps.setString(8, patient.getAllergies());
            ps.setString(9, patient.getMedicalConditions());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all patients belonging to a particular user account
    public List<Patient> getPatientsByUserId(int userId) {

        List<Patient> patients = new ArrayList<>();

        String sql = "SELECT patient_id, user_id, patient_name, date_of_birth, "
                   + "gender, relation, mobile_no, blood_group, allergies, medical_conditions "
                   + "FROM patient WHERE user_id = ? ORDER BY patient_id ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Patient patient = new Patient();
                    patient.setPatientId(rs.getInt("patient_id"));
                    patient.setUserId(rs.getInt("user_id"));
                    patient.setPatientName(rs.getString("patient_name"));
                    patient.setDateOfBirth(rs.getDate("date_of_birth"));
                    patient.setGender(rs.getString("gender"));
                    patient.setRelation(rs.getString("relation"));
                    patient.setMobileNo(rs.getString("mobile_no"));
                    patient.setBloodGroup(rs.getString("blood_group"));
                    patient.setAllergies(rs.getString("allergies"));
                    patient.setMedicalConditions(rs.getString("medical_conditions"));

                    patients.add(patient);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return patients;
    }

    // Get a specific patient by patient ID
    public Patient getPatientById(int patientId) {

        String sql = "SELECT patient_id, user_id, patient_name, date_of_birth, "
                   + "gender, relation, mobile_no, blood_group, allergies, medical_conditions "
                   + "FROM patient WHERE patient_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Patient patient = new Patient();
                    patient.setPatientId(rs.getInt("patient_id"));
                    patient.setUserId(rs.getInt("user_id"));
                    patient.setPatientName(rs.getString("patient_name"));
                    patient.setDateOfBirth(rs.getDate("date_of_birth"));
                    patient.setGender(rs.getString("gender"));
                    patient.setRelation(rs.getString("relation"));
                    patient.setMobileNo(rs.getString("mobile_no"));
                    patient.setBloodGroup(rs.getString("blood_group"));
                    patient.setAllergies(rs.getString("allergies"));
                    patient.setMedicalConditions(rs.getString("medical_conditions"));

                    return patient;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Update patient information
    public boolean updatePatient(Patient patient) {

        String sql = "UPDATE patient SET "
                   + "patient_name = ?, "
                   + "date_of_birth = ?, "
                   + "gender = ?, "
                   + "relation = ?, "
                   + "mobile_no = ?, "
                   + "blood_group = ?, "
                   + "allergies = ?, "
                   + "medical_conditions = ? "
                   + "WHERE patient_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, patient.getPatientName());

            if (patient.getDateOfBirth() != null) {
                ps.setDate(2, new java.sql.Date(patient.getDateOfBirth().getTime()));
            } else {
                ps.setDate(2, null);
            }

            ps.setString(3, patient.getGender());
            ps.setString(4, patient.getRelation());
            ps.setString(5, patient.getMobileNo());
            ps.setString(6, patient.getBloodGroup());
            ps.setString(7, patient.getAllergies());
            ps.setString(8, patient.getMedicalConditions());
            ps.setInt(9, patient.getPatientId());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
