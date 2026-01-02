import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

import '../../modules/home/controllers/home_controller.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      HomeController homeController = Get.find<HomeController>();

    return Center(
      child: Neumorphic(
        style: NeumorphicStyle(
          color: Get.find<HomeController>().isDarkMode.value 
              ? AppColors.darkBackground 
              : AppColors.lightBackground,
          boxShape: NeumorphicBoxShape.circle(),
          depth: 8,
        ),
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
          ),
        ),
      ),
    );
  }
}