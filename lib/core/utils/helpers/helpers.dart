import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../themes/colors.dart';

class Helpers {
  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 3),
    );
  }
}