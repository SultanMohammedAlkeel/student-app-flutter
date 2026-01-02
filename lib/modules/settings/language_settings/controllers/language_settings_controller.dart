import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_service.dart';
import '../models/language_settings_model.dart';

class LanguageSettingsController extends GetxController {
  final StorageService _storageService = Get.find();
  
  // Observable variables
  final Rx<LanguageSettings> _settings = const LanguageSettings(
    languageCode: 'ar',
    countryCode: 'SA',
    displayName: 'العربية',
    isRTL: true,
  ).obs;
  
  final RxBool _isLoading = false.obs;
  final RxBool _hasChanges = false.obs;
  final RxString _selectedLanguageCode = 'ar'.obs;
  
  // Getters
  LanguageSettings get settings => _settings.value;
  bool get isLoading => _isLoading.value;
  bool get hasChanges => _hasChanges.value;
  String get selectedLanguageCode => _selectedLanguageCode.value;
  
  // Available languages (only Arabic is currently supported)
  List<SupportedLanguage> get availableLanguages => SupportedLanguage.languages;
  
  // Currently supported language
  SupportedLanguage get currentLanguage {
    return availableLanguages.firstWhere(
      (lang) => lang.code == _selectedLanguageCode.value,
      orElse: () => availableLanguages.first,
    );
  }
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  void _loadSettings() {
    _isLoading.value = true;
    try {
      _settings.value = _storageService.getLanguageSettings();
      _selectedLanguageCode.value = _settings.value.languageCode;
      _hasChanges.value = false;
    } catch (e) {
      _showError('خطأ في تحميل إعدادات اللغة: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Change Language
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (!language.isAvailable) {
      _showComingSoonMessage(language);
      return;
    }
    
    if (_selectedLanguageCode.value == language.code) return;
    
    _selectedLanguageCode.value = language.code;
    
    final newSettings = LanguageSettings(
      languageCode: language.code,
      countryCode: language.countryCode,
      displayName: language.nativeName,
      isRTL: language.isRTL,
    );
    
    _settings.value = newSettings;
    _hasChanges.value = true;
    
    try {
      await _storageService.saveLanguageSettings(newSettings);
      await _applyLanguageChange(language);
      _showSuccess('تم تغيير اللغة إلى ${language.nativeName}');
    } catch (e) {
      _showError('خطأ في تغيير اللغة: $e');
    }
  }
  
  Future<void> _applyLanguageChange(SupportedLanguage language) async {
    // Update GetX locale
    final locale = Locale(language.code, language.countryCode);
    Get.updateLocale(locale);
    
    // Update text direction
    if (language.isRTL) {
      Get.forceAppUpdate(); // Force rebuild to apply RTL
    }
  }
  
  // Save Settings
  Future<void> saveSettings() async {
    if (!_hasChanges.value) return;
    
    _isLoading.value = true;
    try {
      await _storageService.saveLanguageSettings(_settings.value);
      _hasChanges.value = false;
      _showSuccess('تم حفظ إعدادات اللغة بنجاح');
    } catch (e) {
      _showError('خطأ في حفظ إعدادات اللغة: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Reset to Default
  Future<void> resetToDefault() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'إعادة تعيين اللغة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: const Text(
          'هل تريد إعادة تعيين اللغة إلى العربية (الافتراضية)؟',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'إعادة تعيين',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
    
    if (result == true) {
      _isLoading.value = true;
      try {
        await _storageService.resetLanguageToDefaults();
        _loadSettings();
        await _applyLanguageChange(availableLanguages.first);
        _showSuccess('تم إعادة تعيين اللغة إلى العربية');
      } catch (e) {
        _showError('خطأ في إعادة تعيين اللغة: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }
  
  // Show Coming Soon Message
  void _showComingSoonMessage(SupportedLanguage language) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Text(
              language.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              language.nativeName,
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'قريباً!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستتوفر اللغة ${language.nativeName} في التحديثات القادمة.',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            const SizedBox(height: 8),
            const Text(
              'نعمل حالياً على إضافة المزيد من اللغات لتحسين تجربة المستخدمين.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'حسناً',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }
  
  // Get Language Info
  Map<String, dynamic> getLanguageInfo() {
    return {
      'currentLanguage': currentLanguage.nativeName,
      'languageCode': currentLanguage.code,
      'countryCode': currentLanguage.countryCode,
      'isRTL': currentLanguage.isRTL,
      'totalLanguages': availableLanguages.length,
      'availableLanguages': availableLanguages.where((lang) => lang.isAvailable).length,
    };
  }
  
  // Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return availableLanguages.any(
      (lang) => lang.code == languageCode && lang.isAvailable,
    );
  }
  
  // Get language by code
  SupportedLanguage? getLanguageByCode(String code) {
    try {
      return availableLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
  
  // Helper methods
  void _showSuccess(String message) {
    Get.snackbar(
      'نجح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
  // Export/Import language settings
  Map<String, dynamic> exportLanguageSettings() {
    return {
      'language': _settings.value.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
  
  Future<bool> importLanguageSettings(Map<String, dynamic> data) async {
    try {
      if (data['language'] != null) {
        final languageSettings = LanguageSettings.fromJson(data['language']);
        await _storageService.saveLanguageSettings(languageSettings);
        _loadSettings();
        return true;
      }
      return false;
    } catch (e) {
      _showError('خطأ في استيراد إعدادات اللغة: $e');
      return false;
    }
  }
}

