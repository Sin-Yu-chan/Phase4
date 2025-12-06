<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.UserDAO" %>
<%@ page import="Phase4.UserDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String role = request.getParameter("role");
    String dept = request.getParameter("dept");
    String id = request.getParameter("id");
    String pw = request.getParameter("pw");
    String name = request.getParameter("name");
    String phone = request.getParameter("phone");
    String adminCode = request.getParameter("adminCode"); // 인증코드
    
    final String ADMIN_SECRET_KEY = "KNU2025"; 

    String msg = "";
    String url = "";
    boolean isValid = true;

    // 1. 관리자 인증 코드 확인
    if ("Admin".equals(role)) {
        dept = "Administration"; // 학과 강제 고정
        if (adminCode == null || !adminCode.equals(ADMIN_SECRET_KEY)) {
            msg = "❌ 관리자 승인 코드가 일치하지 않습니다. (가입 거부)";
            url = "register.jsp";
            isValid = false;
        }
    }

    if (isValid) {
        Connection conn = DBConnection.getConnection();
        UserDAO userDAO = new UserDAO();

        // 2. 중복 검사
        if (userDAO.isIdExists(conn, id)) {
            msg = "이미 존재하는 아이디입니다.";
            url = "register.jsp";
        } else if (userDAO.isPhoneExists(conn, phone)) {
            msg = "이미 존재하는 전화번호입니다.";
            url = "register.jsp";
        } else {
            // 3. 가입 진행
            UserDTO newUser = new UserDTO(id, name, role, dept, phone, pw);
            boolean success = userDAO.signUp(conn, newUser);
            
            if (success) {
                msg = "회원가입이 완료되었습니다! 로그인해주세요.";
                url = "login.jsp";
            } else {
                msg = "회원가입 실패 (DB 오류).";
                url = "register.jsp";
            }
        }
        DBConnection.close(conn);
    }
%>

<script>
    alert("<%= msg %>");
    location.href = "<%= url %>";
</script>