package model.patient;

import java.io.Serializable;
import java.util.Date;

public class Patient implements Serializable {

    private static final long serialVersionUID = 1L;

    private int patientId;
    private int userId;
    private String patientName;
    private Date dateOfBirth;
    private String gender;
    private String relation;
    private String mobileNo;
    private String bloodGroup;
    private String allergies;
    private String medicalConditions;

    public Patient() {
    }

    public Patient(int patientId, int userId, String patientName,
                   Date dateOfBirth, String gender, String relation,
                   String mobileNo, String bloodGroup, String allergies,
                   String medicalConditions) {
        this.patientId = patientId;
        this.userId = userId;
        this.patientName = patientName;
        this.dateOfBirth = dateOfBirth;
        this.gender = gender;
        this.relation = relation;
        this.mobileNo = mobileNo;
        this.bloodGroup = bloodGroup;
        this.allergies = allergies;
        this.medicalConditions = medicalConditions;
    }

    public int getPatientId() {
        return patientId;
    }

    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getRelation() {
        return relation;
    }

    public void setRelation(String relation) {
        this.relation = relation;
    }

    public String getMobileNo() {
        return mobileNo;
    }

    public void setMobileNo(String mobileNo) {
        this.mobileNo = mobileNo;
    }

    public String getBloodGroup() {
        return bloodGroup;
    }

    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
    }

    public String getAllergies() {
        return allergies;
    }

    public void setAllergies(String allergies) {
        this.allergies = allergies;
    }

    public String getMedicalConditions() {
        return medicalConditions;
    }

    public void setMedicalConditions(String medicalConditions) {
        this.medicalConditions = medicalConditions;
    }
}
