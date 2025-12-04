package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsageLogDAO {

    // 공통 SQL: 로그 + 사용자명 + 비품모델명 JOIN
    private final String BASE_SQL = 
          "SELECT L.Log_ID, L.Usage_Start_Time, L.Usage_End_Time, "
        + "       L.User_ID, U.Name AS User_Name, "
        + "       L.Equipment_ID, CE.Model_Name "
        + "FROM Usage_Log L "
        + "JOIN P_User U ON L.User_ID = U.User_ID "
        + "JOIN Classroom_Equipment CE ON L.Equipment_ID = CE.Equipment_ID ";

    // 1. 전체 로그 조회 (최신순)
    public List<UsageLogDTO> getAllLogs(Connection conn) {
        return searchLogs(conn, "", null); 
    }

    // 2. 사용자 ID로 검색
    public List<UsageLogDTO> getLogsByUser(Connection conn, String userId) {
        return searchLogs(conn, "AND L.User_ID LIKE ?", "%" + userId + "%");
    }

    // 3. 비품 ID로 검색
    public List<UsageLogDTO> getLogsByEquipment(Connection conn, String equipId) {
        return searchLogs(conn, "AND L.Equipment_ID = ?", equipId);
    }

    // Helper: 검색 조건에 따라 쿼리 실행
    private List<UsageLogDTO> searchLogs(Connection conn, String whereClause, String param) {
        List<UsageLogDTO> list = new ArrayList<>();
        String sql = BASE_SQL + "WHERE 1=1 " + whereClause + " ORDER BY L.Usage_Start_Time DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (param != null) {
                pstmt.setString(1, param);
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new UsageLogDTO(
                        rs.getString("Log_ID"),
                        rs.getTimestamp("Usage_Start_Time"),
                        rs.getTimestamp("Usage_End_Time"),
                        rs.getString("User_ID"),
                        rs.getString("User_Name"),
                        rs.getString("Equipment_ID"),
                        rs.getString("Model_Name")
                    ));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ 로그 조회 실패: " + e.getMessage());
        }
        return list;
    }
}