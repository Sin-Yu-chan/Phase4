package Phase4;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // 1. 로그인 (ID/PW 확인)
    public UserDTO login(Connection conn, String id, String pw) {
        String sql = "SELECT * FROM P_User WHERE User_ID = ? AND Password = ?";
        UserDTO user = null;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, id);
            pstmt.setString(2, pw);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new UserDTO(
                        rs.getString("User_ID"),
                        rs.getString("Name"),
                        rs.getString("Role"),
                        rs.getString("Department"),
                        rs.getString("Phone_Number"),
                        rs.getString("Password")
                    );
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ 로그인 에러: " + e.getMessage());
        }
        return user;
    }

    // 2. 회원가입 (INSERT)
    public boolean signUp(Connection conn, UserDTO newUser) {
        String sql = "INSERT INTO P_User (User_ID, Name, Role, Department, Phone_Number, Password) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newUser.getUserId());
            pstmt.setString(2, newUser.getName());
            pstmt.setString(3, newUser.getRole());
            pstmt.setString(4, newUser.getDepartment());
            pstmt.setString(5, newUser.getPhoneNumber());
            pstmt.setString(6, newUser.getPassword());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ 회원가입 에러: " + e.getMessage());
            return false;
        }
    }

    // 3. ID 중복 확인
    public boolean isIdExists(Connection conn, String id) {
        String sql = "SELECT User_ID FROM P_User WHERE User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 4. 전화번호 중복 확인
    public boolean isPhoneExists(Connection conn, String phone) {
        String sql = "SELECT Phone_Number FROM P_User WHERE Phone_Number = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, phone);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 5. 회원 정보 수정 (이름, 학과, 전화번호)
    public boolean updateUserInfo(Connection conn, String userId, String newName, String newDept, String newPhone) {
        String sql = "UPDATE P_User SET Name = ?, Department = ?, Phone_Number = ? WHERE User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newName);
            pstmt.setString(2, newDept);
            pstmt.setString(3, newPhone);
            pstmt.setString(4, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            if(e.getErrorCode() == 1) System.out.println("❌ 수정 실패: 이미 존재하는 전화번호입니다.");
            else e.printStackTrace();
            return false;
        }
    }

    // 6. 비밀번호 변경
    public boolean updatePassword(Connection conn, String userId, String newPw) {
        String sql = "UPDATE P_User SET Password = ? WHERE User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newPw);
            pstmt.setString(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 7. 회원 탈퇴
    public boolean deleteUser(Connection conn, String userId) {
        String sql = "DELETE FROM P_User WHERE User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 8. 관리자 수 확인 (탈퇴 방지용)
    public int getAdminCount(Connection conn) {
        String sql = "SELECT COUNT(*) FROM P_User WHERE Role = 'Admin'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
    
    public UserDTO getUserById(Connection conn, String id) {
        String sql = "SELECT * FROM P_User WHERE User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new UserDTO(
                        rs.getString("User_ID"), rs.getString("Name"),
                        rs.getString("Role"), rs.getString("Department"),
                        rs.getString("Phone_Number"), rs.getString("Password")
                    );
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
    
    // [수정됨] 10. [Query 1] 학과별 학생 조회 (웹 전용 - List 반환)
    public List<UserDTO> getStudentsByDept(Connection conn, String deptName) {
        List<UserDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM P_User WHERE Department = ? AND Role = 'Student' ORDER BY Name";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, deptName);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new UserDTO(
                        rs.getString("User_ID"),
                        rs.getString("Name"),
                        rs.getString("Role"),
                        rs.getString("Department"),
                        rs.getString("Phone_Number"),
                        rs.getString("Password")
                    ));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ 조회 실패: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}