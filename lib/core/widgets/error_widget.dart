import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart'hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? animationPath;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.animationPath,
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
            if (animationPath != null)
              Lottie.asset(
                animationPath!,
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
              )
            else
              Icon(
                Icons.error_outline,
                color: isDarkMode ? AppColors.darkError : AppColors.lightError,
                size: 80.sp,
              ),
            SizedBox(height: 20.h),
            Text(
              'حدث خطأ!',
              style: AppTextStyles.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 20.sp),
                label: Text(
                  'إعادة المحاولة',
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


