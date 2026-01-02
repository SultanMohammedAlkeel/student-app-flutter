import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../controllers/login_controller.dart';

class BottomContainer extends StatelessWidget {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
          HomeController homeController = Get.find<HomeController>();

    return Directionality(
      textDirection: TextDirection.rtl, // إضافة Directionality للتصميم RTL
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            depth: 5,
            intensity: 0.8, // تعديل الشدة لتكون أكثر واقعية

            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.only(
                topLeft: Radius.elliptical(350.r, 250.r),
                topRight: Radius.elliptical(350.r, 250.r),
              ),
            ),
          ),
          child: Container(
            height: 0.3.sh,
            child: Column(
              children: [
                SizedBox(height: 0.07.sh),
                NeumorphicButton(
                  onPressed: controller.login,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: 2, // زيادة العمق لجعل الزر أكثر بروزاً
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(50.r),
                    ),
                    color: AppColors.cometColor, // إضافة لون للزر
                  ),
                  child: Container(
                    width: 0.5.sw,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    alignment: Alignment.center,
                    child: Text(
                      'تسجيل الدخول', // تغيير النص للعربية
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Get.isDarkMode
                            ? Colors.white
                            : homeController.getSecondaryColor(), // استخدام لون مناسب للنص
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: GestureDetector(
                    onTap: controller.goToRegister,
                    child: Text(
                      'إنشاء حساب جديد', // تغيير النص للعربية
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color:
                            Get.isDarkMode ? Colors.white : homeController.getSecondaryColor(),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
