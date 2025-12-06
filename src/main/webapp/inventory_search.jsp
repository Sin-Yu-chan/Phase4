<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.EquipmentDAO" %>
<%@ page import="Phase4.EquipmentDTO" %>

<%
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"Admin".equals(userRole)) {
        out.println("<script>alert('관리자만 접근할 수 있습니다.'); location.href='index.jsp';</script>");
        return;
    }

    Connection conn = DBConnection.getConnection();
    EquipmentDAO equipDAO = new EquipmentDAO();
    List<String> buildingList = equipDAO.getAllBuildingIds(conn);

    request.setCharacterEncoding("UTF-8");
    String buildingId = request.getParameter("buildingId");
    String searchType = request.getParameter("searchType");
    String keyword = request.getParameter("keyword");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>스마트 재고 검색</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; }
    .container { width: 90%; margin: 30px auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    
    /* 검색 박스 스타일 */
    .search-box { background: #e9ecef; padding: 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; justify-content: center; gap: 10px; }
    select, input[type=text] { padding: 8px; border-radius: 4px; border: 1px solid #ccc; height: 35px; box-sizing: border-box; }
    
    button { height: 35px; padding: 0 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; color: white; }
    .btn-search { background-color: #28a745; }
    .btn-home { background-color: #6c757d; }
    
    /* [New] 지우기 버튼 스타일 */
    .btn-clear {
        background-color: #dc3545; 
        color: white; 
        border: none; 
        border-radius: 4px; 
        width: 30px; 
        height: 35px; 
        cursor: pointer; 
        font-weight: bold;
        display: flex; 
        align-items: center; 
        justify-content: center;
    }

    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 10px; font-size: 14px; }
    th { background-color: #007bff; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
</style>

<script>
    function updateInputMode() {
        var type = document.getElementById("searchType").value;
        var keywordInput = document.getElementById("keywordInput");
        var statusSelect = document.getElementById("statusSelect");
        
        if (type == "1") { // 건물 전체
            keywordInput.style.display = "none";
            statusSelect.style.display = "none";
            keywordInput.disabled = true;
            statusSelect.disabled = true;
        } else if (type == "2") { // 강의실별
            keywordInput.style.display = "inline-block";
            statusSelect.style.display = "none";
            keywordInput.disabled = false;
            statusSelect.disabled = true;
            keywordInput.placeholder = "호수 입력 (예: 101)";
        } else if (type == "3") { // 상태별
            keywordInput.style.display = "none";
            statusSelect.style.display = "inline-block";
            keywordInput.disabled = true;
            statusSelect.disabled = false;
        }
    }
    
    // [New] 입력창 비우기 함수
    function clearBuilding() {
        var input = document.getElementsByName("buildingId")[0];
        input.value = "";
        input.focus();
    }
</script>
</head>
<body onload="updateInputMode()">

<div class="container">
    <h2>🔎 관리자 스마트 재고 검색</h2>
    
    <div class="search-box">
        <form action="inventory_search.jsp" method="get" style="display:flex; align-items:center; gap:10px;">
            
            <b>건물:</b>
            <div style="display:flex; align-items:center;">
                <input type="text" list="buildingOptions" name="buildingId" 
                       value="<%= (buildingId != null) ? buildingId : "" %>" 
                       required placeholder="건물 선택" 
                       style="width: 150px;">
                <datalist id="buildingOptions">
                    <% for(String b : buildingList) { %>
                        <option value="<%= b %>">
                    <% } %>
                </datalist>
                <button type="button" class="btn-clear" onclick="clearBuilding()" title="입력 지우기">X</button>
            </div>

            <select id="searchType" name="searchType" onchange="updateInputMode()">
                <option value="1" <%= "1".equals(searchType)?"selected":"" %>>건물 전체 보기</option>
                <option value="2" <%= "2".equals(searchType)?"selected":"" %>>강의실 검색</option>
                <option value="3" <%= "3".equals(searchType)?"selected":"" %>>상태/수량 검색</option>
            </select>

            <input type="text" id="keywordInput" name="keyword" value="<%= (keyword!=null)?keyword:"" %>" style="width:150px;">
            
            <select id="statusSelect" name="keyword" style="display:none; width:150px;" disabled>
                <option value="Normal">Normal (정상)</option>
                <option value="Broken">Broken (고장)</option>
                <option value="Repair">Repair (수리중)</option>
                <option value="Low_Stock">Low Stock (부족)</option>
                <option value="Empty">Empty (없음)</option>
            </select>

            <button type="submit" class="btn-search">검색 조회</button>
            <a href="index.jsp"><button type="button" class="btn-home">메인으로</button></a>
        </form>
    </div>

    <%
        if (buildingId != null && !buildingId.trim().isEmpty()) {
            List<EquipmentDTO> list = null;

            if ("1".equals(searchType)) {
                list = equipDAO.searchByBuilding(conn, buildingId);
            } else if ("2".equals(searchType)) {
                list = equipDAO.searchByClassroom(conn, buildingId, keyword);
            } else if ("3".equals(searchType)) {
                list = equipDAO.searchByStatus(conn, buildingId, keyword);
            }

            if (list != null && !list.isEmpty()) {
    %>
                <h3 style="text-align: left;">📋 검색 결과: <%= list.size() %>건</h3>
                <table>
                    <tr>
                        <th>ID</th>
                        <th>비품명</th>
                        <th>모델명</th>
                        <th>위치</th>
                        <th>유형</th>
                        <th>상태 / 수량</th>
                    </tr>
                    <%
                        for (EquipmentDTO dto : list) {
                            String location = dto.getBuildingId() + "-" + dto.getClassroomNum();
                            String statusInfo = "";
                            String rowStyle = "";

                            if ("Asset".equals(dto.getManagementStyle())) {
                                statusInfo = "[" + dto.getStatus() + "] S/N:" + dto.getSerialNumber();
                                if(!"Normal".equals(dto.getStatus())) rowStyle = "background-color: #ffe6e6;";
                            } else {
                                int maxQty = (dto.getMaxQuantity() > 0) ? dto.getMaxQuantity() : 10;
                                statusInfo = "수량: " + dto.getQuantity() + " / " + maxQty;
                                if (dto.getQuantity() < maxQty) {
                                    statusInfo += " <b style='color:red;'>(부족)</b>";
                                    rowStyle = "background-color: #fff3cd;";
                                }
                            }
                    %>
                    <tr style="<%= rowStyle %>">
                        <td><%= dto.getEquipmentId() %></td>
                        <td><%= dto.getEquipmentName() %></td>
                        <td><%= dto.getModelName() %></td>
                        <td><%= location %></td>
                        <td><%= dto.getManagementStyle() %></td>
                        <td><%= statusInfo %></td>
                    </tr>
                    <%
                        }
                    %>
                </table>
    <%
            } else {
    %>
                <br><br>
                <h3 style="color: red;">🚫 검색 결과가 없습니다. 조건(건물, 호수 등)을 확인해주세요.</h3>
    <%
            }
        }
        DBConnection.close(conn);
    %>
</div>

</body>
</html>