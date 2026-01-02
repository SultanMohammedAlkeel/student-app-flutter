import 'dart:io';

import 'package:get/get.dart' hide FormData, Response, MultipartFile;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/themes/colors.dart';
import '../../home/controllers/home_controller.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();
  final homecontroller = Get.find<HomeController>();
  final RxBool isLoading = false.obs;
  final RxInt currentStep = 1.obs;
  final RxString imagePath = ''.obs;

  // خطوة المصادقة
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController activationCodeController =
      TextEditingController();
  final RxString studentIdError = RxString('');
  final RxString activationCodeError = RxString('');

  // خطوة البيانات
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString usernameError = RxString('');
  final RxString passwordError = RxString('');
  final RxString imageError = RxString('');

  // خطوة التواصل
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString emailError = RxString('');
  final RxString phoneError = RxString('');

  XFile? pickedFile = XFile('assets/images/user_profile.jpg');

  @override
  void onClose() {
    studentIdController.dispose();
    activationCodeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // التحقق من صحة بيانات المصادقة
  bool validateAuthStep() {
    bool isValid = true;
    studentIdError.value = '';
    activationCodeError.value = '';

    if (studentIdController.text.isEmpty) {
      studentIdError.value = 'الرقم الجامعي مطلوب';
      isValid = false;
    } else if (!GetUtils.isNumericOnly(studentIdController.text)) {
      studentIdError.value = 'يجب أن يحتوي الرقم الجامعي على أرقام فقط';
      isValid = false;
    }

    if (activationCodeController.text.isEmpty) {
      activationCodeError.value = 'رمز التفعيل مطلوب';
      isValid = false;
    } else if (activationCodeController.text.length < 4) {
      activationCodeError.value = 'رمز التفعيل يجب أن يكون 4 أحرف على الأقل';
      isValid = false;
    }

    return isValid;
  }

  // التحقق من صحة بيانات المستخدم
  bool validateUserDataStep() {
    bool isValid = true;
    usernameError.value = '';
    passwordError.value = '';

    if (usernameController.text.isEmpty) {
      usernameError.value = 'اسم المستخدم مطلوب';
      isValid = false;
    } else if (usernameController.text.length < 3) {
      usernameError.value = 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = 'كلمة المرور مطلوبة';
      isValid = false;
    } else if (passwordController.text.length < 8) {
      passwordError.value = 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
      isValid = false;
    }

    return isValid;
  }

  // التحقق من صحة بيانات التواصل
  bool validateContactStep() {
    bool isValid = true;
    emailError.value = '';
    phoneError.value = '';

    if (emailController.text.isEmpty) {
      emailError.value = 'البريد الإلكتروني مطلوب';
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text)) {
      emailError.value = 'بريد إلكتروني غير صالح';
      isValid = false;
    }

    if (phoneController.text.isEmpty) {
      phoneError.value = 'رقم الهاتف مطلوب';
      isValid = false;
    } else if (!GetUtils.isPhoneNumber(phoneController.text)) {
      phoneError.value = 'رقم هاتف غير صالح';
      isValid = false;
    }

    return isValid;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // التحقق من امتداد الملف
        final extension = pickedFile.path.split('.').last.toLowerCase();
        final allowedExtensions = ['jpeg', 'png', 'jpg', 'gif'];

        if (!allowedExtensions.contains(extension)) {
          imageError.value = 'نوع الصورة غير مسموح به';
          showErrorSnackbar(
              title: 'خطأ',
              message: 'يجب أن تكون الصورة بصيغة: jpeg, png, jpg, gif');
          return;
        }

        // التحقق من حجم الملف
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > 2) {
          imageError.value = 'حجم الصورة كبير جدًا';
          showErrorSnackbar(
              title: 'خطأ', message: 'يجب أن لا يتجاوز حجم الصورة 2MB');
          return;
        }

        this.pickedFile = pickedFile;
        imagePath.value = pickedFile.path;
        imageError.value = '';
      }
    } catch (e) {
      imageError.value = 'حدث خطأ في اختيار الصورة';
      showErrorSnackbar(
          title: 'خطأ', message: 'فشل في اختيار الصورة: ${e.toString()}');
    }
  }

  // التحقق من صحة الطالب ورمز التفعيل
  Future<bool> verifyStudent() async {
    if (!validateAuthStep()) return false;

    isLoading.value = true;

    try {
      final response = await _apiService.post(
        'verify-student',
        data: {
          'student_id': studentIdController.text,
          'activation_code': activationCodeController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessSnackbar(
            title: 'تم التحقق',
            message:
                response.data['message'] ?? 'تم التحقق من بيانات الطالب بنجاح');
        return true;
      } else {
        handleApiError(response.data);
        return false;
      }
    } on DioException catch (e) {
      handleDioError(e);
      return false;
    } catch (e) {
      showErrorSnackbar(
          title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!validateContactStep()) return;

    isLoading.value = true;

    try {
      final formData = FormData.fromMap({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'student_id': studentIdController.text.trim(),
        'password': passwordController.text,
        'phone': phoneController.text.trim(),
        'activation_code': activationCodeController.text.trim(),
        'image': imagePath.value.isNotEmpty
            ? await MultipartFile.fromFile(
                imagePath.value,
                filename:
                    'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              )
            : null,
      });

      final response = await _apiService.post(
        'register',
        data: formData,
      );

      if (response.statusCode == 201) {
        // حفظ التوكن
        await _apiService.saveToken(response.data['token']);
        await _apiService.saveStudentData(response.data['student']);
        // حفظ بيانات المستخدم والطالب
        await AuthService.saveAuthData(
            response.data['token'], response.data['user']);
        final bytes = await pickedFile!.readAsBytes();
        await homecontroller.cacheImage(bytes);

        // توجيه إلى الصفحة الرئيسية
        Get.offAllNamed(AppRoutes.home);

        showSuccessSnackbar(
          title: 'نجاح',
          message: response.data['message'] ?? 'تم إنشاء الحساب بنجاح',
        );
      } else {
        handleApiError(response.data);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleApiError(e.response!.data);
      } else {
        showErrorSnackbar(
          title: 'خطأ في الاتصال',
          message: 'تعذر الاتصال بالسيرفر',
        );
      }
    } catch (e) {
      showErrorSnackbar(
        title: 'خطأ غير متوقع',
        message: 'حدث خطأ: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleApiError(Map<String, dynamic>? data) {
    String errorMessage = 'حدث خطأ في الخادم'; // رسالة افتراضية

    if (data != null) {
      if (data.containsKey('errors') && data['errors'] is Map) {
        // إذا كانت هناك أخطاء تفصيلية لكل حقل
        final Map<String, dynamic> errors = data['errors'];
        List<String> detailedErrors = [];
        errors.forEach((key, value) {
          if (value is List) {
            detailedErrors.addAll(value.map((e) => e.toString()));
          }
        });
        if (detailedErrors.isNotEmpty) {
          errorMessage =
              detailedErrors.join('\n'); // جمع الأخطاء في سطر واحد لكل خطأ
        } else if (data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      } else if (data.containsKey('message')) {
        errorMessage = data['message'].toString();
      } else if (data.containsKey('error')) {
        errorMessage = data['error'].toString();
      }
    }

    showErrorSnackbar(title: 'خطأ', message: errorMessage);
  }

  void handleDioError(DioException e) {
    final error = e.response?.data?['message'] ??
        e.response?.data?['error'] ??
        e.message ??
        'حدث خطأ في الاتصال';
    showErrorSnackbar(title: 'خطأ', message: error.toString());
  }

  void showSuccessSnackbar({required String title, required String message}) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.success,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      ),
    );
  }

  void showErrorSnackbar({required String title, required String message}) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.error,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      ),
    );
  }
}
