package Phase4;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // 1. 알림 전송 (기존 유지)
    public void sendNotificationToAdmins(Connection conn, String reportId, String content) {
        String notifId = "N" + System.currentTimeMillis();
        String sqlNotif = "INSERT INTO Notification (Notification_ID, Notification_Type, Notification_Time, Content, Report_ID) VALUES (?, 'New Report', SYSTIMESTAMP, ?, ?)";
        String sqlFindAdmins = "SELECT User_ID FROM P_User WHERE Role = 'Admin'";
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
            rs.close(); pstmt.close();

            // (3) 수신자 연결
            pstmt = conn.prepareStatement(sqlReceives);
            for (String adminId : adminIds) {
                pstmt.setString(1, adminId);
                pstmt.setString(2, notifId);
                pstmt.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            try { if(pstmt!=null) pstmt.close(); if(rs!=null) rs.close(); } catch(Exception e) {}
        }
    }

    // [New] 2. 안 읽은 알림 개수 조회 (메인 배지용)
    public int getUnreadCount(Connection conn, String userId) {
        String sql = "SELECT COUNT(*) FROM Receives WHERE User_ID = ? AND Is_Checked = 'N'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // [Modified] 3. 나의 알림 목록 조회 (DTO 수정 반영)
    public List<NotificationDTO> getMyNotifications(Connection conn, String userId) {
        List<NotificationDTO> list = new ArrayList<>();
        String sql = "SELECT N.Notification_ID, N.Notification_Type, N.Notification_Time, N.Content, N.Report_ID, R.Is_Checked "
                   + "FROM Notification N "
                   + "JOIN Receives R ON N.Notification_ID = R.Notification_ID "
                   + "WHERE R.User_ID = ? "
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
                        rs.getString("Report_ID"),
                        rs.getString("Is_Checked") // ★ 추가됨
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // [New] 4. 개별 알림 읽음 처리
    public void markAsRead(Connection conn, String notifId, String userId) {
        String sql = "UPDATE Receives SET Is_Checked = 'Y' WHERE Notification_ID = ? AND User_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, notifId);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
            conn.commit();
        } catch (SQLException e) { try{conn.rollback();}catch(Exception ex){} e.printStackTrace(); }
    }

    // 5. 전체 읽음 처리
    public void markAllAsRead(Connection conn, String userId) {
        String sql = "UPDATE Receives SET Is_Checked = 'Y' WHERE User_ID = ? AND Is_Checked = 'N'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            conn.commit();
        } catch (SQLException e) { try{conn.rollback();}catch(Exception ex){} e.printStackTrace(); }
    }
}