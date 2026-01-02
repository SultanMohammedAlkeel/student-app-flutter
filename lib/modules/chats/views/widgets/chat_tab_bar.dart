// ignore_for_file: unused_local_variable

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ChatTabBar extends StatelessWidget {
  final Function(int) onTabChanged;
  final RxInt currentIndex;

  const ChatTabBar({
    Key? key,
    required this.onTabChanged,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = NeumorphicTheme.baseColor(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      width: 430.w,
      height: 50.h, // Reduced height for a cleaner look
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(context, 0, 'الدردشات'),
          _buildTab(context, 1, 'المجموعات'),
          _buildTab(context, 2, 'القنوات'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = NeumorphicTheme.baseColor(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Obx(() {
      final isSelected = currentIndex.value == index;
  final HomeController _homeController = Get.find<HomeController>();

      return Expanded(
        child: GestureDetector(
          onTap: () => onTabChanged(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? _homeController.getPrimaryColor()
                      : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? _homeController.getPrimaryColor()
                      : secondaryTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    });
  }
}
