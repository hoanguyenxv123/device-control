import 'package:flutter/material.dart';
import '../bluetooth_control/voice_control.dart';
import '../data/remote/firestore_service.dart';
import '../model/room/room_model.dart';

class MicControl extends StatefulWidget {
  final List<RoomModel> rooms; // Nhận danh sách phòng

  const MicControl({super.key, required this.rooms});

  @override
  State<MicControl> createState() => _MicControlState();
}

class _MicControlState extends State<MicControl> {
  late VoiceControl _voiceControl;
  bool isListening = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _voiceControl = VoiceControl(onCommandReceived: _handleVoiceCommand);
  }

  Future<void> sendCommand(String roomId, int deviceId, bool turnOn) async {
    await _firestoreService.updateDeviceByPort(roomId, deviceId, turnOn);
  }

  void _handleVoiceCommand(String command) {
    String lowerCommand = command.toLowerCase();
    bool? turnOn;

    if (lowerCommand.contains("bật")) {
      turnOn = true;
    } else if (lowerCommand.contains("tắt")) {
      turnOn = false;
    }

    if (turnOn == null) {
      print("❌ Không xác định được hành động (bật/tắt) từ lệnh: $command");
      return;
    }

    // Kiểm tra danh sách thiết bị
    for (var room in widget.rooms) {
      print("📌 Kiểm tra phòng: ${room.name}");
      for (var device in room.deviceList) {
        print("🔹 Thiết bị: ${device.name} (Port: ${device.devicePort})");
      }
    }

    // Tìm thiết bị
    for (var room in widget.rooms) {
      for (var device in room.deviceList) {
        if (lowerCommand.contains(device.name.toLowerCase())) {
          print(
            "✅ Nhận lệnh '${command}' - Cập nhật thiết bị: ${device.name} (Port: ${device.devicePort})",
          );

          // Gửi cập nhật lên Firestore
          _firestoreService.updateDeviceByPort(
            room.id,
            device.devicePort,
            turnOn,
          );
          return;
        }
      }
    }

    print("❌ Không tìm thấy thiết bị phù hợp với lệnh: $command");
  }

  void _toggleListening() {
    if (isListening) {
      _voiceControl.stopListening();
    } else {
      _voiceControl.startListening();
    }
    setState(() {
      isListening = !isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggleListening,
      backgroundColor: isListening ? Colors.red : Colors.blue,
      child: Icon(isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
    );
  }
}
