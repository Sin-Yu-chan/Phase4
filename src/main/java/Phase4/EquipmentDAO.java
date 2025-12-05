package Phase4;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {

    // 공통 SQL (JOIN 포함)
    private final String BASE_SQL = 
          "SELECT CE.Equipment_ID, CE.Management_Style, CE.Building_ID, CE.Classroom_Num, CE.Model_Name, "
        + "       AI.Serial_Number, AI.Status, "
        + "       CS.Quantity, "
        + "       ET.Equipment_Name, "
        + "       C.Capacity "
        + "FROM Classroom_Equipment CE "
        + "LEFT JOIN Asset_Item AI ON CE.Equipment_ID = AI.Equipment_ID "
        + "LEFT JOIN Consumable_Stock CS ON CE.Equipment_ID = CS.Equipment_ID "
        + "JOIN Equipment_Type ET ON CE.Model_Name = ET.Model_Name "
        + "JOIN Classroom C ON CE.Building_ID = C.Building_ID AND CE.Classroom_Num = C.Classroom_Num ";

    private final String SORT_ORDER = 
          "ORDER BY CE.Management_Style ASC, AI.Status ASC, CS.Quantity ASC, ET.Equipment_Name ASC, CE.Classroom_Num ASC";

    // 1. 건물별 전체 비품 검색
    public List<EquipmentDTO> searchByBuilding(Connection conn, String buildingId) {
        List<EquipmentDTO> list = new ArrayList<>();
        String sql = BASE_SQL + "WHERE CE.Building_ID = ? " + SORT_ORDER;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, buildingId);
            list = executeQuery(pstmt);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. 특정 강의실 비품 검색
    public List<EquipmentDTO> searchByClassroom(Connection conn, String buildingId, String roomNum) {
        List<EquipmentDTO> list = new ArrayList<>();
        String sql = "";
        
        // 검색어(roomNum)가 있으면 조건 추가, 없으면 건물 전체
        if(roomNum != null && !roomNum.trim().isEmpty()) {
            sql = BASE_SQL + "WHERE CE.Building_ID = ? AND CE.Classroom_Num LIKE ? " + SORT_ORDER;
        } else {
            return searchByBuilding(conn, buildingId);
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, buildingId);
            pstmt.setString(2, "%" + roomNum + "%"); // 부분 검색 지원
            list = executeQuery(pstmt);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. 특정 상태 비품 검색 (자산 한정)
    public List<EquipmentDTO> searchByStatus(Connection conn, String buildingId, String status) {
        List<EquipmentDTO> list = new ArrayList<>();
        String sql = BASE_SQL + "WHERE CE.Building_ID = ? AND AI.Status = ? " + SORT_ORDER;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, buildingId);
            pstmt.setString(2, status);
            list = executeQuery(pstmt);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. 비품 상태 변경
    public boolean updateEquipmentStatus(Connection conn, String equipId, String newStatus) {
        String sql = "UPDATE Asset_Item SET Status = ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setString(2, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            return false;
        }
    }

    // 5. 건물 존재 여부 확인
    public boolean isBuildingExist(Connection conn, String bId) {
        String sql = "SELECT COUNT(*) FROM Building WHERE Building_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 6. 강의실 존재 여부 확인
    public boolean isClassroomExist(Connection conn, String bId, String room) {
        String sql = "SELECT COUNT(*) FROM Classroom WHERE Building_ID = ? AND Classroom_Num = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bId);
            pstmt.setString(2, room);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 7. 모든 모델명 조회
    public List<String> getAllModelNames(Connection conn) {
        List<String> models = new ArrayList<>();
        String sql = "SELECT Model_Name FROM Equipment_Type ORDER BY Model_Name";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                models.add(rs.getString("Model_Name"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return models;
    }

    // 8. 소모품 중복 확인 (ID 반환)
    public String getExistingConsumableId(Connection conn, String bId, String room, String model) {
        String sql = "SELECT CE.Equipment_ID FROM Classroom_Equipment CE "
                   + "WHERE CE.Building_ID = ? AND CE.Classroom_Num = ? "
                   + "AND CE.Model_Name = ? AND CE.Management_Style = 'Consumable'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bId);
            pstmt.setString(2, room);
            pstmt.setString(3, model);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // 9. 자산 추가 (트랜잭션)
    public boolean addAsset(Connection conn, String newId, String bId, String room, String model) {
        String sql1 = "INSERT INTO Classroom_Equipment (Equipment_ID, Management_Style, Building_ID, Classroom_Num, Model_Name) VALUES (?, 'Asset', ?, ?, ?)";
        String sql2 = "INSERT INTO Asset_Item (Equipment_ID, Serial_Number, Status) VALUES (?, ?, 'Normal')";
        
        try {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, newId);
                pstmt.setString(2, bId);
                pstmt.setString(3, room);
                pstmt.setString(4, model);
                pstmt.executeUpdate();
            }
            try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                pstmt.setString(1, newId);
                pstmt.setString(2, "SN-" + newId);
                pstmt.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    // 10. 소모품 추가 (트랜잭션)
    public boolean addNewConsumable(Connection conn, String newId, String bId, String room, String model, int qty) {
        String sql1 = "INSERT INTO Classroom_Equipment (Equipment_ID, Management_Style, Building_ID, Classroom_Num, Model_Name) VALUES (?, 'Consumable', ?, ?, ?)";
        String sql2 = "INSERT INTO Consumable_Stock (Equipment_ID, Quantity) VALUES (?, ?)";
        
        try {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setString(1, newId);
                pstmt.setString(2, bId);
                pstmt.setString(3, room);
                pstmt.setString(4, model);
                pstmt.executeUpdate();
            }
            try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                pstmt.setString(1, newId);
                pstmt.setInt(2, qty);
                pstmt.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            return false;
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    // 11. 소모품 수량 덮어쓰기
    public boolean updateConsumableQty(Connection conn, String equipId, int newQty) {
        String sql = "UPDATE Consumable_Stock SET Quantity = ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newQty);
            pstmt.setString(2, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    // 12. 소모품 수량 보충 (증가)
    public boolean increaseConsumableQty(Connection conn, String equipId, int amountToAdd) {
        String sql = "UPDATE Consumable_Stock SET Quantity = Quantity + ? WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amountToAdd);
            pstmt.setString(2, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    // 13. 비품 삭제
    public boolean deleteEquipment(Connection conn, String equipId) {
        String sql = "DELETE FROM Classroom_Equipment WHERE Equipment_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, equipId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }
    
    // 14. 모든 건물 ID 목록 조회
    public List<String> getAllBuildingIds(Connection conn) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT BUILDING_ID FROM CLASSROOM_EQUIPMENT ORDER BY BUILDING_ID";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("BUILDING_ID"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    //ResultSet 매핑
    private List<EquipmentDTO> executeQuery(PreparedStatement pstmt) throws SQLException {
        List<EquipmentDTO> list = new ArrayList<>();
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(new EquipmentDTO(
                    rs.getString("Equipment_ID"),
                    rs.getString("Management_Style"),
                    rs.getString("Building_ID"),
                    rs.getString("Classroom_Num"),
                    rs.getString("Model_Name"),
                    rs.getString("Serial_Number"),
                    rs.getString("Status"),
                    rs.getInt("Quantity"),
                    rs.getString("Equipment_Name"),
                    rs.getInt("Capacity")
                ));
            }
        }
        return list;
    }
}