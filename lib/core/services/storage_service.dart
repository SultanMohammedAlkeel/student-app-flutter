import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/settings/appearance_settings/models/appearance_settings_model.dart';
import '../../modules/settings/language_settings/models/language_settings_model.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;
  late final GetStorage _box;

  Future<StorageService> init(SharedPreferences prefs) async {
    try {
      _prefs = prefs;
      await GetStorage.init();
      _box = GetStorage();
      return this;
    } catch (e) {
      throw 'فشل في تهيئة خدمة التخزين: ${e.toString()}';
    }
  }

  // ============ SharedPreferences Methods ============
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw 'فشل في حفظ البيانات: ${e.toString()}';
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw 'فشل في قراءة البيانات: ${e.toString()}';
    }
  }

  // ============ GetStorage Methods ============
  Future<void> write(String key, dynamic value) async {
    try {
      await _box.write(key, value);
    } catch (e) {
      throw 'فشل في حفظ البيانات: ${e.toString()}';
    }
  }

  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      throw 'فشل في قراءة البيانات: ${e.toString()}';
    }
  }

  Future<void> remove(String key) async {
    try {
      await _box.remove(key);
    } catch (e) {
      throw 'فشل في حذف البيانات: ${e.toString()}';
    }
  }

  Future<void> clear() async {
    try {
      await _box.erase();
      await _prefs.clear();
    } catch (e) {
      throw 'فشل في مسح جميع البيانات: ${e.toString()}';
    }
  }

  
  Future<void> writeBytes(String key, Uint8List value) async {
    await _box.write(key, value);
  }

  Future<Uint8List?> readBytes(String key) async {
    return _box.read<Uint8List>(key);
  }
  
  Future<void> removeBytes(String key) async {
    await _box.remove(key);
  }


  // حفظ قيمة نصية
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // الحصول على قيمة نصية
 

  // حفظ كائن
  Future<bool> saveObject(String key, dynamic value) async {
    return await _prefs.setString(key, json.encode(value));
  }

  // الحصول على كائن
  Future<dynamic> getObject(String key) async {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    return json.decode(jsonString);
  }

  // حذف جميع القيم

  // ============ Blocked User IDs Methods ============
  // ignore: prefer_final_fields
  String _blockedUserIdsKey = 'blocked_user_ids';

  List<int> getBlockedUserIds() {
    return _box.read<List<dynamic>>(_blockedUserIdsKey)?.map((e) => e as int).toList() ?? [];
  }

  Future<void> addBlockedUserId(int userId) async {
    List<int> blockedIds = getBlockedUserIds();
    if (!blockedIds.contains(userId)) {
      blockedIds.add(userId);
      await _box.write(_blockedUserIdsKey, blockedIds);
    }
  }

  Future<void> removeBlockedUserId(int userId) async {
    List<int> blockedIds = getBlockedUserIds();
    blockedIds.remove(userId);
    await _box.write(_blockedUserIdsKey, blockedIds);
  }
  // التحقق من وجود مفتاح
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
  
   static const String _tasksKey = 'student_tasks';
  static const String _studyScheduleKey = 'study_schedule';
  static const String _darkModeKey = 'dark_mode';
  static const String _localeKey = 'locale';

  



  // حفظ المهام
   Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    await _box.write(_tasksKey, jsonEncode(tasks));
  }

  // الحصول على المهام
   List<Map<String, dynamic>> getTasks() {
    final data = _box.read<String>(_tasksKey);
    if (data != null) {
      final List<dynamic> decodedData = jsonDecode(data);
      return decodedData.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  // إضافة مهمة جديدة
   Future<void> addTask(Map<String, dynamic> task) async {
    final tasks = getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  // تحديث مهمة
   Future<void> updateTask(String taskId, Map<String, dynamic> updatedTask) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((task) => task['id'] == taskId);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  // حذف مهمة
   Future<void> deleteTask(String taskId) async {
    final tasks = getTasks();
    tasks.removeWhere((task) => task['id'] == taskId);
    await saveTasks(tasks);
  }

  // حفظ جدول المذاكرة
   Future<void> saveStudySchedule(List<Map<String, dynamic>> schedule) async {
    await _box.write(_studyScheduleKey, jsonEncode(schedule));
  }

  // الحصول على جدول المذاكرة
   List<Map<String, dynamic>> getStudySchedule() {
    final data = _box.read<String>(_studyScheduleKey);
    if (data != null) {
      final List<dynamic> decodedData = jsonDecode(data);
      return decodedData.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  // حفظ وضع الظلام
   Future<void> saveDarkMode(bool isDarkMode) async {
    await _box.write(_darkModeKey, isDarkMode);
  }

  // الحصول على وضع الظلام
   bool getDarkMode() {
    return _box.read<bool>(_darkModeKey) ?? false;
  }

  // حفظ اللغة
   Future<void> saveLocale(String locale) async {
    await _box.write(_localeKey, locale);
  }

  // الحصول على اللغة
   String getLocale() {
    return _box.read<String>(_localeKey) ?? 'ar';
  }

  // تنسيق التاريخ حسب اللغة
   String formatDate(DateTime date) {
    final locale = getLocale();
    return DateFormat.yMMMd(locale).format(date);
  }

  // تنسيق الوقت حسب اللغة
   String formatTime(DateTime time) {
    final locale = getLocale();
    return DateFormat.jm(locale).format(time);
  }

  // حذف جميع البيانات (تسجيل الخروج)
   Future<void> clearAll() async {
    await _box.erase();
  }
  ///////////////////////////////////////////////////////////////////////////////////


 

  Future<void> erase() async {
    await _box.erase();
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }

  // Settings specific methods
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _box.write('app_settings', settings);
  }

  Map<String, dynamic>? getSettings() {
    return _box.read<Map<String, dynamic>>('app_settings');
  }

  // User preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _box.write('user_preferences', preferences);
  }

  Map<String, dynamic>? getUserPreferences() {
    return _box.read<Map<String, dynamic>>('user_preferences');
  }

  // Theme settings
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _box.write('is_dark_mode', isDarkMode);
  }

  bool getThemeMode() {
    return _box.read<bool>('is_dark_mode') ?? false;
  }

  // Language settings
  Future<void> saveLanguage(String languageCode) async {
    await _box.write('language_code', languageCode);
  }

  String getLanguage() {
    return _box.read<String>('language_code') ?? 'ar';
  }

  // Notification settings
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _box.write('notification_settings', settings);
  }

  Map<String, dynamic>? getNotificationSettings() {
    return _box.read<Map<String, dynamic>>('notification_settings');
  }

  // Privacy settings
  Future<void> savePrivacySettings(Map<String, dynamic> settings) async {
    await _box.write('privacy_settings', settings);
  }

  Map<String, dynamic>? getPrivacySettings() {
    return _box.read<Map<String, dynamic>>('privacy_settings');
  }

  // Accessibility settings
  Future<void> saveAccessibilitySettings(Map<String, dynamic> settings) async {
    await _box.write('accessibility_settings', settings);
  }

  Map<String, dynamic>? getAccessibilitySettings() {
    return _box.read<Map<String, dynamic>>('accessibility_settings');
  }

  // Learning preferences
  Future<void> saveLearningPreferences(Map<String, dynamic> preferences) async {
    await _box.write('learning_preferences', preferences);
  }

  Map<String, dynamic>? getLearningPreferences() {
    return _box.read<Map<String, dynamic>>('learning_preferences');
  }

  // Social settings
  Future<void> saveSocialSettings(Map<String, dynamic> settings) async {
    await _box.write('social_settings', settings);
  }

  Map<String, dynamic>? getSocialSettings() {
    return _box.read<Map<String, dynamic>>('social_settings');
  }

  // Cache management
  Future<void> clearCache() async {
    // Clear specific cache keys
    final cacheKeys = ['temp_data', 'cached_images', 'api_cache'];
    for (String key in cacheKeys) {
      await _box.remove(key);
    }
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    final keys = _box.getKeys();
    final values = _box.getValues();
    
    return {
      'total_keys': keys.length,
      'storage_size': _calculateStorageSize(values),
      'keys': keys.toList(),
    };
  }

  int _calculateStorageSize(Iterable<dynamic> values) {
    // Simple estimation of storage size
    int totalSize = 0;
    for (var value in values) {
      if (value is String) {
        totalSize += value.length * 2; // Approximate UTF-16 encoding
      } else if (value is Map || value is List) {
        totalSize += value.toString().length * 2;
      } else {
        totalSize += 8; // Approximate for other types
      }
    }
    return totalSize;
  }

  // Backup and restore
  Map<String, dynamic> exportAllData() {
    final keys = _box.getKeys();
    final Map<String, dynamic> allData = {};
    
    for (String key in keys) {
      allData[key] = _box.read(key);
    }
    
    return allData;
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    for (String key in data.keys) {
      await _box.write(key, data[key]);
    }
  }

  // First time setup
  Future<void> markFirstTimeSetupComplete() async {
    await _box.write('first_time_setup_complete', true);
  }

  bool isFirstTimeSetupComplete() {
    return _box.read<bool>('first_time_setup_complete') ?? false;
  }

  // App version tracking
  Future<void> saveAppVersion(String version) async {
    await _box.write('app_version', version);
  }

  String? getAppVersion() {
    return _box.read<String>('app_version');
  }

  // Last sync timestamp
  Future<void> saveLastSyncTime(DateTime timestamp) async {
    await _box.write('last_sync_time', timestamp.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeString = _box.read<String>('last_sync_time');
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  // User session data
  Future<void> saveUserSession(Map<String, dynamic> sessionData) async {
    await _box.write('user_session', sessionData);
  }

  Map<String, dynamic>? getUserSession() {
    return _box.read<Map<String, dynamic>>('user_session');
  }

  Future<void> clearUserSession() async {
    await _box.remove('user_session');
  }

  // Temporary data with expiration
  Future<void> saveTempData(String key, dynamic value, Duration expiration) async {
    final expirationTime = DateTime.now().add(expiration);
    await _box.write('temp_$key', {
      'value': value,
      'expiration': expirationTime.toIso8601String(),
    });
  }

  T? getTempData<T>(String key) {
    final data = _box.read<Map<String, dynamic>>('temp_$key');
    if (data == null) return null;
    
    final expirationTime = DateTime.parse(data['expiration']);
    if (DateTime.now().isAfter(expirationTime)) {
      _box.remove('temp_$key');
      return null;
    }
    
    return data['value'] as T?;
  }

  // Clean expired temporary data
  Future<void> cleanExpiredTempData() async {
    final keys = _box.getKeys().where((key) => key.startsWith('temp_')).toList();
    
    for (String key in keys) {
      final data = _box.read<Map<String, dynamic>>(key);
      if (data != null) {
        final expirationTime = DateTime.parse(data['expiration']);
        if (DateTime.now().isAfter(expirationTime)) {
          await _box.remove(key);
        }
      }
    }
  }

  static const String _appearanceKey = 'appearance_settings';
  static const String _languageKey = 'language_settings';
  static const String _firstLaunchKey = 'first_launch';
  static const String _lastUpdateKey = 'last_update';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initStorage();
  }
  
  Future<void> _initStorage() async {
    await GetStorage.init('app_settings');
    _box = GetStorage('app_settings');
  }
  
  // Appearance Settings
  AppearanceSettings getAppearanceSettings() {
    final data = _box.read(_appearanceKey);
    if (data != null) {
      return AppearanceSettings.fromJson(Map<String, dynamic>.from(data));
    }
    return AppearanceSettings(); // Default settings
  }
  
  Future<void> saveAppearanceSettings(AppearanceSettings settings) async {
    await _box.write(_appearanceKey, settings.toJson());
    await _updateLastModified();
  }
  
  // Language Settings
  LanguageSettings getLanguageSettings() {
    final data = _box.read(_languageKey);
    if (data != null) {
      return LanguageSettings.fromJson(Map<String, dynamic>.from(data));
    }
    return const LanguageSettings(
      languageCode: 'ar',
      countryCode: 'SA',
      displayName: 'العربية',
      isRTL: true,
    ); // Default settings
  }
  
  Future<void> saveLanguageSettings(LanguageSettings settings) async {
    await _box.write(_languageKey, settings.toJson());
    await _updateLastModified();
  }
  
  // First Launch
  bool isFirstLaunch() {
    return _box.read(_firstLaunchKey) ?? true;
  }
  
  Future<void> setFirstLaunchCompleted() async {
    await _box.write(_firstLaunchKey, false);
  }
  
  // Last Update
  DateTime? getLastUpdate() {
    final timestamp = _box.read(_lastUpdateKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  Future<void> _updateLastModified() async {
    await _box.write(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  // Backup and Restore
  Map<String, dynamic> exportAllSettings() {
    return {
      'appearance': getAppearanceSettings().toJson(),
      'language': getLanguageSettings().toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }
  
  Future<bool> importAllSettings(Map<String, dynamic> data) async {
    try {
      if (data['appearance'] != null) {
        final appearance = AppearanceSettings.fromJson(data['appearance']);
        await saveAppearanceSettings(appearance);
      }
      
      if (data['language'] != null) {
        final language = LanguageSettings.fromJson(data['language']);
        await saveLanguageSettings(language);
      }
      
      return true;
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }
  
  // Reset to defaults
  Future<void> resetAppearanceToDefaults() async {
    await saveAppearanceSettings(AppearanceSettings());
  }
  
  Future<void> resetLanguageToDefaults() async {
    await saveLanguageSettings(const LanguageSettings(
      languageCode: 'ar',
      countryCode: 'SA',
      displayName: 'العربية',
      isRTL: true,
    ));
  }
  
  Future<void> resetAllToDefaults() async {
    await resetAppearanceToDefaults();
    await resetLanguageToDefaults();
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    await _box.erase();
  }
  
  // Storage info
  // Map<String, dynamic> getStorageInfo() {
  //   final keys = _box.getKeys();
  //   final values = _box.getValues();
    
  //   return {
  //     'totalKeys': keys.length,
  //     'storageSize': _calculateStorageSize(values),
  //     'lastUpdate': getLastUpdate()?.toIso8601String(),
  //     'isFirstLaunch': isFirstLaunch(),
  //   };
  // }
  
  // int _calculateStorageSize(Map<dynamic, dynamic> values) {
  //   // Simple estimation of storage size
  //   int size = 0;
  //   values.forEach((key, value) {
  //     size += key.toString().length;
  //     size += value.toString().length;
  //   });
  //   return size;
  // }
  
  // Specific color settings
  Future<void> savePrimaryColor(String colorValue) async {
    final current = getAppearanceSettings();
    await saveAppearanceSettings(current.copyWith(primaryColor: colorValue));
  }
  
  Future<void> saveSecondaryColor(String colorValue) async {
    final current = getAppearanceSettings();
    await saveAppearanceSettings(current.copyWith(secondaryColor: colorValue));
  }
  
  // Future<void> saveThemeMode(String mode) async {
  //   final current = getAppearanceSettings();
  //   await saveAppearanceSettings(current.copyWith(themeMode: mode));
  // }
  
  Future<void> saveFontSize(double size) async {
    final current = getAppearanceSettings();
    await saveAppearanceSettings(current.copyWith(fontSize: size));
  }
  
  Future<void> saveHighContrast(bool enabled) async {
    final current = getAppearanceSettings();
    await saveAppearanceSettings(current.copyWith(isHighContrastEnabled: enabled));
  }
  
  // Validation
  bool validateSettings() {
    try {
      getAppearanceSettings();
      getLanguageSettings();
      return true;
    } catch (e) {
      print('Settings validation failed: $e');
      return false;
    }
  }


}