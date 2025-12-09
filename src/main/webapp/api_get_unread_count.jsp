<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.NotificationDAO" %>
<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { out.print("-1"); return; }
    Connection conn = null;
    int count = 0;
    try {
        conn = DBConnection.getConnection();
        NotificationDAO dao = new NotificationDAO();
        count = dao.getUnreadCount(conn, userId);
    } catch(Exception e) { count = -1; } finally { DBConnection.close(conn); }
    out.print(count);
%>