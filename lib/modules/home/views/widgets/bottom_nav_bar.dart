import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/home/views/widgets/nav_button.dart';

import '../../../../core/themes/colors.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth:
            Get.isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: Get.isDarkMode
            ? AppConstants.darkIntensity
            : AppConstants.lightIntensity,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavButton(
                  
                  icon: Icons.home,
                  isActive: controller.currentIndex.value == 0,
                  onTap: () => controller.changePage(0),
                  color: Colors.blueAccent,
                ),
                NavButton(
                  icon: Icons.chat,
                  isActive: controller.currentIndex.value == 1,
                  onTap: () => controller.changePage(1),
                  color: Colors.greenAccent,
                ),
                NavButton(
                  icon: Icons.article,
                  isActive: controller.currentIndex.value == 2,
                  onTap: () => controller.changePage(2),
                  color: Colors.orangeAccent,
                ),
                NavButton(
                  icon: Icons.person,
                  isActive: controller.currentIndex.value == 3,
                  onTap: () => controller.changePage(3),
                  color: Colors.purpleAccent,
                ),
              ],
            )),
      ),
    );
  }
}
