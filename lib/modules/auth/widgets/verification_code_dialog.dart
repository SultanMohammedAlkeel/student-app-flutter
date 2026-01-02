import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class VerificationCodeDialog extends StatelessWidget {
  final RegisterController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 8,
          intensity: 0.5, // تقليل شدة التوهج
          color: NeumorphicTheme.baseColor(context),
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(20.r),
          ),
          lightSource: LightSource.topLeft,
        ),
        child: Container(
          width: 0.9.sw,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان
              NeumorphicText(
                'تفعيل الحساب',
                style: NeumorphicStyle(
                  depth: 2,
                  color: NeumorphicTheme.isUsingDark(context)
                      ? Colors.white
                      : Colors.black87,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),

              // الرسالة التوضيحية
              NeumorphicText(
                'تم إرسال رمز التفعيل إلى بريدك الإلكتروني',
                style: NeumorphicStyle(
                  depth: 1,
                  color: NeumorphicTheme.isUsingDark(context)
                      ? Colors.white70
                      : Colors.black54,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // حقل إدخال الرمز
              Neumorphic(
                style: NeumorphicStyle(
                  depth: -3,
                  intensity: 0.3,
                  color: NeumorphicTheme.baseColor(context),
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12.r),
                  ),
                ),
                child: TextField(
                  controller: controller.activationCodeController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: NeumorphicTheme.isUsingDark(context)
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز التفعيل',
                    hintStyle: TextStyle(
                      color: NeumorphicTheme.isUsingDark(context)
                          ? Colors.white54
                          : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // أزرار التحكم
              Row(
                children: [
                  // زر الإلغاء
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        controller.activationCodeController.clear();
                        // controller.showVerification.value = false;
                      },
                      style: NeumorphicStyle(
                        depth: 2,
                        intensity: 0.3,
                        color: NeumorphicTheme.baseColor(context),
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12.r),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: NeumorphicTheme.isUsingDark(context)
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // زر التأكيد
                  Expanded(
                    child: Obx(() => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : NeumorphicButton(
                      //      onPressed: controller.verifyAccount,
                            style: NeumorphicStyle(
                              depth: 4,
                              intensity: 0.3,
                              color: Colors.blue.shade600,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12.r),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Text(
                              'تأكيد',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}