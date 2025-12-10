<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReservationDAO" %>
<%@ page import="Phase4.ReservationDTO" %>

<%
    String equipId = request.getParameter("equipId");
    if (equipId == null) return;

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        ReservationDAO dao = new ReservationDAO();
        List<ReservationDTO> list = dao.getFutureReservations(conn, equipId);
        
        if (list.isEmpty()) {
            out.print("<li style='color:green;'>📅 현재 예약된 일정이 없습니다. (바로 예약 가능)</li>");
        } else {
            SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
            out.print("<li style='font-weight:bold; color:#333; background:#eee;'>🚫 예약 불가능 시간대</li>");
            for (ReservationDTO r : list) {
                String range = sdf.format(r.getStartTime()) + " ~ " + sdf.format(r.getEndTime());
                out.print("<li style='color:#dc3545;'>" + range + "</li>");
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }
%>