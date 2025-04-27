class DeviceModel {
  final String? id;
  final int devicePort;
  final String name;
  final String controllerName;
  final String type;
  final String imagePath;
  final bool isOn;

  DeviceModel({
    this.id,
    required this.devicePort,
    required this.name,
    required this.controllerName,
    required this.type,
    required this.imagePath,
    required this.isOn,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json, String id) {
    return DeviceModel(
      id: id,
      devicePort: json['devicePort'],
      name: json['name'],
      controllerName: json['controllerName'] ?? '',
      type: json['type'],
      imagePath: json['imagePath'],
      isOn: json['isOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devicePort': devicePort,
      'name': name,
      'controllerName': controllerName,
      'type': type,
      'imagePath': imagePath,
      'isOn': isOn,
    };
  }
}
