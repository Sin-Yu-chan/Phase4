package Phase4;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {

    // [수정] CS.Max_Quantity 조회 추가
    private final String BASE_SQL = 
          "SELECT CE.Equipment_ID, CE.Management_Style, CE.Building_ID, CE.Classroom_Num, CE.Model_Name, "
        + "       AI.Serial_Number, AI.Status, "
        + "       CS.Quantity, CS.Max_Quantity, " // ★ 추가됨
        + "       ET.Equipment_Name, "
        + "       C.Capacity "
        + "FROM Classroom_Equipment CE "
        + "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID "
        + "LEFT JOIN Consumable_Stock CS ON CE.Equipment_ID = CS.Equipment_ID "
        + "LEFT JOIN Equipment_Type ET ON CE.Model_Name = ET.Model_Name "
        + "LEFT JOIN Classroom C ON CE.Building_ID = C.Building_ID AND CE.Classroom_Num = C.Classroom_Num ";

    private final String SORT_ORDER = 
          "ORDER BY CE.Management_Style ASC, AI.Status ASC, CS.Quantity ASC, ET.Equipment_Name ASC, CE.Classroom_Num ASC";

    // 1. 건물별 검색
    public List<EquipmentDTO> searchByBuilding(Connection conn, String buildingId) {
        List<EquipmentDTO> list = new ArrayList<>();
        String sql = BASE_SQL + "WHERE CE.Building_ID = ? " + SORT_ORDER;
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, buildingId);
            list = executeQuery(pstmt);
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 2. 강의실별 검색
    public List<EquipmentDTO> searchByClassroom(Connection conn, String buildingId, String roomNum) {
        List<EquipmentDTO> list = new ArrayList<>();
        if(roomNum != null && !roomNum.trim().isEmpty()) {
            String sql = BASE_SQL + "WHERE CE.Building_ID = ? AND CE.Classroom_Num = ? " + SORT_ORDER;
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, buildingId);
                pstmt.setString(2, roomNum); 
                list = executeQuery(pstmt);
            } catch (SQLException e) { e.printStackTrace(); }
        } else {
            return searchByBuilding(conn, buildingId);
        }
        return list;
    }
    
    // [참조 데이터 자동 생성]
    private void ensureReferenceData(Connection conn, String bId, String room, String model) throws SQLException {
        String sqlModel = "INSERT INTO Equipment_Type (Model_Name, Equipment_Name) SELECT ?, ? FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM Equipment_Type WHERE Model_Name = ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlModel)) {
            pstmt.setString(1, model); pstmt.setString(2, model); pstmt.setString(3, model); pstmt.executeUpdate();
        }
        String sqlRoom = "INSERT INTO Classroom (Building_ID, Classroom_Num, Capacity, Classroom_Type, Current_Status) SELECT ?, ?, 30, 'General', 'Available' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM Classroom WHERE Building_ID = ? AND Classroom_Num = ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlRoom)) {
            pstmt.setString(1, bId); pstmt.setString(2, room); pstmt.setString(3, bId); pstmt.setString(4, room); pstmt.executeUpdate();
        }
    }

    // 9. 자산 추가
    public boolean addAsset(Connection conn, String newId, String bId, String room, String model) {
        String sql1 = "INSERT INTO Classroom_Equipment (Equipment_ID, Management_Style, Building_ID, Classroom_Num, Model_Name) VALUES (?, 'Asset', ?, ?, ?)";
        String sql2 = "INSERT INTO Asset_Item (Equipment_ID, Serial_Number, Status) VALUES (?, ?, 'Normal')";
        try {
            conn.setAutoCommit(false);
            ensureReferenceData(conn, bId, room, model);
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, newId); pstmt.setString(2, bId); pstmt.setString(3, room); pstmt.setString(4, model); pstmt.executeUpdate();
            }
            try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                pstmt.setString(1, newId); pstmt.setString(2, "SN-" + newId); pstmt.executeUpdate();
            }
            conn.commit(); return true;
        } catch (SQLException e) { try { conn.rollback(); } catch (SQLException ex) {} return false; } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    // 10. 소모품 추가 [수정됨: maxQty 인자 추가 및 저장]
    public boolean addNewConsumable(Connection conn, String newId, String bId, String room, String model, int qty, int maxQty) {
        String sql1 = "INSERT INTO Classroom_Equipment (Equipment_ID, Management_Style, Building_ID, Classroom_Num, Model_Name) VALUES (?, 'Consumable', ?, ?, ?)";
        // [수정] Max_Quantity 저장
        String sql2 = "INSERT INTO Consumable_Stock (Equipment_ID, Quantity, Max_Quantity) VALUES (?, ?, ?)";
        try {
            conn.setAutoCommit(false);
            ensureReferenceData(conn, bId, room, model);
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, newId); pstmt.setString(2, bId); pstmt.setString(3, room); pstmt.setString(4, model); pstmt.executeUpdate();
            }
            try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                pstmt.setString(1, newId); 
                pstmt.setInt(2, qty); 
                pstmt.setInt(3, maxQty); // ★ 저장
                pstmt.executeUpdate();
            }
            conn.commit(); return true;
        } catch (SQLException e) { try { conn.rollback(); } catch (SQLException ex) {} return false; } finally { try { conn.setAutoCommit(true); } catch (SQLException e) {} }
    }

    // (기타 메서드들 유지)
    public boolean isBuildingExist(Connection conn, String bId) { return false; }
    public boolean isClassroomExist(Connection conn, String bId, String room) { return false; }
    
    public List<String> getAllBuildingIds(Connection conn) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT BUILDING_ID FROM CLASSROOM_EQUIPMENT ORDER BY BUILDING_ID";
        try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) { while (rs.next()) list.add(rs.getString("BUILDING_ID")); } catch (Exception e) {} return list;
    }
    
    public List<String> getAllModelNames(Connection conn) {
        List<String> models = new ArrayList<>();
        String sql = "SELECT Model_Name FROM Equipment_Type ORDER BY Model_Name";
        try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) { while (rs.next()) models.add(rs.getString("Model_Name")); } catch (Exception e) {} return models;
    }
    
    public List<String> getClassroomList(Connection conn, String buildingId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT Classroom_Num FROM Classroom WHERE Building_ID = ? ORDER BY Classroom_Num";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, buildingId);
            try (ResultSet rs = pstmt.executeQuery()) { while (rs.next()) list.add(rs.getString("Classroom_Num")); }
        } catch (SQLException e) {} return list;
    }
    
    public String getExistingConsumableId(Connection conn, String bId, String room, String model) {
        String sql = "SELECT CE.Equipment_ID FROM Classroom_Equipment CE "
                   + "WHERE CE.Building_ID = ? AND CE.Classroom_Num = ? "
                   + "AND CE.Model_Name = ? AND CE.Management_Style = 'Consumable'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bId); pstmt.setString(2, room); pstmt.setString(3, model);
            try (ResultSet rs = pstmt.executeQuery()) { if (rs.next()) return rs.getString(1); }
        } catch (SQLException e) {} return null;
    }

    public boolean updateConsumableQty(Connection conn, String equipId, int newQty) {
        String sql = "UPDATE Consumable_Stock SET Quantity = ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { pstmt.setInt(1, newQty); pstmt.setString(2, equipId); return pstmt.executeUpdate() > 0; } catch (SQLException e) { return false; }
    }
    
    public boolean increaseConsumableQty(Connection conn, String equipId, int amountToAdd) {
        String sql = "UPDATE Consumable_Stock SET Quantity = Quantity + ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { pstmt.setInt(1, amountToAdd); pstmt.setString(2, equipId); return pstmt.executeUpdate() > 0; } catch (SQLException e) { return false; }
    }
    
    public boolean deleteEquipment(Connection conn, String equipId) {
        String sql = "DELETE FROM Classroom_Equipment WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { pstmt.setString(1, equipId); return pstmt.executeUpdate() > 0; } catch (SQLException e) { return false; }
    }
    
    public boolean updateEquipmentStatus(Connection conn, String equipId, String newStatus) {
        String sql = "UPDATE Asset_Item SET Status = ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) { pstmt.setString(1, newStatus); pstmt.setString(2, equipId); return pstmt.executeUpdate() > 0; } catch (SQLException e) { return false; }
    }
    public List<EquipmentDTO> searchByStatus(Connection conn, String buildingId, String status) { return null; }

    // Helper: ResultSet 매핑 (수정됨)
    private List<EquipmentDTO> executeQuery(PreparedStatement pstmt) throws SQLException {
        List<EquipmentDTO> list = new ArrayList<>();
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                String eName = rs.getString("Equipment_Name");
                if (eName == null) eName = rs.getString("Model_Name");
                
                // [수정] DB의 Max_Quantity 값 가져오기 (없으면 0 -> 10으로 처리)
                int maxQ = rs.getInt("Max_Quantity");
                if(rs.wasNull()) maxQ = 10; 

                list.add(new EquipmentDTO(
                    rs.getString("Equipment_ID"), rs.getString("Management_Style"),
                    rs.getString("Building_ID"), rs.getString("Classroom_Num"),
                    rs.getString("Model_Name"), rs.getString("Serial_Number"),
                    rs.getString("Status"), rs.getInt("Quantity"), eName, rs.getInt("Capacity"),
                    maxQ // ★ DTO에 전달
                ));
            }
        }
        return list;
    }
}