import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart'; // Assuming colors.dart path
import 'package:student_app/modules/home/controllers/home_controller.dart';
// Removed ThemeService import as we force light theme here

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      HomeController homeController = Get.find<HomeController>();

    // --- Force Light Theme for Onboarding --- 
    const bool isDarkMode = false; // Force light mode
    final bgColor = AppColors.neuBackground; // Light background
    final textColor = AppColors.textColor; // Light theme text color
    final secondaryTextColor = AppColors.textSecondary; // Light theme secondary text color
    final primaryColor = homeController.getPrimaryColor(); // Use the primary color from AppColors
    final lightShadow = AppColors.neuLightShadow; // Light theme light shadow
    final darkShadow = AppColors.neuDarkShadow; // Light theme dark shadow
    // --- End Force Light Theme --- 

    // Define Neumorphic style based on theme (now always light)
    // --- Updated depth and intensity --- 
    NeumorphicStyle neumorphicStyle(double depth) => NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: 3, // Updated depth
          intensity: 1, // Updated intensity
          color: bgColor,
          lightSource: LightSource.topLeft,
          shadowLightColor: lightShadow,
          shadowDarkColor: darkShadow,
        );

    NeumorphicStyle neumorphicButtonStyle(double depth) => NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: 3, // Updated depth
          intensity: 1, // Updated intensity
          color: bgColor,
          lightSource: LightSource.topLeft,
          shadowLightColor: lightShadow,
          shadowDarkColor: darkShadow,
        );
    // --- End Updated depth and intensity --- 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              // --- Reverse Scroll Direction --- 
              reverse: true, // Enable RTL scrolling
              // --- End Reverse Scroll Direction --- 
              controller: controller.pageController,
              onPageChanged: controller.selectedPageIndex,
              itemCount: controller.onboardingPages.length,
              itemBuilder: (context, index) {
                final pageInfo = controller.onboardingPages[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Get.height * 0.4, // Adjust height as needed
                        child: Lottie.asset(
                          pageInfo.imageAsset,
                          // Handle potential loading errors
                          errorBuilder: (context, error, stackTrace) {
                            print("Lottie Error: $error"); // Add print for debugging
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'خطأ في تحميل الصورة المتحركة\nتأكد من المسار واسم الملف في الكود و pubspec.yaml',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.error, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        pageInfo.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: textColor,
                          fontFamily: 'Tajawal', // Assuming Tajawal font is used
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pageInfo.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16, 
                          color: secondaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 80), // Space for bottom controls
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  NeumorphicButton(
                    style: neumorphicButtonStyle(3), // Updated depth
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    onPressed: controller.completeOnboarding,
                    child: Text(
                      'تخطي',
                      style: TextStyle(color: textColor, fontFamily: 'Tajawal', fontSize: 14),
                    ),
                  ),
                  // Dots Indicator
                  Row(
                    children: List.generate(
                      controller.onboardingPages.length,
                      (index) => Obx(() {
                        final isSelected = controller.selectedPageIndex.value == index;
                        return Neumorphic(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: isSelected ? -2 : 3, // Updated depth (inset can be smaller)
                            intensity: 1, // Updated intensity
                            color: isSelected ? primaryColor : bgColor,
                            lightSource: LightSource.topLeft,
                            shadowLightColor: lightShadow,
                            shadowDarkColor: darkShadow,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                          ),
                        );
                      }),
                    ),
                  ),
                  // Next/Finish Button
                  NeumorphicButton(
                    style: neumorphicButtonStyle(3).copyWith( // Updated depth
                      color: primaryColor, // Make the primary button stand out
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    onPressed: controller.forwardAction,
                    child: Obx(() {
                      return Text(
                        controller.isLastPage ? 'إنهاء' : 'التالي',
                        style: TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

