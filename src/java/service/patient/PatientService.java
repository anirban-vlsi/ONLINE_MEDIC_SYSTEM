package service.patient;

import dao.patient.PatientDAO;
import model.patient.Patient;

import java.util.List;

public class PatientService {

    private final PatientDAO patientDAO;

    public PatientService() {
        this.patientDAO = new PatientDAO();
    }

    public PatientService(PatientDAO patientDAO) {
        this.patientDAO = patientDAO;
    }

    // Add a new patient record
    public boolean addPatient(Patient patient) {

        if (patient == null) {
            return false;
        }

        if (patient.getUserId() <= 0) {
            return false;
        }

        if (patient.getPatientName() == null || patient.getPatientName().trim().isEmpty()) {
            return false;
        }

        return patientDAO.addPatient(patient);
    }

    // Get all patients belonging to a user
    public List<Patient> getPatientsByUserId(int userId) {
        if (userId <= 0) {
            return null;
        }
        return patientDAO.getPatientsByUserId(userId);
    }

    // Get a patient by patient ID
    public Patient getPatientById(int patientId) {
        if (patientId <= 0) {
            return null;
        }
        return patientDAO.getPatientById(patientId);
    }

    // Update patient information
    public boolean updatePatient(Patient patient) {
        if (patient == null) {
            return false;
        }

        if (patient.getPatientId() <= 0) {
            return false;
        }

        if (patient.getPatientName() == null || patient.getPatientName().trim().isEmpty()) {
            return false;
        }

        return patientDAO.updatePatient(patient);
    }
}
