<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대학교 비품 관리 시스템 - 로그인</title>
<style>
    body { font-family: sans-serif; display: flex; justify-content: center; padding-top: 100px; background-color: #f0f2f5; }
    .login-container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 300px; text-align: center; }
    input { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; }
    button { width: 95%; padding: 10px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
    button:hover { background-color: #0056b3; }
</style>
</head>
<body>

<div class="login-container">
    <h2>시스템 로그인</h2>
    
    <form action="login_action.jsp" method="post">
        <input type="text" name="userID" placeholder="아이디" required>
        <input type="password" name="userPassword" placeholder="비밀번호" required>
        <button type="submit">로그인</button>
    </form>
    
    <div style="margin-top: 15px; font-size: 14px;">
        <a href="register.jsp">회원가입</a>
    </div>
</div>

</body>
</html>