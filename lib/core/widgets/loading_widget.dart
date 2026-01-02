import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart'hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final String? animationPath;

  const LoadingWidget({
    Key? key,
    this.message,
    this.animationPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (animationPath != null)
            Lottie.asset(
              animationPath!,
              width: 150.w,
              height: 150.h,
              fit: BoxFit.contain,
            ) 
          else
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          SizedBox(height: 20.h),
          Text(
            message ?? 'جاري التحميل...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


