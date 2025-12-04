package Phase4;

public class UserDTO {
    private String userId;
    private String name;
    private String role;
    private String department;
    private String phoneNumber;
    private String password;

    public UserDTO(String userId, String name, String role, String department, String phoneNumber, String password) {
        this.userId = userId;
        this.name = name;
        this.role = role;
        this.department = department;
        this.phoneNumber = phoneNumber;
        this.password = password;
    }

    // Getters
    public String getUserId() { return userId; }
    public String getName() { return name; }
    public String getRole() { return role; }
    public String getDepartment() { return department; }
    public String getPhoneNumber() { return phoneNumber; }
    public String getPassword() { return password; }

    @Override
    public String toString() {
        return "[ID: " + userId + ", 이름: " + name + ", 학과: " + department + ", 역할: " + role + "]";
    }
}