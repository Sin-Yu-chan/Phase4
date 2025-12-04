package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class ReservationDTO {
    private String reservationId;
    private Timestamp startTime;
    private Timestamp endTime;
    private String userId;
    private String equipmentId;
    
    // JOIN을 통해 가져온 추가 정보
    private String modelName;
    private String equipmentName;

    public ReservationDTO(String reservationId, Timestamp startTime, Timestamp endTime, 
                          String userId, String equipmentId, String modelName, String equipmentName) {
        this.reservationId = reservationId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.userId = userId;
        this.equipmentId = equipmentId;
        this.modelName = modelName;
        this.equipmentName = equipmentName;
    }

    // Getters
    public String getReservationId() { return reservationId; }
    public Timestamp getStartTime() { return startTime; }
    public Timestamp getEndTime() { return endTime; }
    public String getUserId() { return userId; }
    public String getEquipmentId() { return equipmentId; }
    public String getModelName() { return modelName; }
    public String getEquipmentName() { return equipmentName; }

    // 날짜 포맷팅 (예: 2025-11-20 14:00)
    public String getFormattedTime(Timestamp ts) {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm").format(ts);
    }

    @Override
    public String toString() {
        return String.format("[%s] %s (%s) : %s ~ %s", 
            reservationId, equipmentName, modelName, 
            getFormattedTime(startTime), getFormattedTime(endTime));
    }
}