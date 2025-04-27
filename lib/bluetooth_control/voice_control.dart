import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../model/device/device_model.dart';
import 'bluetooth_control.dart';

class VoiceControl {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final BluetoothControl _bluetoothControl = BluetoothControl();
  final Function(String) onCommandReceived;

  final Function(String)? onSpeechChanged;

  VoiceControl({required this.onCommandReceived, this.onSpeechChanged});

  List<DeviceModel> _cachedDevices = [];

  Future<void> refreshDevicesFromFirestore() async {
    final roomsSnapshot =
        await FirebaseFirestore.instance.collection('rooms').get();
    List<DeviceModel> devices = [];

    for (var roomDoc in roomsSnapshot.docs) {
      final deviceSnapshot =
          await roomDoc.reference.collection('deviceList').get();
      for (var deviceDoc in deviceSnapshot.docs) {
        final data = deviceDoc.data() as Map<String, dynamic>;
        devices.add(DeviceModel.fromJson(data, deviceDoc.id));
      }
    }

    _cachedDevices = devices;
    print("🔄 Đã làm mới danh sách thiết bị từ Firestore");
  }

  void startListening() async {
    await refreshDevicesFromFirestore();

    bool available = await _speech.initialize(
      onStatus: (status) => print("SpeechToText Status: $status"),
      onError: (error) => print("Lỗi: ${error.errorMsg}"),
    );

    if (available) {
      _speech.listen(
        onResult: (result) async {
          onSpeechChanged?.call(result.recognizedWords);
          if (result.finalResult) {
            final commandText = result.recognizedWords;
            print("📢 Lệnh nhận được: $commandText");
            onCommandReceived(commandText);
            await stopListening();
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<List<MapEntry<int, bool>>> processVoiceCommand(String command) async {
    command = command.toLowerCase().trim();
    print("📢 Xử lý lệnh giọng nói: $command");

    String normalize(String text) {
      return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    }

    List<MapEntry<int, bool>> actions = [];

    final RegExp exp = RegExp(r'\b(bật|tắt)\b\s+(.+?)(?=(\bbật\b|\btắt\b|$))');
    final matches = exp.allMatches(command);

    for (final match in matches) {
      final actionText = match.group(1); // "bật" hoặc "tắt"
      final deviceText = match.group(2); // phần thiết bị như "tivi", "quạt"

      if (actionText == null || deviceText == null) continue;

      bool isOn = actionText == 'bật';
      final cleanedDeviceText = normalize(deviceText);

      print("🔍 Đang xử lý: [$actionText] [$cleanedDeviceText]");

      for (var device in _cachedDevices) {
        if (device.controllerName.trim().isEmpty) continue;

        if (cleanedDeviceText.contains(normalize(device.controllerName))) {
          actions.add(MapEntry(device.devicePort, isOn));
          print(
            "🎯 Khớp với: ${device.controllerName} (Port: ${device.devicePort}) → ${isOn ? 'BẬT' : 'TẮT'}",
          );
        }
      }
    }

    if (actions.isEmpty) {
      print("❗ Không khớp với thiết bị nào.");
      return actions;
    }

    if (_bluetoothControl.controlCharacteristic == null) {
      print("⚠️ Đặc tính chưa được xác định, tìm kiếm...");
      await _bluetoothControl.findControlCharacteristic();
    }

    for (var action in actions) {
      _bluetoothControl.sendCommand(action.key, action.value);
      print(
        "🔄 Đã gửi lệnh đến thiết bị port ${action.key} (isOn: ${action.value})",
      );
    }

    return actions;
  }
}
