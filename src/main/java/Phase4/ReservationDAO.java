package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    // 1. 예약 가능 여부 확인 (중복 체크)
    public boolean isAvailable(Connection conn, String equipId, Timestamp newStart, Timestamp newEnd) {
        // 시간 겹침 조건: 기존 시작 < 내 종료 AND 기존 종료 > 내 시작
        String sql = "SELECT COUNT(*) FROM Reservation "
                   + "WHERE Equipment_ID = ? "
                   + "AND (Start_Time < ? AND End_Time > ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, equipId);
            pstmt.setTimestamp(2, newEnd);   
            pstmt.setTimestamp(3, newStart);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0; // 0이면 예약 가능
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false; 
    }

    // 2. 예약 하기 (INSERT)
    public boolean addReservation(Connection conn, String userId, String equipId, Timestamp start, Timestamp end) {
        String resId = "RES" + (System.currentTimeMillis() % 1000000); 
        String sql = "INSERT INTO Reservation (Reservation_ID, Start_Time, End_Time, User_ID, Equipment_ID) "
                   + "VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, resId);
            pstmt.setTimestamp(2, start);
            pstmt.setTimestamp(3, end);
            pstmt.setString(4, userId);
            pstmt.setString(5, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 3. 나의 예약 목록 조회 (시간 역순 정렬)
    public List<ReservationDTO> getMyReservations(Connection conn, String userId) {
        List<ReservationDTO> list = new ArrayList<>();
        String sql = "SELECT R.Reservation_ID, R.Start_Time, R.End_Time, R.User_ID, R.Equipment_ID, "
                   + "       CE.Model_Name, ET.Equipment_Name "
                   + "FROM Reservation R "
                   + "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID "
                   + "JOIN Equipment_Type ET ON CE.Model_Name = ET.Model_Name "
                   + "WHERE R.User_ID = ? "
                   + "ORDER BY R.Start_Time DESC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new ReservationDTO(
                        rs.getString("Reservation_ID"),
                        rs.getTimestamp("Start_Time"),
                        rs.getTimestamp("End_Time"),
                        rs.getString("User_ID"),
                        rs.getString("Equipment_ID"),
                        rs.getString("Model_Name"),
                        rs.getString("Equipment_Name")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. 예약 취소 (DELETE)
    public boolean cancelReservation(Connection conn, String resId) {
        String sql = "DELETE FROM Reservation WHERE Reservation_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, resId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}