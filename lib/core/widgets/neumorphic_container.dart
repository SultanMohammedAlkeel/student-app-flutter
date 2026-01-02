import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_app/core/themes/colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double depth;
  final double blurRadius;
  final Offset offset;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.depth = 5.0,
    this.blurRadius = 10.0,
    this.offset = const Offset(3, 3),
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final baseColor = backgroundColor ??
        (isDarkMode ? AppColors.darkSurface : AppColors.lightBackground);
    final shadowDark =
        isDarkMode ? AppColors.darkShadowDark : AppColors.lightShadowDark;
    final shadowLight =
        isDarkMode ? AppColors.darkShadowLight : AppColors.lightShadowLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: shadowDark,
              offset: offset,
              blurRadius: blurRadius,
            ),
            BoxShadow(
              color: shadowLight,
              offset: Offset(-offset.dx, -offset.dy),
              blurRadius: blurRadius,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
