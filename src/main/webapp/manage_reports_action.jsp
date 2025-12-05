<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReportDAO" %>
<%@ page import="Phase4.EquipmentDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    // 관리자 체크
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"Admin".equals(userRole)) return;

    String reportId = request.getParameter("reportId");
    String newStatus = request.getParameter("newStatus");
    String equipId = request.getParameter("equipId");

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        ReportDAO reportDAO = new ReportDAO();
        EquipmentDAO equipDAO = new EquipmentDAO();

        // 1. 상태 변경 실행
        boolean result = reportDAO.updateReportStatus(conn, reportId, newStatus);

        if (result) {
            // 2. 'Completed'인 경우 비품 상태도 'Normal'로 자동 복구
            if ("Completed".equals(newStatus)) {
                equipDAO.updateEquipmentStatus(conn, equipId, "Normal");
            }
            
            // ★ [수정됨] 알림창(alert) 없이 바로 대시보드로 이동! (새로고침 효과)
            response.sendRedirect("manage_reports.jsp");
            
        } else {
            // 실패했을 때만 알림창 띄움
%>
            <script>
                alert("상태 변경에 실패했습니다.");
                history.back();
            </script>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }
%>