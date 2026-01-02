import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart' as neumorphic;
import '../services/storage_service.dart';
import '../themes/colors.dart';
import '../../modules/settings/appearance_settings/models/appearance_settings_model.dart';

class AppThemeService extends GetxService {
  static AppThemeService get instance => Get.find();

  final StorageService _storageService = Get.find();

  final Rx<AppearanceSettings> _currentSettings = AppearanceSettings().obs;
  final RxBool _isDarkMode = false.obs;

  AppearanceSettings get currentSettings => _currentSettings.value;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _currentSettings.value = _storageService.getAppearanceSettings();
    _updateThemeMode();
  }

  void _updateThemeMode() {
    switch (_currentSettings.value.themeMode) {
      case 'light':
        _isDarkMode.value = false;
        break;
      case 'dark':
        _isDarkMode.value = true;
        break;
      case 'system':
      default:
        _isDarkMode.value = Get.isPlatformDarkMode;
        break;
    }
  }

  // أضف هذه الخاصية الجديدة
  ThemeMode get themeMode {
    switch (_currentSettings.value.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        // قيمة افتراضية في حال عدم وجود إعدادات أو قيمة غير معروفة
        return ThemeMode.light;
    }
  }

  // Theme Mode Management
  Future<void> setThemeMode(String mode) async {
    _currentSettings.value = _currentSettings.value.copyWith(themeMode: mode);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    _updateThemeMode();
    await _applyTheme();
  }

  // Color Management
  Future<void> setPrimaryColor(Color color) async {
    _currentSettings.value = _currentSettings.value.copyWith(
      primaryColor: '0x${color.value.toRadixString(16).toUpperCase()}',
    );
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  Future<void> setSecondaryColor(Color color) async {
    _currentSettings.value = _currentSettings.value.copyWith(
      secondaryColor: '0x${color.value.toRadixString(16).toUpperCase()}',
    );
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Font Management
  Future<void> setFontSize(double size) async {
    _currentSettings.value = _currentSettings.value.copyWith(fontSize: size);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(fontFamily: fontFamily);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Accessibility
  Future<void> setHighContrast(bool enabled) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(isHighContrastEnabled: enabled);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Neumorphic Settings
  Future<void> setNeumorphicEnabled(bool enabled) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(isNeumorphicEnabled: enabled);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  Future<void> setBorderRadius(double radius) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(borderRadius: radius);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  Future<void> setShadowIntensity(double intensity) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(shadowIntensity: intensity);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Animations
  Future<void> setAnimationsEnabled(bool enabled) async {
    _currentSettings.value =
        _currentSettings.value.copyWith(isAnimationsEnabled: enabled);
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Apply Theme Preset
  Future<void> applyThemePreset(ThemePreset preset) async {
    _currentSettings.value = _currentSettings.value.copyWith(
      primaryColor: preset.primaryColor,
      secondaryColor: preset.secondaryColor,
    );
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    await _applyTheme();
  }

  // Get Current Colors
  Color get primaryColor {
    try {
      return Color(int.parse(_currentSettings.value.primaryColor));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Color get secondaryColor {
    try {
      return Color(int.parse(_currentSettings.value.secondaryColor));
    } catch (e) {
      return AppColors.secondary;
    }
  }

  // Generate Theme Data
  ThemeData get lightTheme {
    return _generateThemeData(false);
  }

  ThemeData get darkTheme {
    return _generateThemeData(true);
  }

  ThemeData _generateThemeData(bool isDark) {
    final primary = primaryColor;
    final secondary = secondaryColor;
    final fontSize = _currentSettings.value.fontSize;
    final fontFamily = _currentSettings.value.fontFamily;
    final isHighContrast = _currentSettings.value.isHighContrastEnabled;
    final borderRadius = _currentSettings.value.borderRadius;

    final backgroundColor = isDark
        ? (isHighContrast ? Colors.black : AppColors.darkBackground)
        : (isHighContrast ? Colors.white : AppColors.lightBackground);

    final textColor = isDark
        ? (isHighContrast ? Colors.white : AppColors.textLight)
        : (isHighContrast ? Colors.black : AppColors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        secondary: secondary,
      ),
      textTheme: _generateTextTheme(fontSize, fontFamily, textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primary,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      fontFamily: fontFamily,
    );
  }

  TextTheme _generateTextTheme(
      double baseFontSize, String fontFamily, Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: baseFontSize + 12,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: baseFontSize + 8,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: baseFontSize - 4,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: baseFontSize,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: baseFontSize - 2,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: baseFontSize - 4,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: baseFontSize - 4,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: baseFontSize - 6,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
    );
  }

  // Neumorphic Theme Data
  neumorphic.NeumorphicThemeData get lightNeumorphicTheme {
    return neumorphic.NeumorphicThemeData(
      baseColor: _currentSettings.value.isHighContrastEnabled
          ? Colors.white
          : AppColors.lightBackground,
      lightSource: neumorphic.LightSource.topLeft,
      depth: AppConstants.lightDepth,
      intensity: _currentSettings.value.shadowIntensity,
      shadowLightColor: Colors.white,
      shadowDarkColor: AppColors.shadowLight,
      accentColor: primaryColor,
      variantColor: secondaryColor,
      disabledColor: Colors.grey,
    );
  }

  neumorphic.NeumorphicThemeData get darkNeumorphicTheme {
    return neumorphic.NeumorphicThemeData(
      baseColor: _currentSettings.value.isHighContrastEnabled
          ? Colors.black
          : AppColors.darkBackground,
      lightSource: neumorphic.LightSource.topLeft,
      depth: AppConstants.darkDepth,
      intensity: _currentSettings.value.shadowIntensity,
      shadowLightColor: const Color(0xFF2C2C2C),
      shadowDarkColor: Colors.black,
      accentColor: primaryColor,
      variantColor: secondaryColor,
      disabledColor: Colors.grey,
    );
  }

  // Apply Theme
  Future<void> _applyTheme() async {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    Get.changeTheme(_isDarkMode.value ? darkTheme : lightTheme);

    // Update system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode.value
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        systemNavigationBarIconBrightness:
            _isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _currentSettings.value = AppearanceSettings();
    await _storageService.saveAppearanceSettings(_currentSettings.value);
    _updateThemeMode();
    await _applyTheme();
  }

  // Restart app to apply changes
  Future<void> restartApp() async {
    await _applyTheme();
    // Force rebuild all widgets
    Get.forceAppUpdate();
  }
}
