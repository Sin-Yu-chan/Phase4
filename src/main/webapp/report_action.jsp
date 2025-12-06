<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReportDAO" %>
<%@ page import="Phase4.NotificationDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userID");
    String action = request.getParameter("action");
    
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    Connection conn = DBConnection.getConnection();
    ReportDAO reportDAO = new ReportDAO();
    NotificationDAO notifDAO = new NotificationDAO();
    
    String msg = "처리되었습니다.";
    String nextUrl = "index.jsp";

    try {
        // 1. 신고 제출
        if ("submit".equals(action)) {
            String equipId = request.getParameter("equipId");
            String equipName = request.getParameter("equipName");
            
            String type = request.getParameter("type");
            String content = request.getParameter("content");
            String rId = "R" + (System.currentTimeMillis() % 1000000);
            
            if(reportDAO.submitReport(conn, rId, type, content, userId, equipId)) {
                msg = "신고가 접수되었습니다.";

                String notifMsg = "[" + type + "] " + equipName + " : " + content;
                
                notifDAO.sendNotificationToAdmins(conn, rId, notifMsg);
                
                nextUrl = "report.jsp";
            } else {
                msg = "신고 접수 실패.";
            }
        }
        // 2. 신고 취소
        else if ("cancel".equals(action)) {
            String reportId = request.getParameter("reportId");
            int result = reportDAO.cancelMyReport(conn, reportId, userId);
            if (result == 1) {
                msg = "신고가 취소되었습니다.";
                nextUrl = "my_reports.jsp";
            } else {
                msg = "이미 처리되었거나 존재하지 않는 신고입니다.";
                nextUrl = "my_reports.jsp";
            }
        }
    } catch(Exception e) { e.printStackTrace(); }
    finally { DBConnection.close(conn); }
%>
<script>
    alert("<%= msg %>");
    location.href = "<%= nextUrl %>";
</script>