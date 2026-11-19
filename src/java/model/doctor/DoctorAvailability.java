package model.doctor;

import java.io.Serializable;
import java.sql.Time;

public class DoctorAvailability implements Serializable {
    private static final long serialVersionUID = 1L;

    private int availabilityId;
    private String doctorRegNo;
    private String visitMode = "CLINIC"; // CLINIC or HOME_VISIT
    private String dayOfWeek;
    private Time startTime;
    private Time endTime;
    private int maxPatientsPerDay = 20;
    private int maxPatients = 20;
    private boolean isActive = true;

    public DoctorAvailability() {}

    public int getAvailabilityId() { return availabilityId; }
    public void setAvailabilityId(int availabilityId) { this.availabilityId = availabilityId; }

    public String getDoctorRegNo() { return doctorRegNo; }
    public void setDoctorRegNo(String doctorRegNo) { this.doctorRegNo = doctorRegNo; }

    public String getVisitMode() { return visitMode; }
    public void setVisitMode(String visitMode) { this.visitMode = visitMode; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public int getMaxPatientsPerDay() { return maxPatientsPerDay; }
    public void setMaxPatientsPerDay(int maxPatientsPerDay) { this.maxPatientsPerDay = maxPatientsPerDay; }

    public int getMaxPatients() { return maxPatients; }
    public void setMaxPatients(int maxPatients) { this.maxPatients = maxPatients; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
}
