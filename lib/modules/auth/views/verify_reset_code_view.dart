import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/colors.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/login_controller.dart';

class VerifyResetCodeView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
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
    return Positioned(
      top: 0.05.sh,
      left: 0,
      right: 0,
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          _buildCodeInput(),
          SizedBox(height: 15.h),
          _buildTimer(),
          SizedBox(height: 15.h),
          _buildVerifyButton(),
          SizedBox(height: 10.h),
          _buildResendButton(),
          SizedBox(height: 10.h),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // أيقونة التحقق
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 2,
            intensity: 0.8,
            color: AppColors.getBackgroundColor(Get.isDarkMode),
          ),
          child: Container(
            width: 100.w,
            height: 100.w,
            child: Icon(
              Icons.verified_user_rounded,
              size: 50.sp,
              color: Colors.green[600],
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // العنوان الرئيسي
        Text(
          'تحقق من رمز التفعيل',
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
          child: Obx(() => RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.getSecondaryTextColor(Get.isDarkMode),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                        text: 'تم إرسال رمز التفعيل إلى البريد الإلكتروني\n'),
                    TextSpan(
                      text: controller.resetEmail.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          Text(
            'أدخل رمز التفعيل المكون من 6 أرقام',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getSecondaryTextColor(Get.isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // حقول إدخال الرمز
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildCodeDigit(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeDigit(int index) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12.r)),
        depth: -2,
        intensity: 0.8,
        color: AppColors.getBackgroundColor(Get.isDarkMode),
      ),
      child: Container(
        width: 45.w,
        height: 55.h,
        child: TextField(
          controller: _getDigitController(index),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(Get.isDarkMode),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _onDigitChanged(value, index),
        ),
      ),
    );
  }

  TextEditingController _getDigitController(int index) {
    // إنشاء متحكمات منفصلة لكل رقم
    switch (index) {
      case 0:
        return controller.digit1Controller ??= TextEditingController();
      case 1:
        return controller.digit2Controller ??= TextEditingController();
      case 2:
        return controller.digit3Controller ??= TextEditingController();
      case 3:
        return controller.digit4Controller ??= TextEditingController();
      case 4:
        return controller.digit5Controller ??= TextEditingController();
      case 5:
        return controller.digit6Controller ??= TextEditingController();
      default:
        return TextEditingController();
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      print('Digit $index changed to $value');
      // الانتقال للحقل التالي
      if (index < 5) {
        FocusScope.of(Get.context!).nextFocus();
      } else {
        // إذا كان الحقل الأخير، قم بتجميع الرمز
        _updateVerificationCode();
      }
    } else {
      // الانتقال للحقل السابق
      if (index > 0) {
        FocusScope.of(Get.context!).previousFocus();
      }
    }
    _updateVerificationCode();
  }

  void _updateVerificationCode() {
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += _getDigitController(i).text;
    }
    controller.verificationCodeController.text = code;
  }

  Widget _buildTimer() {
    return Obx(() {
      if (controller.remainingTime.value <= 0) {
        return _buildExpiredMessage();
      }

      return Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
          depth: -2,
          intensity: 0.5,
          color: Colors.orange[50],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: Colors.orange[600],
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'ينتهي الرمز خلال: ${controller.formattedRemainingTime}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildExpiredMessage() {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15.r)),
        depth: -2,
        intensity: 0.5,
        color: Colors.red[50],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red[600],
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            'انتهت صلاحية الرمز',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Obx(() => NeumorphicButton(
            onPressed: controller.isVerificationLoading.value
                ? null
                : () => controller.verifyResetCode(),
            style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
              depth: controller.isVerificationLoading.value ? -2 : 2,
              intensity: 0.8,
              color: controller.isVerificationLoading.value
                  ? homeController.getSecondaryColor()
                  : homeController
                      .getPrimaryColor(), // لون الزر حسب حالة التحميل
            ),
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Container(
              width: double.infinity,
              child: controller.isVerificationLoading.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'جاري التحقق...',
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
                          Icons.check_circle_outline_rounded,
                          color: Colors.green[600],
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'تحقق من الرمز',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  Widget _buildResendButton() {
    HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Obx(() => NeumorphicButton(
            onPressed: controller.isTimeExpired
                ? () => controller.resendResetCode()
                : null,
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(25.r)),
              depth: controller.isTimeExpired ? -2 : 0,
              intensity: 0.5,
              color: controller.isTimeExpired
                  ? homeController.getPrimaryColor()
                  : homeController.getSecondaryColor(), // لون الزر حسب حالة انتهاء الوقت
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'إعادة إرسال الرمز',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildBackButton() {
          HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: NeumorphicButton(
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
                'العودة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
