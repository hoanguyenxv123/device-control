import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothControl {
  BluetoothCharacteristic? controlCharacteristic;

  /// 🔥 Tìm đặc tính Bluetooth để gửi lệnh
  Future<void> findControlCharacteristic() async {
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

  /// 🔥 Gửi lệnh Bluetooth
  Future<void> sendCommand(int deviceId, bool turnOn) async {
    if (controlCharacteristic != null) {
      String command = "$deviceId:${turnOn ? "1" : "0"}";
      await controlCharacteristic!.write(command.codeUnits);
      print("🔵 Gửi lệnh: $command");
    } else {
      print("⚠️ Chưa tìm thấy đặc tính ghi dữ liệu!");
    }
  }


}
