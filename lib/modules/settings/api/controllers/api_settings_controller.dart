import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';

class ApiSettingsController extends GetxController {
  final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();
  
  final TextEditingController urlController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString currentUrl = ''.obs;
  final RxBool isValidUrl = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUrl();
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }

  void _loadCurrentUrl() {
    currentUrl.value = _apiUrlService.currentApiUrl;
    urlController.text = currentUrl.value;
  }

  void onUrlChanged(String value) {
    isValidUrl.value = _apiUrlService.isValidUrl(value);
  }

  Future<void> saveApiUrl() async {
    if (!isValidUrl.value) {
      _showErrorSnackbar('الرجاء إدخال رابط صحيح');
      return;
    }

    try {
      isLoading.value = true;
      
      await _apiUrlService.setApiUrl(urlController.text);
      currentUrl.value = _apiUrlService.currentApiUrl;
      
      _showSuccessSnackbar('تم حفظ عنوان الـ API بنجاح');
      
      // إعادة تشغيل التطبيق لتطبيق التغييرات
      _showRestartDialog();
      
    } catch (e) {
      _showErrorSnackbar('فشل في حفظ عنوان الـ API: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetToDefault() async {
    try {
      isLoading.value = true;
      
      await _apiUrlService.resetToDefault();
      _loadCurrentUrl();
      
      _showSuccessSnackbar('تم إعادة تعيين عنوان الـ API إلى القيمة الافتراضية');
      
      // إعادة تشغيل التطبيق لتطبيق التغييرات
      _showRestartDialog();
      
    } catch (e) {
      _showErrorSnackbar('فشل في إعادة تعيين عنوان الـ API: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

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

  void _showRestartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تشغيل التطبيق'),
        content: const Text('يجب إعادة تشغيل التطبيق لتطبيق التغييرات. هل تريد إعادة التشغيل الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // يمكن إضافة كود إعادة تشغيل التطبيق هنا
              // أو توجيه المستخدم لإعادة تشغيل التطبيق يدوياً
            },
            child: const Text('إعادة التشغيل'),
          ),
        ],
      ),
    );
  }

  bool get isDefaultUrl => _apiUrlService.isDefaultUrl();
  
  String get defaultUrl => _apiUrlService.getDefaultApiUrl();
}

