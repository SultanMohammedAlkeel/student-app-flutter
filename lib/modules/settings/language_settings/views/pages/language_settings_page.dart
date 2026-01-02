import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../controllers/language_settings_controller.dart';
import '../../models/language_settings_model.dart';
import '../widgets/language_card.dart';
import '../widgets/language_info_card.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageSettingsController>(
      init: LanguageSettingsController(),
      builder: (controller) {
        final isDarkMode = Get.isDarkMode;
        final bgColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
        final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: _buildAppBar(controller, isDarkMode, textColor),
            body: Obx(() {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentLanguageSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildAvailableLanguagesSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildComingSoonSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildLanguageInfoSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 30),
                    _buildActionButtons(controller, isDarkMode),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    LanguageSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return AppBar(
      title: const Text(
        'اللغة والمنطقة',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      foregroundColor: textColor,
      elevation: 0,
      actions: [
        Obx(() {
          if (controller.hasChanges) {
            return IconButton(
              onPressed: controller.saveSettings,
              icon: const Icon(Icons.save),
              tooltip: 'حفظ التغييرات',
            );
          }
          return const SizedBox.shrink();
        }),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'reset':
                controller.resetToDefault();
                break;
              case 'info':
                _showLanguageInfo(controller);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.restore),
                  SizedBox(width: 8),
                  Text(
                    'إعادة تعيين',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text(
                    'معلومات اللغة',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentLanguageSection(
    LanguageSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'اللغة الحالية',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Obx(() {
        final currentLang = controller.currentLanguage;
        return LanguageCard(
          language: currentLang,
          isSelected: true,
          isCurrentLanguage: true,
          onTap: () {}, // No action for current language
          isDarkMode: isDarkMode,
        );
      }),
    );
  }

  Widget _buildAvailableLanguagesSection(
    LanguageSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    final availableLanguages = controller.availableLanguages
        .where((lang) => lang.isAvailable)
        .toList();

    return _buildSection(
      title: 'اللغات المتاحة',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: availableLanguages.map((language) {
          return Obx(() {
            final isSelected = controller.selectedLanguageCode == language.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LanguageCard(
                language: language,
                isSelected: isSelected,
                isCurrentLanguage: false,
                onTap: () => controller.changeLanguage(language),
                isDarkMode: isDarkMode,
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildComingSoonSection(
    LanguageSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    final comingSoonLanguages = controller.availableLanguages
        .where((lang) => !lang.isAvailable)
        .toList();

    if (comingSoonLanguages.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: 'قريباً',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ستتوفر هذه اللغات في التحديثات القادمة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...comingSoonLanguages.map((language) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LanguageCard(
                language: language,
                isSelected: false,
                isCurrentLanguage: false,
                onTap: () => controller.changeLanguage(language),
                isDarkMode: isDarkMode,
                showComingSoon: true,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguageInfoSection(
    LanguageSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'معلومات اللغة',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: LanguageInfoCard(
        controller: controller,
        isDarkMode: isDarkMode,
      ),
    );
  }

  Widget _buildActionButtons(
    LanguageSettingsController controller,
    bool isDarkMode,
  ) {
          HomeController homeController = Get.find<HomeController>();

    return Row(
      children: [
        Expanded(
          child: Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              depth: isDarkMode ? -2 : 3,
              intensity: 0.8,
              color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.resetToDefault,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restore, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'إعادة تعيين',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              depth: isDarkMode ? -2 : 3,
              intensity: 0.8,
              color: homeController.getPrimaryColor(),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLanguageInfo(controller),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'معلومات',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required bool isDarkMode,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            depth: isDarkMode ? -2 : 3,
            intensity: 0.8,
            color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  void _showLanguageInfo(LanguageSettingsController controller) {
    final info = controller.getLanguageInfo();
    
    Get.dialog(
      AlertDialog(
        title: const Text(
          'معلومات اللغة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('اللغة الحالية:', info['currentLanguage']),
            _buildInfoRow('رمز اللغة:', info['languageCode']),
            _buildInfoRow('رمز البلد:', info['countryCode']),
            _buildInfoRow('اتجاه النص:', info['isRTL'] ? 'من اليمين إلى اليسار' : 'من اليسار إلى اليمين'),
            _buildInfoRow('إجمالي اللغات:', '${info['totalLanguages']}'),
            _buildInfoRow('اللغات المتاحة:', '${info['availableLanguages']}'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }
}

