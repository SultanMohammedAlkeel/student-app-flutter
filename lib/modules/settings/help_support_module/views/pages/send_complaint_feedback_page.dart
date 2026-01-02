import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../controllers/help_support_controller.dart';

class SendComplaintFeedbackPage extends GetView<HelpSupportController> {
  const SendComplaintFeedbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final isDarkMode = Get.isDarkMode;
    final cardColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textDark;
    final accentColor = isDarkMode
        ? homeController.getSecondaryColor()
        : homeController.getPrimaryColor();

    final baseColor =
        isDarkMode ? AppColors.darkNeuBackground : AppColors.lightOnSurface;

    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NeumorphicAppBar(
          title: Text(
            'إرسال شكوى أو ملاحظة',
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
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('نوع الرسالة', textColor),
              const SizedBox(height: 12.0),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => controller.setType('complaint'),
                          style: NeumorphicStyle(
                            shape: controller.selectedType.value == 'complaint'
                                ? NeumorphicShape.concave
                                : NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12)),
                            depth: controller.selectedType.value == 'complaint'
                                ? -2
                                : 2,
                            intensity: 0.7,
                            lightSource: LightSource.topLeft,
                            color: controller.selectedType.value == 'complaint'
                                ? homeController.getPrimaryColor()
                                : cardColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: NeumorphicText(
                              'شكوى',
                              style: NeumorphicStyle(
                                depth:
                                    controller.selectedType.value == 'complaint'
                                        ? 2
                                        : 0,
                                intensity: 0.6,
                                lightSource: LightSource.topLeft,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textStyle: NeumorphicTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => controller.setType('feedback'),
                          style: NeumorphicStyle(
                            shape: controller.selectedType.value == 'feedback'
                                ? NeumorphicShape.concave
                                : NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12)),
                            depth: controller.selectedType.value == 'feedback'
                                ? -2
                                : 2,
                            intensity: 0.7,
                            lightSource: LightSource.topLeft,
                            color: controller.selectedType.value == 'feedback'
                                ? homeController.getPrimaryColor()
                                : cardColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: NeumorphicText(
                              'ملاحظة',
                              style: NeumorphicStyle(
                                depth:
                                    controller.selectedType.value == 'feedback'
                                        ? 2
                                        : 0,
                                intensity: 0.6,
                                lightSource: LightSource.topLeft,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textStyle: NeumorphicTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 24.0),
              _buildSectionTitle('عنوان الرسالة', textColor),
              const SizedBox(height: 12.0),
              Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  depth: -2,
                  intensity: 0.7,
                  lightSource: LightSource.topLeft,
                  color: cardColor,
                ),
                child: TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    fillColor: cardColor,
                    hintText:
                        'ادخل عنوان الرسالة (مثال: مشكلة في تسجيل الدخول)',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
              const SizedBox(height: 24.0),
              _buildSectionTitle('تفاصيل الرسالة', textColor),
              const SizedBox(height: 12.0),
              Neumorphic(
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
                  controller: controller.descriptionController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    fillColor: cardColor,
                    hintText: 'ادخل تفاصيل الشكوى أو الملاحظة هنا...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
              const SizedBox(height: 24.0),
              Obx(() => NeumorphicButton(
                    onPressed: controller.isSubmittingComplaint.value
                        ? null
                        : () => controller.submitComplaintFeedback(),
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12)),
                      depth: 2,
                      intensity: 0.7,
                      lightSource: LightSource.topLeft,
                      color: accentColor,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: controller.isSubmittingComplaint.value
                          ? NeumorphicProgressIndeterminate(
                              style: ProgressStyle(
                                depth: 5,
                                lightSource: LightSource.topLeft,
                                accent: textColor,
                              ),
                            )
                          : NeumorphicText(
                              'إرسال الرسالة',
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
                  )),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
