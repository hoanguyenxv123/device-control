import 'package:flutter/material.dart';
import 'package:test_control/common_widget/device.dart';
import 'package:test_control/common_widget/primary_appbar.dart';
import 'package:test_control/common_widget/title_add_new.dart';
import 'package:test_control/screens/room/widget/header_room.dart';

import '../../bluetooth_control/bluetooth_guard.dart';
import '../../data/remote/firestore_service.dart';
import '../../model/device/device_model.dart';
import '../../model/room/room_model.dart';
import '../add_device/add_device_screen.dart';

class RoomScreen extends StatefulWidget {
  final RoomModel room;

  const RoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isListening = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return BluetoothGuard(
      child: Scaffold(
        backgroundColor: Colors.white.withAlpha((255.0 * 0.95).round()),
        body: StreamBuilder<List<DeviceModel>>(
          stream: _firestoreService.getDevicesStream(widget.room.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            List<DeviceModel> devices = snapshot.data!;

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Image.asset(
                        widget.room.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 40,
                      ),
                      child: PrimaryAppbar(),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 20,
                      right: 20,
                      child: HeaderRoom(
                        roomModel: widget.room,
                        devices: devices,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TitleAddNew(
                    title: '',
                    addNew: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddDeviceScreen(roomId: widget.room.id),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        return Device(
                          device: devices[index],
                          roomId: widget.room.id,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}
