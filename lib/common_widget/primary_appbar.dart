import 'package:flutter/material.dart';
import 'package:test_control/constant/app_colors.dart';

class PrimaryAppbar extends StatelessWidget {
  final bool checkBack;

  const PrimaryAppbar({super.key, this.checkBack = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: checkBack ? Colors.white : Colors.blue.shade100,
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 24,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
