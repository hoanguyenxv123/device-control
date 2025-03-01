import 'package:flutter/material.dart';
import 'package:test_control/constant/app_colors.dart';
import 'package:test_control/data/remote/firestore_service.dart';

class SwitchButton extends StatelessWidget {
  final String roomId;
  final int devicePort;
  final Function(bool) onChanged;

  const SwitchButton({
    super.key,
    required this.roomId,
    required this.devicePort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool?>(
      stream: FirestoreService().deviceStateStream(roomId, devicePort),
      // Lắng nghe Firestore
      builder: (context, snapshot) {
        bool isOn =
            snapshot.data ??
            false; // Giá trị mặc định nếu Firestore chưa có dữ liệu

        return GestureDetector(
          onTap: () async {
            bool newState = !isOn;
            await FirestoreService().updateDeviceByPort(
              roomId,
              devicePort,
              newState,
            );
            onChanged(newState);
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
                margin: EdgeInsets.symmetric(horizontal: 3),
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
