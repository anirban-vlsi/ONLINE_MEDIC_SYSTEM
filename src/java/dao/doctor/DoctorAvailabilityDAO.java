package dao.doctor;

import dao.common.DBConnection;
import model.doctor.DoctorAvailability;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class DoctorAvailabilityDAO {

    public List<DoctorAvailability> getAvailabilityByDoctor(String doctorRegNo) {
        return getAvailabilityByDoctorAndMode(doctorRegNo, null);
    }

    public List<DoctorAvailability> getAvailabilityByDoctorAndMode(String doctorRegNo, String visitMode) {
        List<DoctorAvailability> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM doctor_availability WHERE doctor_reg_no = ? ");
        if (visitMode != null && !visitMode.trim().isEmpty() && !"ALL".equalsIgnoreCase(visitMode)) {
            sql.append("AND visit_mode = ? ");
        }
        sql.append("ORDER BY FIELD(day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'), visit_mode");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            ps.setString(1, doctorRegNo);
            if (visitMode != null && !visitMode.trim().isEmpty() && !"ALL".equalsIgnoreCase(visitMode)) {
                ps.setString(2, visitMode.trim().toUpperCase());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DoctorAvailability da = new DoctorAvailability();
                    da.setAvailabilityId(rs.getInt("availability_id"));
                    da.setDoctorRegNo(rs.getString("doctor_reg_no"));
                    da.setVisitMode(rs.getString("visit_mode"));
                    da.setDayOfWeek(rs.getString("day_of_week"));
                    da.setStartTime(rs.getTime("start_time"));
                    da.setEndTime(rs.getTime("end_time"));
                    da.setMaxPatientsPerDay(rs.getInt("max_patients_per_day"));
                    da.setMaxPatients(rs.getInt("max_patients"));
                    da.setActive(rs.getBoolean("is_active"));
                    list.add(da);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public DoctorAvailability getAvailabilityForSlot(String doctorRegNo, String visitMode, String dayOfWeek) {
        String sql = "SELECT * FROM doctor_availability WHERE doctor_reg_no = ? AND visit_mode = ? AND day_of_week = ? AND is_active = 1";
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, doctorRegNo);
            ps.setString(2, visitMode != null ? visitMode.trim().toUpperCase() : "CLINIC");
            ps.setString(3, dayOfWeek != null ? dayOfWeek.trim().toUpperCase() : "");

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DoctorAvailability da = new DoctorAvailability();
                    da.setAvailabilityId(rs.getInt("availability_id"));
                    da.setDoctorRegNo(rs.getString("doctor_reg_no"));
                    da.setVisitMode(rs.getString("visit_mode"));
                    da.setDayOfWeek(rs.getString("day_of_week"));
                    da.setStartTime(rs.getTime("start_time"));
                    da.setEndTime(rs.getTime("end_time"));
                    da.setMaxPatientsPerDay(rs.getInt("max_patients_per_day"));
                    da.setMaxPatients(rs.getInt("max_patients"));
                    da.setActive(rs.getBoolean("is_active"));
                    return da;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveOrUpdateAvailability(DoctorAvailability da) {
        String mode = (da.getVisitMode() != null && !da.getVisitMode().trim().isEmpty())
                ? da.getVisitMode().trim().toUpperCase() : "CLINIC";
        int quota = da.getMaxPatientsPerDay() > 0 ? da.getMaxPatientsPerDay() : (da.getMaxPatients() > 0 ? da.getMaxPatients() : 20);

        String sql = "INSERT INTO doctor_availability (doctor_reg_no, visit_mode, day_of_week, start_time, end_time, max_patients_per_day, max_patients, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE start_time = VALUES(start_time), end_time = VALUES(end_time), "
                   + "max_patients_per_day = VALUES(max_patients_per_day), max_patients = VALUES(max_patients), is_active = VALUES(is_active)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, da.getDoctorRegNo());
            ps.setString(2, mode);
            ps.setString(3, da.getDayOfWeek().toUpperCase());
            ps.setTime(4, da.getStartTime());
            ps.setTime(5, da.getEndTime());
            ps.setInt(6, quota);
            ps.setInt(7, quota);
            ps.setBoolean(8, da.isActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
