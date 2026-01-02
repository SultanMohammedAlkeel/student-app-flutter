import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../core/services/app_settings_storage_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../models/appearance_settings_model.dart';

class AppearanceSettingsController extends GetxController {
  final AppThemeService _themeService = Get.find();
  final StorageService _storageService = Get.find();

  // Observable variables
  final Rx<AppearanceSettings> _settings = AppearanceSettings().obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasChanges = false.obs;
  final RxString _selectedPresetId = ''.obs;

  // Getters
  AppearanceSettings get settings => _settings.value;
  bool get isLoading => _isLoading.value;
  bool get hasChanges => _hasChanges.value;
  String get selectedPresetId => _selectedPresetId.value;

  // Theme mode options
  final List<Map<String, dynamic>> themeModeOptions = [
    {
      'value': 'light',
      'title': 'فاتح',
      'subtitle': 'المظهر الفاتح دائماً',
      'icon': Icons.light_mode,
    },
    {
      'value': 'dark',
      'title': 'داكن',
      'subtitle': 'المظهر الداكن دائماً',
      'icon': Icons.dark_mode,
    },
    {
      'value': 'system',
      'title': 'تلقائي',
      'subtitle': 'يتبع إعدادات النظام',
      'icon': Icons.auto_mode,
    },
  ];

