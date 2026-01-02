import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/colors.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final bool isRTL;
  final TextInputType? keyboardType;
  final String? errorText;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final Widget? suffixIcon; // إضافة suffixIcon
  final VoidCallback? onSuffixIconPressed; // إضافة onSuffixIconPressed

  const AuthTextField({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.isRTL = true,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
    this.suffixIcon, // تهيئة suffixIcon
    this.onSuffixIconPressed, // تهيئة onSuffixIconPressed
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              color: Get.isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(30.r)),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              focusNode: focusNode,
              onChanged: (value) {
                if (onChanged != null) onChanged!(value);
              },
              onSubmitted: (value) {
                if (onFieldSubmitted != null) onFieldSubmitted!(value);
              },
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                fillColor: Get.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                hintText: hintText,
                hintTextDirection:
                    isRTL ? TextDirection.rtl : TextDirection.ltr,
                prefixIcon: Icon(prefixIcon, textDirection: TextDirection.rtl),
                suffixIcon: suffixIcon != null // استخدام suffixIcon هنا
                    ? IconButton(
                        icon: suffixIcon!,
                        onPressed: onSuffixIconPressed,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),
          if (errorText != null && errorText!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -3,
                  intensity: 0.8,
                  color: Get.isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: Text(
                  errorText!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
