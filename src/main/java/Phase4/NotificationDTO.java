package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class NotificationDTO {
    private String notifId;
    private String type;
    private Timestamp time;
    private String content;
    private String reportId;

    public NotificationDTO(String notifId, String type, Timestamp time, String content, String reportId) {
        this.notifId = notifId;
        this.type = type;
        this.time = time;
        this.content = content;
        this.reportId = reportId;
    }
    
    // Getters
    public String getNotifId() { return notifId; }
    public String getType() { return type; }
    public Timestamp getTime() { return time; }
    public String getContent() { return content; }
    public String getReportId() { return reportId; }

    // 날짜 포맷팅 헬퍼
    public String getFormattedTime() {
        return new SimpleDateFormat("MM-dd HH:mm").format(time);
    }

    @Override
    public String toString() {
        return String.format("[%s] %s : %s (Report: %s)", getFormattedTime(), type, content, reportId);
    }
}