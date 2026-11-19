package model.admin;

import java.io.Serializable;
import java.sql.Timestamp;

public class ActivityLog implements Serializable {

    private static final long serialVersionUID = 1L;

    private long activityId;
    private String actorId;
    private String actorName;
    private String actorType; // PATIENT, DOCTOR, ADMIN, SYSTEM
    private String activityType; // LOGIN, LOGOUT, REGISTRATION, APPROVAL, REJECTION, BLOCK, UNBLOCK, DELETION
    private String actionDescription;
    private String targetEntityType;
    private String targetEntityId;
    private String result; // SUCCESS, FAILURE
    private String ipAddress;
    private Timestamp createdAt;

    public ActivityLog() {
    }

    public ActivityLog(long activityId, String actorId, String actorName, String actorType,
                       String activityType, String actionDescription, String targetEntityType,
                       String targetEntityId, String result, String ipAddress, Timestamp createdAt) {
        this.activityId = activityId;
        this.actorId = actorId;
        this.actorName = actorName;
        this.actorType = actorType;
        this.activityType = activityType;
        this.actionDescription = actionDescription;
        this.targetEntityType = targetEntityType;
        this.targetEntityId = targetEntityId;
        this.result = result;
        this.ipAddress = ipAddress;
        this.createdAt = createdAt;
    }

    public long getActivityId() {
        return activityId;
    }

    public void setActivityId(long activityId) {
        this.activityId = activityId;
    }

    public String getActorId() {
        return actorId;
    }

    public void setActorId(String actorId) {
        this.actorId = actorId;
    }

    public String getActorName() {
        return actorName;
    }

    public void setActorName(String actorName) {
        this.actorName = actorName;
    }

    public String getActorType() {
        return actorType;
    }

    public void setActorType(String actorType) {
        this.actorType = actorType;
    }

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public String getActionDescription() {
        return actionDescription;
    }

    public void setActionDescription(String actionDescription) {
        this.actionDescription = actionDescription;
    }

    public String getTargetEntityType() {
        return targetEntityType;
    }

    public void setTargetEntityType(String targetEntityType) {
        this.targetEntityType = targetEntityType;
    }

    public String getTargetEntityId() {
        return targetEntityId;
    }

    public void setTargetEntityId(String targetEntityId) {
        this.targetEntityId = targetEntityId;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
