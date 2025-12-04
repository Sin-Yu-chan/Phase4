package Phase4;

public class EquipmentDTO {
    private String equipmentId;
    private String managementStyle;
    private String buildingId;
    private String classroomNum;
    private String modelName;
    private String serialNumber;
    private String status;
    private int quantity;
    private String equipmentName;
    private int roomCapacity;

    public EquipmentDTO(String equipmentId, String managementStyle, String buildingId, 
                        String classroomNum, String modelName, String serialNumber, 
                        String status, int quantity, String equipmentName, int roomCapacity) {
        this.equipmentId = equipmentId;
        this.managementStyle = managementStyle;
        this.buildingId = buildingId;
        this.classroomNum = classroomNum;
        this.modelName = modelName;
        this.serialNumber = serialNumber;
        this.status = status;
        this.quantity = quantity;
        this.equipmentName = equipmentName;
        this.roomCapacity = roomCapacity;
    }

    public String getEquipmentId() { return equipmentId; }
    public String getManagementStyle() { return managementStyle; }
    public String getBuildingId() { return buildingId; }
    public String getClassroomNum() { return classroomNum; }
    public String getModelName() { return modelName; }
    public String getSerialNumber() { return serialNumber; }
    public String getStatus() { return status; }
    public int getQuantity() { return quantity; }
    public String getEquipmentName() { return equipmentName; }
    public int getRoomCapacity() { return roomCapacity; }

    @Override
    public String toString() {
        return String.format("[%s] %s (%s)", equipmentId, equipmentName, modelName);
    }
}