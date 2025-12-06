<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.EquipmentDAO" %>
<%@ page import="Phase4.EquipmentDTO" %>

<%
    if (!"Admin".equals(session.getAttribute("userRole"))) {
        out.println("<script>location.href='index.jsp';</script>");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String buildingId = request.getParameter("buildingId");
    String keyword = request.getParameter("keyword"); 

    Connection conn = DBConnection.getConnection();
    EquipmentDAO equipDAO = new EquipmentDAO();
    
    List<String> bList = equipDAO.getAllBuildingIds(conn);
    List<String> mList = equipDAO.getAllModelNames(conn);
    
    if (buildingId == null && !bList.isEmpty()) buildingId = bList.get(0);
    
    List<EquipmentDTO> fullList = null;
    if (buildingId != null) {
        if (keyword != null && !keyword.isEmpty()) {
            fullList = equipDAO.searchByClassroom(conn, buildingId, keyword);
        } else {
            fullList = equipDAO.searchByBuilding(conn, buildingId);
        }
    }
    DBConnection.close(conn);

    List<EquipmentDTO> urgentList = new ArrayList<>();
    List<EquipmentDTO> normalList = new ArrayList<>();
    
    if (fullList != null) {
        for (EquipmentDTO dto : fullList) {
            boolean isAsset = "Asset".equals(dto.getManagementStyle());
            boolean isProblem = false;
            
            // [수정] DB의 MaxQuantity 사용 (기본값 10)
            int targetQty = (dto.getMaxQuantity() > 0) ? dto.getMaxQuantity() : 10;

            if (isAsset) {
                if (!"Normal".equals(dto.getStatus())) isProblem = true;
            } else {
                if (dto.getQuantity() < targetQty) isProblem = true;
            }

            if (isProblem) urgentList.add(dto);
            else normalList.add(dto);
        }
    }

    Comparator<EquipmentDTO> sorter = new Comparator<EquipmentDTO>() {
        @Override
        public int compare(EquipmentDTO o1, EquipmentDTO o2) {
            boolean c1 = "Consumable".equals(o1.getManagementStyle());
            boolean c2 = "Consumable".equals(o2.getManagementStyle());
            if (c1 && !c2) return -1;
            if (!c1 && c2) return 1;
            return 0;
        }
    };
    Collections.sort(urgentList, sorter);
    Collections.sort(normalList, sorter);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비품 자재 관리</title>
<style>
    /* 스타일 그대로 유지 */
    body { font-family: 'Segoe UI', sans-serif; text-align: center; background-color: #f4f6f9; margin: 0; padding-bottom: 50px; }
    .header-bar { background: #343a40; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    .header-bar h2 { margin: 0; font-size: 22px; }
    .btn-home { background-color: #6c757d; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold; }
    .control-bar { background: white; padding: 15px; margin: 20px auto; width: 95%; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; }
    .search-form { display: flex; gap: 10px; align-items: center; }
    select, input[type=text] { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    button { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; color: white; }
    .btn-search { background-color: #007bff; }
    .btn-add { background-color: #28a745; font-size: 14px; }
    .dashboard-container { display: flex; width: 96%; margin: 0 auto; gap: 20px; align-items: flex-start; }
    .panel { flex: 1; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); overflow: hidden; min-height: 500px; }
    .panel-header { padding: 15px; font-weight: bold; font-size: 18px; color: white; text-align: left; }
    .left-panel .panel-header { background-color: #dc3545; } 
    .right-panel .panel-header { background-color: #007bff; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px 10px; border-bottom: 1px solid #eee; font-size: 13px; text-align: left; vertical-align: middle; }
    th { background-color: #f8f9fa; color: #555; font-weight: bold; border-bottom: 2px solid #ddd; }
    tr:hover { background-color: #f1f1f1; }
    .badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
    .bg-asset { background-color: #17a2b8; }
    .bg-cons { background-color: #ffc107; color: #333; }
    .text-danger { color: #dc3545; font-weight: bold; }
    .text-success { color: #28a745; font-weight: bold; }
    .text-model { font-weight: bold; color: #333; font-size: 14px; }
    .text-sub { font-size: 12px; color: #888; }
    .inline-form { display: flex; align-items: center; gap: 3px; }
    .input-qty { width: 40px; padding: 6px; text-align: center; border: 1px solid #ccc; border-radius: 4px; font-size: 13px; margin-right: 5px; }
    .action-btn { padding: 6px 10px; border: none; border-radius: 4px; cursor: pointer; color: white; font-size: 12px; font-weight: bold; margin-right: 2px; }
    .btn-blue { background-color: #17a2b8; }
    .btn-yellow { background-color: #ffc107; color: #333; }
    .btn-red { background-color: #dc3545; }
    .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5); }
    .modal-content { background-color: #fefefe; margin: 10% auto; padding: 25px; border: 1px solid #888; width: 400px; border-radius: 10px; text-align: left; }
    .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
    .modal-input { width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    .btn-submit-modal { width: 100%; padding: 12px; background-color: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
</style>

<script>
    function onBuildingChange() { document.getElementById("searchForm").submit(); }
    function confirmDelete(id) {
        if(confirm("정말로 이 비품을 영구 삭제(폐기)하시겠습니까?")) {
            location.href = "stock_action.jsp?action=delete&id=" + id;
        }
    }
    function openModal() { document.getElementById("addModal").style.display = "block"; }
    function closeModal() { document.getElementById("addModal").style.display = "none"; }
    window.onclick = function(event) { if (event.target == document.getElementById("addModal")) closeModal(); }

    function toggleQty() {
        var type = document.querySelector('input[name="type"]:checked').value;
        document.getElementById("qtyDiv").style.display = (type === "Asset") ? "none" : "block";
    }
</script>
</head>
<body>

    <div class="header-bar">
        <h2>🛠️ 비품 자재 관리 센터</h2>
        <button class="btn-home" onclick="location.href='index.jsp'">🏠 메인으로</button>
    </div>

    <div class="control-bar">
        <form id="searchForm" action="manage_stock.jsp" method="get" class="search-form">
            <label>📍 위치 선택:</label>
            <select name="buildingId" onchange="onBuildingChange()">
                <option value="">-- 건물 선택 --</option>
                <% for(String b : bList) { %>
                    <option value="<%= b %>" <%= b.equals(buildingId)?"selected":"" %>><%= b %></option>
                <% } %>
            </select>
            <input type="text" name="keyword" value="<%= keyword!=null?keyword:"" %>" placeholder="호수 입력 (선택)">
            <button type="submit" class="btn-search">조회</button>
        </form>
        <button class="btn-add" onclick="openModal()">+ 신규 비품 등록</button>
    </div>

    <% if (buildingId != null && !buildingId.isEmpty()) { %>
    <div class="dashboard-container">
        
        <div class="panel left-panel">
            <div class="panel-header">🔥 조치 필요 (고장 / 부족: <%= urgentList.size() %>건)</div>
            <table>
                <thead><tr><th width="35%">비품 정보</th><th width="20%">위치</th><th width="20%">상태</th><th>추가</th></tr></thead>
                <tbody>
                <% if (urgentList.isEmpty()) { %>
                    <tr><td colspan="4" style="text-align:center; padding:30px; color:#999;">현재 조치가 필요한 비품이 없습니다. 👍</td></tr>
                <% } else { 
                    for (EquipmentDTO d : urgentList) { 
                        boolean isAsset = "Asset".equals(d.getManagementStyle());
                     // [수정] MaxQuantity 사용
                        int targetQty = (d.getMaxQuantity() > 0) ? d.getMaxQuantity() : 10;
                %>
                    <tr style="background-color: #fff5f5;">
                        <td>
                            <div class="text-model"><%= d.getModelName() %></div>
                            <span class="text-sub"><%= d.getEquipmentId() %></span>
                        </td>
                        <td><%= d.getBuildingId() %>-<%= d.getClassroomNum() %></td>
                        <td>
                            <% if (isAsset) { %>
                                <span class="text-danger">[<%= d.getStatus() %>]</span>
                            <% } else { %>
                                <b class="text-danger"><%= d.getQuantity() %></b><span style="color:#999; font-size:11px;"> / <%= targetQty %></span>
                            <% } %>
                        </td>
                        <td>
                            <% if (isAsset) { %>
                                <button class="action-btn btn-red" onclick="confirmDelete('<%= d.getEquipmentId() %>')">폐기</button>
                            <% } else { %>
                                <form action="stock_action.jsp" method="post" class="inline-form">
                                    <input type="hidden" name="id" value="<%= d.getEquipmentId() %>">
                                    <input type="hidden" name="currentQty" value="<%= d.getQuantity() %>">
                                    <input type="number" name="amount" value="1" min="1" class="input-qty">
                                    <button type="submit" name="action" value="restock" class="action-btn btn-blue">+</button>
                                </form>
                            <% } %>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
        </div>

        <div class="panel right-panel">
            <div class="panel-header">✅ 정상 보유 현황 (<%= normalList.size() %>건)</div>
            <table>
                <thead><tr><th width="10%">유형</th><th width="30%">비품 정보</th><th width="15%">위치</th><th width="20%">수량</th><th>관리</th></tr></thead>
                <tbody>
                <% if (normalList.isEmpty()) { %>
                    <tr><td colspan="5" style="text-align:center; padding:30px; color:#999;">비품 데이터가 없습니다.</td></tr>
                <% } else { 
                    for (EquipmentDTO d : normalList) { 
                        boolean isAsset = "Asset".equals(d.getManagementStyle());
                        // [수정] MaxQuantity 사용
                        int targetQty = (d.getMaxQuantity() > 0) ? d.getMaxQuantity() : 10;
                %>
                    <tr>
                        <td>
                            <% if (isAsset) { %><span class="badge bg-asset">Asset</span><% } else { %><span class="badge bg-cons">Consumable</span><% } %>
                        </td>
                        <td>
                            <div class="text-model"><%= d.getModelName() %></div>
                            <span class="text-sub"><%= d.getEquipmentId() %></span>
                        </td>
                        <td><%= d.getClassroomNum() %>호</td>
                        <td>
                            <% if (isAsset) { %>
                                <span class="text-success">Normal</span>
                            <% } else { %>
                                <b><%= d.getQuantity() %></b> <span style="color:#999;"> / <%= targetQty %></span>
                            <% } %>
                        </td>
                        <td>
                            <% if (isAsset) { %>
                                <button class="action-btn btn-red" onclick="confirmDelete('<%= d.getEquipmentId() %>')">삭제</button>
                            <% } else { %>
                                <form action="stock_action.jsp" method="post" class="inline-form">
                                    <input type="hidden" name="id" value="<%= d.getEquipmentId() %>">
                                    <input type="hidden" name="currentQty" value="<%= d.getQuantity() %>">
                                    <input type="number" name="amount" value="1" min="1" class="input-qty">
                                    <button type="submit" name="action" value="restock" class="action-btn btn-blue">+</button>
                                    <button type="submit" name="action" value="reduce" class="action-btn btn-yellow">-</button>
                                    <button type="button" class="action-btn btn-red" onclick="confirmDelete('<%= d.getEquipmentId() %>')">X</button>
                                </form>
                            <% } %>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
        </div>
        
    </div>
    <% } %>

    <div id="addModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h3 style="margin-top:0; border-bottom:2px solid #28a745; padding-bottom:10px;">📦 신규 비품 등록</h3>
            <form action="stock_action.jsp" method="post">
                <input type="hidden" name="action" value="add">
                <label style="display:block; margin-top:10px;">1. 설치 장소 (건물)</label>
                <select name="buildingId" class="modal-input" required>
                    <option value="">-- 건물 선택 --</option>
                    <% for(String b : bList) { %><option value="<%= b %>"><%= b %></option><% } %>
                </select>
                <label style="display:block; margin-top:10px;">2. 강의실 호수</label>
                <input type="text" name="room" class="modal-input" required placeholder="예: 101">
                <label style="display:block; margin-top:10px;">3. 모델명</label>
                <input type="text" list="modalModelList" name="model" class="modal-input" required placeholder="모델명 입력">
                <datalist id="modalModelList"><% for(String m : mList) { %><option value="<%= m %>"><% } %></datalist>
                <label style="display:block; margin-top:10px;">4. 관리 유형</label>
                <div style="margin-top:5px;">
                    <label><input type="radio" name="type" value="Asset" checked onclick="toggleQty()"> 자산</label>
                    <label><input type="radio" name="type" value="Consumable" onclick="toggleQty()"> 소모품</label>
                </div>
                
                <div id="qtyDiv" style="display:none;">
                    <div style="display:flex; gap:10px;">
                        <div style="flex:1;">
                            <label style="display:block; margin-top:10px;">현재 수량</label>
                            <input type="number" name="qty" value="10" min="1" class="modal-input">
                        </div>
                        <div style="flex:1;">
                            <label style="display:block; margin-top:10px;">기준(최대) 수량</label>
                            <input type="number" name="maxQty" value="10" min="1" class="modal-input" placeholder="기본: 10">
                        </div>
                    </div>
                </div>
                
                <button type="submit" class="btn-submit-modal">등록 완료</button>
            </form>
        </div>
    </div>

</body>
</html>