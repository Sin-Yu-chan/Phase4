<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Phase4.UserDAO" %>
<%@ page import="Phase4.UserDTO" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="java.sql.Connection" %>

<%
    // 1. 로그인 체크
    String userId = (String) session.getAttribute("userID");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    // 2. 최신 정보 가져오기
    Connection conn = DBConnection.getConnection();
    UserDAO userDAO = new UserDAO();
    UserDTO user = userDAO.getUserById(conn, userId);
    
    // 탈퇴 방지용 관리자 수 체크
    int adminCount = 0;
    if ("Admin".equals(user.getRole())) {
        adminCount = userDAO.getAdminCount(conn);
    }
    
    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>나의 정보 관리</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; background-color: #f8f9fa; text-align: center; }
    .container { width: 600px; margin: 30px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); text-align: left; }
    
    h2 { margin-top: 0; color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
    
    .section { margin-bottom: 30px; padding: 20px; border: 1px solid #eee; border-radius: 8px; background: #fff; }
    .section h3 { margin-top: 0; font-size: 18px; color: #555; }
    
    label { display: block; font-weight: bold; margin-top: 10px; font-size: 14px; }
    input, select { width: 100%; padding: 8px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    input[readonly] { background-color: #e9ecef; color: #666; cursor: not-allowed; }
    
    button { width: 100%; padding: 10px; margin-top: 15px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; color: white; }
    .btn-update { background-color: #28a745; }
    .btn-pw { background-color: #ffc107; color: #333; }
    .btn-delete { background-color: #dc3545; }
    .home-btn { background-color: #6c757d; margin-bottom: 20px; width: auto; padding: 5px 15px; float: right; font-size: 12px; }
</style>
</head>
<body>

    <div class="container">
        <button class="home-btn" onclick="location.href='index.jsp'">🏠 메인으로</button>
        <h2>👤 나의 정보 관리 (My Info)</h2>

        <div class="section">
            <h3>📝 기본 정보 수정</h3>
            <form action="my_info_action.jsp" method="post">
                <input type="hidden" name="action" value="update_info">
                
                <label>아이디 (수정불가)</label>
                <input type="text" value="<%= user.getUserId() %>" readonly>
                
                <label>역할 (Role)</label>
                <input type="text" value="<%= user.getRole() %>" readonly>

                <label>이름</label>
                <input type="text" name="name" value="<%= user.getName() %>" required>

                <label>전화번호</label>
                <input type="text" name="phone" value="<%= user.getPhoneNumber() %>" required>

                <label>학과 (Department)</label>
                <% if ("Admin".equals(user.getRole())) { %>
                    <input type="text" name="dept" value="<%= user.getDepartment() %>" readonly title="관리자는 학과 변경 불가">
                <% } else { %>
                    <select name="dept">
                        <option value="Computer Science" <%= "Computer Science".equals(user.getDepartment())?"selected":"" %>>Computer Science</option>
                        <option value="Electronic Eng" <%= "Electronic Eng".equals(user.getDepartment())?"selected":"" %>>Electronic Eng</option>
                        <option value="Mechanical Eng" <%= "Mechanical Eng".equals(user.getDepartment())?"selected":"" %>>Mechanical Eng</option>
                        <option value="Business Admin" <%= "Business Admin".equals(user.getDepartment())?"selected":"" %>>Business Admin</option>
                        <option value="English Lit" <%= "English Lit".equals(user.getDepartment())?"selected":"" %>>English Lit</option>
                        <option value="Physics" <%= "Physics".equals(user.getDepartment())?"selected":"" %>>Physics</option>
                    </select>
                <% } %>

                <button type="submit" class="btn-update">정보 수정 저장</button>
            </form>
        </div>

        <div class="section">
            <h3>🔒 비밀번호 변경</h3>
            <form action="my_info_action.jsp" method="post">
                <input type="hidden" name="action" value="update_pw">
                
                <label>현재 비밀번호</label>
                <input type="password" name="currentPw" required placeholder="현재 사용 중인 비밀번호">
                
                <label>새 비밀번호</label>
                <input type="password" name="newPw" required placeholder="변경할 비밀번호 (4자 이상)">
                
                <button type="submit" class="btn-pw">비밀번호 변경</button>
            </form>
        </div>

        <div class="section" style="border-color: #ffcccc; background-color: #fff5f5;">
            <h3 style="color: #dc3545;">⚠️ 회원 탈퇴</h3>
            <p style="font-size:13px; color:#666;">
                탈퇴 시 모든 예약 및 활동 기록이 삭제될 수 있습니다.<br>
                <% if ("Admin".equals(user.getRole()) && adminCount <= 1) { %>
                    <b style="color:red;">(주의: 현재 마지막 관리자이므로 탈퇴가 불가능합니다.)</b>
                <% } %>
            </p>
            
            <form action="my_info_action.jsp" method="post" onsubmit="return confirm('정말로 탈퇴하시겠습니까?');">
                <input type="hidden" name="action" value="withdraw">
                <% if ("Admin".equals(user.getRole()) && adminCount <= 1) { %>
                    <button type="button" class="btn-delete" disabled style="opacity:0.5; cursor:not-allowed;">탈퇴 불가 (마지막 관리자)</button>
                <% } else { %>
                    <button type="submit" class="btn-delete">회원 탈퇴</button>
                <% } %>
            </form>
        </div>

    </div>

</body>
</html>