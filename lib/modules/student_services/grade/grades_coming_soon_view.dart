import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/widgets/custom_app_bar.dart';
import 'package:student_app/core/themes/colors.dart'hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';

class GradesComingSoonView extends StatelessWidget {
  const GradesComingSoonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(
        title: 'الدرجات',
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/soon.json', // يجب توفير هذا الملف في مجلد assets/animations
                width: 250.w,
                height: 250.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30.h),
              // Title
              Text(
                'خدمة الدرجات قريباً!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              // Subtitle
              Text(
                'نحن نعمل بجد لإطلاق هذه الخدمة قريباً. ترقبوا التحديثات!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


