import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/services/auth_service.dart';
import 'package:student_app/core/network/profile_service.dart';

import '../../../core/themes/app_theme.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();
  final AppThemeService _appThemeService = Get.find<AppThemeService>();
  final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

  // Observable variables
  final RxMap<String, dynamic> userData = RxMap();
  final RxMap<String, dynamic> studentData = RxMap();
  final Rx<Uint8List?> cachedImage = Rx<Uint8List?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;
  final RxBool isUpdatingProfile = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _loadCachedImage();
  }

  Color getPrimaryColor() {
    return _appThemeService.primaryColor;
  }

  Color getSecondaryColor() {
    return _appThemeService.secondaryColor;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// تحميل بيانات المستخدم
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

      // تحميل البيانات من التخزين المحلي أولاً
      final localUser = await _storage.read<Map<String, dynamic>>('user_data');
      final localStudent =
          await _storage.read<Map<String, dynamic>>('student_data');

      if (localUser != null) {
        userData.assignAll(localUser);
        _updateFormControllers();
      }

      if (localStudent != null) {
        studentData.assignAll(localStudent);
      }

      // جلب البيانات المحدثة من السيرفر
      final result = await _profileService.getCurrentUser();
      if (result['success'] == true) {
        userData.assignAll(result['user']);
        studentData.assignAll(result['student']);
        _updateFormControllers();
      }
    } catch (e) {
      _showErrorSnackbar('فشل في تحميل البيانات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث controllers النماذج
  void _updateFormControllers() {
    nameController.text = userData['name'] ?? '';
    emailController.text = userData['email'] ?? '';
    phoneController.text = userData['phone_number'] ?? '';
    addressController.text = userData['address'] ?? '';
  }

  /// تحميل الصورة المخزنة محلياً
  Future<void> _loadCachedImage() async {
    try {
      final imagePath = await _storage.read<String>('profile_image_path');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          cachedImage.value = bytes;
          return;
        }
      }

      // إذا لم توجد صورة محلية، جلبها من السيرفر
      if (userData['image_url'] != null) {
        await downloadAndCacheImage(userData['image_url']);
      }
    } catch (e) {
      debugPrint('Error loading cached image: $e');
    }
  }

  /// تحميل وحفظ الصورة من السيرفر
  // Future<void> downloadAndCacheImage(String imageUrl) async {
  //   try {
  //     // استخدم Dio مباشرة مع الرابط الكامل
  //     final dio = Dio();
  //     final response = await dio.get(
  //       'http://192.168.1.9:8000/$imageUrl',
  //       options: Options(responseType: ResponseType.bytes),
  //     );

  //     if (response.statusCode == 200) {
  //       await cacheImage(response.data);
  //     }
  //   } catch (e) {
  //     debugPrint('Error downloading image: $e');
  //   }
  // }
  Future<void> downloadAndCacheImage(String imageUrl) async {
    try {
      // استخدم الخدمة الجديدة للحصول على الرابط الكامل
      final fullImageUrl = _apiUrlService.getImageUrl(imageUrl);
      
      final dio = Dio();
      final response = await dio.get(
        fullImageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        await cacheImage(response.data);
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
  }
  /// حفظ الصورة محلياً
  Future<void> cacheImage(Uint8List imageBytes) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/profile_image.jpg');
      await file.writeAsBytes(imageBytes);

      await _storage.write('profile_image_path', file.path);
      cachedImage.value = imageBytes;
    } catch (e) {
      debugPrint('Error caching image: $e');
    }
  }

  /// اختيار وتحديث صورة الملف الشخصي
  Future<void> changeProfileImage() async {
    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      isImageUploading.value = true;
      _showLoadingDialog('جاري رفع الصورة...');

      final bytes = await image.readAsBytes();
      final tempFile = await _createTempFile(bytes);

      final result = await _profileService.uploadProfileImage(file: tempFile);

      Get.back(); // إغلاق dialog التحميل

      if (result['success'] == true) {
        cachedImage.value = bytes;
        userData.assignAll(result['user']);
        await cacheImage(bytes);
        _showSuccessSnackbar(result['message']);
      } else {
        _showErrorSnackbar(result['message']);
      }
    } catch (e) {
      Get.back(); // إغلاق dialog التحميل
      _showErrorSnackbar('فشل في تحديث الصورة: ${e.toString()}');
    } finally {
      isImageUploading.value = false;
    }
  }

  /// عرض dialog اختيار مصدر الصورة
  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر مصدر الصورة',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceButton(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  source: ImageSource.camera,
                ),
                _buildImageSourceButton(
                  icon: Icons.photo_library,
                  label: 'المعرض',
                  source: ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء زر اختيار مصدر الصورة
  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Get.back(result: source),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Get.theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Get.theme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// إنشاء ملف مؤقت
  Future<File> _createTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// تحديث البيانات الأساسية
  Future<void> updateBasicInfo() async {
    try {
      final errors = _profileService.validateProfileData(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
      );

      if (errors.isNotEmpty) {
        _showErrorSnackbar(errors.values.first!);
        return;
      }

      isUpdatingProfile.value = true;
      _showLoadingDialog('جاري تحديث البيانات...');

      final result = await _profileService.updateProfile(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
      );

      Get.back(); // إغلاق dialog التحميل

      if (result['success'] == true) {
        userData.assignAll(result['user']);
        _showSuccessSnackbar(result['message']);
      } else {
        _showErrorSnackbar(result['message']);
      }
    } catch (e) {
      Get.back(); // إغلاق dialog التحميل
      _showErrorSnackbar('فشل في تحديث البيانات: ${e.toString()}');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// تحديث معلومات التواصل
  Future<void> updateContactInfo() async {
    try {
      final errors = _profileService.validateContactInfo(
        email: emailController.text,
        phoneNumber: phoneController.text,
      );

      if (errors.isNotEmpty) {
        _showErrorSnackbar(errors.values.first!);
        return;
      }

      isUpdatingProfile.value = true;
      _showLoadingDialog('جاري تحديث معلومات التواصل...');

      final result = await _profileService.updateContactInfo(
        email: emailController.text,
        phoneNumber: phoneController.text,
        address: addressController.text,
      );

      Get.back(); // إغلاق dialog التحميل

      if (result['success'] == true) {
        userData.assignAll(result['user']);
        _showSuccessSnackbar(result['message']);
      } else {
        _showErrorSnackbar(result['message']);
      }
    } catch (e) {
      Get.back(); // إغلاق dialog التحميل
      _showErrorSnackbar('فشل في تحديث معلومات التواصل: ${e.toString()}');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword() async {
    try {
      final errors = _profileService.validatePasswordChange(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        newPasswordConfirmation: confirmPasswordController.text,
      );

      if (errors.isNotEmpty) {
        _showErrorSnackbar(errors.values.first!);
        return;
      }

      isUpdatingProfile.value = true;
      _showLoadingDialog('جاري تغيير كلمة المرور...');

      final result = await _profileService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        newPasswordConfirmation: confirmPasswordController.text,
      );

      Get.back(); // إغلاق dialog التحميل

      if (result['success'] == true) {
        _clearPasswordFields();
        _showSuccessSnackbar(result['message']);

        if (result['requires_relogin'] == true) {
          // إعادة توجيه لصفحة تسجيل الدخول
          Get.offAllNamed('/login');
        }
      } else {
        _showErrorSnackbar(result['message']);
      }
    } catch (e) {
      Get.back(); // إغلاق dialog التحميل
      _showErrorSnackbar('فشل في تغيير كلمة المرور: ${e.toString()}');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// مسح حقول كلمة المرور
  void _clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// عرض الصورة بملء الشاشة
  void showFullScreenImage() {
    if (cachedImage.value != null) {
      Get.dialog(
        Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(
                cachedImage.value!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      );
    }
  }

  /// عرض dialog التحميل
  void _showLoadingDialog(String message) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// عرض رسالة نجاح
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  /// تسجيل الخروج
  void logout() {
    AuthService.clearAuthData();
    _storage.remove('cached_profile_image');
    _storage.remove('profile_image_path');
    Get.offAllNamed('/login');
  }

  /// تحديث البيانات
  Future<void> refreshData() async {
    await loadUserData();
  }
}
