package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {
    
    // 1. 신고 제출
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

    // 2. 관리자용 조회 (수정됨: Model_Name 사용)
    public List<ReportDTO> getAllReports(Connection conn) {
        List<ReportDTO> list = new ArrayList<>();
        
        // ★ [수정 포인트] CE.Equipment_Name -> CE.Model_Name
        String sql = "SELECT R.*, CE.Building_ID, CE.Classroom_Num, CE.Model_Name " 
                   + "FROM Report R "
                   + "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID "
                   + "ORDER BY R.Time DESC, CE.Building_ID ASC, CE.Classroom_Num ASC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                list.add(new ReportDTO(
                    rs.getString("Report_ID"),
                    rs.getString("Report_Type"),
                    rs.getString("Content"),
                    rs.getString("Processing_Status"),
                    rs.getTimestamp("Time"),
                    rs.getString("Reporter_ID"),
                    rs.getString("Equipment_ID"),
                    rs.getString("Model_Name"), // ★ [수정] DB에서 Model_Name 가져옴
                    rs.getString("Building_ID"),
                    rs.getString("Classroom_Num")
                ));
            }
        } catch (SQLException e) {
            System.out.println("❌ 오류: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 3. 상태 변경
    public boolean updateReportStatus(Connection conn, String reportId, String newStatus) {
        String sql = "UPDATE Report SET Processing_Status = ? WHERE Report_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setString(2, reportId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 4. 사용자용 조회 (수정됨: Model_Name 사용)
    public List<ReportDTO> getUserReports(Connection conn, String userId) {
        List<ReportDTO> list = new ArrayList<>();
        // ★ [수정 포인트] CE.Model_Name 사용
        String sql = "SELECT R.*, CE.Building_ID, CE.Classroom_Num, CE.Model_Name " 
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
                        rs.getString("Content"),
                        rs.getString("Processing_Status"),
                        rs.getTimestamp("Time"),
                        rs.getString("Reporter_ID"),
                        rs.getString("Equipment_ID"),
                        rs.getString("Model_Name"), // ★ [수정]
                        rs.getString("Building_ID"),
                        rs.getString("Classroom_Num")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. 신고 취소 (기존 동일)
    public int cancelMyReport(Connection conn, String reportId, String userId) {
        String checkSql = "SELECT COUNT(*) FROM Report WHERE Report_ID = ? AND Reporter_ID = ? AND Processing_Status = 'Pending'";
        String delReceives = "DELETE FROM Receives WHERE Notification_ID IN (SELECT Notification_ID FROM Notification WHERE Report_ID = ?)";
        String delNotif = "DELETE FROM Notification WHERE Report_ID = ?";
        String delReport = "DELETE FROM Report WHERE Report_ID = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
            pstmt.setString(1, reportId);
            pstmt.setString(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) return 0;
            }
            // 삭제 로직 실행 (생략: 위와 동일하게 유지)
            try(PreparedStatement p2 = conn.prepareStatement(delReceives)) {
                p2.setString(1, reportId); p2.executeUpdate();
            }
            try(PreparedStatement p3 = conn.prepareStatement(delNotif)) {
                p3.setString(1, reportId); p3.executeUpdate();
            }
            try(PreparedStatement p4 = conn.prepareStatement(delReport)) {
                p4.setString(1, reportId); return p4.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }
}