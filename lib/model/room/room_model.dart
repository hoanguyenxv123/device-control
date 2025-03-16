import '../device/device_model.dart';

class RoomModel {
  final String id; // 🔥 Thêm ID từ Firestore
  final String name;
  final String iconPath;
  final int color;
  final String imagePath;
  final List<DeviceModel> deviceList;

  RoomModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    required this.imagePath,
    required this.deviceList,
  });

  /// **🔥 Chuyển từ Firestore JSON thành RoomModel**
  factory RoomModel.fromJson(String id, Map<String, dynamic> json) {
    return RoomModel(
      id: id, // ✅ Lấy ID từ Firestore
      name: json['name'] ?? '',
      iconPath: json['iconPath'] ?? '',
      color: json['color'] ?? 0xFFFFFFFF, // ✅ Mặc định là trắng
      imagePath: json['imagePath'] ?? '',
      deviceList: (json['deviceList'] as List<dynamic>?)
          ?.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  /// **🔥 Chuyển RoomModel thành JSON để lưu Firestore**
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconPath': iconPath,
      'color': color,
      'imagePath': imagePath,
      'deviceList': deviceList.map((e) => e.toJson()).toList(),
    };
  }
}
