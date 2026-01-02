import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../controllers/help_support_controller.dart';
import 'contact_info_page.dart';
import 'faq_page.dart';
import 'send_complaint_feedback_page.dart';
import 'user_guide_page.dart';

class HelpSupportMainPage extends GetView<HelpSupportController> {
  const HelpSupportMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final isDarkMode = Get.isDarkMode;
    final bgColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textDark;
    final iconColor = isDarkMode
        ? homeController.getSecondaryColor()
        : homeController.getPrimaryColor();

    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NeumorphicAppBar(
          title: Text(
            'المساعدة والدعم',
            style: TextStyle(color: textColor),
          ),
          centerTitle: true,
          buttonStyle: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 1,
            intensity: 0.7,
            lightSource: LightSource.topLeft,
            color: cardColor,
          ),
          iconTheme: IconThemeData(color: iconColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('الخدمات المتاحة', textColor),
              const SizedBox(height: 16.0),
              _buildServiceCard(
                context,
                'دليل الاستخدام',
                'تعرف على كيفية استخدام التطبيق وميزاته.',
                Icons.book_outlined,
                () => Get.to(() => const UserGuidePage()),
                cardColor,
                textColor,
                iconColor,
              ),
              const SizedBox(height: 16.0),
              _buildServiceCard(
                context,
                'الأسئلة الشائعة',
                'إجابات لأكثر الأسئلة شيوعاً حول التطبيق.',
                Icons.help_outline,
                () => Get.to(() => const FAQPage()),
                cardColor,
                textColor,
                iconColor,
              ),
              const SizedBox(height: 16.0),
              _buildServiceCard(
                context,
                'معلومات التواصل',
                'تواصل مع فريق الدعم عبر الهاتف أو البريد الإلكتروني.',
                Icons.contact_mail_outlined,
                () => Get.to(() => const ContactInfoPage()),
                cardColor,
                textColor,
                iconColor,
              ),
              const SizedBox(height: 16.0),
              _buildServiceCard(
                context,
                'إرسال شكوى/ملاحظة',
                'أرسل شكواك أو ملاحظاتك لتحسين التطبيق.',
                Icons.feedback_outlined,
                () => Get.to(() => const SendComplaintFeedbackPage()),
                cardColor,
                textColor,
                iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: NeumorphicText(
        title,
        style: NeumorphicStyle(
          depth: 2,
          intensity: 0.6,
          lightSource: LightSource.topLeft,
          color: textColor,
        ),
        textStyle: NeumorphicTextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color cardColor,
    Color textColor,
    Color iconColor,
  ) {
    return NeumorphicButton(
      onPressed: onTap,
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 1,
        intensity: 0.7,
        lightSource: LightSource.topLeft,
        color: cardColor,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          NeumorphicIcon(
            icon,
            size: 30,
            style: NeumorphicStyle(
              color: iconColor,
              depth: 2,
              intensity: 0.8,
              lightSource: LightSource.topLeft,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeumorphicText(
                  title,
                  style: NeumorphicStyle(
                    depth: 2,
                    intensity: 0.6,
                    lightSource: LightSource.topLeft,
                    color: textColor,
                  ),
                  textStyle: NeumorphicTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: textColor.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ),
          NeumorphicIcon(
            Icons.arrow_forward_ios,
            size: 20,
            style: NeumorphicStyle(
              color: iconColor,
              depth: 2,
              intensity: 0.8,
              lightSource: LightSource.topLeft,
            ),
          ),
        ],
      ),
    );
  }
}
