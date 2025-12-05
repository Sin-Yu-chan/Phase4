<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReportDAO" %>
<%@ page import="Phase4.ReportDTO" %>

<%
    // 1. 관리자 권한 체크
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"Admin".equals(userRole)) {
        out.println("<script>alert('관리자 전용 페이지입니다.'); location.href='index.jsp';</script>");
        return;
    }

    // 2. 모든 데이터 가져오기
    Connection conn = null;
    List<ReportDTO> list = null;
    try {
        conn = DBConnection.getConnection();
        ReportDAO reportDAO = new ReportDAO();
        list = reportDAO.getAllReports(conn);
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        DBConnection.close(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>처리 완료 내역 (History)</title>
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; background-color: #f4f6f9; }
    
    h2 { margin-top: 40px; color: #28a745; } /* 초록색 테마 */
    
    .container { width: 95%; margin: 20px auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border-bottom: 1px solid #ddd; padding: 12px; font-size: 14px; vertical-align: middle; }
    th { background-color: #28a745; color: white; text-align: center; } /* 헤더 초록색 */
    
    tr:hover { background-color: #f1f1f1; }
    
    .status-badge { padding: 5px 10px; border-radius: 15px; font-weight: bold; font-size: 12px; color: white; display: inline-block; }
    .badge-completed { background-color: #28a745; }
    .badge-rejected { background-color: #6c757d; } /* 회색 */

    .btn-back { padding: 10px 20px; background-color: #343a40; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: bold; margin-bottom: 20px; }
    .btn-back:hover { background-color: #23272b; }
</style>
</head>
<body>

    <br>
    <div style="text-align: left; width: 95%; margin: 0 auto;">
        <button class="btn-back" onclick="location.href='manage_reports.jsp'">⬅️ 대시보드로 돌아가기</button>
    </div>

    <div class="container">
        <h2>✅ 처리 완료 및 반려 내역 (History)</h2>
        <p style="color: gray;">이곳은 처리가 끝난 신고 내역이 영구 보관되는 장소입니다.</p>
        
        <table>
            <thead>
                <tr>
                    <th style="width: 10%;">처리 일시 (접수)</th>
                    <th style="width: 10%;">위치</th>
                    <th style="width: 15%;">비품 정보 (ID)</th>
                    <th>신고 내용</th>
                    <th style="width: 10%;">작성자</th>
                    <th style="width: 10%;">최종 상태</th>
                </tr>
            </thead>
            <tbody>
            <%
                boolean hasHistory = false;
                if (list != null) {
                    for (ReportDTO r : list) {
                        // 필터링: Completed(완료) 또는 Rejected(반려)인 것만 표시
                        if ("Completed".equals(r.getStatus()) || "Rejected".equals(r.getStatus())) {
                            hasHistory = true;
                            String badgeClass = "Completed".equals(r.getStatus()) ? "badge-completed" : "badge-rejected";
                            String statusText = "Completed".equals(r.getStatus()) ? "처리 완료" : "반려됨";
            %>
                <tr>
                    <td><%= r.getFormattedTime() %></td>
                    <td><%= r.getBuildingId() %>-<%= r.getClassroomNum() %></td>
                    
                    <td style="text-align: left; padding-left: 20px;">
                        <strong><%= r.getModelName() %></strong><br>
                        <span style="color: #888; font-size: 12px;"><%= r.getEquipmentId() %></span>
                    </td>
                    
                    <td style="text-align: left;"><%= r.getContent() %></td>
                    <td><%= r.getUserId() %></td>
                    
                    <td>
                        <span class="status-badge <%= badgeClass %>"><%= statusText %></span>
                    </td>
                </tr>
            <%
                        }
                    }
                }
                
                if (!hasHistory) {
            %>
                <tr><td colspan="6" style="padding: 40px; color: #999;">보관된 처리 내역이 없습니다.</td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

</body>
</html>