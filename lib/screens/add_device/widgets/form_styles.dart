import 'package:flutter/material.dart';

import '../../../constant/app_colors.dart';

InputDecoration customInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
    filled: true,
  );
}
