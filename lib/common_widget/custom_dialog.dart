import 'package:flutter/material.dart';
import 'package:test_control/common_widget/primary_button.dart';
import '../constant/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onConfirm;

  const CustomDialog({
    super.key,
    required this.message,
    this.isError = true,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          isError ? 'Error' : 'Confirm',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isError) ...[
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: PrimaryButton(
                    title: 'OK',
                    onTap: () {
                      Navigator.of(context).pop();
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
