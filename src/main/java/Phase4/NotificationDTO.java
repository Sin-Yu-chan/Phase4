package Phase4;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class NotificationDTO {
    private String notifId;
    private String type;
    private Timestamp time;
    private String content;
    private String reportId;
    private String isChecked; // [★추가] 읽음 여부 ('Y' or 'N')

    // 생성자 수정
    public NotificationDTO(String notifId, String type, Timestamp time, String content, String reportId, String isChecked) {
        this.notifId = notifId;
        this.type = type;
        this.time = time;
        this.content = content;
        this.reportId = reportId;
        this.isChecked = isChecked;
    }
    
    // Getters
    public String getNotifId() { return notifId; }
    public String getType() { return type; }
    public Timestamp getTime() { return time; }
    public String getContent() { return content; }
    public String getReportId() { return reportId; }
    public String getIsChecked() { return isChecked; } // Getter 추가

    public String getFormattedTime() {
        return new SimpleDateFormat("MM-dd HH:mm").format(time);
    }

    @Override
    public String toString() {
        return String.format("[%s] %s : %s (Read: %s)", getFormattedTime(), type, content, isChecked);
    }
}