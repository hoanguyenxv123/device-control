import 'package:flutter/material.dart';
import 'package:test_control/constant/app_colors.dart';
import 'package:test_control/data/remote/firestore_service.dart';

import '../bluetooth_control/bluetooth_control.dart';

class SwitchButton extends StatefulWidget {
  final String roomId;

  final bool isRoom;
  final int? devicePort;

  const SwitchButton({
    super.key,
    required this.roomId,
    this.devicePort,
    this.isRoom = false,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  final BluetoothControl _bluetoothControl = BluetoothControl();

  @override
  void initState() {
    super.initState();
    if (_bluetoothControl.controlCharacteristic == null) {
      print("⚠️ Đặc tính chưa được xác định, tìm kiếm...");
      _bluetoothControl.findControlCharacteristic();
    }
  }

  /// Lấy trạng thái tổng: tất cả thiết bị trong phòng có bật không
  Stream<bool> getRoomAllDevicesStateStream() {
    return FirestoreService().getDevicesStream(widget.roomId).map((devices) {
      if (devices.isEmpty) return false;
      return devices.every((device) => device.isOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream:
          widget.isRoom
              ? getRoomAllDevicesStateStream()
              : FirestoreService()
                  .deviceStateStream(widget.roomId, widget.devicePort!)
                  .map((event) => event ?? false),

      builder: (context, snapshot) {
        bool isOn = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            bool newState = !isOn;

            setState(() {
              isOn = newState;
            });

            if (widget.isRoom) {
              FirestoreService().toggleAllDevices(widget.roomId, newState);

              final devices = await FirestoreService().getDevices(
                widget.roomId,
              );
              for (var device in devices) {
                _bluetoothControl.sendCommand(device.devicePort, newState);
              }
            } else {
              if (widget.devicePort != null) {
                await FirestoreService().updateDeviceByPort(
                  widget.roomId,
                  widget.devicePort!,
                  newState,
                );
                _bluetoothControl.sendCommand(widget.devicePort!, newState);
              }
            }
          },
          child: Container(
            width: 56,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isOn ? AppColors.primaryColor : Colors.grey,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
