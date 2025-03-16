import 'package:flutter/material.dart';
import 'package:test_control/common_widget/device.dart';
import 'package:test_control/common_widget/primary_appbar.dart';
import 'package:test_control/common_widget/title_add_new.dart';
import 'package:test_control/screens/room/widget/header_room.dart';

import '../../bluetooth_control/voice_control.dart';
import '../../data/remote/firestore_service.dart';
import '../../model/device/device_model.dart';
import '../../model/room/room_model.dart';

class RoomScreen extends StatefulWidget {
  final RoomModel room;

  const RoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late VoiceControl _voiceControl;
  bool isListening = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _voiceControl = VoiceControl(onCommandReceived: _handleVoiceCommand);
  }

  Future<void> sendCommand(int deviceId, bool turnOn) async {
    try {
      await _firestoreService.updateDeviceByPort(widget.room.id, deviceId, turnOn);
      print("✅ Gửi lệnh cập nhật thiết bị thành công: $deviceId - Trạng thái: $turnOn");
    } catch (e) {
      print("❌ Lỗi khi gửi lệnh cập nhật thiết bị: $e");
    }
  }

  void _handleVoiceCommand(String command) {
    _voiceControl.processVoiceCommand(
      command,
      widget.room.deviceList.map((d) => d.devicePort).toList(),
      sendCommand,
          (deviceId, turnOn) {
        print("🎤 Cập nhật UI từ giọng nói: $deviceId - Trạng thái: $turnOn");
      },
    );
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
    return Scaffold(
      backgroundColor: Colors.white.withAlpha((255.0 * 0.95).round()),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.asset(widget.room.imagePath, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: const PrimaryAppbar(),
              ),
              Positioned(
                bottom: -50,
                left: 20,
                right: 20,
                child: HeaderRoom(roomModel: widget.room),
              ),
            ],
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TitleAddNew(title: 'Devices', addNew: () {}),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<List<DeviceModel>>(
                stream: _firestoreService.getDevicesStream(widget.room.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<DeviceModel> devices = snapshot.data!;

                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return Device(
                        device: devices[index],
                        roomId: widget.room.id,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        backgroundColor: isListening ? Colors.red : Colors.blue,
        child: Icon(
          isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
