<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 - KNU 비품 관리</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; background-color: #f0f2f5; text-align: center; padding-top: 80px; }
    
    .login-container { width: 360px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    h2 { margin-top: 0; color: #333; margin-bottom: 20px; }
    
    .input-group { margin-bottom: 15px; text-align: left; }
    .input-group label { display: block; font-size: 13px; font-weight: bold; margin-bottom: 5px; color: #555; }
    .input-group input { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    
    .btn-submit { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 4px; font-weight: bold; font-size: 16px; cursor: pointer; margin-top: 10px; }
    .btn-submit:hover { background-color: #0056b3; }
    
    .links { margin-top: 20px; font-size: 13px; color: #666; }
    .links a { text-decoration: none; color: #007bff; margin-left: 5px; font-weight: bold; }
    
    .home-link { display: block; margin-bottom: 20px; color: #666; text-decoration: none; font-size: 14px; }
</style>
</head>
<body>

    <a href="index.jsp" class="home-link">🏠 메인 화면으로 돌아가기</a>

    <div class="login-container">
        <h2>시스템 로그인</h2>
        <form action="login_action.jsp" method="post">
            <div class="input-group">
                <label>아이디 (ID)</label>
                <input type="text" name="userID" required placeholder="학번 또는 사번">
            </div>
            <div class="input-group">
                <label>비밀번호 (Password)</label>
                <input type="password" name="userPassword" required placeholder="비밀번호">
            </div>
            <button type="submit" class="btn-submit">로그인</button>
        </form>
        
        <div class="links">
            계정이 없으신가요? <a href="register.jsp">회원가입 하기</a>
        </div>
    </div>

</body>
</html>