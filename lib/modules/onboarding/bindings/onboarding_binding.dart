import 'package:get/get.dart';
import 'package:student_app/modules/home/bindinges/home_binding.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    HomeBinding().dependencies(); // Ensure HomeBinding is initialized
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(),
    );
  }
}

