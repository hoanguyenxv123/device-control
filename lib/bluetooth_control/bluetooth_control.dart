import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothControl {
  // Biến lưu đặc tính Bluetooth để gửi lệnh
  BluetoothCharacteristic? controlCharacteristic;

  /// 🔥 Tìm đặc tính Bluetooth để gửi lệnh
  Future<void> findControlCharacteristic() async {
    if (controlCharacteristic != null) {
      print("✅ Đặc tính đã tìm thấy, không cần tìm lại.");
      return;
    }

    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      BluetoothDevice device = connectedDevices.first;
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            controlCharacteristic = characteristic;
            print("✅ Đã tìm thấy đặc tính ghi dữ liệu.");
            return;
          }
        }
      }
    }
    print("❌ Không tìm thấy đặc tính ghi dữ liệu.");
  }


  /// 🔥 Gửi lệnh Bluetooth đến thiết bị
  Future<void> sendCommand(int deviceId, bool turnOn) async {
    // Kiểm tra xem đã tìm thấy đặc tính ghi dữ liệu chưa
    if (controlCharacteristic != null) {
      // Tạo chuỗi lệnh với định dạng: "<deviceId>:<1 hoặc 0>"
      String command = "$deviceId:${turnOn ? "1" : "0"}";

      // Gửi lệnh dưới dạng danh sách mã ký tự (UTF-16 code units)
      // await controlCharacteristic!.write(command.codeUnits);
      controlCharacteristic!.write(command.codeUnits, withoutResponse: true);

      // In ra lệnh đã gửi
      print("🔵 Gửi lệnh: $command");
    } else {
      // Nếu chưa tìm thấy đặc tính ghi dữ liệu, thông báo lỗi
      print("⚠️ Chưa tìm thấy đặc tính ghi dữ liệu!");
    }
  }
}
