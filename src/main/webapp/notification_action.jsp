<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.NotificationDAO" %>

<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String action = request.getParameter("action");
    String notifId = request.getParameter("id");

    Connection conn = DBConnection.getConnection();
    NotificationDAO notifDAO = new NotificationDAO();

    if ("read".equals(action)) {
        notifDAO.markAsRead(conn, notifId, userId);
    } else if ("readAll".equals(action)) {
        notifDAO.markAllAsRead(conn, userId);
    }
    
    DBConnection.close(conn);
    
    response.sendRedirect("notification_list.jsp");
%>