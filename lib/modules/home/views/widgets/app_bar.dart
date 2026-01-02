import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../../../../core/themes/colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return NeumorphicAppBar(
      title: NeumorphicText(
        'Student App',
        style: NeumorphicStyle(
          color: Get.isDarkMode
              ? AppConstants.lightBackgroundColor
              : AppConstants.darkBackgroundColor,
        ),
        textStyle: NeumorphicTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: NeumorphicButton(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.stadium(),
          depth:
              Get.isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
          intensity: Get.isDarkMode
              ? AppConstants.darkIntensity
              : AppConstants.lightIntensity,
          color: Colors.transparent,
          shadowLightColor: Get.isDarkMode ? Colors.grey[800]! : Colors.white,
          shadowDarkColor: Get.isDarkMode ? Colors.black : Colors.grey.shade400,
        ),
        padding: const EdgeInsets.all(0),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        child: Icon(
          Icons.menu,
          color: Get.isDarkMode
              ? AppConstants.lightBackgroundColor
              : AppConstants.darkBackgroundColor,
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8.0),
      //     child: Neumorphic(
      //       style: NeumorphicStyle(
      //         shape: NeumorphicShape.convex,
      //         boxShape: NeumorphicBoxShape.circle(),
      //         depth: Get.isDarkMode
      //             ? AppConstants.darkDepth
      //             : AppConstants.lightDepth,
      //         intensity: Get.isDarkMode
      //             ? AppConstants.darkIntensity
      //             : AppConstants.lightIntensity,
      //         color: NeumorphicTheme.baseColor(context),
      //       ),
      //       child: IconButton(
      //         iconSize: 24,
      //         padding: EdgeInsets.zero,
      //         icon:  Icon(
      //               Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
      //               color: Get.isDarkMode
      //                   ? AppConstants.lightBackgroundColor
      //                   : AppConstants.darkBackgroundColor,
      //             ),
      //         onPressed: controller.toggleTheme,
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
