import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../../controllers/help_support_controller.dart';

class FAQPage extends GetView<HelpSupportController> {
  const FAQPage({Key? key}) : super(key: key);

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
            'الأسئلة الشائعة',
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.concave,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: -4,
                  intensity: 0.7,
                  lightSource: LightSource.topLeft,
                  color: cardColor,
                ),
                child: TextField(
                  controller: controller.faqSearchController,
                  onChanged: controller.searchFAQ,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن سؤال...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: iconColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: controller.getFAQCategories().map((category) {
                      final isSelected =
                          controller.selectedFAQCategory.value == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: NeumorphicButton(
                          onPressed: () =>
                              controller.filterFAQByCategory(category),
                          style: NeumorphicStyle(
                            shape: isSelected
                                ? NeumorphicShape.concave
                                : NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(8)),
                            depth: isSelected ? -2 : 1,
                            intensity: 0.7,
                            lightSource: LightSource.topLeft,
                            color: isSelected
                                ? NeumorphicTheme.currentTheme(context)
                                    .baseColor
                                : cardColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: NeumorphicText(
                            category,
                            style: NeumorphicStyle(
                              depth: isSelected ? 1 : 0,
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
                      );
                    }).toList(),
                  ),
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingFAQ.value) {
                  return Center(
                    child: NeumorphicProgressIndeterminate(
                      style: ProgressStyle(
                        depth: 2,
                        lightSource: LightSource.topLeft,
                        accent:
                            NeumorphicTheme.currentTheme(context).accentColor,
                      ),
                    ),
                  );
                }

                if (controller.filteredFAQData.isEmpty) {
                  return Center(
                    child: NeumorphicText(
                      'لا توجد أسئلة شائعة مطابقة.',
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.filteredFAQData.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = controller.filteredFAQData[categoryIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: NeumorphicText(
                            category['category'],
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
                        ),
                        ...category['questions'].map<Widget>((question) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(12)),
                                depth: 1,
                                intensity: 0.7,
                                lightSource: LightSource.topLeft,
                                color: cardColor,
                              ),
                              child: ExpansionTile(
                                title: NeumorphicText(
                                  question['question'],
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
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      question['answer'],
                                      style: TextStyle(
                                          color: textColor.withOpacity(0.8),
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
