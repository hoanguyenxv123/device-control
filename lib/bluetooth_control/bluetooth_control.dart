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

    List<BluetoothDevice> connectedDevices =
        await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      BluetoothDevice device = connectedDevices.first;
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
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

  Future<void> sendCommand(int deviceId, bool turnOn) async {
    if (controlCharacteristic != null) {
      String command = "$deviceId:${turnOn ? "1" : "0"}\n";

      controlCharacteristic!.write(command.codeUnits, withoutResponse: true);
      await Future.delayed(Duration(milliseconds: 15));
    } else {
      print("Error!");
    }
  }
}
