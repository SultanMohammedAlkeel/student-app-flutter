import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../../controllers/help_support_controller.dart';
import '../../data/user_guide_data.dart';

class UserGuidePage extends GetView<HelpSupportController> {
  const UserGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
          HomeController homeController = Get.find<HomeController>();

    final isDarkMode = Get.isDarkMode;
    final bgColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textDark;
    final iconColor = isDarkMode         ? homeController.getSecondaryColor()
        : homeController.getPrimaryColor();


    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NeumorphicAppBar(
          title: Text(
            'دليل الاستخدام',
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
        body: Obx(() {
          if (controller.isLoadingUserGuide.value) {
            return Center(
              child: NeumorphicProgressIndeterminate(
                style: ProgressStyle(
                  depth: 2,
                  lightSource: LightSource.topLeft,
                  accent: NeumorphicTheme.currentTheme(context).accentColor,
                ),
              ),
            );
          }

          if (controller.userGuideData.isEmpty) {
            return Center(
              child: NeumorphicText(
                'لا يوجد دليل استخدام متاح حالياً.',
                style: NeumorphicStyle(
                  depth: 2,
                  intensity: 0.6,
                  lightSource: LightSource.topLeft,
                  color: textColor,
                ),
                textStyle: NeumorphicTextStyle(
                  fontSize: 16,
                ),
              ),
            );
          }

          return Row(
            children: [
              // Left sidebar for sections
              Expanded(
                flex: 1,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.rect(),
                    depth: 2,
                    intensity: 0.7,
                    lightSource: LightSource.topLeft,
                    color: cardColor,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: controller.userGuideData.length,
                    itemBuilder: (context, index) {
                      final section = controller.userGuideData[index];
                      final isSelected =
                          controller.selectedGuideSection.value == index;
                      return NeumorphicButton(
                        onPressed: () => controller.selectGuideSection(index),
                        style: NeumorphicStyle(
                          shape: isSelected
                              ? NeumorphicShape.concave
                              : NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(8)),
                          depth: isSelected ? -2 : 2,
                          intensity: 0.7,
                          lightSource: LightSource.topLeft,
                          color: isSelected
                              ? NeumorphicTheme.currentTheme(context).baseColor
                              : cardColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 8.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              _getIconData(section['icon']),
                              color: isSelected
                                  ? NeumorphicTheme.currentTheme(context)
                                      .accentColor
                                  : iconColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: NeumorphicText(
                                section['title'],
                                style: NeumorphicStyle(
                                  depth: isSelected ? 2 : 0,
                                  intensity: 0.6,
                                  lightSource: LightSource.topLeft,
                                  color: isSelected
                                      ? NeumorphicTheme.currentTheme(context)
                                          .accentColor
                                      : textColor,
                                ),
                                textStyle: NeumorphicTextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Right content area for selected section
              Expanded(
                flex: 2,
                child: Obx(() {
                  final currentSection = controller
                      .userGuideData[controller.selectedGuideSection.value];
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: currentSection['sections'].length,
                    itemBuilder: (context, index) {
                      final subSection = currentSection['sections'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12)),
                            depth: 2,
                            intensity: 0.7,
                            lightSource: LightSource.topLeft,
                            color: cardColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NeumorphicText(
                                  subSection['title'],
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
                                const SizedBox(height: 12.0),
                                Text(
                                  subSection['content'],
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 15),
                                ),
                                if (subSection['image'] != null &&
                                    subSection['image'].isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(8)),
                                        depth: 2,
                                        intensity: 0.7,
                                        lightSource: LightSource.topLeft,
                                        color: cardColor,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/images/help_guide/${subSection['image']}', // Assuming images are in assets/images/help_guide/
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_not_supported,
                                              color: textColor.withOpacity(0.5),
                                              size: 50,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'play_circle_outline':
        return Icons.play_circle_outline;
      case 'schedule':
        return Icons.schedule;
      case 'grade':
        return Icons.grade;
      case 'library_books':
        return Icons.library_books;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.info_outline;
    }
  }
}
