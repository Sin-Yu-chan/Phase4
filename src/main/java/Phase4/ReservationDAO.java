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
    
 // 5. 반납 처리
    public boolean returnEquipment(Connection conn, String resId) {
        PreparedStatement pstmtSelect = null;
        PreparedStatement pstmtInsert = null;
        PreparedStatement pstmtDelete = null;
        ResultSet rs = null;
        
        String sqlSelect = "SELECT * FROM Reservation WHERE Reservation_ID = ?";
        String sqlInsert = "INSERT INTO Usage_Log (Log_ID, Usage_Start_Time, Usage_End_Time, User_ID, Equipment_ID) VALUES (?, ?, SYSTIMESTAMP, ?, ?)";
        String sqlDelete = "DELETE FROM Reservation WHERE Reservation_ID = ?";
        
        try {
            conn.setAutoCommit(false);
            
            // 1. 기존 예약 정보 조회
            pstmtSelect = conn.prepareStatement(sqlSelect);
            pstmtSelect.setString(1, resId);
            rs = pstmtSelect.executeQuery();
            
            if (rs.next()) {
                String userId = rs.getString("User_ID");
                String equipId = rs.getString("Equipment_ID");
                Timestamp startTime = rs.getTimestamp("Start_Time");
                
                // 2. 로그 테이블에 기록 (ID 생성)
                String logId = "LOG" + System.currentTimeMillis();
                pstmtInsert = conn.prepareStatement(sqlInsert);
                pstmtInsert.setString(1, logId);
                pstmtInsert.setTimestamp(2, startTime);
                pstmtInsert.setString(3, userId);
                pstmtInsert.setString(4, equipId);
                pstmtInsert.executeUpdate();
                
                // 3. 예약 테이블에서 삭제
                pstmtDelete = conn.prepareStatement(sqlDelete);
                pstmtDelete.setString(1, resId);
                int count = pstmtDelete.executeUpdate();
                
                if (count > 0) {
                    conn.commit();
                    return true;
                }
            }
            conn.rollback(); // 데이터가 없거나 실패 시
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            try { 
                conn.setAutoCommit(true); 
                if(rs != null) rs.close();
                if(pstmtSelect != null) pstmtSelect.close();
                if(pstmtInsert != null) pstmtInsert.close();
                if(pstmtDelete != null) pstmtDelete.close();
            } catch (Exception e) {}
        }
        return false;
    }
    
    //트랜잭션 예약 처리
    public String makeSafeReservation(Connection conn, String userId, String equipId, Timestamp start, Timestamp end) {
        String resultMsg = "fail";
        PreparedStatement pstmtLock = null;
        PreparedStatement pstmtCheck = null;
        PreparedStatement pstmtInsert = null;
        ResultSet rs = null;

        try {
            // 1. 트랜잭션 수동 관리 시작
            conn.setAutoCommit(false);

            // 2. 부모 테이블(Classroom_Equipment)을 먼저 잠급니다.
            // 빈 시간대(Reservation 데이터가 없는 구간)에 동시에 들어오는 것을 막기 위해 존재하는 장비 행(Row)을 잡음
            String sqlLock = "SELECT Equipment_ID FROM Classroom_Equipment WHERE Equipment_ID = ? FOR UPDATE";
            pstmtLock = conn.prepareStatement(sqlLock);
            pstmtLock.setString(1, equipId);
            
            if (!pstmtLock.executeQuery().next()) {
                conn.rollback();
                return "존재하지 않는 비품입니다.";
            }

            // 3. 겹치는 일정이 있는지 검사
            String sqlCheck = "SELECT Reservation_ID FROM Reservation "
                            + "WHERE Equipment_ID = ? "
                            + "AND (Start_Time < ? AND End_Time > ?)";
            
            pstmtCheck = conn.prepareStatement(sqlCheck);
            pstmtCheck.setString(1, equipId);
            pstmtCheck.setTimestamp(2, end);
            pstmtCheck.setTimestamp(3, start);

            rs = pstmtCheck.executeQuery();

            if (rs.next()) {
                // 겹치는 예약 발견 -> 실패 처리
                conn.rollback();
                resultMsg = "이미 예약된 시간입니다.";
            } else {
                // 4. 예약 진행 (Insert)
                String newId = "RES" + (System.currentTimeMillis() % 1000000); // 기존 로직 유지
                String sqlInsert = "INSERT INTO Reservation (Reservation_ID, Start_Time, End_Time, User_ID, Equipment_ID) "
                                 + "VALUES (?, ?, ?, ?, ?)";

                pstmtInsert = conn.prepareStatement(sqlInsert);
                pstmtInsert.setString(1, newId);
                pstmtInsert.setTimestamp(2, start);
                pstmtInsert.setTimestamp(3, end);
                pstmtInsert.setString(4, userId);
                pstmtInsert.setString(5, equipId);
                
                int rows = pstmtInsert.executeUpdate();
                
                if (rows > 0) {
                    conn.commit(); // 5. 성공 시 커밋 (이때 락 해제됨)
                    resultMsg = "success";
                } else {
                    conn.rollback();
                    resultMsg = "DB 오류로 예약에 실패했습니다.";
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            try { conn.rollback(); } catch (SQLException ex) {} // 에러 발생 시 롤백
            resultMsg = "시스템 오류: " + e.getMessage();
        } finally {
            try { 
                conn.setAutoCommit(true); // 오토커밋 원래대로 복구 (필수)
                if(rs != null) rs.close();
                if(pstmtLock != null) pstmtLock.close();
                if(pstmtCheck != null) pstmtCheck.close();
                if(pstmtInsert != null) pstmtInsert.close();
            } catch (Exception e) {}
        }
        
        return resultMsg;
    }
}