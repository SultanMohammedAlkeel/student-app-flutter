// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import '../../modules/settings/appearance_settings/models/appearance_settings_model.dart';
// import '../../modules/settings/language_settings/models/language_settings_model.dart';

// class AppSettingsStorageService extends GetxService {
//   static AppSettingsStorageService get instance => Get.find();
  
//   late final GetStorage _box;
  
//   // Storage keys
//   static const String _appearanceKey = 'appearance_settings';
//   static const String _languageKey = 'language_settings';
//   static const String _firstLaunchKey = 'first_launch';
//   static const String _lastUpdateKey = 'last_update';
  
//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     await _initStorage();
//   }
  
//   Future<void> _initStorage() async {
//     await GetStorage.init('app_settings');
//     _box = GetStorage('app_settings');
//   }
  
//   // Appearance Settings
//   AppearanceSettings getAppearanceSettings() {
//     final data = _box.read(_appearanceKey);
//     if (data != null) {
//       return AppearanceSettings.fromJson(Map<String, dynamic>.from(data));
//     }
//     return AppearanceSettings(); // Default settings
//   }
  
//   Future<void> saveAppearanceSettings(AppearanceSettings settings) async {
//     await _box.write(_appearanceKey, settings.toJson());
//     await _updateLastModified();
//   }
  
//   // Language Settings
//   LanguageSettings getLanguageSettings() {
//     final data = _box.read(_languageKey);
//     if (data != null) {
//       return LanguageSettings.fromJson(Map<String, dynamic>.from(data));
//     }
//     return const LanguageSettings(
//       languageCode: 'ar',
//       countryCode: 'SA',
//       displayName: 'العربية',
//       isRTL: true,
//     ); // Default settings
//   }
  
//   Future<void> saveLanguageSettings(LanguageSettings settings) async {
//     await _box.write(_languageKey, settings.toJson());
//     await _updateLastModified();
//   }
  
//   // First Launch
//   bool isFirstLaunch() {
//     return _box.read(_firstLaunchKey) ?? true;
//   }
  
//   Future<void> setFirstLaunchCompleted() async {
//     await _box.write(_firstLaunchKey, false);
//   }
  
//   // Last Update
//   DateTime? getLastUpdate() {
//     final timestamp = _box.read(_lastUpdateKey);
//     if (timestamp != null) {
//       return DateTime.fromMillisecondsSinceEpoch(timestamp);
//     }
//     return null;
//   }
  
//   Future<void> _updateLastModified() async {
//     await _box.write(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
//   }
  
//   // Backup and Restore
//   Map<String, dynamic> exportAllSettings() {
//     return {
//       'appearance': getAppearanceSettings().toJson(),
//       'language': getLanguageSettings().toJson(),
//       'exportDate': DateTime.now().toIso8601String(),
//       'version': '1.0.0',
//     };
//   }
  
//   Future<bool> importAllSettings(Map<String, dynamic> data) async {
//     try {
//       if (data['appearance'] != null) {
//         final appearance = AppearanceSettings.fromJson(data['appearance']);
//         await saveAppearanceSettings(appearance);
//       }
      
//       if (data['language'] != null) {
//         final language = LanguageSettings.fromJson(data['language']);
//         await saveLanguageSettings(language);
//       }
      
//       return true;
//     } catch (e) {
//       print('Error importing settings: $e');
//       return false;
//     }
//   }
  
//   // Reset to defaults
//   Future<void> resetAppearanceToDefaults() async {
//     await saveAppearanceSettings(AppearanceSettings());
//   }
  
//   Future<void> resetLanguageToDefaults() async {
//     await saveLanguageSettings(const LanguageSettings(
//       languageCode: 'ar',
//       countryCode: 'SA',
//       displayName: 'العربية',
//       isRTL: true,
//     ));
//   }
  
//   Future<void> resetAllToDefaults() async {
//     await resetAppearanceToDefaults();
//     await resetLanguageToDefaults();
//   }
  
//   // Clear all data
//   Future<void> clearAllData() async {
//     await _box.erase();
//   }
  
//   // Storage info
//   Map<String, dynamic> getStorageInfo() {
//     final keys = _box.getKeys();
//     final values = _box.getValues();
    
//     return {
//       'totalKeys': keys.length,
//       'storageSize': _calculateStorageSize(values),
//       'lastUpdate': getLastUpdate()?.toIso8601String(),
//       'isFirstLaunch': isFirstLaunch(),
//     };
//   }
  
//   int _calculateStorageSize(Map<dynamic, dynamic> values) {
//     // Simple estimation of storage size
//     int size = 0;
//     values.forEach((key, value) {
//       size += key.toString().length;
//       size += value.toString().length;
//     });
//     return size;
//   }
  
//   // Specific color settings
//   Future<void> savePrimaryColor(String colorValue) async {
//     final current = getAppearanceSettings();
//     await saveAppearanceSettings(current.copyWith(primaryColor: colorValue));
//   }
  
//   Future<void> saveSecondaryColor(String colorValue) async {
//     final current = getAppearanceSettings();
//     await saveAppearanceSettings(current.copyWith(secondaryColor: colorValue));
//   }
  
//   Future<void> saveThemeMode(String mode) async {
//     final current = getAppearanceSettings();
//     await saveAppearanceSettings(current.copyWith(themeMode: mode));
//   }
  
//   Future<void> saveFontSize(double size) async {
//     final current = getAppearanceSettings();
//     await saveAppearanceSettings(current.copyWith(fontSize: size));
//   }
  
//   Future<void> saveHighContrast(bool enabled) async {
//     final current = getAppearanceSettings();
//     await saveAppearanceSettings(current.copyWith(isHighContrastEnabled: enabled));
//   }
  
//   // Validation
//   bool validateSettings() {
//     try {
//       getAppearanceSettings();
//       getLanguageSettings();
//       return true;
//     } catch (e) {
//       print('Settings validation failed: $e');
//       return false;
//     }
//   }
// }

