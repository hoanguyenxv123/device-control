import 'package:flutter/material.dart';

import '../../../common_widget/switch_button.dart';
import '../../../constant/app_colors.dart';
import '../../../model/room/room_model.dart';

class HeaderRoom extends StatelessWidget {
  final RoomModel roomModel;

  const HeaderRoom({super.key, required this.roomModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255.0 * 0.5).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255.0 * 0.1).round()),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primaryColor,
                      ),
                      child: Center(
                        child: Image.asset(
                          roomModel.iconPath,
                          height: 25,
                          width: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      roomModel.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SwitchButton(
                  roomId: roomModel.id, // Đảm bảo roomModel.id không bị rỗng
                  devicePort: 0,
                  onChanged: (bool value) {},
                ),

              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[700]),
                children: [
                  TextSpan(text: "${roomModel.devices} devices"),
                  TextSpan(
                    text: "  •  ",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  TextSpan(text: "1000 watt"),
                  TextSpan(
                    text: "  •  ",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  TextSpan(text: "1000 volt"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
