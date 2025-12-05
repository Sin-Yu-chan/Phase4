package Phase4;

public class StatDTO {
    private String label; // 항목 이름 (예: 101관, PC, 컴퓨터공학과)
    private int value;    // 수치 (예: 50, 12)

    public StatDTO(String label, int value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() { return label; }
    public int getValue() { return value; }
}