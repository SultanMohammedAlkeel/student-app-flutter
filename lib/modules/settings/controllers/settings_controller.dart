import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:student_app/core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final _box = GetStorage();

  // Observable variables for settings
  var isDarkMode = false.obs;
  var isNotificationsEnabled = true.obs;
  var isAcademicNotificationsEnabled = true.obs;
  var isAdminNotificationsEnabled = true.obs;
  var isRemindersEnabled = true.obs;
  var selectedLanguage = 'ar'.obs;
  var fontSize = 16.0.obs;
  var isHighContrastEnabled = false.obs;
  var isVoiceOverEnabled = false.obs;
  var isDataSaverEnabled = false.obs;
  var isAutoBackupEnabled = true.obs;
  var isLocationSharingEnabled = false.obs;
  var isAnalyticsEnabled = true.obs;
  var isPersonalizedAdsEnabled = false.obs;
  var isOnlineStatusVisible = true.obs;
  var isAchievementSharingEnabled = true.obs;
  var learningStyle = 'visual'.obs; // visual, auditory, kinesthetic
  var preferredStudyTime = 'morning'.obs; // morning, afternoon, evening, night
  var studySessionDuration = 45.obs; // minutes
  var breakDuration = 15.obs; // minutes
  var isStudyRemindersEnabled = true.obs;
  var isProgressTrackingEnabled = true.obs;
  var isAchievementSystemEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load settings from storage
  void loadSettings() {
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    isNotificationsEnabled.value = _box.read('isNotificationsEnabled') ?? true;
    isAcademicNotificationsEnabled.value = _box.read('isAcademicNotificationsEnabled') ?? true;
    isAdminNotificationsEnabled.value = _box.read('isAdminNotificationsEnabled') ?? true;
    isRemindersEnabled.value = _box.read('isRemindersEnabled') ?? true;
    selectedLanguage.value = _box.read('selectedLanguage') ?? 'ar';
    fontSize.value = _box.read('fontSize') ?? 16.0;
    isHighContrastEnabled.value = _box.read('isHighContrastEnabled') ?? false;
    isVoiceOverEnabled.value = _box.read('isVoiceOverEnabled') ?? false;
    isDataSaverEnabled.value = _box.read('isDataSaverEnabled') ?? false;
    isAutoBackupEnabled.value = _box.read('isAutoBackupEnabled') ?? true;
    isLocationSharingEnabled.value = _box.read('isLocationSharingEnabled') ?? false;
    isAnalyticsEnabled.value = _box.read('isAnalyticsEnabled') ?? true;
    isPersonalizedAdsEnabled.value = _box.read('isPersonalizedAdsEnabled') ?? false;
    isOnlineStatusVisible.value = _box.read('isOnlineStatusVisible') ?? true;
    isAchievementSharingEnabled.value = _box.read('isAchievementSharingEnabled') ?? true;
    learningStyle.value = _box.read('learningStyle') ?? 'visual';
    preferredStudyTime.value = _box.read('preferredStudyTime') ?? 'morning';
    studySessionDuration.value = _box.read('studySessionDuration') ?? 45;
    breakDuration.value = _box.read('breakDuration') ?? 15;
    isStudyRemindersEnabled.value = _box.read('isStudyRemindersEnabled') ?? true;
    isProgressTrackingEnabled.value = _box.read('isProgressTrackingEnabled') ?? true;
    isAchievementSystemEnabled.value = _box.read('isAchievementSystemEnabled') ?? true;
  }

  // Save individual setting
  void saveSetting(String key, dynamic value) {
    _box.write(key, value);
  }

  // Theme settings
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    saveSetting('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  // Notification settings
  void toggleNotifications() {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
    saveSetting('isNotificationsEnabled', isNotificationsEnabled.value);
    update();
  }

  void toggleAcademicNotifications() {
    isAcademicNotificationsEnabled.value = !isAcademicNotificationsEnabled.value;
    saveSetting('isAcademicNotificationsEnabled', isAcademicNotificationsEnabled.value);
    update();
  }

  void toggleAdminNotifications() {
    isAdminNotificationsEnabled.value = !isAdminNotificationsEnabled.value;
    saveSetting('isAdminNotificationsEnabled', isAdminNotificationsEnabled.value);
    update();
  }

  void toggleReminders() {
    isRemindersEnabled.value = !isRemindersEnabled.value;
    saveSetting('isRemindersEnabled', isRemindersEnabled.value);
    update();
  }

  // Language settings
  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    saveSetting('selectedLanguage', languageCode);
    // Implement language change logic here
    update();
  }

  // Font size settings
  void changeFontSize(double size) {
    fontSize.value = size;
    saveSetting('fontSize', size);
    update();
  }

  // Accessibility settings
  void toggleHighContrast() {
    isHighContrastEnabled.value = !isHighContrastEnabled.value;
    saveSetting('isHighContrastEnabled', isHighContrastEnabled.value);
    update();
  }

  void toggleVoiceOver() {
    isVoiceOverEnabled.value = !isVoiceOverEnabled.value;
    saveSetting('isVoiceOverEnabled', isVoiceOverEnabled.value);
    update();
  }

  // Data and storage settings
  void toggleDataSaver() {
    isDataSaverEnabled.value = !isDataSaverEnabled.value;
    saveSetting('isDataSaverEnabled', isDataSaverEnabled.value);
    update();
  }

  void toggleAutoBackup() {
    isAutoBackupEnabled.value = !isAutoBackupEnabled.value;
    saveSetting('isAutoBackupEnabled', isAutoBackupEnabled.value);
    update();
  }

  // Privacy settings
  void toggleLocationSharing() {
    isLocationSharingEnabled.value = !isLocationSharingEnabled.value;
    saveSetting('isLocationSharingEnabled', isLocationSharingEnabled.value);
    update();
  }

  void toggleAnalytics() {
    isAnalyticsEnabled.value = !isAnalyticsEnabled.value;
    saveSetting('isAnalyticsEnabled', isAnalyticsEnabled.value);
    update();
  }

  void togglePersonalizedAds() {
    isPersonalizedAdsEnabled.value = !isPersonalizedAdsEnabled.value;
    saveSetting('isPersonalizedAdsEnabled', isPersonalizedAdsEnabled.value);
    update();
  }

  // Social settings
  void toggleOnlineStatusVisibility() {
    isOnlineStatusVisible.value = !isOnlineStatusVisible.value;
    saveSetting('isOnlineStatusVisible', isOnlineStatusVisible.value);
    update();
  }

  void toggleAchievementSharing() {
    isAchievementSharingEnabled.value = !isAchievementSharingEnabled.value;
    saveSetting('isAchievementSharingEnabled', isAchievementSharingEnabled.value);
    update();
  }

  // Learning settings
  void changeLearningStyle(String style) {
    learningStyle.value = style;
    saveSetting('learningStyle', style);
    update();
  }

  void changePreferredStudyTime(String time) {
    preferredStudyTime.value = time;
    saveSetting('preferredStudyTime', time);
    update();
  }

  void changeStudySessionDuration(int duration) {
    studySessionDuration.value = duration;
    saveSetting('studySessionDuration', duration);
    update();
  }

  void changeBreakDuration(int duration) {
    breakDuration.value = duration;
    saveSetting('breakDuration', duration);
    update();
  }

  void toggleStudyReminders() {
    isStudyRemindersEnabled.value = !isStudyRemindersEnabled.value;
    saveSetting('isStudyRemindersEnabled', isStudyRemindersEnabled.value);
    update();
  }

  void toggleProgressTracking() {
    isProgressTrackingEnabled.value = !isProgressTrackingEnabled.value;
    saveSetting('isProgressTrackingEnabled', isProgressTrackingEnabled.value);
    update();
  }

  void toggleAchievementSystem() {
    isAchievementSystemEnabled.value = !isAchievementSystemEnabled.value;
    saveSetting('isAchievementSystemEnabled', isAchievementSystemEnabled.value);
    update();
  }

  // Clear all data
  void clearAllData() {
    _box.erase();
    loadSettings(); // Reload default settings
    Get.snackbar(
      'تم',
      'تم مسح جميع البيانات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
    update();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'isDarkMode': isDarkMode.value,
      'isNotificationsEnabled': isNotificationsEnabled.value,
      'isAcademicNotificationsEnabled': isAcademicNotificationsEnabled.value,
      'isAdminNotificationsEnabled': isAdminNotificationsEnabled.value,
      'isRemindersEnabled': isRemindersEnabled.value,
      'selectedLanguage': selectedLanguage.value,
      'fontSize': fontSize.value,
      'isHighContrastEnabled': isHighContrastEnabled.value,
      'isVoiceOverEnabled': isVoiceOverEnabled.value,
      'isDataSaverEnabled': isDataSaverEnabled.value,
      'isAutoBackupEnabled': isAutoBackupEnabled.value,
      'isLocationSharingEnabled': isLocationSharingEnabled.value,
      'isAnalyticsEnabled': isAnalyticsEnabled.value,
      'isPersonalizedAdsEnabled': isPersonalizedAdsEnabled.value,
      'isOnlineStatusVisible': isOnlineStatusVisible.value,
      'isAchievementSharingEnabled': isAchievementSharingEnabled.value,
      'learningStyle': learningStyle.value,
      'preferredStudyTime': preferredStudyTime.value,
      'studySessionDuration': studySessionDuration.value,
      'breakDuration': breakDuration.value,
      'isStudyRemindersEnabled': isStudyRemindersEnabled.value,
      'isProgressTrackingEnabled': isProgressTrackingEnabled.value,
      'isAchievementSystemEnabled': isAchievementSystemEnabled.value,
    };
  }

  // Import settings
  void importSettings(Map<String, dynamic> settings) {
    settings.forEach((key, value) {
      _box.write(key, value);
    });
    loadSettings();
    Get.snackbar(
      'تم',
      'تم استيراد الإعدادات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
    update();
  }

  // Reset to default settings
  void resetToDefaults() {
    clearAllData();
    Get.snackbar(
      'تم',
      'تم إعادة تعيين الإعدادات إلى الافتراضية',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Get storage usage info
  Map<String, dynamic> getStorageInfo() {
    // This would typically call a service to get actual storage info
    return {
      'totalSpace': '32 GB',
      'usedSpace': '8.5 GB',
      'freeSpace': '23.5 GB',
      'appData': '150 MB',
      'cache': '45 MB',
      'downloads': '2.3 GB',
    };
  }

  // Clear cache
  void clearCache() {
    // Implement cache clearing logic
    Get.snackbar(
      'تم',
      'تم مسح الملفات المؤقتة بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Clear downloads
  void clearDownloads() {
    // Implement downloads clearing logic
    Get.snackbar(
      'تم',
      'تم مسح التحميلات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

