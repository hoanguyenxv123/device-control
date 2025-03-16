import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final Widget icon;
  const CustomIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      height: 46,
      width: 56,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(child: icon),
    );
  }
}
