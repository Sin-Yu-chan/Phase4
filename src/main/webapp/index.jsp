<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대학교 비품 관리 시스템</title>
</head>
<body>
    <div align="center">
        <h1>🏫 대학교 비품 관리 시스템</h1>

        <%
            //로그인 정보 가져오기
            String userID = (String) session.getAttribute("userID");
            String userName = (String) session.getAttribute("userName");
            String userRole = (String) session.getAttribute("userRole");

            if (userID == null) {
                // 1. 로그인 안 된 상태
        %>
                <h3>로그인이 필요합니다.</h3>
                <a href="login.jsp"><button>로그인</button></a>
                <a href="register.jsp"><button>회원가입</button></a>
        <%
            } else {
                // 2. 로그인 된 상태
        %>
                <h3>[<%= userName %>]님 환영합니다. (<%= userRole %>)</h3>
                <button onclick="location.href='logout_action.jsp'">로그아웃</button>
                <hr>
                
                <%
                    if ("Admin".equals(userRole)) {
                %>
                    <h3>[관리자 기능]</h3>
                    <ul>
                        <li><a href="inventory_search.jsp">1. 재고 통합 검색</a></li>
                        <li><a href="manage_reports.jsp">2. 신고 내역 관리</a></li>
                        <li><a href="search_logs.jsp">3. 대여비품 사용 로그 검색</a></li>
                        <li><a href="#">4. 통계 데이터 확인</a></li>
                        <li><a href="#">5. 학과별 학생 조회</a></li>
                        <li><a href="#">6. 나의 알림 확인</a></li>
                        <li><a href="#">7. 나의 정보 관리</a></li>
                        <li><a href="#">8. 비품 자재 관리</a></li>
                    </ul>
                <%
                    } else {
                %>
                    <h3>[사용자 기능]</h3>
                    <ul>
                        <li><a href="reservation.jsp">1. 비품 예약 (대여 센터)</a></li>
                        <li><a href="#">2. 나의 예약 확인/취소</a></li>
                        <li><a href="#">3. 고장/부족 신고 하기</a></li>
                        <li><a href="#">4. 나의 신고 내역 확인</a></li>
                        <li><a href="#">5. 나의 정보 관리</a></li>
                    </ul>
                <%
                    }
                %>
        <%
            }
        %>
    </div>
</body>
</html>