package model.doctor;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Doctor implements Serializable {

    private static final long serialVersionUID = 1L;

    private String registrationNumber;
    private String doctorName;
    private int age;
    private String email;
    private String password;
    private String address;
    private String city = "Bangalore";
    private String specialization;
    private BigDecimal consultationFee = new BigDecimal("500.00");
    private boolean homeVisitAvailable = false;
    private BigDecimal homeVisitFee;
    private String serviceAreas;
    private String verificationStatus;
    private Timestamp createdAt;

    public Doctor() {
    }

    public Doctor(String registrationNumber, String doctorName, int age, String email,
                  String password, String address, String specialization,
                  String verificationStatus, Timestamp createdAt) {
        this.registrationNumber = registrationNumber;
        this.doctorName = doctorName;
        this.age = age;
        this.email = email;
        this.password = password;
        this.address = address;
        this.specialization = specialization;
        this.verificationStatus = verificationStatus;
        this.createdAt = createdAt;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public BigDecimal getConsultationFee() {
        return consultationFee;
    }

    public void setConsultationFee(BigDecimal consultationFee) {
        this.consultationFee = consultationFee;
    }

    public boolean isHomeVisitAvailable() {
        return homeVisitAvailable;
    }

    public void setHomeVisitAvailable(boolean homeVisitAvailable) {
        this.homeVisitAvailable = homeVisitAvailable;
    }

    public BigDecimal getHomeVisitFee() {
        return homeVisitFee;
    }

    public void setHomeVisitFee(BigDecimal homeVisitFee) {
        this.homeVisitFee = homeVisitFee;
    }

    public String getServiceAreas() {
        return serviceAreas;
    }

    public void setServiceAreas(String serviceAreas) {
        this.serviceAreas = serviceAreas;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isVerified() {
        return "VERIFIED".equalsIgnoreCase(this.verificationStatus);
    }
}
