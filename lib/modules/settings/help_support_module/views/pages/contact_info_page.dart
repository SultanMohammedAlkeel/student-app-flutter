import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../controllers/help_support_controller.dart';

class ContactInfoPage extends GetView<HelpSupportController> {
  const ContactInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final isDarkMode = Get.isDarkMode;
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
            'معلومات التواصل',
            style: TextStyle(color: textColor),
          ),
          centerTitle: true,
          buttonStyle: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.circle(),
            depth: 2,
            intensity: 0.7,
            lightSource: LightSource.topLeft,
            color: cardColor,
          ),
          iconTheme: IconThemeData(color: iconColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final contact = controller.contactInfo;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('أرقام الهواتف', textColor),
                const SizedBox(height: 12.0),
                ..._buildPhoneList(
                    contact['phones'], cardColor, textColor, iconColor),
                const SizedBox(height: 24.0),
                _buildSectionTitle('البريد الإلكتروني', textColor),
                const SizedBox(height: 12.0),
                ..._buildEmailList(
                    contact['emails'], cardColor, textColor, iconColor),
                const SizedBox(height: 24.0),
                _buildSectionTitle('حسابات التواصل الاجتماعي', textColor),
                const SizedBox(height: 12.0),
                ..._buildSocialMediaList(
                    contact['social_media'], cardColor, textColor, iconColor),
                const SizedBox(height: 24.0),
                _buildSectionTitle('ساعات العمل', textColor),
                const SizedBox(height: 12.0),
                _buildInfoCard(
                  context,
                  contact['office_hours'] ?? 'غير متوفر',
                  Icons.access_time,
                  cardColor,
                  textColor,
                  iconColor,
                ),
                const SizedBox(height: 24.0),
                _buildSectionTitle('العنوان', textColor),
                const SizedBox(height: 12.0),
                _buildInfoCard(
                  context,
                  contact['address'] ?? 'غير متوفر',
                  Icons.location_on_outlined,
                  cardColor,
                  textColor,
                  iconColor,
                ),
              ],
            );
          }),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildPhoneList(List<dynamic>? phones, Color cardColor,
      Color textColor, Color iconColor) {
    if (phones == null || phones.isEmpty) return [const SizedBox.shrink()];
    return phones.map((phone) {
      return _buildContactItem(
        context: Get.context!,
        label: phone['label'],
        value: phone['number'],
        icon: Icons.phone,
        onTap: () => controller.launchURL('tel:${phone['number']}'),
        onLongPress: () => controller.copyToClipboard(phone['number']),
        cardColor: cardColor,
        textColor: textColor,
        iconColor: iconColor,
      );
    }).toList();
  }

  List<Widget> _buildEmailList(List<dynamic>? emails, Color cardColor,
      Color textColor, Color iconColor) {
    if (emails == null || emails.isEmpty) return [const SizedBox.shrink()];
    return emails.map((email) {
      return _buildContactItem(
        context: Get.context!,
        label: email['label'],
        value: email['email'],
        icon: Icons.email_outlined,
        onTap: () => controller.launchURL('mailto:${email['email']}'),
        onLongPress: () => controller.copyToClipboard(email['email']),
        cardColor: cardColor,
        textColor: textColor,
        iconColor: iconColor,
      );
    }).toList();
  }

  List<Widget> _buildSocialMediaList(List<dynamic>? socialMedia,
      Color cardColor, Color textColor, Color iconColor) {
    if (socialMedia == null || socialMedia.isEmpty)
      return [const SizedBox.shrink()];
    return socialMedia.map((item) {
      return _buildContactItem(
        context: Get.context!,
        label: item['platform'],
        value: item['display'],
        icon: _getSocialMediaIcon(item['icon']),
        onTap: () => controller.launchURL(item['url']),
        onLongPress: () => controller.copyToClipboard(item['display']),
        cardColor: cardColor,
        textColor: textColor,
        iconColor: iconColor,
      );
    }).toList();
  }

  Widget _buildContactItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: NeumorphicButton(
          onPressed: onTap,
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            depth: 2,
            intensity: 0.7,
            lightSource: LightSource.topLeft,
            color: cardColor,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              NeumorphicIcon(
                icon,
                size: 24,
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
                    Text(
                      label,
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 4.0),
                    NeumorphicText(
                      value,
                      style: NeumorphicStyle(
                        depth: 2,
                        intensity: 0.6,
                        lightSource: LightSource.topLeft,
                        color: textColor,
                      ),
                      textStyle: NeumorphicTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              NeumorphicIcon(
                Icons.copy,
                size: 20,
                style: NeumorphicStyle(
                  color: iconColor.withOpacity(0.7),
                  depth: 2,
                  intensity: 0.8,
                  lightSource: LightSource.topLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String text,
    IconData icon,
    Color cardColor,
    Color textColor,
    Color iconColor,
  ) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 2,
        intensity: 0.7,
        lightSource: LightSource.topLeft,
        color: cardColor,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          NeumorphicIcon(
            icon,
            size: 24,
            style: NeumorphicStyle(
              color: iconColor,
              depth: 2,
              intensity: 0.8,
              lightSource: LightSource.topLeft,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: NeumorphicText(
              text,
              style: NeumorphicStyle(
                depth: 2,
                intensity: 0.6,
                lightSource: LightSource.topLeft,
                color: textColor,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialMediaIcon(String iconName) {
    switch (iconName) {
      case 'whatsapp':
        return Icons.wechat_sharp;
      case 'telegram':
        return Icons.telegram;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons
            .camera_alt_outlined; // Using a generic icon as Instagram icon is not directly available in default Icons
      default:
        return Icons.public;
    }
  }
}
