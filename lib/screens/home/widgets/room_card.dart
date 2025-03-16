import 'package:flutter/material.dart';
import 'package:test_control/model/room/room_model.dart';

class RoomCard extends StatelessWidget {
  final VoidCallback onTap;
  final RoomModel room;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Color(room.color), BlendMode.srcIn),
              child: Image.asset(room.iconPath, width: 40, height: 40),
            ),
            SizedBox(height: 10),
            Text(
              room.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "${room.deviceList.length} Devices",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
