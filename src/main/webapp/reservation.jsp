<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.EquipmentDAO" %>
<%@ page import="Phase4.EquipmentDTO" %>

<%
    // 1. 로그인 체크
    String userId = (String) session.getAttribute("userID");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    // 2. 비품 목록 가져오기
    Connection conn = DBConnection.getConnection();
    EquipmentDAO equipDAO = new EquipmentDAO();
    // Phase 3와 동일하게 'RENTAL_B' 건물의 물건만 대여 가능하다고 가정
    List<EquipmentDTO> list = equipDAO.searchByBuilding(conn, "RENTAL_B");
    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비품 예약 센터</title>
<style>
    body { font-family: sans-serif; text-align: center; }
    .container { width: 95%; margin: 20px auto; display: flex; gap: 20px; }
    
    /* 왼쪽: 예약 폼 */
    .form-section { flex: 1; background: #f8f9fa; padding: 20px; border-radius: 10px; height: fit-content; text-align: left; }
    input, button { width: 100%; padding: 10px; margin: 5px 0; box-sizing: border-box; }
    button { background-color: #007bff; color: white; border: none; cursor: pointer; font-weight: bold; }
    button:hover { background-color: #0056b3; }

    /* 예약 현황 리스트 스타일 */
    .schedule-box { margin-top: 20px; background: white; border: 1px solid #ddd; border-radius: 5px; padding: 10px; }
    .schedule-box h4 { margin: 0 0 10px 0; font-size: 14px; border-bottom: 1px solid #eee; padding-bottom: 5px; }
    #scheduleList { list-style: none; padding: 0; margin: 0; font-size: 13px; max-height: 200px; overflow-y: auto; }
    #scheduleList li { padding: 5px; border-bottom: 1px solid #f1f1f1; }

    /* 오른쪽: 비품 리스트 */
    .list-section { flex: 2; height: 600px; overflow-y: auto; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 10px; font-size: 14px; }
    th { background-color: #343a40; color: white; position: sticky; top: 0; }
    tr:hover { background-color: #f1f1f1; cursor: pointer; } 
</style>

<script>
    // 테이블의 행(Row)을 클릭하면 실행되는 함수
    function selectItem(id, name) {
        // 1. 입력창 값 채우기
        document.getElementById("equipId").value = id;
        document.getElementById("equipNameDisplay").value = name;
        
        // 2. 예약 현황 가져오기 (AJAX)
        fetch("api_reservations.jsp?equipId=" + id)
            .then(response => response.text())
            .then(html => {
                document.getElementById("scheduleList").innerHTML = html;
            })
            .catch(error => {
                console.error("Error fetching schedule:", error);
                document.getElementById("scheduleList").innerHTML = "<li style='color:red;'>일정 로딩 실패</li>";
            });
    }
</script>
</head>
<body>

<h2>📅 비품 대여 예약 센터</h2>
<button onclick="location.href='index.jsp'" style="width: 200px; background: gray;">메인으로</button>
<hr>

<div class="container">
    <div class="form-section">
        <h3>예약 정보 입력</h3>
        <form action="reservation_action.jsp" method="post">
            <label>선택한 비품:</label>
            <input type="text" id="equipNameDisplay" placeholder="오른쪽 목록에서 클릭하세요" readonly style="background: #e9ecef;">
            <input type="hidden" id="equipId" name="equipId" required> 
            
            <label>시작 시간:</label>
            <input type="datetime-local" name="startTime" required>

            <label>종료 시간:</label>
            <input type="datetime-local" name="endTime" required>

            <button type="submit">예약 신청하기</button>
        </form>

        <div class="schedule-box">
            <h4>📅 해당 비품 예약 현황</h4>
            <ul id="scheduleList">
                <li style="color:#999;">비품을 선택하면 예약된 일정이 표시됩니다.</li>
            </ul>
        </div>
    </div>

    <div class="list-section">
        <h3>대여 가능 목록 (RENTAL_B)</h3>
        <table>
            <tr>
                <th>ID</th>
                <th>비품명</th>
                <th>모델명</th>
                <th>상태 / 수량</th>
            </tr>
            <%
                if (list != null && !list.isEmpty()) {
                    for (EquipmentDTO dto : list) {
                        String statusInfo = "Asset".equals(dto.getManagementStyle()) ? dto.getStatus() : "잔여: " + dto.getQuantity();
                        
                        // 고장난 건 클릭 못하게(혹은 빨간색) 표시
                        boolean isBroken = "Asset".equals(dto.getManagementStyle()) && !"Normal".equals(dto.getStatus());
                        String rowColor = isBroken ? "background-color: #ffcccc;" : "";
                        String clickAction = isBroken ? "alert('대여 불가능한 상태입니다.');" : "selectItem('" + dto.getEquipmentId() + "', '" + dto.getEquipmentName() + "')";
            %>
            <tr style="<%= rowColor %>" onclick="<%= clickAction %>">
                <td><%= dto.getEquipmentId() %></td>
                <td><%= dto.getEquipmentName() %></td>
                <td><%= dto.getModelName() %></td>
                <td><%= statusInfo %></td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr><td colspan="4">대여 가능한 비품이 없습니다.</td></tr>
            <%
                }
                DBConnection.close(conn);
            %>
        </table>
    </div>
</div>

</body>
</html>