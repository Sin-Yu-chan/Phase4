<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.ReportDAO" %>
<%@ page import="Phase4.ReportDTO" %>

<%
    // 1. 관리자 권한 체크
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"Admin".equals(userRole)) {
        out.println("<script>location.href='index.jsp';</script>");
        return;
    }

    Connection conn = null;
    List<ReportDTO> newReports = new ArrayList<>();      // 왼쪽: 신규 (Pending)
    List<ReportDTO> inProgressReports = new ArrayList<>(); // 오른쪽: 처리중 (Processing)
    
    try {
        conn = DBConnection.getConnection();
        ReportDAO reportDAO = new ReportDAO();
        List<ReportDTO> allList = reportDAO.getAllReports(conn);
        
        for (ReportDTO r : allList) {
            if ("Pending".equals(r.getStatus())) {
                newReports.add(r);
            } else if ("Processing".equals(r.getStatus())) {
                inProgressReports.add(r);
            }
        }
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
<title>관리자 신고 대시보드</title>
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f4f6f9; }
    
    /* 상단 헤더 */
    .header { background-color: #343a40; color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
    .header h2 { margin: 0; font-size: 24px; }
    .header-btns button { padding: 8px 15px; margin-left: 10px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    .btn-home { background-color: #6c757d; color: white; }
    .btn-history { background-color: #28a745; color: white; } /* 초록색 */

    /* 메인 컨테이너 (좌우 분할) */
    .container { display: flex; padding: 20px; gap: 20px; height: calc(100vh - 80px); }
    
    .panel { flex: 1; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: flex; flex-direction: column; }
    .panel-header { padding: 15px; border-bottom: 2px solid #ddd; font-weight: bold; font-size: 18px; }
    
    /* 왼쪽 패널 스타일 */
    .left-panel { border-top: 5px solid #dc3545; } /* 빨간색 띠 */
    .left-title { color: #dc3545; }
    
    /* 오른쪽 패널 스타일 */
    .right-panel { border-top: 5px solid #007bff; } /* 파란색 띠 */
    .right-title { color: #007bff; }

    /* 리스트 영역 (스크롤 가능) */
    .list-area { flex: 1; overflow-y: auto; padding: 10px; background-color: #f8f9fa; }

    /* 카드 스타일 */
    .report-card { background: white; border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 15px; border-left: 4px solid gray; transition: transform 0.2s; }
    .report-card:hover { transform: translateY(-2px); box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .card-left { border-left-color: #dc3545; }
    .card-right { border-left-color: #007bff; }

    .card-header { display: flex; justify-content: space-between; font-size: 12px; color: #666; margin-bottom: 5px; }
    .card-title { font-weight: bold; font-size: 16px; margin-bottom: 5px; }
    .card-content { font-size: 14px; margin-bottom: 10px; color: #333; }
    .card-footer { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #eee; padding-top: 10px; }

    /* 버튼들 */
    .btn-confirm { background-color: #17a2b8; color: white; padding: 5px 10px; border: none; border-radius: 3px; cursor: pointer; }
    .btn-complete { background-color: #007bff; color: white; padding: 5px 10px; border: none; border-radius: 3px; cursor: pointer; }
    .btn-reject { background-color: #dc3545; color: white; padding: 5px 10px; border: none; border-radius: 3px; cursor: pointer; }
</style>
</head>
<body>

    <div class="header">
        <h2>🚨 신고 처리 대시보드</h2>
        <div class="header-btns">
            <button class="btn-history" onclick="location.href='report_history.jsp'">📂 처리 완료 내역 보기</button>
            <button class="btn-home" onclick="location.href='index.jsp'">🏠 메인으로</button>
        </div>
    </div>

    <div class="container">
        <div class="panel left-panel">
            <div class="panel-header left-title">
                🔥 신규 접수 (<%= newReports.size() %>건)
            </div>
            <div class="list-area">
                <% if (newReports.isEmpty()) { %>
                    <div style="text-align:center; padding:20px; color:#999;">신규 신고가 없습니다.</div>
                <% } else { 
                    for (ReportDTO r : newReports) { %>
                    <div class="report-card card-left">
                        <div class="card-header">
                            <span><%= r.getFormattedTime() %></span>
                            <span><%= r.getBuildingId() %>-<%= r.getClassroomNum() %></span>
                        </div>
                        <div class="card-title">
                            <%= r.getModelName() %> <span style="font-size:0.8em; color:gray;">(<%= r.getReportType() %>)</span>
                        </div>
                        <div class="card-content">
                            "<%= r.getContent() %>"<br>
                            <small>작성자: <%= r.getUserId() %></small>
                        </div>
                        <div class="card-footer">
                            <span style="color:#dc3545; font-weight:bold;">대기중</span>
                            <form action="manage_reports_action.jsp" method="post" style="margin:0;">
                                <input type="hidden" name="reportId" value="<%= r.getReportId() %>">
                                <input type="hidden" name="newStatus" value="Processing">
                                <button type="submit" class="btn-confirm">접수 확인 (이동 ➡️)</button>
                            </form>
                        </div>
                    </div>
                <% }} %>
            </div>
        </div>

        <div class="panel right-panel">
            <div class="panel-header right-title">
                🛠️ 처리 / 수리 중 (<%= inProgressReports.size() %>건)
            </div>
            <div class="list-area">
                <% if (inProgressReports.isEmpty()) { %>
                    <div style="text-align:center; padding:20px; color:#999;">처리 중인 내역이 없습니다.</div>
                <% } else { 
                    for (ReportDTO r : inProgressReports) { %>
                    <div class="report-card card-right">
                        <div class="card-header">
                            <span>ID: <%= r.getReportId() %></span>
                            <span><%= r.getBuildingId() %>-<%= r.getClassroomNum() %></span>
                        </div>
                        <div class="card-title">
                            <%= r.getModelName() %>
                        </div>
                        <div class="card-content">
                            "<%= r.getContent() %>"<br>
                            <small style="color:#555;">작성자: <%= r.getUserId() %></small>
                        </div>
                        <div class="card-footer">
                            <span style="color:#007bff; font-weight:bold; margin-right:10px;">처리중...</span>
                            
                            <form action="manage_reports_action.jsp" method="post" style="margin:0; display:flex; gap:5px;">
                                <input type="hidden" name="reportId" value="<%= r.getReportId() %>">
                                <input type="hidden" name="equipId" value="<%= r.getEquipmentId() %>">
                                
                                <button type="submit" name="newStatus" value="Completed" class="btn-complete" title="수리 완료 및 비품 정상화">
                                    ✅ 완료
                                </button>
                                <button type="submit" name="newStatus" value="Rejected" class="btn-reject" title="신고 거절">
                                    🚫 반려
                                </button>
                            </form>
                        </div>
                    </div>
                <% }} %>
            </div>
        </div>
    </div>

</body>
</html>