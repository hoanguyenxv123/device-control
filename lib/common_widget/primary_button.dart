import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A5AE0),
                Color(0xFFB775FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                // Làm mềm màu đổ bóng
                offset: Offset(4, 4),
                // Dịch sang phải 4px và xuống dưới 4px
                blurRadius: 3,
                // Làm mờ bóng
                spreadRadius: 0.5, // Mở rộng vùng đổ bóng
              )
            ]),
        child: Center(
            child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }
}
