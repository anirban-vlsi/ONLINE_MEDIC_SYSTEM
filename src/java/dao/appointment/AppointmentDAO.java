package dao.appointment;

import dao.common.DBConnection;
import model.appointment.Appointment;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    public boolean bookAppointment(Appointment appt) {
        String sql = "INSERT INTO appointment (patient_id, user_id, doctor_reg_no, visit_type, "
                   + "patient_city, patient_home_address, fee_charged, appointment_date, appointment_time, "
                   + "reason, status, payment_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, appt.getPatientId());
            ps.setInt(2, appt.getUserId());
            ps.setString(3, appt.getDoctorRegNo());
            ps.setString(4, appt.getVisitType() != null ? appt.getVisitType() : "CLINIC");
            ps.setString(5, appt.getPatientCity());
            ps.setString(6, appt.getPatientHomeAddress());
            ps.setBigDecimal(7, appt.getFeeCharged());
            ps.setDate(8, appt.getAppointmentDate());
            if (appt.getAppointmentTime() != null) {
                ps.setTime(9, appt.getAppointmentTime());
            } else {
                ps.setNull(9, java.sql.Types.TIME);
            }
            ps.setString(10, appt.getReason());
            ps.setString(11, appt.getStatus() != null ? appt.getStatus() : "PENDING");
            ps.setString(12, appt.getPaymentStatus() != null ? appt.getPaymentStatus() : "UNPAID");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        appt.setAppointmentId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check count of non-cancelled appointments for a doctor on a specific date and visit mode
    public int countAppointmentsOnDate(String doctorRegNo, Date date, String visitType) {
        String sql = "SELECT COUNT(*) FROM appointment WHERE doctor_reg_no = ? AND appointment_date = ? "
                   + "AND visit_type = ? AND status != 'CANCELLED'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            ps.setDate(2, date);
            ps.setString(3, visitType != null ? visitType.toUpperCase() : "CLINIC");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Check if duplicate booking exists for exact doctor, date, and time slot
    public boolean isSlotBooked(String doctorRegNo, Date date, Time time) {
        String sql = "SELECT COUNT(*) FROM appointment WHERE doctor_reg_no = ? AND appointment_date = ? "
                   + "AND appointment_time = ? AND status != 'CANCELLED'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            ps.setDate(2, date);
            ps.setTime(3, time);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Propose reschedule by doctor
    public boolean proposeReschedule(int appointmentId, String doctorRegNo, Date proposedDate, Time proposedTime, String remarks) {
        String sql = "UPDATE appointment SET proposed_date = ?, proposed_time = ?, doctor_remarks = ?, "
                   + "status = 'RESCHEDULE_PROPOSED' WHERE appointment_id = ? AND doctor_reg_no = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setDate(1, proposedDate);
            ps.setTime(2, proposedTime);
            ps.setString(3, remarks);
            ps.setInt(4, appointmentId);
            ps.setString(5, doctorRegNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Accept reschedule proposal by patient
    public boolean acceptReschedule(int appointmentId, int userId) {
        String sql = "UPDATE appointment SET appointment_date = proposed_date, appointment_time = proposed_time, "
                   + "proposed_date = NULL, proposed_time = NULL, status = 'CONFIRMED' "
                   + "WHERE appointment_id = ? AND user_id = ? AND status = 'RESCHEDULE_PROPOSED'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cancel appointment by patient
    public boolean cancelAppointmentByPatient(int appointmentId, int userId) {
        String sql = "UPDATE appointment SET status = 'CANCELLED' WHERE appointment_id = ? AND user_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Confirm appointment and assign appointment time by doctor (validating no exact duplicate slot booked)
    public boolean confirmAppointmentWithTime(int appointmentId, String doctorRegNo, Time appointmentTime) {
        Appointment appt = getAppointmentById(appointmentId);
        if (appt == null || !doctorRegNo.equalsIgnoreCase(appt.getDoctorRegNo())) {
            return false;
        }

        // Check if doctor already has another confirmed appointment at that exact date and time
        String checkSql = "SELECT COUNT(*) FROM appointment WHERE doctor_reg_no = ? AND appointment_date = ? "
                        + "AND appointment_time = ? AND appointment_id != ? AND status = 'CONFIRMED'";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement psCheck = con.prepareStatement(checkSql)
        ) {
            psCheck.setString(1, doctorRegNo);
            psCheck.setDate(2, appt.getAppointmentDate());
            psCheck.setTime(3, appointmentTime);
            psCheck.setInt(4, appointmentId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Time conflict
                }
            }

            String sql = "UPDATE appointment SET appointment_time = ?, status = 'CONFIRMED' "
                       + "WHERE appointment_id = ? AND doctor_reg_no = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setTime(1, appointmentTime);
                ps.setInt(2, appointmentId);
                ps.setString(3, doctorRegNo);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update appointment status by doctor (e.g. CONFIRMED, COMPLETED, CANCELLED)
    public boolean updateAppointmentStatusByDoctor(int appointmentId, String doctorRegNo, String status, String remarks) {
        String sql = "UPDATE appointment SET status = ?, doctor_remarks = COALESCE(?, doctor_remarks) "
                   + "WHERE appointment_id = ? AND doctor_reg_no = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setString(2, remarks);
            ps.setInt(3, appointmentId);
            ps.setString(4, doctorRegNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentStatus(int appointmentId, String paymentStatus) {
        String sql = "UPDATE appointment SET payment_status = ? WHERE appointment_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, paymentStatus.trim().toUpperCase());
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Appointment> getAppointmentsByUserId(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.patient_name, p.gender AS patient_gender, p.relation AS patient_relation, "
                   + "d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "JOIN doctor d ON a.doctor_reg_no = d.registration_number "
                   + "WHERE a.user_id = ? "
                   + "ORDER BY a.appointment_date DESC, a.appointment_time DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAppointment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Appointment> getAppointmentsByDoctor(String doctorRegNo) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.patient_name, p.gender AS patient_gender, p.relation AS patient_relation, "
                   + "d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "JOIN doctor d ON a.doctor_reg_no = d.registration_number "
                   + "WHERE a.doctor_reg_no = ? "
                   + "ORDER BY a.appointment_date DESC, a.appointment_time ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAppointment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Appointment getAppointmentById(int appointmentId) {
        String sql = "SELECT a.*, p.patient_name, p.gender AS patient_gender, p.relation AS patient_relation, "
                   + "d.doctor_name, d.specialization AS doctor_specialization "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "JOIN doctor d ON a.doctor_reg_no = d.registration_number "
                   + "WHERE a.appointment_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAppointment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateAppointmentStatus(int appointmentId, String status) {
        String sql = "UPDATE appointment SET status = ? WHERE appointment_id = ?";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Appointment> getAllAppointments(String statusFilter) {
        List<Appointment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, p.patient_name, p.gender AS patient_gender, p.relation AS patient_relation, "
          + "d.doctor_name, d.specialization AS doctor_specialization "
          + "FROM appointment a "
          + "JOIN patient p ON a.patient_id = p.patient_id "
          + "JOIN doctor d ON a.doctor_reg_no = d.registration_number "
        );
        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE a.status = ? ");
            params.add(statusFilter.trim());
        }
        sql.append("ORDER BY a.appointment_date DESC, a.appointment_time DESC");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAppointment(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Appointment mapAppointment(ResultSet rs) throws Exception {
        Appointment a = new Appointment();
        a.setAppointmentId(rs.getInt("appointment_id"));
        a.setPatientId(rs.getInt("patient_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setDoctorRegNo(rs.getString("doctor_reg_no"));
        try { a.setVisitType(rs.getString("visit_type")); } catch (Exception ignored) {}
        try { a.setPatientCity(rs.getString("patient_city")); } catch (Exception ignored) {}
        try { a.setPatientHomeAddress(rs.getString("patient_home_address")); } catch (Exception ignored) {}
        try { a.setFeeCharged(rs.getBigDecimal("fee_charged")); } catch (Exception ignored) {}
        a.setAppointmentDate(rs.getDate("appointment_date"));
        a.setAppointmentTime(rs.getTime("appointment_time"));
        a.setReason(rs.getString("reason"));
        try { a.setProposedDate(rs.getDate("proposed_date")); } catch (Exception ignored) {}
        try { a.setProposedTime(rs.getTime("proposed_time")); } catch (Exception ignored) {}
        try { a.setDoctorRemarks(rs.getString("doctor_remarks")); } catch (Exception ignored) {}
        a.setStatus(rs.getString("status"));
        try { a.setPaymentStatus(rs.getString("payment_status")); } catch (Exception ignored) {}
        a.setAdminRemarks(rs.getString("admin_remarks"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));

        a.setPatientName(rs.getString("patient_name"));
        a.setPatientGender(rs.getString("patient_gender"));
        a.setPatientRelation(rs.getString("patient_relation"));
        a.setDoctorName(rs.getString("doctor_name"));
        a.setDoctorSpecialization(rs.getString("doctor_specialization"));
        return a;
    }
}
