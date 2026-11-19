package dao.common;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/medic?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "manager";

    static {
        try {
            // Load MySQL Connector Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            try {
                // Fallback to legacy driver name if older connector is present
                Class.forName("com.mysql.jdbc.Driver");
            } catch (ClassNotFoundException ex) {
                System.err.println("MySQL Driver not found: " + ex.getMessage());
            }
        }
    }

    public static Connection getConnection() {
        Connection con = null;
        try {
            con = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            // Retry without extra URL parameters if older server/driver prefers basic URL
            try {
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/medic", USERNAME, PASSWORD);
            } catch (Exception ex) {
                System.err.println("Database connection failed: " + ex.getMessage());
                ex.printStackTrace();
            }
        }
        return con;
    }
}
