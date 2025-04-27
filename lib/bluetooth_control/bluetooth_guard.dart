import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:test_control/screens/bluetooth/bluetooth_control_screen.dart';

class BluetoothGuard extends StatelessWidget {
  final Widget child;

  const BluetoothGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) async {
        final devices = await FlutterBluePlus.connectedDevices;
        return devices.isNotEmpty;
      }),
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        if (!isConnected) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BluetoothControlScreen(),
              ),
            );
          });
        }

        // Show nội dung nếu đang kết nối Bluetooth
        return child;
      },
    );
  }
}
