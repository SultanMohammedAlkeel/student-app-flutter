import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  var selectedPageIndex = 0.obs;
  var pageController = PageController();
  bool get isLastPage => selectedPageIndex.value == onboardingPages.length - 1;

  // Function to move to the next page or navigate to login
  void forwardAction() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }

  // Function to mark onboarding as completed and navigate to login
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAllNamed(AppRoutes.login); // Navigate to login and remove previous routes
  }

  // List of onboarding page data
  List<OnboardingInfo> onboardingPages = [
    OnboardingInfo(
        'assets/animations/lottie_welcome.json', // Placeholder - Replace with actual Lottie file name
        'بوابتك الذكية للخدمات الجامعية',
        'كل ما تحتاجه من خدمات أكاديمية وتواصل في مكان واحد.'),
    OnboardingInfo(
        'assets/animations/lottie_schedule.json', // Placeholder
        'تابع جدولك ودرجاتك بسهولة',
        'لا تفوت محاضرة أو تحديث لدرجاتك بعد الآن.'),
    OnboardingInfo(
        'assets/animations/lottie_library.json', // Placeholder
        'ادخل المكتبة الرقمية وحمّل الموارد',
        'آلاف الكتب والمراجع والمستندات بانتظارك.'),
    OnboardingInfo(
        'assets/animations/lottie_communication.json', // Placeholder
        'تواصل مع زملائك وشارك في المنشورات',
        'ابق على اطلاع وتفاعل مع مجتمعك الجامعي.'),
    OnboardingInfo(
        'assets/animations/lottie_tasks.json', // Placeholder
        'نظّم مهامك الدراسية واستعد للاختبارات',
        'أدوات لمساعدتك على التفوق الأكاديمي.'),
  ];
}

// Simple class to hold onboarding page information
class OnboardingInfo {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingInfo(this.imageAsset, this.title, this.description);
}

