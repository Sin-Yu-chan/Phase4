package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StatisticsDAO {

    public List<StatDTO> getUnifiedStats(Connection conn, String target, String groupBy, 
                                         String bFilter, String mFilter, String sFilter, 
                                         String startDate, String endDate, int limit, 
                                         int minQty, int maxQty) {
        
        List<StatDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        
        // 1. SELECT 절
        sql.append("SELECT ");
        String labelCol = getLabelColumn(target, groupBy);
        sql.append("COALESCE(" + labelCol + ", '(소모품/기타)') AS LABEL, ");

        String countExpr = "COUNT(*)";
        if ("ASSET".equals(target)) {
            countExpr = "SUM(COALESCE(CS.Quantity, 1))";
        }
        sql.append(countExpr + " AS CNT ");

        // 2. FROM & JOIN 절
        sql.append(getFromClause(target));
        
        // 3. WHERE 절 
        sql.append("WHERE 1=1 ");
        
        if (bFilter != null && !bFilter.isEmpty() && !"ALL".equals(bFilter)) {
            sql.append("AND CE.Building_ID = ? ");
            params.add(bFilter);
        }
        if (mFilter != null && !mFilter.isEmpty()) {
            sql.append("AND CE.Model_Name LIKE ? ");
            params.add("%" + mFilter + "%");
        }
        if (sFilter != null && !sFilter.isEmpty() && !"ALL".equals(sFilter)) {
            if ("REPORT".equals(target)) {
                sql.append("AND R.Report_Type = ? ");
            } else {
                sql.append("AND AI.Status = ? ");
            }
            params.add(sFilter);
        }
        
        String dateCol = getDateColumn(target);
        if (dateCol != null) {
            if (startDate != null && !startDate.isEmpty()) {
                sql.append("AND " + dateCol + " >= TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') ");
                params.add(startDate + " 00:00:00");
            }
            if (endDate != null && !endDate.isEmpty()) {
                sql.append("AND " + dateCol + " <= TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') ");
                params.add(endDate + " 23:59:59");
            }
        }

        // 4. GROUP BY
        sql.append("GROUP BY " + labelCol + " ");
        
        // 5. HAVING
        if (minQty > 0 || maxQty > 0) {
            sql.append("HAVING 1=1 ");
            if (minQty > 0) sql.append("AND " + countExpr + " >= " + minQty + " ");
            if (maxQty > 0) sql.append("AND " + countExpr + " <= " + maxQty + " ");
        }
        
        // 6. ORDER BY & ROWNUM
        sql.append("ORDER BY CNT DESC");
        String finalSql = "SELECT * FROM (" + sql.toString() + ") WHERE ROWNUM <= ?";
        params.add(limit);

        try (PreparedStatement pstmt = conn.prepareStatement(finalSql)) {
            // 파라미터 세팅 루프
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof String) pstmt.setString(i + 1, (String) p);
                else if (p instanceof Integer) pstmt.setInt(i + 1, (Integer) p);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new StatDTO(rs.getString("LABEL"), rs.getInt("CNT")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private String getLabelColumn(String target, String groupBy) {
        if ("BUILDING".equals(groupBy)) return "CE.Building_ID";
        if ("MODEL".equals(groupBy)) return "CE.Model_Name";
        if ("DEPT".equals(groupBy)) return "U.Department";
        if ("STATUS".equals(groupBy)) {
            if ("REPORT".equals(target)) return "R.Report_Type";
            return "AI.Status";
        }
        return "CE.Building_ID";
    }

    private String getFromClause(String target) {
        if ("ASSET".equals(target)) {
            return "FROM Classroom_Equipment CE " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID " +
                   "LEFT JOIN Consumable_Stock CS ON CE.Equipment_ID = CS.Equipment_ID ";
        } 
        else if ("REPORT".equals(target)) {
            return "FROM Report R " +
                   "JOIN P_User U ON R.Reporter_ID = U.User_ID " +
                   "JOIN Classroom_Equipment CE ON R.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        } 
        else if ("USAGE".equals(target)) {
            return "FROM Usage_Log UL " +
                   "JOIN Classroom_Equipment CE ON UL.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        } 
        else if ("RESERVATION".equals(target)) {
            return "FROM Reservation RES " +
                   "JOIN P_User U ON RES.User_ID = U.User_ID " +
                   "JOIN Classroom_Equipment CE ON RES.Equipment_ID = CE.Equipment_ID " +
                   "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID ";
        }
        return "";
    }

    private String getDateColumn(String target) {
        if ("REPORT".equals(target)) return "R.Time";
        if ("USAGE".equals(target)) return "UL.Usage_Start_Time";
        if ("RESERVATION".equals(target)) return "RES.Start_Time";
        return null;
    }
}