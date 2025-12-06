<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.EquipmentDAO" %>
<%@ page import="Phase4.EquipmentDTO" %>

<%
    String userId = (String) session.getAttribute("userID");
    if (userId == null) { out.println("<script>location.href='login.jsp';</script>"); return; }

    request.setCharacterEncoding("UTF-8");
    String buildingId = request.getParameter("buildingId");
    String room = request.getParameter("room");

    Connection conn = DBConnection.getConnection();
    EquipmentDAO equipDAO = new EquipmentDAO();
    List<String> bList = equipDAO.getAllBuildingIds(conn);
    
    if (buildingId == null && !bList.isEmpty()) buildingId = bList.get(0);

    List<EquipmentDTO> list = null;
    if (buildingId != null && room != null && !room.isEmpty()) {
        list = equipDAO.searchByClassroom(conn, buildingId, room);
    }
    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>고장/부족 신고</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; padding: 20px; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    select, input { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    button { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; color: white; }
    .btn-search { background-color: #007bff; }
    .btn-report { background-color: #dc3545; padding: 5px 10px; font-size: 12px; }
    
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 10px; border-bottom: 1px solid #eee; }
    th { background-color: #343a40; color: white; }

    .modal { display: none; position: fixed; z-index: 1; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.4); }
    .modal-content { background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 400px; border-radius: 10px; text-align: left; }
    .full-width { width: 100%; margin-top: 5px; margin-bottom: 10px; box-sizing: border-box; }
</style>
<script>
    function openReportModal(id, name, type) {
        document.getElementById("equipId").value = id;
        document.getElementById("equipName").value = name;
        
        var select = document.getElementById("reportType");
        select.innerHTML = ""; // 초기화
        
        if(type === 'Asset') {
            var opts = ["Broken", "Damaged", "Lost", "Other"];
            for(var i=0; i<opts.length; i++) select.options.add(new Option(opts[i], opts[i]));
        } else {
            var opts = ["Low_Stock", "Empty", "Other"];
            for(var i=0; i<opts.length; i++) select.options.add(new Option(opts[i], opts[i]));
        }
        
        document.getElementById("reportModal").style.display = "block";
    }
    function closeModal() { document.getElementById("reportModal").style.display = "none"; }
</script>
</head>
<body>
    <div class="container">
        <h2>📢 고장 및 부족 신고</h2>
        <button onclick="location.href='index.jsp'" style="background:#6c757d; float:right;">메인으로</button>
        <br><br>

        <form action="report.jsp" method="get">
            건물: <select name="buildingId">
                <% for(String b : bList) { %><option value="<%= b %>" <%= b.equals(buildingId)?"selected":"" %>><%= b %></option><% } %>
            </select>
            호수: <input type="text" name="room" value="<%= room!=null?room:"" %>" placeholder="예: 101">
            <button type="submit" class="btn-search">조회</button>
        </form>

        <% if(list != null && !list.isEmpty()) { %>
            <table>
                <tr><th>ID</th><th>비품명</th><th>모델</th><th>상태/수량</th><th>신고</th></tr>
                <% for(EquipmentDTO d : list) { %>
                <tr>
                    <td><%= d.getEquipmentId() %></td>
                    <td><%= d.getEquipmentName() %></td>
                    <td><%= d.getModelName() %></td>
                    <td><%= "Asset".equals(d.getManagementStyle()) ? d.getStatus() : d.getQuantity()+"개" %></td>
                    <td>
                        <button class="btn-report" onclick="openReportModal('<%= d.getEquipmentId() %>', '<%= d.getEquipmentName() %>', '<%= d.getManagementStyle() %>')">🚨 신고</button>
                    </td>
                </tr>
                <% } %>
            </table>
        <% } else if(room != null) { %>
            <p>해당 강의실에 비품이 없습니다.</p>
        <% } %>
    </div>

    <div id="reportModal" class="modal">
        <div class="modal-content">
            <h3>🚨 신고 접수</h3>
            <form action="report_action.jsp" method="post">
                <input type="hidden" name="action" value="submit">
                <input type="hidden" name="equipId" id="equipId">
                
                <label>비품명:</label>
                <input type="text" id="equipName" name="equipName" class="full-width" readonly style="background:#eee;">
                
                <label>유형:</label>
                <select name="type" id="reportType" class="full-width"></select>
                
                <label>내용:</label>
                <textarea name="content" class="full-width" rows="3" required placeholder="상세 내용을 입력하세요"></textarea>
                
                <button type="submit" style="background:#dc3545; width:100%;">제출하기</button>
                <button type="button" onclick="closeModal()" style="background:#6c757d; width:100%; margin-top:5px;">취소</button>
            </form>
        </div>
    </div>
</body>
</html>
</body>
</html>