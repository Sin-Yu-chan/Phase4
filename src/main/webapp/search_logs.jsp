<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.UsageLogDAO" %>
<%@ page import="Phase4.UsageLogDTO" %>

<%
    // 1. 관리자 권한 체크
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"Admin".equals(userRole)) {
        out.println("<script>alert('관리자 전용입니다.'); location.href='index.jsp';</script>");
        return;
    }

    // 2. 검색 파라미터 처리
    request.setCharacterEncoding("UTF-8");
    String searchType = request.getParameter("searchType");
    String keyword = request.getParameter("keyword");

    Connection conn = null;
    List<UsageLogDTO> list = null;

    try {
        conn = DBConnection.getConnection();
        UsageLogDAO logDAO = new UsageLogDAO();

        if (keyword == null || keyword.trim().isEmpty()) {
            list = logDAO.getAllLogs(conn);
        } else if ("user".equals(searchType)) {
            list = logDAO.getLogsByUser(conn, keyword);
        } else if ("equip".equals(searchType)) {
            list = logDAO.getLogsByEquipment(conn, keyword);
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
<title>대여비품 사용 로그 검색</title>
<style>
    body { font-family: sans-serif; text-align: center; background-color: #f8f9fa; }
    .container { width: 90%; margin: 30px auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    
    h2 { color: #6610f2; }
    
    .search-bar { margin-bottom: 20px; padding: 15px; background: #e9ecef; border-radius: 5px; display: inline-block; }
    select, input[type=text] { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    button { padding: 8px 15px; background-color: #6610f2; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    button:hover { background-color: #520dc2; }
    .btn-reset { background-color: #6c757d; }
    .btn-reset:hover { background-color: #5a6268; }

    /* 테이블 스타일 */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border-bottom: 1px solid #ddd; padding: 12px; font-size: 14px; }
    th { background-color: #343a40; color: white; }
    tr:hover { background-color: #f1f1f1; }
</style>
</head>
<body>

    <div class="container">
        <h2>📜 대여비품 사용 로그 (System Usage Logs)</h2>
        <button onclick="location.href='index.jsp'" style="background:#6c757d; margin-bottom:10px;">🏠 메인으로</button>
        
        <div class="search-bar">
            <form action="search_logs.jsp" method="get">
                <select name="searchType">
                    <option value="user" <%= "user".equals(searchType)?"selected":"" %>>사용자 ID 검색</option>
                    <option value="equip" <%= "equip".equals(searchType)?"selected":"" %>>비품 ID 검색</option>
                </select>
                <input type="text" name="keyword" value="<%= keyword!=null?keyword:"" %>" placeholder="검색어 입력...">
                <button type="submit">🔍 검색</button>
                <button type="button" class="btn-reset" onclick="location.href='search_logs.jsp'">초기화</button>
            </form>
        </div>

        <table>
            <thead>
                <tr>
                    <th>로그 ID</th>
                    <th>사용 시작</th>
                    <th>사용 종료</th>
                    <th>사용자 (이름)</th>
                    <th>비품 정보 (모델명)</th>
                </tr>
            </thead>
            <tbody>
            <%
                if (list != null && !list.isEmpty()) {
                    for (UsageLogDTO l : list) {
            %>
                <tr>
                    <td><%= l.getLogId() %></td>
                    <td><%= l.getFormattedStartTime() %></td>
                    <td><%= l.getFormattedEndTime() %></td>
                    
                    <td>
                        <%= l.getUserId() %><br>
                        <span style="font-size:0.85em; color:gray;">(<%= l.getUserName() %>)</span>
                    </td>
                    
                    <td style="color:#0056b3; font-weight:bold;">
                        <%= l.getEquipmentId() %><br>
                        <span style="font-size:0.85em; color:gray; font-weight:normal;"><%= l.getModelName() %></span>
                    </td>
                </tr>
            <%
                    }
                } else {
            %>
                <tr><td colspan="5" style="padding:30px; color:#999;">검색된 로그 데이터가 없습니다.</td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

</body>
</html>