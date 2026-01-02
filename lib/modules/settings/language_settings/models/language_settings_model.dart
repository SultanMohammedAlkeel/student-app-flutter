class LanguageSettings {
  final String languageCode;
  final String countryCode;
  final String displayName;
  final bool isRTL;

  const LanguageSettings({
    required this.languageCode,
    required this.countryCode,
    required this.displayName,
    required this.isRTL,
  });

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      languageCode: json['languageCode'] ?? 'ar',
      countryCode: json['countryCode'] ?? 'SA',
      displayName: json['displayName'] ?? 'العربية',
      isRTL: json['isRTL'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'displayName': displayName,
      'isRTL': isRTL,
    };
  }

  LanguageSettings copyWith({
    String? languageCode,
    String? countryCode,
    String? displayName,
    bool? isRTL,
  }) {
    return LanguageSettings(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      displayName: displayName ?? this.displayName,
      isRTL: isRTL ?? this.isRTL,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageSettings &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.displayName == displayName &&
        other.isRTL == isRTL;
  }

  @override
  int get hashCode {
    return Object.hash(languageCode, countryCode, displayName, isRTL);
  }
}

class SupportedLanguage {
  final String code;
  final String countryCode;
  final String name;
  final String nativeName;
  final bool isRTL;
  final bool isAvailable;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.countryCode,
    required this.name,
    required this.nativeName,
    required this.isRTL,
    this.isAvailable = false,
    required this.flag,
  });

  static const List<SupportedLanguage> languages = [
    SupportedLanguage(
      code: 'ar',
      countryCode: 'SA',
      name: 'Arabic',
      nativeName: 'العربية',
      isRTL: true,
      isAvailable: true,
      flag: '🇸🇦',
    ),
    SupportedLanguage(
      code: 'en',
      countryCode: 'US',
      name: 'English',
      nativeName: 'English',
      isRTL: false,
      isAvailable: false,
      flag: '🇺🇸',
    ),
    SupportedLanguage(
      code: 'fr',
      countryCode: 'FR',
      name: 'French',
      nativeName: 'Français',
      isRTL: false,
      isAvailable: false,
      flag: '🇫🇷',
    ),
    SupportedLanguage(
      code: 'es',
      countryCode: 'ES',
      name: 'Spanish',
      nativeName: 'Español',
      isRTL: false,
      isAvailable: false,
      flag: '🇪🇸',
    ),
    SupportedLanguage(
      code: 'de',
      countryCode: 'DE',
      name: 'German',
      nativeName: 'Deutsch',
      isRTL: false,
      isAvailable: false,
      flag: '🇩🇪',
    ),
    SupportedLanguage(
      code: 'tr',
      countryCode: 'TR',
      name: 'Turkish',
      nativeName: 'Türkçe',
      isRTL: false,
      isAvailable: false,
      flag: '🇹🇷',
    ),
    SupportedLanguage(
      code: 'ur',
      countryCode: 'PK',
      name: 'Urdu',
      nativeName: 'اردو',
      isRTL: true,
      isAvailable: false,
      flag: '🇵🇰',
    ),
  ];
}

