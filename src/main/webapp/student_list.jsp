<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.UserDAO" %>
<%@ page import="Phase4.UserDTO" %>

<%
    // 관리자 체크
    if (!"Admin".equals(session.getAttribute("userRole"))) {
        out.println("<script>alert('관리자 전용 페이지입니다.'); location.href='index.jsp';</script>");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String searchType = request.getParameter("searchType"); 
    String keyword = request.getParameter("keyword");

    List<UserDTO> list = null;
    
    // 검색 조건이 있을 때만 조회
    if (searchType != null && keyword != null && !keyword.trim().isEmpty()) {
        Connection conn = DBConnection.getConnection();
        UserDAO userDAO = new UserDAO();
        list = userDAO.searchStudents(conn, searchType, keyword.trim());
        DBConnection.close(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>학생 명단 통합 조회</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f8f9fa; }
    .container { width: 85%; margin: 40px auto; background: white; padding: 30px; border-radius: 10px;
                 box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    
    h2 { color: #333; margin-bottom: 20px; }
    
    .search-box { background: #e9ecef; padding: 20px; border-radius: 8px; margin-bottom: 30px; display: inline-block; }
    select, input { padding: 8px 12px; border-radius: 4px; border: 1px solid #ccc; font-size: 14px; margin-right: 5px; }
    button { padding: 8px 20px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    button:hover { background-color: #0056b3; }
    
    .home-btn { float: right; background-color: #6c757d; padding: 5px 10px; font-size: 12px; }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { background-color: #343a40; color: white; padding: 12px; }
    td { border-bottom: 1px solid #ddd; padding: 10px; color: #333; }
    tr:hover { background-color: #f1f1f1; }
    
    .no-data { color: #888; padding: 30px; font-style: italic; }
</style>

<script>
    // 검색 조건에 따라 입력 UI를 변경
    function updateSearchUI() {
        var type = document.getElementById("searchType").value;
        var textInput = document.getElementById("keywordInput");
        var deptSelect = document.getElementById("deptSelect");
        
        if (type === "dept") {
            // 학과 선택 시
            textInput.style.display = "none";
            textInput.disabled = true;
            
            deptSelect.style.display = "inline-block";
            deptSelect.disabled = false;
        } else {
            // 학번/이름 선택 시
            textInput.style.display = "inline-block";
            textInput.disabled = false;
            deptSelect.style.display = "none";
            deptSelect.disabled = true;
            
            if(type === "id") textInput.placeholder = "예: 2025 (학번 앞자리)";
            else if(type === "name") textInput.placeholder = "예: kim (대소문자 무시)";
        }
    }
</script>
</head>
<body onload="updateSearchUI()">

    <div class="container">
        <button class="home-btn" onclick="location.href='index.jsp'">🏠 메인으로</button>
        <h2>👨‍🎓 학생 통합 조회 시스템</h2>
        
        <div class="search-box">
            <form action="student_list.jsp" method="get">
                <label style="font-weight:bold;">검색 조건:</label>
                
                <select name="searchType" id="searchType" onchange="updateSearchUI()">
                    <option value="id" <%= "id".equals(searchType)?"selected":"" %>>학번 (Student ID)</option>
                    <option value="name" <%= "name".equals(searchType)?"selected":"" %>>이름 (Name)</option>
                    <option value="dept" <%= "dept".equals(searchType)?"selected":"" %>>학과 (Department)</option>
                </select>
                
                <input type="text" id="keywordInput" name="keyword" value="<%= (keyword!=null && !"dept".equals(searchType))?keyword:"" %>" style="width:250px;">
                
                <select id="deptSelect" name="keyword" style="display:none; width:260px;" disabled>
                    <option value="">-- 학과를 선택하세요 --</option>
                    <option value="Computer Science" <%= "Computer Science".equals(keyword)?"selected":"" %>>컴퓨터공학과 (CS)</option>
                    <option value="Electronic Eng" <%= "Electronic Eng".equals(keyword)?"selected":"" %>>전자공학과 (EE)</option>
                    <option value="Mechanical Eng" <%= "Mechanical Eng".equals(keyword)?"selected":"" %>>기계공학과 (ME)</option>
                    <option value="Business Admin" <%= "Business Admin".equals(keyword)?"selected":"" %>>경영학과 (Biz)</option>
                    <option value="English Lit" <%= "English Lit".equals(keyword)?"selected":"" %>>영문학과 (Eng)</option>
                    <option value="Physics" <%= "Physics".equals(keyword)?"selected":"" %>>물리학과 (Phy)</option>
                </select>
                
                <button type="submit">🔍 조회하기</button>
            </form>
        </div>

        <% if (list != null) { %>
            <h3 style="text-align:left; color:#007bff;">📋 검색 결과 (<%= list.size() %>명)</h3>
            
            <table>
                <thead>
                    <tr>
                        <th>학번 (ID)</th>
                        <th>이름</th>
                        <th>전화번호</th>
                        <th>학과</th>
                        <th>구분</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (!list.isEmpty()) {
                        for (UserDTO u : list) {
                %>
                    <tr>
                        <td><b><%= u.getUserId() %></b></td>
                        <td><%= u.getName() %></td>
                        <td><%= u.getPhoneNumber() %></td>
                        <td><%= u.getDepartment() %></td>
                        <td><span style="background:#e2e6ea; padding:2px 6px; border-radius:4px; font-size:12px;"><%= u.getRole() %></span></td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr><td colspan="5" class="no-data">조건에 맞는 학생이 없습니다.</td></tr>
                <%
                    }
                %>
                </tbody>
            </table>
        <% } %>
    </div>

</body>
</html>