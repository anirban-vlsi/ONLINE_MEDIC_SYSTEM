package service.appointment;

import dao.appointment.AppointmentDAO;
import dao.doctor.DoctorDAO;
import dao.patient.UserDAO;
import model.appointment.Appointment;
import model.doctor.Doctor;

import java.util.List;

public class AppointmentService {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final UserDAO userDAO = new UserDAO();

    public boolean bookAppointment(Appointment appt) {
        if (appt == null || appt.getUserId() <= 0 || appt.getPatientId() <= 0
                || appt.getDoctorRegNo() == null || appt.getAppointmentDate() == null) {
            return false;
        }

        // Strict Requirement: Patient user must be VERIFIED
        String status = userDAO.getUserStatusById(appt.getUserId());
        if (!"VERIFIED".equalsIgnoreCase(status)) {
            return false;
        }

        // Strict Requirement: Doctor must be VERIFIED
        String docStatus = doctorDAO.getDoctorVerificationStatus(appt.getDoctorRegNo());
        if (!"VERIFIED".equalsIgnoreCase(docStatus)) {
            return false;
        }

        return appointmentDAO.bookAppointment(appt);
    }

    public List<Appointment> getAppointmentsByUserId(int userId) {
        return appointmentDAO.getAppointmentsByUserId(userId);
    }

    public List<Appointment> getAppointmentsByDoctor(String doctorRegNo) {
        return appointmentDAO.getAppointmentsByDoctor(doctorRegNo);
    }

    public Appointment getAppointmentById(int appointmentId) {
        return appointmentDAO.getAppointmentById(appointmentId);
    }

    public boolean updateAppointmentStatus(int appointmentId, String status) {
        return appointmentDAO.updateAppointmentStatus(appointmentId, status);
    }

    public List<Appointment> getAllAppointments(String statusFilter) {
        return appointmentDAO.getAllAppointments(statusFilter);
    }

    // Only returns verified doctors for patient directory and appointment booking
    public List<Doctor> getVerifiedDoctors() {
        return doctorDAO.getVerifiedDoctors();
    }
}
