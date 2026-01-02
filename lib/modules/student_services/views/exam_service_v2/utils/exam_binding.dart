import 'package:get/get.dart';
import '../exam_controller.dart';
import '../exam_search_controller.dart';
import '../exam_taking_controller.dart';
import '../exam_result_controller.dart';
import '../exam_creation_controller.dart';
import '../exam_repository.dart';

class ExamBinding implements Bindings {
  @override
  void dependencies() {
    // تسجيل طبقة الوسيط (Repository)
    Get.lazyPut<ExamRepository>(() => ExamRepository(
    ), fenix: true);
    
    // تسجيل المتحكمات
    Get.lazyPut<ExamController>(() => ExamController(
      repository: Get.find<ExamRepository>(),
    ), fenix: true);
    
    Get.lazyPut<ExamSearchController>(() => ExamSearchController(), fenix: true);
    
    Get.lazyPut<ExamTakingController>(() => ExamTakingController(
      repository: Get.find<ExamRepository>(),
    ));
    
    Get.lazyPut<ExamResultController>(() => ExamResultController(
      repository: Get.find<ExamRepository>(),
    ));
    
    Get.lazyPut<ExamCreationController>(() => ExamCreationController(
      repository: Get.find<ExamRepository>(),
    ));
  }
}

// Binding خاص بصفحة تفاصيل الامتحان
class ExamDetailsBinding implements Bindings {
  @override
  void dependencies() {
    // التأكد من وجود طبقة الوسيط
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(() => ExamRepository(
      ), fenix: true);
    }
    
    // تسجيل المتحكم الرئيسي إذا لم يكن مسجلاً
    if (!Get.isRegistered<ExamController>()) {
      Get.lazyPut<ExamController>(() => ExamController(
        repository: Get.find<ExamRepository>(),
      ), fenix: true);
    }
  }
}

// Binding خاص بصفحة إجراء الامتحان
class ExamTakingBinding implements Bindings {
  @override
  void dependencies() {
    // التأكد من وجود طبقة الوسيط
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(() => ExamRepository(
      ), fenix: true);
    }
    
    // تسجيل متحكم إجراء الامتحان
    Get.lazyPut<ExamTakingController>(() => ExamTakingController(
      repository: Get.find<ExamRepository>(),
    ));
  }
}

// Binding خاص بصفحة نتيجة الامتحان
class ExamResultBinding implements Bindings {
  @override
  void dependencies() {
    // التأكد من وجود طبقة الوسيط
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(() => ExamRepository(
      ), fenix: true);
    }
    
    // تسجيل متحكم نتيجة الامتحان
    Get.lazyPut<ExamResultController>(() => ExamResultController(
      repository: Get.find<ExamRepository>(),
    ));
  }
}

// Binding خاص بصفحة إنشاء الامتحان
class ExamCreationBinding implements Bindings {
  @override
  void dependencies() {
    // التأكد من وجود طبقة الوسيط
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(() => ExamRepository(
      ), fenix: true);
    }
    
    // تسجيل متحكم إنشاء الامتحان
    Get.lazyPut<ExamCreationController>(() => ExamCreationController(
      repository: Get.find<ExamRepository>(),
    ));
  }
}
