package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {
    
    // 1. 신고 제출 (INSERT)
    public boolean submitReport(Connection conn, String rId, String type, String content, String userId, String equipId) {
        String sql = "INSERT INTO Report (Report_ID, Report_Type, Time, Processing_Status, Content, Reporter_ID, Equipment_ID) "
                   + "VALUES (?, ?, SYSTIMESTAMP, 'Pending', ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, rId);
            pstmt.setString(2, type);
            pstmt.setString(3, content);
            pstmt.setString(4, userId);
            pstmt.setString(5, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. 모든 신고 내역 조회 (관리자용 - 정렬: 시간>건물>호수)
    public List<ReportDTO> getAllReports(Connection conn) {
        List<ReportDTO> list = new ArrayList<>();
        
        String sql = "SELECT R.*, CE.Building_ID, CE.Classroom_Num " 
                   + "FROM Report R "
                   + "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID "
                   + "ORDER BY R.Time DESC, CE.Building_ID ASC, CE.Classroom_Num ASC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                list.add(new ReportDTO(
                    rs.getString("Report_ID"),
                    rs.getString("Report_Type"),
                    rs.getTimestamp("Time"),
                    rs.getString("Processing_Status"),
                    rs.getString("Content"),
                    rs.getString("Reporter_ID"),
                    rs.getString("Equipment_ID"),
                    rs.getString("Building_ID"),
                    rs.getString("Classroom_Num")
                ));
            }
        } catch (SQLException e) {
            System.out.println("❌ 신고 목록 조회 실패: " + e.getMessage());
        }
        return list;
    }

    // 3. 신고 처리 상태 변경 (UPDATE)
    public boolean updateReportStatus(Connection conn, String reportId, String newStatus) {
        String sql = "UPDATE Report SET Processing_Status = ? WHERE Report_ID = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setString(2, reportId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("❌ 상태 업데이트 실패: " + e.getMessage());
            return false;
        }
    }
    
    // 4. 나의 신고 내역 조회 (사용자용)
    public List<ReportDTO> getUserReports(Connection conn, String userId) {
        List<ReportDTO> list = new ArrayList<>();
        String sql = "SELECT R.*, CE.Building_ID, CE.Classroom_Num " 
                   + "FROM Report R "
                   + "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID "
                   + "WHERE R.Reporter_ID = ? "
                   + "ORDER BY R.Time DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new ReportDTO(
                        rs.getString("Report_ID"),
                        rs.getString("Report_Type"),
                        rs.getTimestamp("Time"),
                        rs.getString("Processing_Status"),
                        rs.getString("Content"),
                        rs.getString("Reporter_ID"),
                        rs.getString("Equipment_ID"),
                        rs.getString("Building_ID"),
                        rs.getString("Classroom_Num")
                    ));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ 내역 조회 실패: " + e.getMessage());
        }
        return list;
    }

    // 5. 신고 취소 (연관된 알림 데이터까지 Cascade 삭제)
    public int cancelMyReport(Connection conn, String reportId, String userId) {
        // 검증: 본인의 Pending 상태인 신고인지 확인
        String checkSql = "SELECT COUNT(*) FROM Report WHERE Report_ID = ? AND Reporter_ID = ? AND Processing_Status = 'Pending'";
        
        // 삭제 쿼리들 (자식 -> 부모 순서)
        String delReceives = "DELETE FROM Receives WHERE Notification_ID IN (SELECT Notification_ID FROM Notification WHERE Report_ID = ?)";
        String delNotif = "DELETE FROM Notification WHERE Report_ID = ?";
        String delReport = "DELETE FROM Report WHERE Report_ID = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // [Step 1] 검증
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, reportId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                return 0; // 조건 불일치 (권한 없음 또는 이미 처리됨)
            }
            rs.close();
            pstmt.close();

            // [Step 2] 연쇄 삭제
            // 1. Receives 삭제
            pstmt = conn.prepareStatement(delReceives);
            pstmt.setString(1, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. Notification 삭제
            pstmt = conn.prepareStatement(delNotif);
            pstmt.setString(1, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            // 3. Report 삭제
            pstmt = conn.prepareStatement(delReport);
            pstmt.setString(1, reportId);
            int result = pstmt.executeUpdate();
            
            return result; // 성공 시 1 반환

        } catch (SQLException e) {
            System.out.println("❌ 신고 취소 중 오류: " + e.getMessage());
            return -1;
        } finally {
            try { 
                if(rs != null) rs.close(); 
                if(pstmt != null) pstmt.close(); 
            } catch(Exception e) {}
        }
    }
}