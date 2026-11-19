package service.admin;

import dao.admin.ActivityLogDAO;
import model.admin.ActivityLog;

public class ActivityLogService {

    private static final ActivityLogDAO logDAO = new ActivityLogDAO();

    // Central logging method callable across the entire application
    public static void log(String actorId, String actorName, String actorType,
                           String activityType, String actionDescription,
                           String targetEntityType, String targetEntityId,
                           String result, String ipAddress) {
        try {
            ActivityLog entry = new ActivityLog();
            entry.setActorId(actorId != null ? actorId : "SYSTEM");
            entry.setActorName(actorName);
            entry.setActorType(actorType != null ? actorType : "SYSTEM");
            entry.setActivityType(activityType != null ? activityType : "GENERAL");
            entry.setActionDescription(actionDescription != null ? actionDescription : "");
            entry.setTargetEntityType(targetEntityType);
            entry.setTargetEntityId(targetEntityId);
            entry.setResult(result != null ? result : "SUCCESS");
            entry.setIpAddress(ipAddress);

            logDAO.logActivity(entry);
        } catch (Exception e) {
            // Safeguard: Never allow audit logging failure to interrupt main transaction
            System.err.println("Audit log failure: " + e.getMessage());
        }
    }
}
