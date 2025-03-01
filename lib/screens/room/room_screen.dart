import 'package:flutter/material.dart';
import 'package:test_control/common_widget/device.dart';
import 'package:test_control/common_widget/primary_appbar.dart';
import 'package:test_control/common_widget/title_add_new.dart';
import 'package:test_control/screens/room/widget/header_room.dart';

import '../../bluetooth_control/voice_control.dart';
import '../../data/remote/firestore_service.dart';
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
    await _firestoreService.updateDeviceByPort(
      widget.room.id,
      widget.room.deviceList.firstWhere((d) => d.devicePort == deviceId).devicePort,
      turnOn,
    );

    setState(() {
      widget.room.deviceList.firstWhere((d) => d.devicePort == deviceId).isOn = turnOn;
    });
  }

  void _handleVoiceCommand(String command) {
    _voiceControl.processVoiceCommand(
      command,
      widget.room.deviceList.map((d) => d.devicePort).toList(),
      sendCommand,
          (deviceId, turnOn) { // ✅ Truyền thêm callback cập nhật UI
        setState(() {
          widget.room.deviceList.firstWhere((d) => d.devicePort == deviceId).isOn = turnOn;
        });
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
          TitleAddNew(title: 'Devices', addNew: () {}),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: widget.room.deviceList.length,
                itemBuilder: (context, index) {
                  return Device(
                    device: widget.room.deviceList[index],
                    roomId: widget.room.id,
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
        child: Icon(isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
