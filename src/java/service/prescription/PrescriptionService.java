package service.prescription;

import dao.appointment.AppointmentDAO;
import dao.doctor.DoctorDAO;
import dao.prescription.PrescriptionDAO;
import model.prescription.Prescription;

import java.util.List;

public class PrescriptionService {

    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    public boolean createPrescription(Prescription rx) {
        if (rx == null || rx.getAppointmentId() <= 0 || rx.getPatientId() <= 0
                || rx.getDoctorRegNo() == null || rx.getDiagnosis() == null || rx.getMedicines() == null) {
            return false;
        }

        // Strict Requirement: Doctor must be VERIFIED
        String docStatus = doctorDAO.getDoctorVerificationStatus(rx.getDoctorRegNo());
        if (!"VERIFIED".equalsIgnoreCase(docStatus)) {
            return false;
        }

        boolean saved = prescriptionDAO.createPrescription(rx);
        if (saved) {
            // Mark the appointment as COMPLETED
            appointmentDAO.updateAppointmentStatus(rx.getAppointmentId(), "COMPLETED");
        }
        return saved;
    }

    public List<Prescription> getPrescriptionsByUserId(int userId) {
        return prescriptionDAO.getPrescriptionsByUserId(userId);
    }

    public List<Prescription> getPrescriptionsByDoctor(String doctorRegNo) {
        return prescriptionDAO.getPrescriptionsByDoctor(doctorRegNo);
    }

    public Prescription getPrescriptionById(int prescriptionId) {
        return prescriptionDAO.getPrescriptionById(prescriptionId);
    }

    public Prescription getPrescriptionByAppointmentId(int appointmentId) {
        return prescriptionDAO.getPrescriptionByAppointmentId(appointmentId);
    }
}
