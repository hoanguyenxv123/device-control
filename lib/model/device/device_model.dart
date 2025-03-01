class DeviceModel {
  final int devicePort; // ID của thiết bị, tương ứng với chân trên Arduino
  final String name; // Tên thiết bị (Lights, SmartTV, ...)
  final String type; // Loại thiết bị (Phillips Hue 2, Apple TV 4K, ...)
  final String imagePath; // Đường dẫn hình ảnh thiết bị
  bool isOn; // Trạng thái thiết bị (Bật/Tắt)

  DeviceModel({
    required this.devicePort,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.isOn,
  });

  /// Chuyển từ Firestore JSON sang `DeviceModel`
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      devicePort: json['devicePort'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imagePath: json['imagePath'] ?? '',
      isOn: json['isOn'] ?? false,
    );
  }

  /// Chuyển từ `DeviceModel` sang Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': devicePort,
      'name': name,
      'type': type,
      'imagePath': imagePath,
      'isOn': isOn,
    };
  }
}
