import 'package:flutter/material.dart';

import '../constant/app_colors.dart';


class CustomTextField extends StatefulWidget {
  final String title;
  final bool passCheck;
  final TextEditingController textEditingController;
  const CustomTextField({
    super.key,
    required this.title,
    required this.textEditingController,
    this.passCheck = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;
  bool showClearIcon = false;

  @override
  void initState() {
    super.initState();

    // Lắng nghe thay đổi focus
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // Lắng nghe thay đổi nội dung TextField
    widget.textEditingController.addListener(() {
      setState(() {
        showClearIcon = widget.textEditingController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Giải phóng FocusNode
    widget.textEditingController.removeListener(() {}); // Xóa listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused
              ? AppColors.primaryColor.withOpacity(0.8)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
      child: Center(
        child: TextField(
          controller: widget.textEditingController,
          obscureText: widget.passCheck ? obscureText : false,
          focusNode: _focusNode, // Gán focusNode để theo dõi trạng thái focus
          decoration: InputDecoration(
            hintText: widget.title,
            hintStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            suffixIcon: showClearIcon
                ? IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      widget.textEditingController.clear();
                    },
                  ),
                  if (widget.passCheck)
                    IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                ],
              ),
            )
                : null,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
