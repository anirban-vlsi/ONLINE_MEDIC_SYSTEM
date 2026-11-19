package service.emergency;

import dao.emergency.AmbulanceDAO;
import dao.emergency.EmergencyRequestDAO;
import model.emergency.Ambulance;
import model.emergency.EmergencyRequest;

import java.util.List;

public class EmergencyService {

    private final EmergencyRequestDAO requestDAO = new EmergencyRequestDAO();
    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();

    public boolean requestEmergencyAssistance(EmergencyRequest req) {
        if (req == null || req.getUserId() <= 0 || req.getPickupAddress() == null || req.getContactPhone() == null) {
            return false;
        }

        // Try to automatically assign an available ambulance
        List<Ambulance> available = ambulanceDAO.getAvailableAmbulances();
        if (!available.isEmpty()) {
            Ambulance assigned = available.get(0);
            req.setAmbulanceId(assigned.getAmbulanceId());
            req.setRequestStatus("DISPATCHED");
        } else {
            req.setRequestStatus("PENDING");
        }

        boolean created = requestDAO.createEmergencyRequest(req);
        if (created && req.getAmbulanceId() != null) {
            ambulanceDAO.updateAmbulanceStatus(req.getAmbulanceId(), "ON_DUTY");
        }
        return created;
    }

    public List<EmergencyRequest> getRequestsByUserId(int userId) {
        return requestDAO.getRequestsByUserId(userId);
    }

    public EmergencyRequest getRequestById(int requestId) {
        return requestDAO.getRequestById(requestId);
    }

    public List<EmergencyRequest> getAllRequests(String statusFilter) {
        return requestDAO.getAllRequests(statusFilter);
    }

    public List<Ambulance> getAllAmbulances() {
        return ambulanceDAO.getAllAmbulances();
    }

    public List<Ambulance> getAvailableAmbulances() {
        return ambulanceDAO.getAvailableAmbulances();
    }

    public boolean dispatchAmbulance(int requestId, int ambulanceId) {
        return requestDAO.dispatchAmbulance(requestId, ambulanceId);
    }

    public boolean updateRequestStatus(int requestId, String status) {
        return requestDAO.updateRequestStatus(requestId, status);
    }
}
