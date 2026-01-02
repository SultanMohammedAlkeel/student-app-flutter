import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

import '../../home/controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: Stack(
            children: [
              //  BackgroundDesign(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 0.04.sh),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          _buildHeader(),
          SizedBox(height: 40.h),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    HomeController homeController = Get.find<HomeController>();

    return Column(
      children: [
        // أيقونة إعادة تعيين كلمة المرور
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 2,
            intensity: 0.8,
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          child: Container(
            width: 100.w,
            height: 100.w,
            child: Icon(
              Icons.lock_open_rounded,
              size: 50.sp,
              color: homeController.getPrimaryColor(),
            ),
          ),
        ),
        SizedBox(height: 15.h),

        // العنوان الرئيسي
        Text(
          'إعادة تعيين كلمة المرور',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 7.h),

        // النص التوضيحي
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'اختر كلمة مرور جديدة وقوية لحسابك',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          // حقل كلمة المرور الجديدة
          Obx(() => AuthTextField(
                hintText: 'كلمة المرور الجديدة',
                prefixIcon: Icons.lock_outline,
                controller: controller.newPasswordController,
                isPassword: controller.obscureNewPassword.value,
                onChanged: (value) => _validatePassword(),
                suffixIcon: Icon(
                  controller.obscureNewPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onSuffixIconPressed: () =>
                    controller.toggleNewPasswordVisibility(),
              )),
          SizedBox(height: 15.h),

          // حقل تأكيد كلمة المرور
          Obx(() => AuthTextField(
                hintText: 'تأكيد كلمة المرور',
                prefixIcon: Icons.lock_outline,
                controller: controller.confirmPasswordController,
                isPassword: controller.obscureConfirmPassword.value,
                onChanged: (value) => _validatePassword(),
                suffixIcon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onSuffixIconPressed: () =>
                    controller.toggleConfirmPasswordVisibility(),
              )),
          SizedBox(height: 15.h),

          // مؤشر قوة كلمة المرور
          _buildPasswordStrengthIndicator(),
          SizedBox(height: 15.h),

          // أزرار إظهار/إخفاء كلمة المرور (تم إزالتها)
          // _buildPasswordVisibilityButtons(),
          // SizedBox(height: 30.h),

          // زر إعادة تعيين كلمة المرور
          Obx(() => _buildResetButton()),
          SizedBox(height: 15.h),

          // زر العودة
          _buildBackButton(),
          SizedBox(height: 20.h),

          // نصائح كلمة المرور القوية
          _buildPasswordTips(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    String password = controller.newPasswordController.text;
    double strength = _calculatePasswordStrength(password);
    Color strengthColor = _getStrengthColor(strength);
    String strengthText = _getStrengthText(strength);
    HomeController homeController = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'قوة كلمة المرور: $strengthText',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: strengthColor,
          ),
        ),
        SizedBox(height: 8.h),
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10.r)),
            depth: -2,
            intensity: 0.5,
            color: Get.isDarkMode
                ? homeController.getPrimaryColor()
                : homeController.getPrimaryColor(),
          ),
          child: Container(
            height: 8.h,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // تم إزالة هذه الدالة لأن الأزرار أصبحت جزءًا من AuthTextField
  // Widget _buildPasswordVisibilityButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Obx(() => NeumorphicButton(
  //               onPressed: () => controller.toggleNewPasswordVisibility(),
  //               style: NeumorphicStyle(
  //                 shape: NeumorphicShape.flat,
  //                 boxShape:
  //                     NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
  //                 depth: -2,
  //                 intensity: 0.5,
  //                 color: Get.isDarkMode ? homeController.getPrimaryColor() : homeController.getPrimaryColor(),
  //               ),
  //               padding: EdgeInsets.symmetric(vertical: 10.h),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     controller.obscureNewPassword.value
  //                         ? Icons.visibility_outlined
  //                         : Icons.visibility_off_outlined,
  //                     color: Colors.grey[600],
  //                     size: 16.sp,
  //                   ),
  //                   SizedBox(width: 5.w),
  //                   Text(
  //                     controller.obscureNewPassword.value ? 'إظهار' : 'إخفاء',
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //       ),
  //       SizedBox(width: 10.w),
  //       Expanded(
  //         child: Obx(() => NeumorphicButton(
  //               onPressed: () => controller.toggleConfirmPasswordVisibility(),
  //               style: NeumorphicStyle(
  //                 shape: NeumorphicShape.flat,
  //                 boxShape:
  //                     NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
  //                 depth: -2,
  //                 intensity: 0.5,
  //                 color: Get.isDarkMode ? homeController.getPrimaryColor() : homeController.getPrimaryColor(),
  //               ),
  //               padding: EdgeInsets.symmetric(vertical: 10.h),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     controller.obscureConfirmPassword.value
  //                         ? Icons.visibility_outlined
  //                         : Icons.visibility_off_outlined,
  //                     color: Colors.grey[600],
  //                     size: 16.sp,
  //                   ),
  //                   SizedBox(width: 5.w),
  //                   Text(
  //                     controller.obscureConfirmPassword.value
  //                         ? 'إظهار'
  //                         : 'إخفاء',
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildResetButton() {
    return NeumorphicButton(
      onPressed: controller.isResetPasswordLoading.value
          ? null
          : () => controller.resetPassword(),
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
        depth: controller.isResetPasswordLoading.value ? 2 : 8,
        intensity: 0.8,
        color: controller.isResetPasswordLoading.value
            ? Colors.grey[300]
            : Colors.grey[200],
      ),
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Container(
        width: double.infinity,
        child: controller.isResetPasswordLoading.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'جاري التحديث...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green[600],
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'تحديث كلمة المرور',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      onPressed: () => Get.back(),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
        depth: -2,
        intensity: 0.5,
        color: Get.isDarkMode
            ? homeController.getPrimaryColor()
            : homeController.getPrimaryColor(),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.grey[600],
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'العودة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTips() {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
        depth: -3,
        intensity: 0.5,
        color: Get.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.green[600],
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'نصائح لكلمة مرور قوية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildTipItem('8 أحرف على الأقل'),
          _buildTipItem('تحتوي على أحرف كبيرة وصغيرة'),
          _buildTipItem('تحتوي على أرقام'),
          _buildTipItem('تحتوي على رموز خاصة (!@#\$%^&*)'),
          _buildTipItem('لا تستخدم معلومات شخصية'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green[600],
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validatePassword() {
    // يمكن إضافة منطق التحقق هنا
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // طول كلمة المرور
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // أحرف كبيرة
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // أحرف صغيرة
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // أرقام
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // رموز خاصة
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength < 0.3) return 'ضعيفة';
    if (strength < 0.6) return 'متوسطة';
    if (strength < 0.8) return 'جيدة';
    return 'قوية';
  }
}
