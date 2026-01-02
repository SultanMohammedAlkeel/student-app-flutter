import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart'hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String animationPath;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.animationPath,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final buttonColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animationPath,
              width: 250.w,
              height: 250.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              subtitle,
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add, size: 20.sp),
                label: Text(
                  actionText!,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


