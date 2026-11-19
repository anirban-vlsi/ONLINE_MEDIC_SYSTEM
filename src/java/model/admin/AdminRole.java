package model.admin;

public class AdminRole {

    public static final String SUPER_ADMIN = "SUPER_ADMIN";
    public static final String ADMIN = "ADMIN";
    public static final String MODERATOR = "MODERATOR";

    public static boolean isValidRole(String role) {
        if (role == null) {
            return false;
        }
        String r = role.trim().toUpperCase();
        return SUPER_ADMIN.equals(r) || ADMIN.equals(r) || MODERATOR.equals(r);
    }
}
