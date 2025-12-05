package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class ReportDTO {
    private String reportId;
    private String reportType;
    private String content;
    private String status;
    private Timestamp reportDate;
    private String userId;
    private String equipmentId;
    private String modelName; // [수정] DB 컬럼명에 맞춰 Model_Name 저장
    private String buildingId;
    private String classroomNum;

    public ReportDTO(String reportId, String reportType, String content, String status, 
                     Timestamp reportDate, String userId, String equipmentId, 
                     String modelName, // [수정]
                     String buildingId, String classroomNum) {
        this.reportId = reportId;
        this.reportType = reportType;
        this.content = content;
        this.status = status;
        this.reportDate = reportDate;
        this.userId = userId;
        this.equipmentId = equipmentId;
        this.modelName = modelName; // [수정]
        this.buildingId = buildingId;
        this.classroomNum = classroomNum;
    }

    // Getter
    public String getReportId() { return reportId; }
    public String getReportType() { return reportType; }
    public String getContent() { return content; }
    public String getStatus() { return status; }
    public Timestamp getReportDate() { return reportDate; }
    public String getUserId() { return userId; }
    public String getEquipmentId() { return equipmentId; }
    public String getModelName() { return modelName; } // [수정] getModelName으로 변경
    public String getBuildingId() { return buildingId; }
    public String getClassroomNum() { return classroomNum; }

    public String getFormattedTime() {
        if (reportDate == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(reportDate);
    }
}