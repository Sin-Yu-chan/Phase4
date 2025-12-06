<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReservationDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userID");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    //동작 구분 (null이면 예약 추가, cancel이면 취소)
    String action = request.getParameter("action");

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        ReservationDAO resDAO = new ReservationDAO();

        // 1.예약 취소 로직
        if ("cancel".equals(action)) {
            String resId = request.getParameter("id");
            boolean success = resDAO.cancelReservation(conn, resId); 
            
            if(success) {
%>
                <script>
                    alert("예약이 취소되었습니다.");
                    location.href = "my_reservations.jsp"; // 목록으로 복귀
                </script>
<%
            } else {
%>
                <script>
                    alert("취소 실패. 이미 지난 예약이거나 오류가 발생했습니다.");
                    history.back();
                </script>
<%
            }
            return;
        }

        // 2. 예약 추가 로직
        String equipId = request.getParameter("equipId");
        String startStr = request.getParameter("startTime");
        String endStr = request.getParameter("endTime");
        
        // 날짜 처리 및 중복 확인 로직
        if (equipId != null && startStr != null && endStr != null) {
            startStr = startStr.replace("T", " ") + ":00";
            endStr = endStr.replace("T", " ") + ":00";
            Timestamp startTs = Timestamp.valueOf(startStr);
            Timestamp endTs = Timestamp.valueOf(endStr);
    
            if (!endTs.after(startTs)) {
%>
                <script>alert("종료 시간이 시작 시간보다 빨라야 합니다."); history.back();</script>
<%
                return;
            }
    
            if (resDAO.isAvailable(conn, equipId, startTs, endTs)) {
                if (resDAO.addReservation(conn, userId, equipId, startTs, endTs)) {
%>
                    <script>alert("✅ 예약 완료!"); location.href = 'index.jsp';</script>
<%
                } else {
%>
                    <script>alert("❌ DB 오류."); history.back();</script>
<%
                }
            } else {
%>
                <script>alert("❌ 이미 예약된 시간입니다."); history.back();</script>
<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>alert("오류 발생: <%= e.getMessage() %>"); history.back();</script>
<%
    } finally {
        DBConnection.close(conn);
    }
%>