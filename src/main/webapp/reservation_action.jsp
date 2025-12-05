<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReservationDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 받기
    String userId = (String) session.getAttribute("userID");
    String equipId = request.getParameter("equipId");
    String startStr = request.getParameter("startTime"); // "2025-11-20T14:00" 형식
    String endStr = request.getParameter("endTime");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        ReservationDAO resDAO = new ReservationDAO();

        // 2. 날짜 변환 (HTML datetime-local -> Java Timestamp)
        startStr = startStr.replace("T", " ") + ":00"; // 초 단위 추가
        endStr = endStr.replace("T", " ") + ":00";
        
        Timestamp startTs = Timestamp.valueOf(startStr);
        Timestamp endTs = Timestamp.valueOf(endStr);

        // 3. 유효성 검사 (종료 시간이 시작 시간보다 빨라야 함)
        if (!endTs.after(startTs)) {
%>
            <script>
                alert("종료 시간이 시작 시간보다 빠를 수 없습니다.");
                history.back();
            </script>
<%
            return;
        }

        // 4. 중복 예약 확인 (Phase 3 로직 사용)
        if (resDAO.isAvailable(conn, equipId, startTs, endTs)) {
            // 5. 예약 실행
            boolean success = resDAO.addReservation(conn, userId, equipId, startTs, endTs);
            
            if (success) {
%>
                <script>
                    alert("✅ 예약이 완료되었습니다!");
                    location.href = 'index.jsp'; // 메인이나 예약확인 페이지로 이동
                </script>
<%
            } else {
%>
                <script>
                    alert("❌ DB 오류로 예약에 실패했습니다.");
                    history.back();
                </script>
<%
            }
        } else {
%>
            <script>
                alert("❌ 해당 시간에 이미 예약이 되어있습니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("오류 발생: <%= e.getMessage() %>");
            history.back();
        </script>
<%
    } finally {
        DBConnection.close(conn);
    }
%>