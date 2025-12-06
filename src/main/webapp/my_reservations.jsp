<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReservationDAO" %>
<%@ page import="Phase4.ReservationDTO" %>

<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    Connection conn = DBConnection.getConnection();
    ReservationDAO resDAO = new ReservationDAO();
    List<ReservationDTO> list = resDAO.getMyReservations(conn, userId);
    DBConnection.close(conn);
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 예약 확인</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; padding: 20px; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 10px; border-bottom: 1px solid #eee; font-size: 14px; }
    th { background-color: #007bff; color: white; }
    .btn-cancel { background-color: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }
</style>
</head>
<body>
    <div class="container">
        <h2>📅 나의 예약 내역</h2>
        <button onclick="location.href='index.jsp'" style="background:#6c757d; color:white; border:none; padding:5px 10px; border-radius:3px; float:right;">메인으로</button>
        
        <table>
            <tr><th>예약ID</th><th>비품명</th><th>모델명</th><th>사용 시간</th><th>관리</th></tr>
            <% 
                if(list.isEmpty()) { out.println("<tr><td colspan='5'>예약 내역이 없습니다.</td></tr>"); }
                else {
                    for(ReservationDTO r : list) {
                        String timeStr = sdf.format(r.getStartTime()) + " ~ " + sdf.format(r.getEndTime()).substring(11);
            %>
            <tr>
                <td><%= r.getReservationId() %></td>
                <td><%= r.getEquipmentName() %></td>
                <td><%= r.getModelName() %></td>
                <td><%= timeStr %></td>
                <td>
                    <button class="btn-cancel" onclick="if(confirm('예약을 취소하시겠습니까?')) location.href='reservation_action.jsp?action=cancel&id=<%= r.getReservationId() %>'">취소</button>
                </td>
            </tr>
            <% }} %>
        </table>
    </div>
</body>
</html>