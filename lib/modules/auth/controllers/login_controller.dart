import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/app/routes/app_pages.dart';
import 'package:student_app/core/services/auth_service.dart';
import 'dart:async';

import '../../../core/network/api_service.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../home/controllers/home_controller.dart';

class LoginController extends GetxController {
    final ApiService _apiService = ApiService();
  final homecontroller= Get.find<HomeController>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  // متحكمات نسيان كلمة المرور
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // متحكمات أرقام رمز التفعيل
  TextEditingController? digit1Controller;
  TextEditingController? digit2Controller;
  TextEditingController? digit3Controller;
  TextEditingController? digit4Controller;
  TextEditingController? digit5Controller;
  TextEditingController? digit6Controller;
  
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isVerificationLoading = false.obs;
  final RxBool isResetPasswordLoading = false.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString resetEmail = ''.obs;
  final RxInt remainingTime = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    _checkRememberMe();
    super.onInit();
  }

  Future<void> _checkRememberMe() async {
    final remembered = await AuthService.getRememberMeStatus();
    rememberMe.value = remembered;
    if (remembered) {
      final savedEmail = await AuthService.getRememberedEmail();
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
    }
  }

Future<void> login() async {
  if (!_validateInputs()) return;

  isLoading.value = true;
  
  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final response = await _apiService.post(
      '/login',
      data: {'email': email, 'password': password},
    );
        if (response.statusCode == 201) {
      // تسجيل الدخول ناجح
        await _apiService.saveToken(response.data['token']);
        await _apiService.saveStudentData(response.data['student']);
           // حفظ بيانات المستخدم والطالب
      await AuthService.saveAuthData(
      response.data['token'],
      response. data['user']
      );
       // حفظ بيانات المستخدم والطالب
        await homecontroller.downloadAndCacheImage(
           response. data['user']['image_url'] ?? 'default.png');

    if (rememberMe.value) {
      await AuthService.setRememberMeStatus(true);
      await AuthService.setRememberedEmail(email);
    } else {
      await AuthService.clearRememberMe();
    }

    // حفظ بيانات المستخدم والتوكن
            Get.offAllNamed(AppRoutes.home);

    } else {
      throw Exception('Login failed: ${response.data['message']}');
    }
    showSuccessSnackbar(
      title: 'نجاح',
      message: 'تم تسجيل الدخول بنجاح',
    );

      
  } catch (e) {
    showErrorSnackbar(
      title: 'خطأ',
      message: e.toString(),
    );
  } finally {
    isLoading.value = false;
  }
}

  // دالة إرسال رمز إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetCode() async {
    if (!_validateForgotPasswordEmail()) return;

    isForgotPasswordLoading.value = true;
    
    try {
      final email = forgotEmailController.text.trim();
      final response = await _apiService.post(
        '/password/send-reset-code',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        resetEmail.value = email;
        showSuccessSnackbar(
          title: 'تم الإرسال',
          message: 'تم إرسال رمز التفعيل إلى بريدك الإلكتروني',
        );
        
        // بدء العد التنازلي (3 دقائق)
        _startCountdown(180);
        
        // الانتقال إلى صفحة التحقق من الرمز
        Get.toNamed(AppRoutes.verifyResetCode);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في إرسال رمز التفعيل');
      }
    } catch (e) {
      showErrorSnackbar(
        title: 'خطأ',
        message: _getErrorMessage(e.toString()),
      );
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  // دالة التحقق من رمز إعادة تعيين كلمة المرور
  Future<void> verifyResetCode() async {
    if (!_validateVerificationCode()) return;

    isVerificationLoading.value = true;
    
    try {
      final email = resetEmail.value;
      final code = verificationCodeController.text.trim();
      
      final response = await _apiService.post(
        '/password/verify-reset-code',
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar(
          title: 'تم التحقق',
          message: 'تم التحقق من رمز التفعيل بنجاح',
        );
        
        // الانتقال إلى صفحة إعادة تعيين كلمة المرور
        Get.toNamed(AppRoutes.resetPassword);
      } else {
        throw Exception(response.data['message'] ?? 'رمز التفعيل غير صحيح');
      }
    } catch (e) {
      showErrorSnackbar(
        title: 'خطأ',
        message: _getErrorMessage(e.toString()),
      );
    } finally {
      isVerificationLoading.value = false;
    }
  }

  // دالة إعادة تعيين كلمة المرور
  Future<void> resetPassword() async {
    if (!_validateNewPassword()) return;

    isResetPasswordLoading.value = true;
    
    try {
      final email = resetEmail.value;
      final code = verificationCodeController.text.trim();
      final newPassword = newPasswordController.text.trim();
      
      final response = await _apiService.post(
        '/password/reset',
        data: {
          'email': email,
          'code': code,
          'password': newPassword,
          'password_confirmation': confirmPasswordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar(
          title: 'تم بنجاح',
          message: 'تم تغيير كلمة المرور بنجاح',
        );
        
        // مسح البيانات
        _clearForgotPasswordData();
        
        // العودة إلى صفحة تسجيل الدخول
        Get.offAllNamed(AppRoutes.login);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تغيير كلمة المرور');
      }
    } catch (e) {
      showErrorSnackbar(
        title: 'خطأ',
        message: _getErrorMessage(e.toString()),
      );
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  // دالة إعادة إرسال رمز التفعيل
  Future<void> resendResetCode() async {
    if (resetEmail.value.isEmpty) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'لا يوجد بريد إلكتروني محفوظ',
      );
      return;
    }

    forgotEmailController.text = resetEmail.value;
    await sendPasswordResetCode();
  }

  // التحقق من صحة البريد الإلكتروني لنسيان كلمة المرور
  bool _validateForgotPasswordEmail() {
    if (forgotEmailController.text.isEmpty || !forgotEmailController.text.isEmail) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'الرجاء إدخال بريد إلكتروني صحيح',
      );
      return false;
    }
    return true;
  }

  // التحقق من صحة رمز التفعيل
  bool _validateVerificationCode() {
    final code = verificationCodeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'الرجاء إدخال رمز التفعيل المكون من 6 أرقام',
      );
      return false;
    }
    return true;
  }

  // التحقق من صحة كلمة المرور الجديدة
  bool _validateNewPassword() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || newPassword.length < 8) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'كلمة المرور وتأكيد كلمة المرور غير متطابقتين',
      );
      return false;
    }

    return true;
  }

  // بدء العد التنازلي
  void _startCountdown(int seconds) {
    remainingTime.value = seconds;
    _timer?.cancel();
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // مسح بيانات نسيان كلمة المرور
  void _clearForgotPasswordData() {
    forgotEmailController.clear();
    verificationCodeController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    
    // مسح متحكمات الأرقام
    digit1Controller?.clear();
    digit2Controller?.clear();
    digit3Controller?.clear();
    digit4Controller?.clear();
    digit5Controller?.clear();
    digit6Controller?.clear();
    
    resetEmail.value = '';
    remainingTime.value = 0;
    _timer?.cancel();
  }

  // الحصول على رسالة الخطأ المناسبة
  String _getErrorMessage(String error) {
    if (error.contains('USER_NOT_FOUND')) {
      return 'البريد الإلكتروني غير مسجل في النظام';
    } else if (error.contains('TOO_MANY_REQUESTS')) {
      return 'تم إرسال رمز التفعيل مؤخراً. يرجى الانتظار';
    } else if (error.contains('INVALID_CODE')) {
      return 'رمز التفعيل غير صحيح';
    } else if (error.contains('CODE_EXPIRED')) {
      return 'انتهت صلاحية رمز التفعيل';
    } else if (error.contains('MAX_ATTEMPTS_EXCEEDED')) {
      return 'تم تجاوز عدد المحاولات المسموحة';
    } else {
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }
  }

  // تنسيق الوقت المتبقي
  String get formattedRemainingTime {
    final minutes = (remainingTime.value / 60).floor();
    final seconds = remainingTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // التحقق من انتهاء الوقت
  bool get isTimeExpired => remainingTime.value <= 0;
  
  
  bool _validateInputs() {
    if (emailController.text.isEmpty || !emailController.text.isEmail) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'الرجاء إدخال بريد إلكتروني صحيح',
      );
      return false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 8) {
      showErrorSnackbar(
        title: 'خطأ',
        message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      );
      return false;
    }

    return true;
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void showSuccessSnackbar({required String title, required String message}) {
    Helpers.showSnackbar(
      title: title,
      message: message,
      isError: false,
    );
  }

  void showErrorSnackbar({required String title, required String message}) {
    Helpers.showSnackbar(
      title: title,
      message: message,
      isError: true,
    );
  }

  @override
  void onClose() {
    
    // emailController.dispose(); // لا تتخلص منها
    // passwordController.dispose(); // لا تتخلص منها
    // forgotEmailController.dispose();
    // verificationCodeController.dispose();
    // newPasswordController.dispose();
    // confirmPasswordController.dispose();
    
    // digit1Controller?.dispose();
    // digit2Controller?.dispose();
    // digit3Controller?.dispose();
    // digit4Controller?.dispose();
    // digit5Controller?.dispose();
    // digit6Controller?.dispose();
    
    _timer?.cancel();
    super.onClose();
  }
}

