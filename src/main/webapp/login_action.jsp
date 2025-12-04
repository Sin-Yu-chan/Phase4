<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Phase4.UserDAO" %>
<%@ page import="Phase4.UserDTO" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.PrintWriter" %>

<%
    // 1. 인코딩 및 파라미터 받기
    request.setCharacterEncoding("UTF-8");
    String userID = request.getParameter("userID");
    String userPassword = request.getParameter("userPassword");

    // 2. DB 연결 (Main.java의 conn = DBConnection.getConnection(); 부분)
    Connection conn = DBConnection.getConnection();
    
    // 3. DAO 생성 및 로그인 시도
    UserDAO userDAO = new UserDAO();
    UserDTO user = userDAO.login(conn, userID, userPassword);

    if (user != null) { // 로그인 성공 (DTO가 반환됨)
        
        // 4. 세션에 중요 정보 저장
        session.setAttribute("userID", user.getUserId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("userRole", user.getRole()); // Admin인지 확인용
        
        DBConnection.close(conn);

        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("location.href = 'index.jsp'");
        script.println("</script>");
        
    } else {
        
        DBConnection.close(conn);
        
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('로그인 실패. 아이디 또는 비밀번호를 확인하세요.');");
        script.println("history.back();");
        script.println("</script>");
    }
%>