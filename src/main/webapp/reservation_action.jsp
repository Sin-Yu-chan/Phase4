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
    
    String action = request.getParameter("action");
    Connection conn = null;
    
    try {
        conn = DBConnection.getConnection();
        ReservationDAO resDAO = new ReservationDAO();

        // 1. 예약 취소
        if ("cancel".equals(action)) {
            String resId = request.getParameter("id");
            boolean success = resDAO.cancelReservation(conn, resId); 
            
            if(success) {
%>
                <script>
                    alert("예약이 취소되었습니다.");
                    location.href = "my_reservations.jsp";
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
        }
        
        // 2. 반납 하기 (로그로 이동)
        else if ("return".equals(action)) {
            String resId = request.getParameter("id");
            boolean success = resDAO.returnEquipment(conn, resId);
            
            if(success) {
%>
                <script>
                    alert("반납이 완료되었습니다. (사용 기록 저장됨)");
                    location.href = "my_reservations.jsp";
                </script>
<%
            } else {
%>
                <script>
                    alert("반납 처리에 실패했습니다.");
                    history.back();
                </script>
<%
            }
        }

        // 3. 예약 추가 (신규 예약)
        else {
            String equipId = request.getParameter("equipId");
            String startStr = request.getParameter("startTime");
            String endStr = request.getParameter("endTime");
            
            if (equipId != null && startStr != null && endStr != null) {
                startStr = startStr.replace("T", " ") + ":00";
                endStr = endStr.replace("T", " ") + ":00";
                Timestamp startTs = Timestamp.valueOf(startStr);
                Timestamp endTs = Timestamp.valueOf(endStr);
                
                // 3-1. 과거 날짜 예약 방지
                Timestamp now = new Timestamp(System.currentTimeMillis());
                if (startTs.before(now)) {
%>
                    <script>
                        alert("❌ 현재 시간보다 이전 시간으로 예약할 수 없습니다.");
                        history.back();
                    </script>
<%
                    return;
                }

                // 3-2. 종료 시간이 시작 시간보다 빠른지 체크
                if (!endTs.after(startTs)) {
%>
                    <script>alert("종료 시간이 시작 시간보다 빨라야 합니다.");
                    history.back();</script>
<%
                    return;
                }
        
                // 3-3. 동시성 제어 적용된 예약 실행
                String result = resDAO.makeSafeReservation(conn, userId, equipId, startTs, endTs);

                if ("success".equals(result)) {
%>
                    <script>alert("✅ 예약 완료!");
                    location.href = 'index.jsp';</script>
<%
                } else {
%>
                    <script>alert("❌ 예약 실패: <%= result %>");
                    history.back();</script>
<%
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>alert("오류 발생: <%= e.getMessage() %>");
        history.back();</script>
<%
    } finally {
        DBConnection.close(conn);
    }
%>