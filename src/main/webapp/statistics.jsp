<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.StatisticsDAO" %>
<%@ page import="Phase4.StatDTO" %>
<%@ page import="Phase4.EquipmentDAO" %>

<%
    // 관리자 체크
    if (!"Admin".equals(session.getAttribute("userRole"))) {
        out.println("<script>location.href='index.jsp';</script>");
        return;
    }

    // 파라미터 수신
    String target = request.getParameter("target");
    if(target == null) target = "ASSET";

    String groupBy = request.getParameter("groupBy");
    if(groupBy == null) groupBy = "BUILDING";

    String bFilter = request.getParameter("bFilter");
    String mFilter = request.getParameter("mFilter");
    String sFilter = request.getParameter("sFilter");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    
    String limitStr = request.getParameter("limit");
    int limit = (limitStr == null || limitStr.isEmpty()) ? 10 : Integer.parseInt(limitStr);
    
    String minQtyStr = request.getParameter("minQty");
    int minQty = (minQtyStr == null || minQtyStr.isEmpty()) ? 0 : Integer.parseInt(minQtyStr);
    
    String maxQtyStr = request.getParameter("maxQty");
    int maxQty = (maxQtyStr == null || maxQtyStr.isEmpty()) ? 0 : Integer.parseInt(maxQtyStr);

    // 데이터 조회
    Connection conn = DBConnection.getConnection();
    StatisticsDAO statDAO = new StatisticsDAO();
    EquipmentDAO equipDAO = new EquipmentDAO();
    
    List<String> bList = equipDAO.getAllBuildingIds(conn);
    List<String> mList = equipDAO.getAllModelNames(conn);
    
    List<StatDTO> resultList = statDAO.getUnifiedStats(conn, target, groupBy, bFilter, mFilter, sFilter, startDate, endDate, limit, minQty, maxQty);

    DBConnection.close(conn);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>통합 통계 센터</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; background-color: #f4f6f9; text-align: center; }
    .container { width: 90%; max-width: 1000px; margin: 30px auto; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); text-align: left; }
    
    h2 { margin-top: 0; color: #333; border-bottom: 2px solid #eee; padding-bottom: 15px; }
    
    .control-panel { display: flex; flex-wrap: wrap; gap: 20px; background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px solid #ddd; }
    .control-group { flex: 1; min-width: 200px; }
    .control-title { font-weight: bold; margin-bottom: 8px; display: block; color: #555; }
    
    label { display: block; margin-bottom: 5px; cursor: pointer; }
    input[type="radio"] { margin-right: 5px; }
    select, input[type="text"], input[type="date"], input[type="number"] { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    
    /* 비활성화 스타일 */
    select:disabled, input:disabled, label.disabled-label { background-color: #e9ecef; cursor: not-allowed; color: #aaa; }

    .btn-submit { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 10px; }
    .btn-submit:hover { background-color: #0056b3; }
    
    .result-area { margin-top: 30px; }
    table { width: 100%; border-collapse: collapse; }
    th { background: #343a40; color: white; padding: 12px; text-align: left; }
    td { border-bottom: 1px solid #eee; padding: 10px; }
    
    .bar-container { background: #e9ecef; width: 100%; height: 25px; border-radius: 4px; overflow: hidden; }
    .bar { height: 100%; background: linear-gradient(90deg, #36b9cc, #2c9faf); text-align: right; color: white; font-size: 12px; line-height: 25px; padding-right: 8px; white-space: nowrap; }
    
    .home-btn { float: right; padding: 5px 10px; background: #6c757d; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 12px; }
</style>

<script>
    function updateUI() {
        var target = document.querySelector('input[name="target"]:checked').value;
        
        var bFilter = document.getElementById("bFilter");
        var rGroupBuilding = document.getElementById("rGroupBuilding");
        
        // 1. 예약/로그는 건물 필터 비활성화 (Rental_B 고정)
        if (target === "USAGE" || target === "RESERVATION") {
            bFilter.value = "ALL";
            bFilter.disabled = true;
            rGroupBuilding.disabled = true;
            if (rGroupBuilding.checked) document.getElementById("rGroupModel").checked = true;
        } else {
            bFilter.disabled = false;
            rGroupBuilding.disabled = false;
        }
        
        // 2. [수정됨] 예약(RESERVATION) 또는 신고(REPORT)일 때 -> 학과별 기준 활성화
        var rGroupDept = document.getElementById("rGroupDept");
        
        if (target === "RESERVATION" || target === "REPORT") {
            rGroupDept.disabled = false;
        } else {
            rGroupDept.disabled = true;
            if (rGroupDept.checked) document.getElementById("rGroupModel").checked = true;
        }
    }
    
    window.onload = function() {
        updateUI();
    };
</script>
</head>
<body>

    <div class="container">
        <button class="home-btn" onclick="location.href='index.jsp'">🏠 메인으로</button>
        <h2>📊 통합 데이터 분석기 (Query Builder)</h2>
        
        <form action="statistics.jsp" method="get">
            <div class="control-panel">
                
                <div class="control-group">
                    <span class="control-title">1. 무엇을 분석할까요?</span>
                    <label><input type="radio" name="target" value="ASSET" <%= "ASSET".equals(target)?"checked":"" %> onclick="updateUI()"> 📦 자산/재고 보유량</label>
                    <label><input type="radio" name="target" value="REPORT" <%= "REPORT".equals(target)?"checked":"" %> onclick="updateUI()"> 🚨 신고/고장 이력</label>
                    <label><input type="radio" name="target" value="USAGE" <%= "USAGE".equals(target)?"checked":"" %> onclick="updateUI()"> 📜 사용(로그) 횟수</label>
                    <label><input type="radio" name="target" value="RESERVATION" <%= "RESERVATION".equals(target)?"checked":"" %> onclick="updateUI()"> 📅 예약 활동량</label>
                </div>

                <div class="control-group">
                    <span class="control-title">2. 기준 (Group By)</span>
                    <label><input type="radio" id="rGroupBuilding" name="groupBy" value="BUILDING" <%= "BUILDING".equals(groupBy)?"checked":"" %>> 🏢 건물별</label>
                    <label><input type="radio" id="rGroupModel" name="groupBy" value="MODEL" <%= "MODEL".equals(groupBy)?"checked":"" %>> 💻 모델명별</label>
                    <label><input type="radio" id="rGroupStatus" name="groupBy" value="STATUS" <%= "STATUS".equals(groupBy)?"checked":"" %>> 🔧 상태/유형별</label>
                    <label><input type="radio" id="rGroupDept" name="groupBy" value="DEPT" <%= "DEPT".equals(groupBy)?"checked":"" %> disabled> 👥 학과별 (예약/신고)</label>
                </div>

                <div class="control-group">
                    <span class="control-title">3. 필터 (Conditions)</span>
                    <select id="bFilter" name="bFilter" style="margin-bottom:5px;">
                        <option value="ALL">🏢 건물 전체</option>
                        <% for(String b : bList) { %>
                            <option value="<%= b %>" <%= b.equals(bFilter)?"selected":"" %>><%= b %></option>
                        <% } %>
                    </select>
                    
                    <input type="text" list="modelList" name="mFilter" value="<%= mFilter!=null?mFilter:"" %>" placeholder="💻 모델명 검색/선택" style="margin-bottom:5px;">
                    <datalist id="modelList">
                        <% for(String m : mList) { %>
                            <option value="<%= m %>">
                        <% } %>
                    </datalist>

                    <select id="sFilter" name="sFilter">
                        <option value="ALL">🔧 상태/유형 전체</option>
                        <option value="Normal" <%= "Normal".equals(sFilter)?"selected":"" %>>Normal (정상)</option>
                        <option value="Broken" <%= "Broken".equals(sFilter)?"selected":"" %>>Broken (파손)</option>
                        <option value="Repair" <%= "Repair".equals(sFilter)?"selected":"" %>>Repair (수리)</option>
                        <option value="Missing" <%= "Missing".equals(sFilter)?"selected":"" %>>Missing (분실)</option>
                    </select>
                </div>

                <div class="control-group">
                    <span class="control-title">4. 기간 및 범위 설정</span>
                    <input type="date" name="startDate" value="<%= startDate!=null?startDate:"" %>" style="margin-bottom:5px;">
                    <input type="date" name="endDate" value="<%= endDate!=null?endDate:"" %>" style="margin-bottom:5px;">
                    
                    <div style="display:flex; gap:5px; align-items:center;">
                        <input type="number" name="minQty" value="<%= minQtyStr!=null?minQtyStr:"" %>" min="0" placeholder="Min" style="width:70px;">
                        <span>~</span>
                        <input type="number" name="maxQty" value="<%= maxQtyStr!=null?maxQtyStr:"" %>" min="0" placeholder="Max" style="width:70px;">
                    </div>
                    <label style="font-size:12px; color:#666;">(수량/횟수 범위)</label>
                    
                    <label style="font-size:13px; margin-top:5px;">출력 개수 (Top N):</label>
                    <input type="number" name="limit" value="<%= limit %>" min="1" max="100">
                </div>
                
                <button type="submit" class="btn-submit">분석 실행 (Analyze)</button>
            </div>
        </form>

        <div class="result-area">
            <% if (resultList.isEmpty()) { %>
                <div style="text-align:center; padding:40px; color:#999;">
                    <h3>조건에 맞는 데이터가 없습니다.</h3>
                    <p>필터 조건을 변경하거나 기간을 늘려보세요.</p>
                </div>
            <% } else { 
                int max = 0;
                for(StatDTO s : resultList) if(s.getValue() > max) max = s.getValue();
            %>
                <h3>📈 분석 결과 (상위 <%= limit %>건)</h3>
                <table>
                    <tr>
                        <th width="30%">구분 (Label)</th>
                        <th width="70%">수치 (Count/Sum)</th>
                    </tr>
                    <% for(StatDTO s : resultList) { 
                       int percent = (int)((double)s.getValue() / max * 100);
                    %>
                    <tr>
                        <td style="font-weight:bold;"><%= s.getLabel() %></td>
                        <td>
                            <div class="bar-container">
                                <div class="bar" style="width: <%= percent %>%;"><%= s.getValue() %>&nbsp;</div>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>
    </div>

</body>
</html>