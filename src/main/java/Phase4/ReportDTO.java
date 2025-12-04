package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class ReportDTO {
    private String reportId;
    private String reportType;
    private Timestamp time;
    private String status;
    private String content;
    private String reporterId;
    private String equipmentId;
    
    // 위치 정보 (JOIN 결과)
    private String buildingId;
    private String classroomNum;

    public ReportDTO(String reportId, String reportType, Timestamp time, String status, 
                     String content, String reporterId, String equipmentId, 
                     String buildingId, String classroomNum) {
        this.reportId = reportId;
        this.reportType = reportType;
        this.time = time;
        this.status = status;
        this.content = content;
        this.reporterId = reporterId;
        this.equipmentId = equipmentId;
        this.buildingId = buildingId;
        this.classroomNum = classroomNum;
    }

    // Getters
    public String getReportId() { return reportId; }
    public String getReportType() { return reportType; }
    public Timestamp getTime() { return time; }
    public String getStatus() { return status; }
    public String getContent() { return content; }
    public String getReporterId() { return reporterId; }
    public String getEquipmentId() { return equipmentId; }
    public String getBuildingId() { return buildingId; }
    public String getClassroomNum() { return classroomNum; }

    // 날짜 포맷팅 헬퍼
    public String getFormattedTime() {
        return new SimpleDateFormat("MM-dd HH:mm").format(time);
    }
}