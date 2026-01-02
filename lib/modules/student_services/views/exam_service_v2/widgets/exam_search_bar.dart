import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/colors.dart';
import '../utils/debouncer.dart';
import '../exam_controller.dart';
import '../exam_filter_model.dart';
import '../neumorphic_widgets.dart';

class ExamSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  const ExamSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
    this.hasActiveFilters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: NeumorphicCard(
        color: Get.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        depth: Get.isDarkMode ? -3 : 3,
        intensity: 1,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // زر الفلتر
            NeumorphicButton(
              color: Get.isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              onPressed: onFilterTap,
              depth: hasActiveFilters ? 2 : 1,
              intensity: 1,
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.filter_list,
                color: hasActiveFilters
                    ? Theme.of(context).primaryColor
                    : Get.isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
              ),
            ),

            // حقل البحث
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  fillColor: Get.isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  hintText: 'ابحث عن امتحان...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  hintStyle: TextStyle(
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor.withOpacity(0.5)
                        : AppColors.textColor.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),

            // زر المسح
            AnimatedOpacity(
              opacity: controller.text.isNotEmpty ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: controller.text.isNotEmpty
                  ? NeumorphicButton(
                      onPressed: onClear,
                      depth: 1,
                      intensity: 1,
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.clear,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor
                            : AppColors.textColor,
                      ),
                    )
                  : SizedBox(width: 48),
            ),
          ],
        ),
      ),
    );
  }
}
