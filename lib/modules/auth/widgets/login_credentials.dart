import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../controllers/login_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginCredentials extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.35.sh,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            _buildWelcomeText(),
            SizedBox(height: 10.h),
            _buildEmailField(),
            SizedBox(height: 8.h),
            _buildPasswordField(),
            SizedBox(height: 15.h),
            _buildRememberMeAndForgotPassword(),
            SizedBox(height: 15.h),
            _buildLoginButton(),
            SizedBox(height: 10.h),
            _buildRegisterLink(),
            SizedBox(height: 10.h),
            _buildApiSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'مرحباً بك',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode
                ? AppColors
                    .lightBackground // لون النص حسب الوضع الداكن أو الفاتح
                : AppColors
                    .darkBackground, // لون النص حسب الوضع الداكن أو الفاتح
            // لون النص حسب الوضع الداكن أو الفاتح
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'سجل دخولك للوصول إلى حسابك',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AuthTextField(
      hintText: 'البريد الإلكتروني',
      prefixIcon: Icons.email_outlined,
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => AuthTextField(
          hintText: 'كلمة المرور',
          prefixIcon: Icons.lock_outline,
          controller: controller.passwordController,
          isPassword: controller.obscurePassword.value,
          onFieldSubmitted: (value) => controller.login(),
          suffixIcon: Icon(
            controller.obscurePassword.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onSuffixIconPressed: () => controller.togglePasswordVisibility(),
        ));
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // تذكرني
        Obx(() => Row(
              children: [
                Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (value) =>
                      controller.rememberMe.value = value ?? false,
                  // style: NeumorphicCheckboxStyle(
                  //   selectedDepth: -3,
                  //   unselectedDepth: 3,
                  //   selectedColor:homeController.getPrimaryColor(),
                  //   //  unselectedColor: Colors.grey[200],
                  // ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'تذكرني',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )),

        // نسيت كلمة المرور
        NeumorphicButton(
          onPressed: () => controller.goToForgotPassword(),
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20.r)),
            depth: -1,
            intensity: 0.3,
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() => NeumorphicButton(
          onPressed:
              controller.isLoading.value ? null : () => controller.login(),
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
            depth: controller.isLoading.value ? 2 : 8,
            intensity: 0.8,
            color: !controller.isLoading.value
                ? homeController.getPrimaryColor()
                : homeController.getSecondaryColor(),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Container(
            width: double.infinity,
            child: controller.isLoading.value
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
                        'جاري تسجيل الدخول...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ));
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟ ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        NeumorphicButton(
          onPressed: () => controller.goToRegister(),
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
            depth: -1,
            intensity: 0.3,
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiSection() {
    HomeController homeController = Get.find<HomeController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NeumorphicButton(
          onPressed: () => Get.toNamed("/api-settings"),
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
            depth: -1,
            intensity: 0.3,
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Text(
            'إعداد عنوان API ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