  // Font family options
  final List<Map<String, dynamic>> fontFamilyOptions = [
    {
      'value': 'Tajawal',
      'title': 'تجوال',
      'subtitle': 'الخط الافتراضي للتطبيق',
    },
    {
      'value': 'Cairo',
      'title': 'القاهرة',
      'subtitle': 'خط عربي حديث',
    },
    {
      'value': 'Amiri',
      'title': 'أميري',
      'subtitle': 'خط عربي كلاسيكي',
    },
    {
      'value': 'Noto Sans Arabic',
      'title': 'نوتو سانس',
      'subtitle': 'خط عربي واضح',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _isLoading.value = true;
    try {
      _settings.value = _storageService.getAppearanceSettings();
      _findMatchingPreset();
      _hasChanges.value = false;
    } catch (e) {
      _showError('خطأ في تحميل الإعدادات: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _findMatchingPreset() {
    for (final preset in ThemePreset.presets) {
      if (preset.primaryColor == _settings.value.primaryColor &&
          preset.secondaryColor == _settings.value.secondaryColor) {
        _selectedPresetId.value = preset.id;
        return;
      }
    }
    _selectedPresetId.value = '';
  }

  // Theme Mode
  Future<void> setThemeMode(String mode) async {
    if (_settings.value.themeMode == mode) return;

    _settings.value = _settings.value.copyWith(themeMode: mode);
    _hasChanges.value = true;
    await _themeService.setThemeMode(mode);
    // // _showSuccess('تم تغيير وضع المظهر');
  }

  // Colors
  Future<void> setPrimaryColor(Color color) async {
    final colorString = '0x${color.value.toRadixString(16).toUpperCase()}';
    if (_settings.value.primaryColor == colorString) return;

    _settings.value = _settings.value.copyWith(primaryColor: colorString);
    _hasChanges.value = true;
    _selectedPresetId.value = ''; // Clear preset selection
    await _themeService.setPrimaryColor(color);
    // // _showSuccess('تم تغيير اللون الأساسي');
  }

  Future<void> setSecondaryColor(Color color) async {
    final colorString = '0x${color.value.toRadixString(16).toUpperCase()}';
    if (_settings.value.secondaryColor == colorString) return;

    _settings.value = _settings.value.copyWith(secondaryColor: colorString);
    _hasChanges.value = true;
    _selectedPresetId.value = ''; // Clear preset selection
    await _themeService.setSecondaryColor(color);
    // _showSuccess('تم تغيير اللون الثانوي');
  }

  // Theme Presets
  Future<void> applyThemePreset(ThemePreset preset) async {
    if (_selectedPresetId.value == preset.id) return;

    _settings.value = _settings.value.copyWith(
      primaryColor: preset.primaryColor,
      secondaryColor: preset.secondaryColor,
    );
    _selectedPresetId.value = preset.id;
    _hasChanges.value = true;
    await _themeService.applyThemePreset(preset);
    // _showSuccess('تم تطبيق ثيم ${preset.name}');
  }

  // Font Settings
  Future<void> setFontSize(double size) async {
    if (_settings.value.fontSize == size) return;

    _settings.value = _settings.value.copyWith(fontSize: size);
    _hasChanges.value = true;
    await _themeService.setFontSize(size);
    // _showSuccess('تم تغيير حجم الخط');
  }

  Future<void> setFontFamily(String fontFamily) async {
    if (_settings.value.fontFamily == fontFamily) return;

    _settings.value = _settings.value.copyWith(fontFamily: fontFamily);
    _hasChanges.value = true;
    await _themeService.setFontFamily(fontFamily);
    // _showSuccess('تم تغيير نوع الخط');
  }

  // Accessibility
  Future<void> toggleHighContrast() async {
    final newValue = !_settings.value.isHighContrastEnabled;
    _settings.value = _settings.value.copyWith(isHighContrastEnabled: newValue);
    _hasChanges.value = true;
    await _themeService.setHighContrast(newValue);
    // _showSuccess(newValue ? 'تم تفعيل التباين العالي' : 'تم إلغاء التباين العالي');
  }

  // Neumorphic Settings
  Future<void> toggleNeumorphic() async {
    final newValue = !_settings.value.isNeumorphicEnabled;
    _settings.value = _settings.value.copyWith(isNeumorphicEnabled: newValue);
    _hasChanges.value = true;
    await _themeService.setNeumorphicEnabled(newValue);
    // _showSuccess(newValue ? 'تم تفعيل التأثيرات المجسمة' : 'تم إلغاء التأثيرات المجسمة');
  }

  Future<void> setBorderRadius(double radius) async {
    if (_settings.value.borderRadius == radius) return;

    _settings.value = _settings.value.copyWith(borderRadius: radius);
    _hasChanges.value = true;
    await _themeService.setBorderRadius(radius);
    // _showSuccess('تم تغيير انحناء الحواف');
  }

  Future<void> setShadowIntensity(double intensity) async {
    if (_settings.value.shadowIntensity == intensity) return;

    _settings.value = _settings.value.copyWith(shadowIntensity: intensity);
    _hasChanges.value = true;
    await _themeService.setShadowIntensity(intensity);
    // _showSuccess('تم تغيير شدة الظلال');
  }

  // Animations
  Future<void> toggleAnimations() async {
    final newValue = !_settings.value.isAnimationsEnabled;
    _settings.value = _settings.value.copyWith(isAnimationsEnabled: newValue);
    _hasChanges.value = true;
    await _themeService.setAnimationsEnabled(newValue);
    // _showSuccess(newValue ? 'تم تفعيل الحركات' : 'تم إلغاء الحركات');
  }

  // Save and Reset
  Future<void> saveSettings() async {
    if (!_hasChanges.value) return;

    _isLoading.value = true;
    try {
      await _storageService.saveAppearanceSettings(_settings.value);
      _hasChanges.value = false;
      // _showSuccess('تم حفظ الإعدادات بنجاح');
      Get.forceAppUpdate();
      _loadSettings(); // Reload settings to reflect changes
    } catch (e) {
      _showError('خطأ في حفظ الإعدادات: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetToDefaults() async {
    HomeController homeController = Get.find<HomeController>();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'إعادة تعيين الإعدادات',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: const Text(
          'هل تريد إعادة تعيين جميع إعدادات المظهر إلى القيم الافتراضية؟',
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
            child: Text(
              'إعادة تعيين',
              style: TextStyle(
                color: homeController.getPrimaryColor(),
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
        await _themeService.resetToDefaults();
        // Get.forceAppUpdate();
        _loadSettings();
        // _showSuccess('تم إعادة تعيين الإعدادات بنجاح');
      } catch (e) {
        _showError('خطأ في إعادة تعيين الإعدادات: $e');
      } finally {
        _isLoading.value = false;
        restartApp();
      }
    }
  }

  // Restart App
  Future<void> restartApp() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'إعادة تشغيل التطبيق',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: const Text(
          'لتطبيق جميع التغييرات بشكل كامل، يُنصح بإعادة تشغيل التطبيق. هل تريد المتابعة؟',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'لاحقاً',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'إعادة تشغيل',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _themeService.restartApp();
    }
  }

  // Helper methods
  Color getPrimaryColor() {
    try {
      return Color(int.parse(_settings.value.primaryColor));
    } catch (e) {
      return const Color(0xFF4ECDC4);
    }
  }

  Color getSecondaryColor() {
    try {
      return Color(int.parse(_settings.value.secondaryColor));
    } catch (e) {
      return const Color(0xFF6B5B95);
    }
  }

  String getThemeModeTitle() {
    switch (_settings.value.themeMode) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      case 'system':
      default:
        return 'تلقائي';
    }
  }

  String getFontFamilyTitle() {
    final option = fontFamilyOptions.firstWhereOrNull(
      (option) => option['value'] == _settings.value.fontFamily,
    );
    return option?['title'] ?? _settings.value.fontFamily;
  }

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

  // Preview methods for real-time changes
  void previewPrimaryColor(Color color) {
    _themeService.setPrimaryColor(color);
  }

  void previewSecondaryColor(Color color) {
    _themeService.setSecondaryColor(color);
  }

  void previewFontSize(double size) {
    _themeService.setFontSize(size);
  }
}
