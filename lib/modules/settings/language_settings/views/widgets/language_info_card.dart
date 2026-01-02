import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../controllers/language_settings_controller.dart';

class LanguageInfoCard extends StatelessWidget {
  final LanguageSettingsController controller;
  final bool isDarkMode;

  const LanguageInfoCard({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final info = controller.getLanguageInfo();

    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.language,
          title: 'اللغة الحالية',
          value: info['currentLanguage'],
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.code,
          title: 'رمز اللغة',
          value: info['languageCode'].toString().toUpperCase(),
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.flag,
          title: 'رمز البلد',
          value: info['countryCode'].toString().toUpperCase(),
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: info['isRTL']
              ? Icons.format_textdirection_r_to_l
              : Icons.format_textdirection_l_to_r,
          title: 'اتجاه النص',
          value:
              info['isRTL'] ? 'من اليمين إلى اليسار' : 'من اليسار إلى اليمين',
          textColor: textColor,
        ),
        const SizedBox(height: 16),
        _buildStatisticsRow(info, textColor),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
  }) {
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
        depth: isDarkMode ? -1 : 1,
        intensity: 0.4,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: homeController.getPrimaryColor(),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: homeController.getPrimaryColor(),
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(Map<String, dynamic> info, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'إجمالي اللغات',
            value: info['totalLanguages'].toString(),
            icon: Icons.translate,
            color: Colors.blue,
            textColor: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'متاحة حالياً',
            value: info['availableLanguages'].toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            textColor: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: isDarkMode ? -1 : 2,
        intensity: 0.6,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.7),
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
