<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="Phase4.DBConnection" %>
<%@ page import="Phase4.EquipmentDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");
    if (!"Admin".equals(session.getAttribute("userRole"))) return;

    Connection conn = null;
    boolean success = false;
    
    try {
        conn = DBConnection.getConnection();
        EquipmentDAO equipDAO = new EquipmentDAO();

        // 1. 신규 등록
        if ("add".equals(action)) {
            String bId = request.getParameter("buildingId");
            String room = request.getParameter("room");
            String model = request.getParameter("model");
            String type = request.getParameter("type");
            String newId = "EQ" + (System.currentTimeMillis() % 1000000);

            if ("Asset".equals(type)) {
                success = equipDAO.addAsset(conn, newId, bId, room, model);
            } else {
                int qty = Integer.parseInt(request.getParameter("qty"));
                
                // [수정] 최대 수량 받기 (입력 안 하면 기본값 10)
                String maxQtyStr = request.getParameter("maxQty");
                int maxQty = (maxQtyStr != null && !maxQtyStr.isEmpty()) ? Integer.parseInt(maxQtyStr) : 10;
                
                String existId = equipDAO.getExistingConsumableId(conn, bId, room, model);
                if (existId != null) {
                    // 이미 있으면 수량만 증가 (최대치는 기존 유지)
                    success = equipDAO.increaseConsumableQty(conn, existId, qty);
                } else {
                    // [수정] 신규 등록 시 최대 수량도 함께 저장
                    success = equipDAO.addNewConsumable(conn, newId, bId, room, model, qty, maxQty);
                }
            }
        }
        
        // 2. 삭제
        else if ("delete".equals(action)) {
            success = equipDAO.deleteEquipment(conn, request.getParameter("id"));
        }
        
        // 3. 보충 (+)
        else if ("restock".equals(action)) {
            success = equipDAO.increaseConsumableQty(conn, request.getParameter("id"), Integer.parseInt(request.getParameter("amount")));
        }
        
        // 4. 감소 (-)
        else if ("reduce".equals(action)) {
            int qty = Integer.parseInt(request.getParameter("currentQty")) - Integer.parseInt(request.getParameter("amount"));
            if (qty <= 0) success = equipDAO.deleteEquipment(conn, request.getParameter("id"));
            else success = equipDAO.updateConsumableQty(conn, request.getParameter("id"), qty);
        }

    } catch(Exception e) { e.printStackTrace(); } 
    finally { DBConnection.close(conn); }

    String referer = request.getHeader("Referer");
    response.sendRedirect(referer != null ? referer : "manage_stock.jsp");
%>