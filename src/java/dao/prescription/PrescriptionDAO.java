package dao.prescription;

import dao.common.DBConnection;
import model.prescription.Prescription;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PrescriptionDAO {

    public boolean createPrescription(Prescription rx) {
        String sql = "INSERT INTO prescription (appointment_id, patient_id, doctor_reg_no, diagnosis, medicines, dosage_instructions, notes, prescribed_date, follow_up_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, rx.getAppointmentId());
            ps.setInt(2, rx.getPatientId());
            ps.setString(3, rx.getDoctorRegNo());
            ps.setString(4, rx.getDiagnosis());
            ps.setString(5, rx.getMedicines());
            ps.setString(6, rx.getDosageInstructions());
            ps.setString(7, rx.getNotes());
            ps.setDate(8, rx.getPrescribedDate());
            ps.setDate(9, rx.getFollowUpDate());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        rx.setPrescriptionId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Prescription> getPrescriptionsByUserId(int userId) {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT pr.*, p.patient_name, d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM prescription pr "
                   + "JOIN patient p ON pr.patient_id = p.patient_id "
                   + "JOIN doctor d ON pr.doctor_reg_no = d.registration_number "
                   + "WHERE p.user_id = ? "
                   + "ORDER BY pr.prescribed_date DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPrescription(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Prescription> getPrescriptionsByDoctor(String doctorRegNo) {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT pr.*, p.patient_name, d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM prescription pr "
                   + "JOIN patient p ON pr.patient_id = p.patient_id "
                   + "JOIN doctor d ON pr.doctor_reg_no = d.registration_number "
                   + "WHERE pr.doctor_reg_no = ? "
                   + "ORDER BY pr.prescribed_date DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapPrescription(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Prescription getPrescriptionById(int prescriptionId) {
        String sql = "SELECT pr.*, p.patient_name, d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM prescription pr "
                   + "JOIN patient p ON pr.patient_id = p.patient_id "
                   + "JOIN doctor d ON pr.doctor_reg_no = d.registration_number "
                   + "WHERE pr.prescription_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, prescriptionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPrescription(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Prescription getPrescriptionByAppointmentId(int appointmentId) {
        String sql = "SELECT pr.*, p.patient_name, d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM prescription pr "
                   + "JOIN patient p ON pr.patient_id = p.patient_id "
                   + "JOIN doctor d ON pr.doctor_reg_no = d.registration_number "
                   + "WHERE pr.appointment_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPrescription(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Prescription mapPrescription(ResultSet rs) throws Exception {
        Prescription rx = new Prescription();
        rx.setPrescriptionId(rs.getInt("prescription_id"));
        rx.setAppointmentId(rs.getInt("appointment_id"));
        rx.setPatientId(rs.getInt("patient_id"));
        rx.setDoctorRegNo(rs.getString("doctor_reg_no"));
        rx.setDiagnosis(rs.getString("diagnosis"));
        rx.setMedicines(rs.getString("medicines"));
        rx.setDosageInstructions(rs.getString("dosage_instructions"));
        rx.setNotes(rs.getString("notes"));
        rx.setPrescribedDate(rs.getDate("prescribed_date"));
        rx.setFollowUpDate(rs.getDate("follow_up_date"));
        rx.setCreatedAt(rs.getTimestamp("created_at"));

        rx.setPatientName(rs.getString("patient_name"));
        rx.setDoctorName(rs.getString("doctor_name"));
        rx.setDoctorSpecialization(rs.getString("doctor_specialization"));
        return rx;
    }
}
