class AppearanceSettings {
  final String themeMode; // 'light', 'dark', 'system'
  final String primaryColor;
  final String secondaryColor;
  final double fontSize;
  final bool isHighContrastEnabled;
  final bool isNeumorphicEnabled;
  final String fontFamily;
  final double borderRadius;
  final double shadowIntensity;
  final bool isAnimationsEnabled;

  AppearanceSettings({
    this.themeMode = 'system',
    this.primaryColor = '0xFF4ECDC4',
    this.secondaryColor = '0xFF6B5B95',
    this.fontSize = 16.0,
    this.isHighContrastEnabled = false,
    this.isNeumorphicEnabled = true,
    this.fontFamily = 'Tajawal',
    this.borderRadius = 12.0,
    this.shadowIntensity = 0.8,
    this.isAnimationsEnabled = true,
  });

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) {
    return AppearanceSettings(
      themeMode: json['themeMode'] ?? 'system',
      primaryColor: json['primaryColor'] ?? '0xFF4ECDC4',
      secondaryColor: json['secondaryColor'] ?? '0xFF6B5B95',
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      isHighContrastEnabled: json['isHighContrastEnabled'] ?? false,
      isNeumorphicEnabled: json['isNeumorphicEnabled'] ?? true,
      fontFamily: json['fontFamily'] ?? 'Tajawal',
      borderRadius: (json['borderRadius'] ?? 12.0).toDouble(),
      shadowIntensity: (json['shadowIntensity'] ?? 0.8).toDouble(),
      isAnimationsEnabled: json['isAnimationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'fontSize': fontSize,
      'isHighContrastEnabled': isHighContrastEnabled,
      'isNeumorphicEnabled': isNeumorphicEnabled,
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
      'shadowIntensity': shadowIntensity,
      'isAnimationsEnabled': isAnimationsEnabled,
    };
  }

  AppearanceSettings copyWith({
    String? themeMode,
    String? primaryColor,
    String? secondaryColor,
    double? fontSize,
    bool? isHighContrastEnabled,
    bool? isNeumorphicEnabled,
    String? fontFamily,
    double? borderRadius,
    double? shadowIntensity,
    bool? isAnimationsEnabled,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontSize: fontSize ?? this.fontSize,
      isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
      isNeumorphicEnabled: isNeumorphicEnabled ?? this.isNeumorphicEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      isAnimationsEnabled: isAnimationsEnabled ?? this.isAnimationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppearanceSettings &&
        other.themeMode == themeMode &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.fontSize == fontSize &&
        other.isHighContrastEnabled == isHighContrastEnabled &&
        other.isNeumorphicEnabled == isNeumorphicEnabled &&
        other.fontFamily == fontFamily &&
        other.borderRadius == borderRadius &&
        other.shadowIntensity == shadowIntensity &&
        other.isAnimationsEnabled == isAnimationsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      primaryColor,
      secondaryColor,
      fontSize,
      isHighContrastEnabled,
      isNeumorphicEnabled,
      fontFamily,
      borderRadius,
      shadowIntensity,
      isAnimationsEnabled,
    );
  }
}

class ThemePreset {
  final String id;
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String description;
  final bool isDark;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    this.isDark = false,
  });

  static const List<ThemePreset> presets = [
    ThemePreset(
      id: 'ocean',
      name: 'المحيط',
      primaryColor: '0xFF4ECDC4',
      secondaryColor: '0xFF6B5B95',
      description: 'ألوان هادئة مستوحاة من المحيط',
    ),
    ThemePreset(
      id: 'sunset',
      name: 'غروب الشمس',
      primaryColor: '0xFFFF6B6B',
      secondaryColor: '0xFFFFE66D',
      description: 'ألوان دافئة مستوحاة من غروب الشمس',
    ),
    ThemePreset(
      id: 'forest',
      name: 'الغابة',
      primaryColor: '0xFF4ECDC4',
      secondaryColor: '0xFF44A08D',
      description: 'ألوان طبيعية مستوحاة من الغابة',
    ),
    ThemePreset(
      id: 'space',
      name: 'الفضاء',
      primaryColor: '0xFF667EEA',
      secondaryColor: '0xFF764BA2',
      description: 'ألوان مستوحاة من الفضاء والنجوم',
    ),
    ThemePreset(
      id: 'classic',
      name: 'كلاسيكي',
      primaryColor: '0xFF2196F3',
      secondaryColor: '0xFF64B5F6',
      description: 'الثيم الكلاسيكي للتطبيق',
    ),
  ];
}

