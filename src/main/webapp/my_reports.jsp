<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReportDAO" %>
<%@ page import="Phase4.ReportDTO" %>

<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    Connection conn = DBConnection.getConnection();
    ReportDAO reportDAO = new ReportDAO();
    List<ReportDTO> list = reportDAO.getUserReports(conn, userId);
    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 신고 내역</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; padding: 20px; }
    .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 10px; border-bottom: 1px solid #eee; font-size: 14px; }
    th { background-color: #343a40; color: white; }
    .btn-cancel { background-color: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }
</style>
</head>
<body>
    <div class="container">
        <h2>📋 나의 신고 내역</h2>
        <button onclick="location.href='index.jsp'" style="background:#6c757d; color:white; border:none; padding:5px 10px; border-radius:3px; float:right;">메인으로</button>
        
        <table>
            <tr><th>날짜</th><th>위치</th><th>비품명(ID)</th><th>유형</th><th>내용</th><th>상태</th><th>관리</th></tr>
            <% 
                if(list.isEmpty()) { out.println("<tr><td colspan='7'>신고 내역이 없습니다.</td></tr>"); }
                else {
                    for(ReportDTO r : list) {
            %>
            <tr>
                <td><%= r.getFormattedTime() %></td>
                <td><%= r.getBuildingId() %>-<%= r.getClassroomNum() %></td>
                <td><%= r.getModelName() %> (<%= r.getEquipmentId() %>)</td>
                <td><%= r.getReportType() %></td>
                <td style="text-align:left;"><%= r.getContent() %></td>
                <td style="font-weight:bold; color:<%= "Pending".equals(r.getStatus())?"red":"blue" %>">
                    <%= r.getStatus() %>
                </td>
                <td>
                    <% if("Pending".equals(r.getStatus())) { %>
                        <button class="btn-cancel" onclick="if(confirm('취소하시겠습니까?')) location.href='report_action.jsp?action=cancel&reportId=<%= r.getReportId() %>'">취소</button>
                    <% } else { %>
                        <span style="color:#999; font-size:12px;">처리됨</span>
                    <% } %>
                </td>
            </tr>
            <% }} %>
        </table>
    </div>
</body>
</html>