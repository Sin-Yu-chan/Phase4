package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class UsageLogDTO {
    private String logId;
    private Timestamp startTime;
    private Timestamp endTime;
    private String userId;
    private String userName;      
    private String equipmentId;
    private String modelName;     

    public UsageLogDTO(String logId, Timestamp startTime, Timestamp endTime, 
                       String userId, String userName, String equipmentId, String modelName) {
        this.logId = logId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.userId = userId;
        this.userName = userName;
        this.equipmentId = equipmentId;
        this.modelName = modelName;
    }

    // Getters
    public String getLogId() { return logId; }
    public Timestamp getStartTime() { return startTime; }
    public Timestamp getEndTime() { return endTime; }
    public String getUserId() { return userId; }
    public String getUserName() { return userName; }
    public String getEquipmentId() { return equipmentId; }
    public String getModelName() { return modelName; }

    // 날짜 포맷팅 헬퍼
    public String getFormattedTime() {
        SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
        String start = (startTime != null) ? sdf.format(startTime) : "-";
        String end = (endTime != null) ? sdf.format(endTime) : "사용중";
        return start + " ~ " + end;
    }

    @Override
    public String toString() {
        return String.format("[%s] %s(%s) used %s(%s)", logId, userName, userId, modelName, equipmentId);
    }
}