import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';

import '../../core/themes/app_theme.dart';

class ThemeService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable theme mode
  var themeMode = ThemeMode.light.obs;
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  /// Load theme preference from storage
  void _loadThemeFromStorage() {
    final savedThemeMode = _storageService.getThemeMode();
    isDarkMode.value = savedThemeMode;
    themeMode.value = savedThemeMode ? ThemeMode.dark : ThemeMode.light;
    
    // Apply the theme immediately
    Get.changeThemeMode(themeMode.value);
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    
    // Save to storage
    _storageService.saveThemeMode(isDarkMode.value);
    
    // Apply theme change
    Get.changeThemeMode(themeMode.value);
    
    // Show feedback to user
    // Get.snackbar(
    //   'تم تغيير المظهر',
    //   isDarkMode.value ? 'تم تفعيل الوضع الداكن' : 'تم تفعيل الوضع الفاتح',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 2),
    // );
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    isDarkMode.value = mode == ThemeMode.dark;
    
    // Save to storage
    _storageService.saveThemeMode(isDarkMode.value);
    
    // Apply theme change
    Get.changeThemeMode(mode);
  }

  /// Set theme based on system preference
  void setSystemTheme() {
    themeMode.value = ThemeMode.system;
    
    // For system theme, we don't save a specific preference
    _storageService.remove('is_dark_mode');
    
    // Apply theme change
    Get.changeThemeMode(ThemeMode.system);
    
    // Get.snackbar(
    //   'تم تغيير المظهر',
    //   'تم تفعيل مظهر النظام',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 2),
    // );
  }

  /// Get current theme data
  ThemeData getCurrentTheme() {
    return isDarkMode.value ? AppThemeService().darkTheme : AppThemeService().lightTheme;
  }

  /// Get current primary color
  Color getCurrentPrimaryColor() {
    return getCurrentTheme().primaryColor;
  }

  /// Get current background color
  Color getCurrentBackgroundColor() {
    return getCurrentTheme().scaffoldBackgroundColor;
  }

  /// Get current text color
  Color getCurrentTextColor() {
    return getCurrentTheme().textTheme.bodyLarge?.color ?? Colors.black;
  }

  /// Check if current theme is dark
  bool get isCurrentThemeDark => isDarkMode.value;

  /// Check if current theme is light
  bool get isCurrentThemeLight => !isDarkMode.value;

  /// Get theme mode string for display
  String get themeModeString {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
    }
  }

  /// Get available theme options
  List<Map<String, dynamic>> getThemeOptions() {
    return [
      {
        'mode': ThemeMode.light,
        'title': 'الوضع الفاتح',
        'subtitle': 'مظهر فاتح ومشرق',
        'icon': Icons.light_mode,
        'isSelected': themeMode.value == ThemeMode.light,
      },
      {
        'mode': ThemeMode.dark,
        'title': 'الوضع الداكن',
        'subtitle': 'مظهر داكن ومريح للعين',
        'icon': Icons.dark_mode,
        'isSelected': themeMode.value == ThemeMode.dark,
      },
      {
        'mode': ThemeMode.system,
        'title': 'تلقائي',
        'subtitle': 'يتبع إعدادات النظام',
        'icon': Icons.auto_mode,
        'isSelected': themeMode.value == ThemeMode.system,
      },
    ];
  }

  /// Reset theme to default
  void resetThemeToDefault() {
    setThemeMode(ThemeMode.light);
    Get.snackbar(
      'تم إعادة تعيين المظهر',
      'تم إعادة تعيين المظهر إلى الافتراضي',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Schedule theme change (for automatic day/night mode)
  void scheduleThemeChange({
    required TimeOfDay lightModeTime,
    required TimeOfDay darkModeTime,
  }) {
    // This would implement automatic theme switching based on time
    // For now, we'll just save the preferences
    _storageService.write('auto_light_time', '${lightModeTime.hour}:${lightModeTime.minute}');
    _storageService.write('auto_dark_time', '${darkModeTime.hour}:${darkModeTime.minute}');
    _storageService.write('auto_theme_enabled', true);
    
    // Get.snackbar(
    //   'تم تفعيل التبديل التلقائي',
    //   'سيتم تبديل المظهر تلقائياً حسب الأوقات المحددة',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 3),
    // );
  }

  /// Disable automatic theme switching
  void disableAutoThemeSwitch() {
    _storageService.write('auto_theme_enabled', false);
    // Get.snackbar(
    //   'تم إلغاء التبديل التلقائي',
    //   'لن يتم تبديل المظهر تلقائياً',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 2),
    // );
  }

  /// Check if auto theme switching is enabled
  bool get isAutoThemeSwitchEnabled {
    return _storageService.read<bool>('auto_theme_enabled') ?? false;
  }

  /// Get auto theme times
  Map<String, TimeOfDay> getAutoThemeTimes() {
    final lightTimeString = _storageService.read<String>('auto_light_time') ?? '06:00';
    final darkTimeString = _storageService.read<String>('auto_dark_time') ?? '18:00';
    
    final lightTimeParts = lightTimeString.split(':');
    final darkTimeParts = darkTimeString.split(':');
    
    return {
      'light': TimeOfDay(
        hour: int.parse(lightTimeParts[0]),
        minute: int.parse(lightTimeParts[1]),
      ),
      'dark': TimeOfDay(
        hour: int.parse(darkTimeParts[0]),
        minute: int.parse(darkTimeParts[1]),
      ),
    };
  }

  /// Check and apply auto theme if needed
  void checkAndApplyAutoTheme() {
    if (!isAutoThemeSwitchEnabled) return;
    
    final times = getAutoThemeTimes();
    final now = TimeOfDay.now();
    final lightTime = times['light']!;
    final darkTime = times['dark']!;
    
    // Convert TimeOfDay to minutes for easier comparison
    final nowMinutes = now.hour * 60 + now.minute;
    final lightMinutes = lightTime.hour * 60 + lightTime.minute;
    final darkMinutes = darkTime.hour * 60 + darkTime.minute;
    
    bool shouldBeDark;
    
    if (lightMinutes < darkMinutes) {
      // Normal day (light time before dark time)
      shouldBeDark = nowMinutes >= darkMinutes || nowMinutes < lightMinutes;
    } else {
      // Overnight (dark time before light time, crossing midnight)
      shouldBeDark = nowMinutes >= darkMinutes && nowMinutes < lightMinutes;
    }
    
    if (shouldBeDark != isDarkMode.value) {
      setThemeMode(shouldBeDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  /// Export theme settings
  Map<String, dynamic> exportThemeSettings() {
    return {
      'theme_mode': themeMode.value.toString(),
      'is_dark_mode': isDarkMode.value,
      'auto_theme_enabled': isAutoThemeSwitchEnabled,
      'auto_light_time': _storageService.read<String>('auto_light_time'),
      'auto_dark_time': _storageService.read<String>('auto_dark_time'),
    };
  }

  /// Import theme settings
  void importThemeSettings(Map<String, dynamic> settings) {
    if (settings['theme_mode'] != null) {
      final themeModeString = settings['theme_mode'] as String;
      ThemeMode mode;
      
      if (themeModeString.contains('dark')) {
        mode = ThemeMode.dark;
      } else if (themeModeString.contains('light')) {
        mode = ThemeMode.light;
      } else {
        mode = ThemeMode.system;
      }
      
      setThemeMode(mode);
    }
    
    if (settings['auto_theme_enabled'] == true) {
      _storageService.write('auto_theme_enabled', true);
      if (settings['auto_light_time'] != null) {
        _storageService.write('auto_light_time', settings['auto_light_time']);
      }
      if (settings['auto_dark_time'] != null) {
        _storageService.write('auto_dark_time', settings['auto_dark_time']);
      }
    }
    
    // Get.snackbar(
    //   'تم استيراد إعدادات المظهر',
    //   'تم تطبيق إعدادات المظهر المستوردة',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 2),
    // );
  }
}

