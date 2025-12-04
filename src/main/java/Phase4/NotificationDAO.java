package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // 1. 알림 생성 및 전송 (Report 발생 시)
    public void sendNotificationToAdmins(Connection conn, String reportId, String content) {
        String notifId = "N" + System.currentTimeMillis();
        
        String sqlNotif = "INSERT INTO Notification (Notification_ID, Notification_Type, Notification_Time, Content, Report_ID) "
                        + "VALUES (?, 'New Report', SYSTIMESTAMP, ?, ?)";
        
        String sqlFindAdmins = "SELECT User_ID FROM P_User WHERE Role = 'Admin'";
        
        // Receives 테이블에 넣을 때 Is_Checked 기본값 'N'
        String sqlReceives = "INSERT INTO Receives (User_ID, Notification_ID, Is_Checked) VALUES (?, ?, 'N')";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // (1) 알림 등록
            pstmt = conn.prepareStatement(sqlNotif);
            pstmt.setString(1, notifId);
            pstmt.setString(2, content);
            pstmt.setString(3, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            // (2) 관리자 조회
            pstmt = conn.prepareStatement(sqlFindAdmins);
            rs = pstmt.executeQuery();
            List<String> adminIds = new ArrayList<>();
            while(rs.next()) adminIds.add(rs.getString("User_ID"));
            rs.close();
            pstmt.close();

            // (3) 수신자 연결
            pstmt = conn.prepareStatement(sqlReceives);
            for (String adminId : adminIds) {
                pstmt.setString(1, adminId);
                pstmt.setString(2, notifId);
                pstmt.executeUpdate();
            }

        } catch (SQLException e) {
            System.out.println("❌ 알림 전송 오류: " + e.getMessage());
        } finally {
            try { if(pstmt!=null) pstmt.close(); if(rs!=null) rs.close(); } catch(Exception e) {}
        }
    }

    // 2. 안 읽은 알림 조회 (Is_Checked = 'N')
    public List<NotificationDTO> getUnreadNotifications(Connection conn, String userId) {
        List<NotificationDTO> list = new ArrayList<>();
        String sql = "SELECT N.* FROM Notification N "
                   + "JOIN Receives R ON N.Notification_ID = R.Notification_ID "
                   + "WHERE R.User_ID = ? AND R.Is_Checked = 'N' "
                   + "ORDER BY N.Notification_Time DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new NotificationDTO(
                        rs.getString("Notification_ID"),
                        rs.getString("Notification_Type"),
                        rs.getTimestamp("Notification_Time"),
                        rs.getString("Content"),
                        rs.getString("Report_ID")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. 알림 읽음 처리 (Update 'N' -> 'Y')
    public void markAllAsRead(Connection conn, String userId) {
        String sql = "UPDATE Receives SET Is_Checked = 'Y' WHERE User_ID = ? AND Is_Checked = 'N'";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}