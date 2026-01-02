import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../models/language_settings_model.dart';

class LanguageCard extends StatelessWidget {
  final SupportedLanguage language;
  final bool isSelected;
  final bool isCurrentLanguage;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool showComingSoon;

  const LanguageCard({
    super.key,
    required this.language,
    required this.isSelected,
    required this.isCurrentLanguage,
    required this.onTap,
    required this.isDarkMode,
    this.showComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
          HomeController homeController = Get.find<HomeController>();

    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final isEnabled = language.isAvailable && !isCurrentLanguage;

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: isSelected ? -3 : (isDarkMode ? -1 : 2),
        intensity: 0.8,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        border: NeumorphicBorder(
          color: isSelected ? homeController.getPrimaryColor() : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : (showComingSoon ? onTap : null),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLanguageFlag(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLanguageInfo(textColor),
                ),
                _buildTrailingWidget(textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageFlag() {
          HomeController homeController = Get.find<HomeController>();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? homeController.getPrimaryColor() : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          language.flag,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildLanguageInfo(Color textColor) {
          HomeController homeController = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                language.nativeName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? homeController.getPrimaryColor() : textColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            if (isCurrentLanguage) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: homeController.getPrimaryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: homeController.getPrimaryColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'الحالية',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: homeController.getPrimaryColor(),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ] else if (showComingSoon) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'قريباً',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          language.name,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.7),
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              language.isRTL
                  ? Icons.format_textdirection_r_to_l
                  : Icons.format_textdirection_l_to_r,
              size: 16,
              color: textColor.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              language.isRTL ? 'من اليمين إلى اليسار' : 'من اليسار إلى اليمين',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.5),
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailingWidget(Color textColor) {
          HomeController homeController = Get.find<HomeController>();

    if (isCurrentLanguage) {
      return Icon(
        Icons.check_circle,
        color: homeController.getPrimaryColor(),
        size: 24,
      );
    }

    if (showComingSoon) {
      return Icon(
        Icons.schedule,
        color: Colors.orange,
        size: 24,
      );
    }

    if (language.isAvailable) {
      return Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
        activeColor: homeController.getPrimaryColor(),
      );
    }

    return Icon(
      Icons.lock,
      color: textColor.withOpacity(0.3),
      size: 20,
    );
  }
}
