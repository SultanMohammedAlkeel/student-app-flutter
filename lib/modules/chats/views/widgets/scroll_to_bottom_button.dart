import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart' as ico_plus;
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const ScrollToBottomButton({
    Key? key,
    required this.onPressed,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final HomeController _homeController = Get.find<HomeController>();

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
          child: NeumorphicFloatingActionButton(
            style: NeumorphicStyle(
              color: Get.isDarkMode
                  ? _homeController.getPrimaryColor()
                  : const Color.fromARGB(255, 1, 124, 102),
              boxShape: NeumorphicBoxShape.circle(),
              depth: 2,
              intensity: 0.6,
              shadowLightColor: Get.isDarkMode ? Colors.black12 : Colors.white,
              shadowDarkColor: Get.isDarkMode ? Colors.white24 : Colors.black26,
            ),
            child:  Icon(
              ico_plus.Bootstrap.arrow_down,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onPressed,
            mini: true,
          ),
        ),
      ),
    );
  }
}
