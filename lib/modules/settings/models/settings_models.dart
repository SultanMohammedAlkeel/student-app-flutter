// lib/modules/settings/models/settings_model.dart

class SettingsModel {
  final bool isDarkMode;
  final bool isNotificationsEnabled;
  final bool isAcademicNotificationsEnabled;
  final bool isAdminNotificationsEnabled;
  final bool isRemindersEnabled;
  final String selectedLanguage;
  final double fontSize;
  final bool isHighContrastEnabled;
  final bool isVoiceOverEnabled;
  final bool isDataSaverEnabled;
  final bool isAutoBackupEnabled;
  final bool isLocationSharingEnabled;
  final bool isAnalyticsEnabled;
  final bool isPersonalizedAdsEnabled;
  final bool isOnlineStatusVisible;
  final bool isAchievementSharingEnabled;
  final String learningStyle;
  final String preferredStudyTime;
  final int studySessionDuration;
  final int breakDuration;
  final bool isStudyRemindersEnabled;
  final bool isProgressTrackingEnabled;
  final bool isAchievementSystemEnabled;

  SettingsModel({
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.isAcademicNotificationsEnabled = true,
    this.isAdminNotificationsEnabled = true,
    this.isRemindersEnabled = true,
    this.selectedLanguage = 'ar',
    this.fontSize = 16.0,
    this.isHighContrastEnabled = false,
    this.isVoiceOverEnabled = false,
    this.isDataSaverEnabled = false,
    this.isAutoBackupEnabled = true,
    this.isLocationSharingEnabled = false,
    this.isAnalyticsEnabled = true,
    this.isPersonalizedAdsEnabled = false,
    this.isOnlineStatusVisible = true,
    this.isAchievementSharingEnabled = true,
    this.learningStyle = 'visual',
    this.preferredStudyTime = 'morning',
    this.studySessionDuration = 45,
    this.breakDuration = 15,
    this.isStudyRemindersEnabled = true,
    this.isProgressTrackingEnabled = true,
    this.isAchievementSystemEnabled = true,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? true,
      isAcademicNotificationsEnabled: json['isAcademicNotificationsEnabled'] ?? true,
      isAdminNotificationsEnabled: json['isAdminNotificationsEnabled'] ?? true,
      isRemindersEnabled: json['isRemindersEnabled'] ?? true,
      selectedLanguage: json['selectedLanguage'] ?? 'ar',
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      isHighContrastEnabled: json['isHighContrastEnabled'] ?? false,
      isVoiceOverEnabled: json['isVoiceOverEnabled'] ?? false,
      isDataSaverEnabled: json['isDataSaverEnabled'] ?? false,
      isAutoBackupEnabled: json['isAutoBackupEnabled'] ?? true,
      isLocationSharingEnabled: json['isLocationSharingEnabled'] ?? false,
      isAnalyticsEnabled: json['isAnalyticsEnabled'] ?? true,
      isPersonalizedAdsEnabled: json['isPersonalizedAdsEnabled'] ?? false,
      isOnlineStatusVisible: json['isOnlineStatusVisible'] ?? true,
      isAchievementSharingEnabled: json['isAchievementSharingEnabled'] ?? true,
      learningStyle: json['learningStyle'] ?? 'visual',
      preferredStudyTime: json['preferredStudyTime'] ?? 'morning',
      studySessionDuration: json['studySessionDuration'] ?? 45,
      breakDuration: json['breakDuration'] ?? 15,
      isStudyRemindersEnabled: json['isStudyRemindersEnabled'] ?? true,
      isProgressTrackingEnabled: json['isProgressTrackingEnabled'] ?? true,
      isAchievementSystemEnabled: json['isAchievementSystemEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'isNotificationsEnabled': isNotificationsEnabled,
      'isAcademicNotificationsEnabled': isAcademicNotificationsEnabled,
      'isAdminNotificationsEnabled': isAdminNotificationsEnabled,
      'isRemindersEnabled': isRemindersEnabled,
      'selectedLanguage': selectedLanguage,
      'fontSize': fontSize,
      'isHighContrastEnabled': isHighContrastEnabled,
      'isVoiceOverEnabled': isVoiceOverEnabled,
      'isDataSaverEnabled': isDataSaverEnabled,
      'isAutoBackupEnabled': isAutoBackupEnabled,
      'isLocationSharingEnabled': isLocationSharingEnabled,
      'isAnalyticsEnabled': isAnalyticsEnabled,
      'isPersonalizedAdsEnabled': isPersonalizedAdsEnabled,
      'isOnlineStatusVisible': isOnlineStatusVisible,
      'isAchievementSharingEnabled': isAchievementSharingEnabled,
      'learningStyle': learningStyle,
      'preferredStudyTime': preferredStudyTime,
      'studySessionDuration': studySessionDuration,
      'breakDuration': breakDuration,
      'isStudyRemindersEnabled': isStudyRemindersEnabled,
      'isProgressTrackingEnabled': isProgressTrackingEnabled,
      'isAchievementSystemEnabled': isAchievementSystemEnabled,
    };
  }

  SettingsModel copyWith({
    bool? isDarkMode,
    bool? isNotificationsEnabled,
    bool? isAcademicNotificationsEnabled,
    bool? isAdminNotificationsEnabled,
    bool? isRemindersEnabled,
    String? selectedLanguage,
    double? fontSize,
    bool? isHighContrastEnabled,
    bool? isVoiceOverEnabled,
    bool? isDataSaverEnabled,
    bool? isAutoBackupEnabled,
    bool? isLocationSharingEnabled,
    bool? isAnalyticsEnabled,
    bool? isPersonalizedAdsEnabled,
    bool? isOnlineStatusVisible,
    bool? isAchievementSharingEnabled,
    String? learningStyle,
    String? preferredStudyTime,
    int? studySessionDuration,
    int? breakDuration,
    bool? isStudyRemindersEnabled,
    bool? isProgressTrackingEnabled,
    bool? isAchievementSystemEnabled,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isAcademicNotificationsEnabled: isAcademicNotificationsEnabled ?? this.isAcademicNotificationsEnabled,
      isAdminNotificationsEnabled: isAdminNotificationsEnabled ?? this.isAdminNotificationsEnabled,
      isRemindersEnabled: isRemindersEnabled ?? this.isRemindersEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      fontSize: fontSize ?? this.fontSize,
      isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
      isVoiceOverEnabled: isVoiceOverEnabled ?? this.isVoiceOverEnabled,
      isDataSaverEnabled: isDataSaverEnabled ?? this.isDataSaverEnabled,
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      isLocationSharingEnabled: isLocationSharingEnabled ?? this.isLocationSharingEnabled,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      isPersonalizedAdsEnabled: isPersonalizedAdsEnabled ?? this.isPersonalizedAdsEnabled,
      isOnlineStatusVisible: isOnlineStatusVisible ?? this.isOnlineStatusVisible,
      isAchievementSharingEnabled: isAchievementSharingEnabled ?? this.isAchievementSharingEnabled,
      learningStyle: learningStyle ?? this.learningStyle,
      preferredStudyTime: preferredStudyTime ?? this.preferredStudyTime,
      studySessionDuration: studySessionDuration ?? this.studySessionDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      isStudyRemindersEnabled: isStudyRemindersEnabled ?? this.isStudyRemindersEnabled,
      isProgressTrackingEnabled: isProgressTrackingEnabled ?? this.isProgressTrackingEnabled,
      isAchievementSystemEnabled: isAchievementSystemEnabled ?? this.isAchievementSystemEnabled,
    );
  }

  @override
  String toString() {
    return 'SettingsModel(isDarkMode: $isDarkMode, selectedLanguage: $selectedLanguage, fontSize: $fontSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel &&
        other.isDarkMode == isDarkMode &&
        other.isNotificationsEnabled == isNotificationsEnabled &&
        other.selectedLanguage == selectedLanguage &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode {
    return isDarkMode.hashCode ^
        isNotificationsEnabled.hashCode ^
        selectedLanguage.hashCode ^
        fontSize.hashCode;
  }
}

// lib/modules/settings/models/notification_preferences_model.dart

class NotificationPreferencesModel {
  final bool isEnabled;
  final bool isAcademicEnabled;
  final bool isAdminEnabled;
  final bool isRemindersEnabled;
  final bool isSoundEnabled;
  final bool isVibrationEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool isQuietHoursEnabled;
  final List<String> enabledCategories;

  NotificationPreferencesModel({
    this.isEnabled = true,
    this.isAcademicEnabled = true,
    this.isAdminEnabled = true,
    this.isRemindersEnabled = true,
    this.isSoundEnabled = true,
    this.isVibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.isQuietHoursEnabled = false,
    this.enabledCategories = const ['academic', 'admin', 'reminders'],
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      isEnabled: json['isEnabled'] ?? true,
      isAcademicEnabled: json['isAcademicEnabled'] ?? true,
      isAdminEnabled: json['isAdminEnabled'] ?? true,
      isRemindersEnabled: json['isRemindersEnabled'] ?? true,
      isSoundEnabled: json['isSoundEnabled'] ?? true,
      isVibrationEnabled: json['isVibrationEnabled'] ?? true,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
      isQuietHoursEnabled: json['isQuietHoursEnabled'] ?? false,
      enabledCategories: List<String>.from(json['enabledCategories'] ?? ['academic', 'admin', 'reminders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isAcademicEnabled': isAcademicEnabled,
      'isAdminEnabled': isAdminEnabled,
      'isRemindersEnabled': isRemindersEnabled,
      'isSoundEnabled': isSoundEnabled,
      'isVibrationEnabled': isVibrationEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'isQuietHoursEnabled': isQuietHoursEnabled,
      'enabledCategories': enabledCategories,
    };
  }

  NotificationPreferencesModel copyWith({
    bool? isEnabled,
    bool? isAcademicEnabled,
    bool? isAdminEnabled,
    bool? isRemindersEnabled,
    bool? isSoundEnabled,
    bool? isVibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? isQuietHoursEnabled,
    List<String>? enabledCategories,
  }) {
    return NotificationPreferencesModel(
      isEnabled: isEnabled ?? this.isEnabled,
      isAcademicEnabled: isAcademicEnabled ?? this.isAcademicEnabled,
      isAdminEnabled: isAdminEnabled ?? this.isAdminEnabled,
      isRemindersEnabled: isRemindersEnabled ?? this.isRemindersEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      isQuietHoursEnabled: isQuietHoursEnabled ?? this.isQuietHoursEnabled,
      enabledCategories: enabledCategories ?? this.enabledCategories,
    );
  }
}

// lib/modules/settings/models/privacy_settings_model.dart

class PrivacySettingsModel {
  final bool isLocationSharingEnabled;
  final bool isAnalyticsEnabled;
  final bool isPersonalizedAdsEnabled;
  final bool isOnlineStatusVisible;
  final bool isProfileSearchable;
  final bool isAchievementSharingEnabled;
  final String profileVisibility; // public, friends, private
  final bool isDataExportEnabled;
  final bool isAccountDeletionEnabled;

  PrivacySettingsModel({
    this.isLocationSharingEnabled = false,
    this.isAnalyticsEnabled = true,
    this.isPersonalizedAdsEnabled = false,
    this.isOnlineStatusVisible = true,
    this.isProfileSearchable = true,
    this.isAchievementSharingEnabled = true,
    this.profileVisibility = 'friends',
    this.isDataExportEnabled = true,
    this.isAccountDeletionEnabled = true,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      isLocationSharingEnabled: json['isLocationSharingEnabled'] ?? false,
      isAnalyticsEnabled: json['isAnalyticsEnabled'] ?? true,
      isPersonalizedAdsEnabled: json['isPersonalizedAdsEnabled'] ?? false,
      isOnlineStatusVisible: json['isOnlineStatusVisible'] ?? true,
      isProfileSearchable: json['isProfileSearchable'] ?? true,
      isAchievementSharingEnabled: json['isAchievementSharingEnabled'] ?? true,
      profileVisibility: json['profileVisibility'] ?? 'friends',
      isDataExportEnabled: json['isDataExportEnabled'] ?? true,
      isAccountDeletionEnabled: json['isAccountDeletionEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLocationSharingEnabled': isLocationSharingEnabled,
      'isAnalyticsEnabled': isAnalyticsEnabled,
      'isPersonalizedAdsEnabled': isPersonalizedAdsEnabled,
      'isOnlineStatusVisible': isOnlineStatusVisible,
      'isProfileSearchable': isProfileSearchable,
      'isAchievementSharingEnabled': isAchievementSharingEnabled,
      'profileVisibility': profileVisibility,
      'isDataExportEnabled': isDataExportEnabled,
      'isAccountDeletionEnabled': isAccountDeletionEnabled,
    };
  }

  PrivacySettingsModel copyWith({
    bool? isLocationSharingEnabled,
    bool? isAnalyticsEnabled,
    bool? isPersonalizedAdsEnabled,
    bool? isOnlineStatusVisible,
    bool? isProfileSearchable,
    bool? isAchievementSharingEnabled,
    String? profileVisibility,
    bool? isDataExportEnabled,
    bool? isAccountDeletionEnabled,
  }) {
    return PrivacySettingsModel(
      isLocationSharingEnabled: isLocationSharingEnabled ?? this.isLocationSharingEnabled,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      isPersonalizedAdsEnabled: isPersonalizedAdsEnabled ?? this.isPersonalizedAdsEnabled,
      isOnlineStatusVisible: isOnlineStatusVisible ?? this.isOnlineStatusVisible,
      isProfileSearchable: isProfileSearchable ?? this.isProfileSearchable,
      isAchievementSharingEnabled: isAchievementSharingEnabled ?? this.isAchievementSharingEnabled,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      isDataExportEnabled: isDataExportEnabled ?? this.isDataExportEnabled,
      isAccountDeletionEnabled: isAccountDeletionEnabled ?? this.isAccountDeletionEnabled,
    );
  }
}

// lib/modules/settings/models/accessibility_settings_model.dart

class AccessibilitySettingsModel {
  final bool isHighContrastEnabled;
  final bool isVoiceOverEnabled;
  final bool isScreenReaderEnabled;
  final double fontSize;
  final bool isZoomEnabled;
  final bool isReduceMotionEnabled;
  final bool isColorBlindnessAssistEnabled;
  final String colorBlindnessType; // none, protanopia, deuteranopia, tritanopia
  final bool isHapticFeedbackEnabled;
  final double touchSensitivity;
  final int responseTime; // in milliseconds

  AccessibilitySettingsModel({
    this.isHighContrastEnabled = false,
    this.isVoiceOverEnabled = false,
    this.isScreenReaderEnabled = false,
    this.fontSize = 16.0,
    this.isZoomEnabled = false,
    this.isReduceMotionEnabled = false,
    this.isColorBlindnessAssistEnabled = false,
    this.colorBlindnessType = 'none',
    this.isHapticFeedbackEnabled = true,
    this.touchSensitivity = 1.0,
    this.responseTime = 500,
  });

  factory AccessibilitySettingsModel.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettingsModel(
      isHighContrastEnabled: json['isHighContrastEnabled'] ?? false,
      isVoiceOverEnabled: json['isVoiceOverEnabled'] ?? false,
      isScreenReaderEnabled: json['isScreenReaderEnabled'] ?? false,
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      isZoomEnabled: json['isZoomEnabled'] ?? false,
      isReduceMotionEnabled: json['isReduceMotionEnabled'] ?? false,
      isColorBlindnessAssistEnabled: json['isColorBlindnessAssistEnabled'] ?? false,
      colorBlindnessType: json['colorBlindnessType'] ?? 'none',
      isHapticFeedbackEnabled: json['isHapticFeedbackEnabled'] ?? true,
      touchSensitivity: (json['touchSensitivity'] ?? 1.0).toDouble(),
      responseTime: json['responseTime'] ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isHighContrastEnabled': isHighContrastEnabled,
      'isVoiceOverEnabled': isVoiceOverEnabled,
      'isScreenReaderEnabled': isScreenReaderEnabled,
      'fontSize': fontSize,
      'isZoomEnabled': isZoomEnabled,
      'isReduceMotionEnabled': isReduceMotionEnabled,
      'isColorBlindnessAssistEnabled': isColorBlindnessAssistEnabled,
      'colorBlindnessType': colorBlindnessType,
      'isHapticFeedbackEnabled': isHapticFeedbackEnabled,
      'touchSensitivity': touchSensitivity,
      'responseTime': responseTime,
    };
  }

  AccessibilitySettingsModel copyWith({
    bool? isHighContrastEnabled,
    bool? isVoiceOverEnabled,
    bool? isScreenReaderEnabled,
    double? fontSize,
    bool? isZoomEnabled,
    bool? isReduceMotionEnabled,
    bool? isColorBlindnessAssistEnabled,
    String? colorBlindnessType,
    bool? isHapticFeedbackEnabled,
    double? touchSensitivity,
    int? responseTime,
  }) {
    return AccessibilitySettingsModel(
      isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
      isVoiceOverEnabled: isVoiceOverEnabled ?? this.isVoiceOverEnabled,
      isScreenReaderEnabled: isScreenReaderEnabled ?? this.isScreenReaderEnabled,
      fontSize: fontSize ?? this.fontSize,
      isZoomEnabled: isZoomEnabled ?? this.isZoomEnabled,
      isReduceMotionEnabled: isReduceMotionEnabled ?? this.isReduceMotionEnabled,
      isColorBlindnessAssistEnabled: isColorBlindnessAssistEnabled ?? this.isColorBlindnessAssistEnabled,
      colorBlindnessType: colorBlindnessType ?? this.colorBlindnessType,
      isHapticFeedbackEnabled: isHapticFeedbackEnabled ?? this.isHapticFeedbackEnabled,
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}

