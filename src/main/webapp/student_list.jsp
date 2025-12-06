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

    String dept = request.getParameter("dept");
    List<UserDTO> list = null;

    if (dept != null && !dept.isEmpty()) {
        Connection conn = DBConnection.getConnection();
        UserDAO userDAO = new UserDAO();
        list = userDAO.getStudentsByDept(conn, dept);
        DBConnection.close(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>학과별 학생 조회</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f8f9fa; }
    .container { width: 80%; margin: 40px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    
    h2 { color: #333; margin-bottom: 20px; }
    
    .search-box { background: #e9ecef; padding: 20px; border-radius: 8px; margin-bottom: 30px; display: inline-block; }
    select { padding: 8px 15px; border-radius: 4px; border: 1px solid #ccc; font-size: 14px; }
    button { padding: 8px 20px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    button:hover { background-color: #0056b3; }
    
    .home-btn { float: right; background-color: #6c757d; padding: 5px 10px; font-size: 12px; }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { background-color: #343a40; color: white; padding: 12px; }
    td { border-bottom: 1px solid #ddd; padding: 10px; color: #333; }
    tr:hover { background-color: #f1f1f1; }
    
    .no-data { color: #888; padding: 30px; font-style: italic; }
</style>
</head>
<body>

    <div class="container">
        <button class="home-btn" onclick="location.href='index.jsp'">🏠 메인으로</button>
        <h2>👨‍🎓 학과별 학생 명단 조회</h2>
        
        <div class="search-box">
            <form action="student_list.jsp" method="get">
                <label style="font-weight:bold; margin-right:10px;">학과 선택:</label>
                <select name="dept">
                    <option value="">-- 학과를 선택하세요 --</option>
                    <option value="Computer Science" <%= "Computer Science".equals(dept)?"selected":"" %>>컴퓨터공학과 (CS)</option>
                    <option value="Electronic Eng" <%= "Electronic Eng".equals(dept)?"selected":"" %>>전자공학과 (EE)</option>
                    <option value="Mechanical Eng" <%= "Mechanical Eng".equals(dept)?"selected":"" %>>기계공학과 (ME)</option>
                    <option value="Business Admin" <%= "Business Admin".equals(dept)?"selected":"" %>>경영학과 (Biz)</option>
                    <option value="English Lit" <%= "English Lit".equals(dept)?"selected":"" %>>영문학과 (Eng)</option>
                    <option value="Physics" <%= "Physics".equals(dept)?"selected":"" %>>물리학과 (Phy)</option>
                </select>
                <button type="submit">조회하기</button>
            </form>
        </div>

        <% if (dept != null && !dept.isEmpty()) { %>
            <h3 style="text-align:left; color:#007bff;">📋 <%= dept %> 학생 목록 (<%= (list != null) ? list.size() : 0 %>명)</h3>
            
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
                    if (list != null && !list.isEmpty()) {
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
                    <tr><td colspan="5" class="no-data">해당 학과에 등록된 학생이 없습니다.</td></tr>
                <%
                    }
                %>
                </tbody>
            </table>
        <% } %>
    </div>

</body>
</html>