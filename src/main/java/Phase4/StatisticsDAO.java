package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StatisticsDAO {

    // [만능 통계 메서드]
    public List<StatDTO> getUnifiedStats(Connection conn, String target, String groupBy, 
                                         String bFilter, String mFilter, String sFilter, 
                                         String startDate, String endDate, int limit, 
                                         int minQty, int maxQty) {
        
        List<StatDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        // 1. SELECT 절 구성
        sql.append("SELECT ");
        String labelCol = getLabelColumn(target, groupBy);
        
        // 라벨이 NULL일 경우(소모품 등) 대체 텍스트 표시
        sql.append("COALESCE(" + labelCol + ", '(소모품/기타)') AS LABEL, ");

        // 집계 기준 설정 (자산은 수량 합산, 나머지는 건수 카운트)
        String countExpr = "COUNT(*)";
        if ("ASSET".equals(target)) {
            countExpr = "SUM(COALESCE(CS.Quantity, 1))";
        }
        sql.append(countExpr + " AS CNT ");

        // 2. FROM & JOIN 절 구성
        sql.append(getFromClause(target));
        
        // 3. WHERE 절 구성 (필터링)
        sql.append("WHERE 1=1 ");
        
        // 건물 필터
        if (bFilter != null && !bFilter.isEmpty() && !"ALL".equals(bFilter)) {
            sql.append("AND CE.Building_ID = '" + bFilter + "' ");
        }
        // 모델명 필터 (부분 검색)
        if (mFilter != null && !mFilter.isEmpty()) {
            sql.append("AND CE.Model_Name LIKE '%" + mFilter + "%' ");
        }
        // 상태/유형 필터
        if (sFilter != null && !sFilter.isEmpty() && !"ALL".equals(sFilter)) {
            if ("REPORT".equals(target)) {
                sql.append("AND R.Report_Type = '" + sFilter + "' ");
            } else {
                sql.append("AND AI.Status = '" + sFilter + "' ");
            }
        }
        
        // 날짜 필터
        String dateCol = getDateColumn(target);
        if (dateCol != null) {
            if (startDate != null && !startDate.isEmpty()) 
                sql.append("AND " + dateCol + " >= TO_DATE('" + startDate + " 00:00:00', 'YYYY-MM-DD HH24:MI:SS') ");
            if (endDate != null && !endDate.isEmpty()) 
                sql.append("AND " + dateCol + " <= TO_DATE('" + endDate + " 23:59:59', 'YYYY-MM-DD HH24:MI:SS') ");
        }

        // 4. GROUP BY 절
        sql.append("GROUP BY " + labelCol + " ");
        
        // 5. HAVING 절 (수량 범위 필터)
        if (minQty > 0 || maxQty > 0) {
            sql.append("HAVING 1=1 ");
            if (minQty > 0) sql.append("AND " + countExpr + " >= " + minQty + " ");
            if (maxQty > 0) sql.append("AND " + countExpr + " <= " + maxQty + " ");
        }
        
        // 6. ORDER BY & ROWNUM
        sql.append("ORDER BY CNT DESC");
        String finalSql = "SELECT * FROM (" + sql.toString() + ") WHERE ROWNUM <= " + limit;

        // 디버깅용 로그
        System.out.println("[통계 쿼리 실행] " + finalSql);

        try (PreparedStatement pstmt = conn.prepareStatement(finalSql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                String label = rs.getString("LABEL");
                list.add(new StatDTO(label, rs.getInt("CNT")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // [헬퍼 1] 그룹핑 기준 컬럼명 반환
    private String getLabelColumn(String target, String groupBy) {
        if ("BUILDING".equals(groupBy)) return "CE.Building_ID";
        if ("MODEL".equals(groupBy)) return "CE.Model_Name";
        if ("DEPT".equals(groupBy)) return "U.Department"; // 예약/신고 시 사용자 학과
        
        if ("STATUS".equals(groupBy)) {
            if ("REPORT".equals(target)) return "R.Report_Type";
            return "AI.Status";
        }
        return "CE.Building_ID"; // 기본값
    }

    // [헬퍼 2] 테이블 조인 구문 반환 (★수정됨: REPORT에 사용자 조인 추가)
    private String getFromClause(String target) {
        
        if ("ASSET".equals(target)) {
            // 자산/재고: 자산(AI) + 소모품(CS) 모두 조인
            return "FROM Classroom_Equipment CE " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID " +
                   "LEFT JOIN Consumable_Stock CS ON CE.Equipment_ID = CS.Equipment_ID ";
        } 
        else if ("REPORT".equals(target)) {
            // [수정] 신고: Report + User(학과용) + CE + AI(상태필터용)
            return "FROM Report R " +
                   "JOIN P_User U ON R.Reporter_ID = U.User_ID " +  // ★ 이 줄 추가됨
                   "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        } 
        else if ("USAGE".equals(target)) {
            // 로그: Usage_Log + CE + AI
            return "FROM Usage_Log UL " +
                   "JOIN Classroom_Equipment CE ON UL.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        } 
        else if ("RESERVATION".equals(target)) {
            // 예약: Reservation + User(학과용) + CE + AI
            return "FROM Reservation RES " +
                   "JOIN P_User U ON RES.User_ID = U.User_ID " +
                   "JOIN Classroom_Equipment CE ON RES.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        }
        return "";
    }

    // [헬퍼 3] 날짜 컬럼명 반환
    private String getDateColumn(String target) {
        if ("REPORT".equals(target)) return "R.Time";
        if ("USAGE".equals(target)) return "UL.Usage_Start_Time";
        if ("RESERVATION".equals(target)) return "RES.Start_Time";
        return null; // ASSET은 날짜 없음
    }
}