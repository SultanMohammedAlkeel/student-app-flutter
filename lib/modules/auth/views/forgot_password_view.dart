import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../controllers/login_controller.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode
          ? AppColors.darkBackground // لون الخلفية الداكن
          : AppColors.lightBackground, // لون الخلفية الفاتح
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: Stack(
            children: [
              // Positioned(
              //   ,
              //   child: BackgroundDesign()),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      top: 0.05.sh,
      left: 0,
      right: 0,
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 15.h),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final HomeController _homeController = Get.find<HomeController>();

    return Column(
      children: [
        // أيقونة نسيان كلمة المرور
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 2,
            intensity: 0.8,
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground, // لون الخلفية حسب الوضع
          ),
          child: Container(
            width: 100.w,
            height: 100.w,
            child: Icon(
              Icons.lock_reset_rounded,
              size: 50.sp,
              color:
                  _homeController.getPrimaryColor(), // لون الأيقونة حسب الوضع
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // العنوان الرئيسي
        Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(Get.isDarkMode),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),

        // النص التوضيحي
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رمز التفعيل لإعادة تعيين كلمة المرور',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.getSecondaryTextColor(Get.isDarkMode),
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
          // حقل البريد الإلكتروني
          AuthTextField(
            hintText: 'البريد الإلكتروني',
            prefixIcon: Icons.email_outlined,
            controller: controller.forgotEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20.h),

          // زر الإرسال
          Obx(() => _buildSendButton()),
          SizedBox(height: 10.h),

          // زر العودة لتسجيل الدخول
          _buildBackToLoginButton(),
          SizedBox(height: 30.h),

          // معلومات إضافية
          _buildHelpInfo(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      onPressed: controller.isForgotPasswordLoading.value
          ? null
          : () => controller.sendPasswordResetCode(),
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
        depth: controller.isForgotPasswordLoading.value ? 2 : 8,
        intensity: 0.8,
        color: controller.isForgotPasswordLoading.value
            ? homeController.getSecondaryColor()
            : homeController.getPrimaryColor(), // لون الزر حسب حالة التحميل
      ),
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Container(
        width: double.infinity,
        child: controller.isForgotPasswordLoading.value
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
                    'جاري الإرسال...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'إرسال رمز التفعيل',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      onPressed: () => Get.back(),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
        depth: -2,
        intensity: 0.5,
        color: homeController.getSecondaryColor(),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'العودة لتسجيل الدخول',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpInfo() {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
        depth: -3,
        intensity: 0.8,
        color: AppColors.getBackgroundColor(Get.isDarkMode),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue[600],
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'معلومات مهمة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '• سيتم إرسال رمز التفعيل إلى بريدك الإلكتروني\n'
            '• الرمز صالح لمدة 3 دقائق فقط\n'
            '• تحقق من مجلد الرسائل غير المرغوب فيها\n'
            '• يمكنك طلب رمز جديد إذا انتهت صلاحية الرمز',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
