import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../controllers/appearance_settings_controller.dart';
import '../../models/appearance_settings_model.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/theme_preset_card.dart';
import '../widgets/font_size_slider.dart';
import '../widgets/setting_tile.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AppearanceSettingsController>(
      init: AppearanceSettingsController(),
      builder: (controller) {
        final isDarkMode = Get.isDarkMode;
        final bgColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
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
                    _buildThemeModeSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildThemePresetsSection(
                        controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildColorCustomizationSection(
                        controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildFontSettingsSection(
                        controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildAccessibilitySection(
                        controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildNeumorphicSection(controller, isDarkMode, textColor),
                    const SizedBox(height: 20),
                    _buildAnimationSection(controller, isDarkMode, textColor),
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
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return AppBar(
      title: const Text(
        'المظهر والثيم',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
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
                controller.resetToDefaults();
                break;
              case 'restart':
                controller.restartApp();
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
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.restart_alt),
                  SizedBox(width: 8),
                  Text(
                    'إعادة تشغيل التطبيق',
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

  Widget _buildThemeModeSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'وضع المظهر',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: controller.themeModeOptions.map((option) {
          return Obx(() {
            final isSelected = controller.settings.themeMode == option['value'];
            return _buildRadioTile(
              title: option['title'],
              subtitle: option['subtitle'],
              icon: option['icon'],
              isSelected: isSelected,
              onTap: () => controller.setThemeMode(option['value']),
              isDarkMode: isDarkMode,
              textColor: textColor,
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildThemePresetsSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'الثيمات الجاهزة',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ThemePreset.presets.length,
          itemBuilder: (context, index) {
            final preset = ThemePreset.presets[index];
            return Obx(() {
              final isSelected = controller.selectedPresetId == preset.id;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ThemePresetCard(
                  preset: preset,
                  isSelected: isSelected,
                  onTap: () => controller.applyThemePreset(preset),
                  isDarkMode: isDarkMode,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildColorCustomizationSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'تخصيص الألوان',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: [
          Obx(() {
            return ColorPickerWidget(
              title: 'اللون الأساسي',
              color: controller.getPrimaryColor(),
              onColorChanged: controller.setPrimaryColor,
              onPreview: controller.previewPrimaryColor,
              isDarkMode: isDarkMode,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return ColorPickerWidget(
              title: 'اللون الثانوي',
              color: controller.getSecondaryColor(),
              onColorChanged: controller.setSecondaryColor,
              onPreview: controller.previewSecondaryColor,
              isDarkMode: isDarkMode,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFontSettingsSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'إعدادات الخط',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: [
          Obx(() {
            return FontSizeSlider(
              value: controller.settings.fontSize,
              onChanged: controller.setFontSize,
              onPreview: controller.previewFontSize,
              isDarkMode: isDarkMode,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return SettingTile(
              title: 'نوع الخط',
              subtitle: controller.getFontFamilyTitle(),
              icon: Icons.font_download,
              onTap: () => _showFontFamilyDialog(controller),
              isDarkMode: isDarkMode,
              textColor: textColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'إمكانية الوصول',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: [
          Obx(() {
            return _buildSwitchTile(
              title: 'التباين العالي',
              subtitle: 'لتحسين وضوح النصوص والعناصر',
              icon: Icons.contrast,
              value: controller.settings.isHighContrastEnabled,
              onChanged: (_) => controller.toggleHighContrast(),
              isDarkMode: isDarkMode,
              textColor: textColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNeumorphicSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'التأثيرات المجسمة',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Column(
        children: [
          Obx(() {
            return _buildSwitchTile(
              title: 'تفعيل التأثيرات المجسمة',
              subtitle: 'تأثيرات بصرية ثلاثية الأبعاد',
              icon: Icons.view_in_ar,
              value: controller.settings.isNeumorphicEnabled,
              onChanged: (_) => controller.toggleNeumorphic(),
              isDarkMode: isDarkMode,
              textColor: textColor,
            );
          }),
          if (controller.settings.isNeumorphicEnabled) ...[
            const SizedBox(height: 16),
            Obx(() {
              return _buildSliderTile(
                title: 'انحناء الحواف',
                value: controller.settings.borderRadius,
                min: 4.0,
                max: 24.0,
                divisions: 20,
                onChanged: controller.setBorderRadius,
                isDarkMode: isDarkMode,
                textColor: textColor,
              );
            }),
            const SizedBox(height: 16),
            Obx(() {
              return _buildSliderTile(
                title: 'شدة الظلال',
                value: controller.settings.shadowIntensity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: controller.setShadowIntensity,
                isDarkMode: isDarkMode,
                textColor: textColor,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimationSection(
    AppearanceSettingsController controller,
    bool isDarkMode,
    Color textColor,
  ) {
    return _buildSection(
      title: 'الحركات والانتقالات',
      isDarkMode: isDarkMode,
      textColor: textColor,
      child: Obx(() {
        return _buildSwitchTile(
          title: 'تفعيل الحركات',
          subtitle: 'حركات انتقال سلسة بين الشاشات',
          icon: Icons.animation,
          value: controller.settings.isAnimationsEnabled,
          onChanged: (_) => controller.toggleAnimations(),
          isDarkMode: isDarkMode,
          textColor: textColor,
        );
      }),
    );
  }

  Widget _buildActionButtons(
    AppearanceSettingsController controller,
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
              color: isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.resetToDefaults,
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
                onTap: controller.restartApp,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restart_alt, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'إعادة تشغيل',
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
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color textColor,
  }) {
          HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: homeController.getPrimaryColor(), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? homeController.getPrimaryColor()
                      : textColor.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: homeController.getPrimaryColor(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
    required Color textColor,
  }) {
          HomeController homeController = Get.find<HomeController>();

    return Row(
      children: [
        Icon(
          icon,
          color: textColor.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: homeController.getPrimaryColor(),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required bool isDarkMode,
    required Color textColor,
  }) {
          HomeController homeController = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                color: homeController.getPrimaryColor(),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: homeController.getPrimaryColor(),
          inactiveColor: textColor.withOpacity(0.3),
        ),
      ],
    );
  }

  void _showFontFamilyDialog(AppearanceSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'اختيار نوع الخط',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.fontFamilyOptions.length,
            itemBuilder: (context, index) {
              final option = controller.fontFamilyOptions[index];
              final isSelected =
                  controller.settings.fontFamily == option['value'];
      HomeController homeController = Get.find<HomeController>();

              return ListTile(
                title: Text(
                  option['title'],
                  style: TextStyle(
                    fontFamily: option['value'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  option['subtitle'],
                  style: const TextStyle(fontFamily: 'Tajawal'),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: homeController.getPrimaryColor())
                    : null,
                onTap: () {
                  controller.setFontFamily(option['value']);
                  Get.back();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }
}
