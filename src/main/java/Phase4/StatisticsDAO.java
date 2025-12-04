package Phase4;

import java.sql.*;

public class StatisticsDAO {

    // [Query 5] 건물별 자산 보유 현황
    public void showAssetCountsByBuilding(Connection conn) {
        String sql = "SELECT B.Name AS Building_Name, COUNT(*) AS Asset_Count "
                   + "FROM Building B, Classroom_Equipment CE "
                   + "WHERE B.Building_ID = CE.Building_ID "
                   + "  AND CE.Management_Style = 'Asset' "
                   + "GROUP BY B.Name";
        
        System.out.println("\n>> [통계] 건물별 자산 보유 현황 (Q5)");
        System.out.println("-------------------------------------");
        System.out.printf("%-20s | %s\n", "건물명", "자산 개수");
        System.out.println("-------------------------------------");

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.printf("%-20s | %d개\n", 
                    rs.getString("Building_Name"), rs.getInt("Asset_Count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        System.out.println("-------------------------------------");
    }

    // [Query 6] 모델별 신고 건수
    public void showReportCountsByModel(Connection conn) {
        String sql = "SELECT ET.Equipment_Name, CE.Model_Name, COUNT(*) AS Report_Count "
                   + "FROM Report R, Classroom_Equipment CE, Equipment_Type ET "
                   + "WHERE R.Equipment_ID = CE.Equipment_ID "
                   + "  AND CE.Model_Name = ET.Model_Name "
                   + "GROUP BY ET.Equipment_Name, CE.Model_Name";

        System.out.println("\n>> [통계] 모델별 신고 건수 (Q6)");
        System.out.println("--------------------------------------------------");
        System.out.printf("%-15s | %-20s | %s\n", "비품종류", "모델명", "신고횟수");
        System.out.println("--------------------------------------------------");

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.printf("%-15s | %-20s | %d건\n", 
                    rs.getString("Equipment_Name"), rs.getString("Model_Name"), rs.getInt("Report_Count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        System.out.println("--------------------------------------------------");
    }
    
    // [Query 14] 예약 활발 학과 (15건 이상)
    public void showActiveDepartments(Connection conn) {
        String sql = "SELECT T.Department, T.Res_Count "
                   + "FROM ( "
                   + "    SELECT U.Department, COUNT(R.Reservation_ID) AS Res_Count "
                   + "    FROM Reservation R, P_User U "
                   + "    WHERE R.User_ID = U.User_ID "
                   + "    GROUP BY U.Department "
                   + ") T "
                   + "WHERE T.Res_Count >= 15"; 

        System.out.println("\n>> [통계] 예약 활발 학과 (Q14)");
        System.out.println("-------------------------------------");
        System.out.printf("%-20s | %s\n", "학과명", "예약 건수");
        System.out.println("-------------------------------------");

        boolean hasData = false;
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.printf("%-20s | %d건\n", 
                    rs.getString("Department"), rs.getInt("Res_Count"));
                hasData = true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        
        if (!hasData) System.out.println("   (기준(15건)을 넘는 학과가 없습니다)");
        System.out.println("-------------------------------------");
    }

    // [Query 17] 학과별 신고 건수 순위
    public void showReportCountsByDept(Connection conn) {
        String sql = "SELECT U.Department, COUNT(*) AS Report_Count "
                   + "FROM Report R, P_User U "
                   + "WHERE R.Reporter_ID = U.User_ID "
                   + "GROUP BY U.Department "
                   + "ORDER BY COUNT(*) DESC"; 

        System.out.println("\n>> [통계] 학과별 신고 순위 (Q17)");
        System.out.println("-------------------------------------");
        System.out.printf("%-20s | %s\n", "학과명", "신고 건수");
        System.out.println("-------------------------------------");

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.printf("%-20s | %d건\n", 
                    rs.getString("Department"), rs.getInt("Report_Count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        System.out.println("-------------------------------------");
    }

    // [Query 18] 사용 빈도 Top 5 비품
    public void showTop5UsedModels(Connection conn) {
        String sql = "SELECT * FROM ("
                   + "  SELECT ET.Equipment_Name, COUNT(*) AS Usage_Count "
                   + "  FROM Usage_Log UL, Classroom_Equipment CE, Equipment_Type ET "
                   + "  WHERE UL.Equipment_ID = CE.Equipment_ID "
                   + "    AND CE.Model_Name = ET.Model_Name "
                   + "  GROUP BY ET.Equipment_Name "
                   + "  ORDER BY COUNT(*) DESC "
                   + ") WHERE ROWNUM <= 5"; 

        System.out.println("\n>> [통계] 사용 빈도 Top 5 (Q18)");
        System.out.println("-------------------------------------");
        System.out.printf("%-20s | %s\n", "비품종류", "사용횟수");
        System.out.println("-------------------------------------");

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                System.out.printf("%-20s | %d회\n", 
                    rs.getString("Equipment_Name"), rs.getInt("Usage_Count"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        System.out.println("-------------------------------------");
    }
}