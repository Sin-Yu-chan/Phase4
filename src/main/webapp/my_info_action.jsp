<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.UserDAO" %>
<%@ page import="Phase4.UserDTO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String action = request.getParameter("action");
    Connection conn = DBConnection.getConnection();
    UserDAO userDAO = new UserDAO();
    UserDTO currentUser = userDAO.getUserById(conn, userId);
    
    String msg = "";
    String nextUrl = "my_info.jsp";

    try {
        // 1. 정보 수정 (이름, 전화번호, 학과)
        if ("update_info".equals(action)) {
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String dept = request.getParameter("dept");
            
            if(userDAO.updateUserInfo(conn, userId, name, dept, phone)) {
                msg = "정보가 수정되었습니다.";
                session.setAttribute("userName", name); // 세션 이름 갱신
            } else {
                msg = "수정 실패. (전화번호 중복 등)";
            }
        }
        
        // 2. 비밀번호 변경
        else if ("update_pw".equals(action)) {
            String currentPw = request.getParameter("currentPw");
            String newPw = request.getParameter("newPw");
            
            if (currentUser != null && currentUser.getPassword().equals(currentPw)) {
                if (newPw.length() >= 4) {
                    if(userDAO.updatePassword(conn, userId, newPw)) {
                        msg = "비밀번호가 변경되었습니다. 다시 로그인해주세요.";
                        session.invalidate();
                        nextUrl = "login.jsp";
                    } else {
                        msg = "변경 실패 (DB 오류).";
                    }
                } else {
                    msg = "새 비밀번호는 4자 이상이어야 합니다.";
                }
            } else {
                msg = "현재 비밀번호가 일치하지 않습니다.";
            }
        }
        
        // 3. 회원 탈퇴
        else if ("withdraw".equals(action)) {
            boolean canDelete = true;
            if ("Admin".equals(currentUser.getRole())) {
                if (userDAO.getAdminCount(conn) <= 1) canDelete = false;
            }
            
            if (canDelete) {
                if (userDAO.deleteUser(conn, userId)) {
                    msg = "탈퇴되었습니다.";
                    session.invalidate();
                    nextUrl = "login.jsp";
                } else {
                    msg = "탈퇴 처리 실패.";
                }
            } else {
                msg = "마지막 관리자는 탈퇴할 수 없습니다.";
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
        msg = "오류 발생: " + e.getMessage();
    } finally {
        DBConnection.close(conn);
    }
%>

<script>
    alert("<%= msg %>");
    location.href = "<%= nextUrl %>";
</script>