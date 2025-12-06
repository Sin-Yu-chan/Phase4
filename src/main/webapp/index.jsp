<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.NotificationDAO" %>

<%
    // 로그인 정보 및 알림 개수 확인
    String userID = (String) session.getAttribute("userID");
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    
    int unreadCount = 0;
    if (userID != null) {
        Connection conn = DBConnection.getConnection();
        NotificationDAO notifDAO = new NotificationDAO();
        unreadCount = notifDAO.getUnreadCount(conn, userID);
        DBConnection.close(conn);
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>KNU 비품 관리 시스템</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; background-color: #f0f2f5; margin: 0; padding: 0; }
    
    /* 상단 헤더 */
    header { background-color: #343a40; color: white; padding: 20px; text-align: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    header h1 { margin: 0; font-size: 24px; font-weight: 600; }
    
    .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
    
    /* 사용자 정보 패널 */
    .user-panel { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .welcome-msg { font-size: 18px; color: #333; }
    .welcome-msg b { color: #007bff; }
    .btn-logout { background-color: #dc3545; color: white; border: none; padding: 8px 15px; border-radius: 5px; cursor: pointer; font-weight: bold; transition: 0.3s; }
    .btn-logout:hover { background-color: #c82333; }

    /* 대시보드 그리드 (카드 레이아웃) */
    .grid-menu { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; }
    
    /* 카드 스타일 */
    .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-align: center; transition: transform 0.2s, box-shadow 0.2s; cursor: pointer; text-decoration: none; color: #333; display: flex; flex-direction: column; justify-content: center; height: 120px; border: 1px solid #eee; }
    .card:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.1); border-color: #007bff; }
    
    .card-icon { font-size: 32px; margin-bottom: 10px; }
    .card-title { font-size: 16px; font-weight: bold; }
    
    /* 알림 배지 */
    .badge-count { background-color: #dc3545; color: white; padding: 2px 8px; border-radius: 12px; font-size: 12px; position: absolute; top: 15px; right: 15px; }
    .card { position: relative; } /* 배지 위치용 */

    /* 로그인 전 화면 스타일 */
    .login-box { background: white; width: 400px; margin: 100px auto; padding: 40px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); text-align: center; }
    .btn-login { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; margin-bottom: 10px; }
    .btn-register { width: 100%; padding: 12px; background-color: #28a745; color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; }
</style>
</head>
<body>

    <header>
        <h1>🏫 대학교 비품 관리 시스템</h1>
    </header>

    <% if (userID == null) { %>
        <div class="login-box">
            <h2 style="margin-top:0;">환영합니다!</h2>
            <p style="color:#666; margin-bottom:30px;">서비스 이용을 위해 로그인해주세요.</p>
            <button class="btn-login" onclick="location.href='login.jsp'">로그인</button>
            <button class="btn-register" onclick="location.href='register.jsp'">회원가입</button>
        </div>
    <% } else { %>
        <div class="container">
            <div class="user-panel">
                <div class="welcome-msg">
                    👋 안녕하세요, <b><%= userName %></b>님 (<%= userRole %>)
                </div>
                <button class="btn-logout" onclick="location.href='logout_action.jsp'">로그아웃</button>
            </div>

            <% if ("Admin".equals(userRole)) { %>
                <h3 style="color:#555;">🔧 관리자 대시보드</h3>
                <div class="grid-menu">
                    <a href="inventory_search.jsp" class="card">
                        <div class="card-icon">🔎</div>
                        <div class="card-title">재고 통합 검색</div>
                    </a>
                    <a href="manage_reports.jsp" class="card">
                        <div class="card-icon">🚨</div>
                        <div class="card-title">신고 내역 관리</div>
                    </a>
                    <a href="search_logs.jsp" class="card">
                        <div class="card-icon">📜</div>
                        <div class="card-title">사용 로그 검색</div>
                    </a>
                    <a href="statistics.jsp" class="card">
                        <div class="card-icon">📊</div>
                        <div class="card-title">통계 데이터</div>
                    </a>
                    <a href="student_list.jsp" class="card">
                        <div class="card-icon">🎓</div>
                        <div class="card-title">학과별 학생 조회</div>
                    </a>
                    <a href="manage_stock.jsp" class="card">
                        <div class="card-icon">📦</div>
                        <div class="card-title">비품 자재 관리</div>
                    </a>
                    <a href="notification_list.jsp" class="card" style="border-color:#ffc107;">
                        <div class="card-icon">🔔</div>
                        <div class="card-title">알림 확인</div>
                        <% if(unreadCount > 0) { %>
                            <span class="badge-count"><%= unreadCount %>건</span>
                        <% } %>
                    </a>
                    <a href="my_info.jsp" class="card">
                        <div class="card-icon">👤</div>
                        <div class="card-title">나의 정보</div>
                    </a>
                </div>
            <% } else { %>
                <h3 style="color:#555;">🙋‍♂️ 사용자 서비스</h3>
                <div class="grid-menu">
                    <a href="reservation.jsp" class="card">
                        <div class="card-icon">📅</div>
                        <div class="card-title">비품 예약</div>
                    </a>
                    <a href="my_reservations.jsp" class="card">
                        <div class="card-icon">✅</div>
                        <div class="card-title">예약 확인/취소</div>
                    </a>
                    <a href="report.jsp" class="card">
                        <div class="card-icon">📢</div>
                        <div class="card-title">고장/부족 신고</div>
                    </a>
                    <a href="my_reports.jsp" class="card">
                        <div class="card-icon">📋</div>
                        <div class="card-title">나의 신고 내역</div>
                    </a>
                    <a href="notification_list.jsp" class="card" style="border-color:#ffc107;">
                        <div class="card-icon">🔔</div>
                        <div class="card-title">나의 알림</div>
                        <% if(unreadCount > 0) { %>
                            <span class="badge-count"><%= unreadCount %>건</span>
                        <% } %>
                    </a>
                    <a href="my_info.jsp" class="card">
                        <div class="card-icon">👤</div>
                        <div class="card-title">나의 정보</div>
                    </a>
                </div>
            <% } %>
        </div>
    <% } %>

</body>
</html>