import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/colors.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/register_controller.dart';
import '../widgets/background_design.dart';
import '../widgets/auth_text_field.dart';

class RegisterView extends GetView<RegisterController> {
  final _pageController = PageController();
  final _scrollController = ScrollController();
  final _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode
          ? AppColors.darkBackground
          : AppColors.lightBackground, // استخدام لون الخلفية من الثيم
      resizeToAvoidBottomInset: true, // مهم لتحسين التجاوب مع الكيبورد
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () {
            // إخفاء الكيبورد عند النقر خارج الحقول
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Stack(
                children: [
                  BackgroundDesign(),
                  _buildRegisterContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterContent() {
    return Positioned(
      top: 0.3.sh,
      left: 0,
      right: 0,
      bottom: 0,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الصفحة
            Text(
              'إنشاء حساب',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode
                    ? AppColors.lightBackground
                    : AppColors.darkBackground,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'أكمل البيانات التالية لإنشاء حسابك',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 15.h),

            // مؤشر الخطوات
            Obx(() => _buildStepsIndicator()),
            SizedBox(height: 15.h),

            // محتوى الخطوات
            SizedBox(
              height: controller.currentStep.value == 4 ? 0.24.sh : 0.24.sh,
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  _scrollToTop();
                },
                children: [
                  _buildAuthStep(),
                  _buildUserDataStep(),
                  _buildContactStep(),
                  _buildAvatarStep(),
                ],
              ),
            ),

            // زر التالي/التسجيل
            SizedBox(height: 10.h),
            Obx(() => _buildActionButton()),
            SizedBox(height: 10.h),

            // روابط المساعدة
            _buildHelpLinks(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildStepsIndicator() {
    HomeController homeController = Get.find<HomeController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final step = index + 1;
        final isActive = controller.currentStep.value >= step;
        final isCurrent = controller.currentStep.value == step;

        return GestureDetector(
          onTap: () {
            if (isActive) {
              controller.currentStep.value = step;
              _pageController.animateToPage(
                step - 1,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? homeController.getPrimaryColor()
                        : isActive
                            ? homeController.getPrimaryColor().withOpacity(0.3)
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: homeController.getPrimaryColor(), width: 2.w)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white
                            : isActive
                                ? homeController.getPrimaryColor()
                                : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  _getStepTitle(step),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isActive
                        ? homeController.getPrimaryColor()
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'المصادقة';
      case 2:
        return 'البيانات';
      case 3:
        return 'التواصل';
      case 4:
        return 'الصورة';
      default:
        return '';
    }
  }

  Widget _buildAuthStep() {
    return Column(
      children: [
        Obx(() => AuthTextField(
              controller: controller.studentIdController,
              hintText: 'الرقم الجامعي',
              prefixIcon: Icons.school,
              isRTL: true,
              keyboardType: TextInputType.number,
              errorText: controller.studentIdError.value,
              onChanged: (value) => controller.studentIdError.value = '',
            )),
        SizedBox(height: 20.h),
        Obx(() => AuthTextField(
              controller: controller.activationCodeController,
              hintText: 'رمز التفعيل',
              prefixIcon: Icons.vpn_key,
              isRTL: true,
              isPassword: true,
              errorText: controller.activationCodeError.value,
              onChanged: (value) => controller.activationCodeError.value = '',
            )),
        SizedBox(height: 10.h),
        Text(
          'يمكن الحصول على رمز التفعيل المقترن بالحساب الأكاديمي\nعبر إدارة الكلية أو البوابة الإلكترونية للطلاب',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDataStep() {
    return Column(
      children: [
        Obx(() => AuthTextField(
              controller: controller.usernameController,
              hintText: 'اسم المستخدم',
              prefixIcon: Icons.person,
              isRTL: true,
              focusNode: _focusNodes[0],
              onFieldSubmitted: (_) => _focusNodes[1].requestFocus(),
              errorText: controller.usernameError.value,
              onChanged: (value) => controller.usernameError.value = '',
            )),
        SizedBox(height: 15.h),
        Obx(() => AuthTextField(
              controller: controller.passwordController,
              hintText: 'كلمة المرور',
              prefixIcon: Icons.lock,
              isRTL: true,
              isPassword: true,
              focusNode: _focusNodes[1],
              onFieldSubmitted: (_) => FocusScope.of(Get.context!).unfocus(),
              errorText: controller.passwordError.value,
              onChanged: (value) => controller.passwordError.value = '',
            )),
        SizedBox(height: 10.h),
        Text(
          'يجب أن تحتوي كلمة المرور على الأقل على 8 رموز\nويفضل أن تحتوي على حروف وأرقام ورموز خاصة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      children: [
        Obx(() => AuthTextField(
              controller: controller.emailController,
              hintText: 'البريد الإلكتروني',
              prefixIcon: Icons.email,
              isRTL: true,
              keyboardType: TextInputType.emailAddress,
              errorText: controller.emailError.value,
              onChanged: (value) => controller.emailError.value = '',
            )),
        SizedBox(height: 20.h),
        Obx(() => AuthTextField(
              controller: controller.phoneController,
              hintText: 'رقم الهاتف',
              prefixIcon: Icons.phone,
              isRTL: true,
              keyboardType: TextInputType.phone,
              errorText: controller.phoneError.value,
              onChanged: (value) => controller.phoneError.value = '',
            )),
        SizedBox(height: 10.h),
        Text(
          'سيتم استخدام البريد الإلكتروني لاستعادة كلمة المرور\nوالتواصل معك في الأمور الأكاديمية المهمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      children: [
        // Text(
        //   'الصورة الشخصية',
        //   style: TextStyle(
        //     fontSize: 18.sp,
        //     fontWeight: FontWeight.bold,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        // SizedBox(height: 5.h),
        // Text(
        //   'اختر صورة واضحة لوجهك',
        //   style: TextStyle(
        //     fontSize: 12.sp,
        //     color: AppColors.textSecondary,
        //   ),
        // ),
        // SizedBox(height: 10.h),
        Obx(() => _buildAvatarPicker()),
        SizedBox(height: 5.h),
        Text(
          'يجب أن تكون الصورة بصيغة: jpeg, png, jpg, gif\nبحجم لا يتجاوز 2MB',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    HomeController homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 125.w,
            height: 125.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: homeController.getPrimaryColor().withOpacity(0.5),
                width: 2.w,
              ),
            ),
            child: ClipOval(
              child: controller.imagePath.value.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 80.w,
                      color: Colors.grey[400],
                    )
                  : Image.file(
                      File(controller.imagePath.value),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50.w,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: homeController.getPrimaryColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                controller.imagePath.value.isEmpty
                    ? Icons.add_a_photo
                    : Icons.edit,
                color: Colors.white,
                size: 20.w,
              ),
            ),
          ),
          if (controller.imagePath.value.isNotEmpty)
            Positioned(
              top: 10.h,
              left: 10.w,
              child: GestureDetector(
                onTap: () {
                  controller.imagePath.value = '';
                  controller.imageError.value = '';
                },
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    HomeController homeController = Get.find<HomeController>();

    Get.dialog(
      AlertDialog(
        title: Text(
          'اختر مصدر الصورة',
          style: TextStyle(fontSize: 16.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: homeController.getPrimaryColor()),
              title: Text('الكاميرا'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: homeController.getPrimaryColor()),
              title: Text('المعرض'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final buttonHeight = 45.h; // ارتفاع موحد للأزرار
    HomeController homeController = Get.find<HomeController>();

    if (controller.currentStep.value == 4) {
      return Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: buttonHeight,
                child: NeumorphicButton(
                  onPressed: controller.register,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(50.r),
                    ),
                    depth: 3,
                    intensity: 1,
                    color: homeController.getPrimaryColor(),
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'تسجيل الحساب',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
      );
    }

    return SizedBox(
      height: buttonHeight,
      child: Row(
        children: [
          // زر الرجوع
          if (controller.currentStep.value > 1)
            Expanded(
              flex: 1,
              child: NeumorphicButton(
                onPressed: () {
                  FocusScope.of(Get.context!).unfocus();
                  controller.currentStep.value--;
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(50.r),
                  ),
                  depth: 2,
                  intensity: 0.8,
                  color: homeController.getSecondaryColor(),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'السابق',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (controller.currentStep.value > 1) SizedBox(width: 10.w),

          // زر التالي
          Expanded(
            flex: 2,
            child: NeumorphicButton(
              onPressed: () async {
                FocusScope.of(Get.context!).unfocus();

                if (controller.currentStep.value == 1) {
                  final success = await controller.verifyStudent();
                  if (success) {
                    controller.currentStep.value++;
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (controller.currentStep.value == 2) {
                  if (controller.validateUserDataStep()) {
                    controller.currentStep.value++;
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (controller.currentStep.value == 3) {
                  if (controller.validateContactStep()) {
                    controller.currentStep.value++;
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(50.r),
                ),
                depth: 3,
                intensity: 1,
                color: homeController.getPrimaryColor(),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'التالي',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpLinks() {
    HomeController homeController = Get.find<HomeController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟ ',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 14.sp,
              color: homeController.getSecondaryColor(),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
