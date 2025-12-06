<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.NotificationDAO" %>
<%@ page import="Phase4.NotificationDTO" %>

<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    Connection conn = DBConnection.getConnection();
    NotificationDAO notifDAO = new NotificationDAO();
    List<NotificationDTO> list = notifDAO.getMyNotifications(conn, userId);
    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 알림함</title>
<style>
    body { font-family: sans-serif; text-align: center; background-color: #f8f9fa; }
    .container { width: 600px; margin: 30px auto; background: white; padding: 20px; border-radius: 10px; text-align: left; border: 1px solid #ddd; }
    
    .notif-item { padding: 15px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
    .notif-item:last-child { border-bottom: none; }
    
    /* 안 읽은 알림 스타일 */
    .unread { background-color: #fff3cd; border-left: 5px solid #ffc107; } 
    
    .time { font-size: 12px; color: #888; margin-bottom: 5px; display: block; }
    .content { font-weight: bold; color: #333; }
    
    .btn-read { padding: 5px 10px; background-color: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 12px; }
    .btn-all-read { width: 100%; padding: 10px; background-color: #17a2b8; color: white; border: none; border-radius: 5px; margin-bottom: 20px; cursor: pointer; font-weight: bold; }
    .btn-home { background-color: #6c757d; float:right; margin-bottom:10px; padding:5px 10px; color:white; border:none; border-radius:3px; cursor:pointer;}
</style>
</head>
<body>
    <div class="container">
        <button class="btn-home" onclick="location.href='index.jsp'">🏠 메인으로</button>
        <h2 style="margin-top:0;">🔔 나의 알림함</h2>
        
        <button class="btn-all-read" onclick="location.href='notification_action.jsp?action=readAll'">📥 모두 읽음 처리</button>
        
        <% if (list.isEmpty()) { %>
            <div style="padding:20px; text-align:center; color:#999;">새로운 알림이 없습니다.</div>
        <% } else { 
            for (NotificationDTO n : list) {
                boolean isUnread = "N".equals(n.getIsChecked());
        %>
            <div class="notif-item <%= isUnread ? "unread" : "" %>">
                <div>
                    <span class="time"><%= n.getFormattedTime() %> [<%= n.getType() %>]</span>
                    <span class="content"><%= n.getContent() %></span>
                    <% if(n.getReportId() != null) { %>
                        <br><small style="color:#007bff;">(관련 신고 ID: <%= n.getReportId() %>)</small>
                    <% } %>
                </div>
                <% if (isUnread) { %>
                    <button class="btn-read" onclick="location.href='notification_action.jsp?action=read&id=<%= n.getNotifId() %>'">확인</button>
                <% } else { %>
                    <span style="font-size:12px; color:#aaa;">읽음</span>
                <% } %>
            </div>
        <% }} %>
    </div>
</body>
</html>