import '../device/device_model.dart';

class RoomModel {
  final String id;
  final String name;
  final String iconPath;
  final int color;
  final String imagePath;
  final List<DeviceModel> deviceList; // vẫn giữ để truyền đi khi cần

  RoomModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    required this.imagePath,
    required this.deviceList,
  });

  /// Chuyển từ Firestore JSON thành RoomModel
  factory RoomModel.fromJson(String id, Map<String, dynamic> json) {
    return RoomModel(
      id: id,
      name: json['name'] ?? '',
      iconPath: json['iconPath'] ?? '',
      color: json['color'] ?? 0xFFFFFFFF,
      imagePath: json['imagePath'] ?? '',
      deviceList: [], // sẽ gán sau bằng getDevices nếu cần
    );
  }

  /// Chuyển RoomModel thành JSON để lưu Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconPath': iconPath,
      'color': color,
      'imagePath': imagePath,
    };
  }
}
