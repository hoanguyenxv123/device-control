class DeviceMapping {
  // Dùng Map để ánh xạ devicePort với tên thiết bị
  static const Map<int, String> deviceMap = {
    2: "đèn phòng khách", // khách
    3: "đèn phòng bếp", //ngủ
    4: "đèn phòng học", //ngủ
    5: "đèn phòng tắm", // bếp
    6: "đèn phòng ngủ", // phòng học
    7: "tivi", // tắm
  };

  // Phương thức để lấy tên thiết bị từ devicePort
  static String getDeviceName(int devicePort) {
    return deviceMap[devicePort] ?? "Thiết bị không xác định";
  }

  // Phương thức để lấy devicePort từ tên thiết bị
  static int? getDevicePort(String deviceName) {
    for (var entry in deviceMap.entries) {
      if (entry.value.toLowerCase() == deviceName.toLowerCase()) {
        return entry.key;
      }
    }
    return null;  // Nếu không tìm thấy
  }
}
