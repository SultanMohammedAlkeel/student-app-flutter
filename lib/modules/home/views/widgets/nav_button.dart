import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/colors.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const NavButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isActive ? 52 : 50,
        height: isActive ? 52 : 50,
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
            depth: isActive ? AppConstants.pressed : AppConstants.unpressed,
            intensity: Get.isDarkMode
                ? AppConstants.darkIntensity
                : AppConstants.lightIntensity,
            color: NeumorphicTheme.baseColor(context),
            border: NeumorphicBorder(
              color: isActive ? color.withOpacity(0.5) : Colors.transparent,
              width: isActive ? 2 : 0,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? color : color.withOpacity(0.7),
            size: isActive ? 30 : 25,
          ),
        ),
      ),
    );
  }
}
