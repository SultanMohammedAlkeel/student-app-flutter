import 'package:get/get.dart';
import '../../../core/services/locale_service.dart';
import '../controllers/services_dashboard_controller.dart';
import '../views/exam_service_v2/exam_controller.dart';
import '../views/exam_service_v2/exam_repository.dart';
import '../views/exam_service_v2/exam_search_controller.dart';
import '../views/exam_service_v2/utils/exam_binding.dart';
import '../views/library_service/library_binding.dart';
import '../views/student_schedule_service/schedule_controller.dart';

class StudentServicesBinding implements Bindings {
  @override
  void dependencies() {
    // تسجيل الخدمات المشتركة
    Get.put(LocaleService(), permanent: true);
    
    // تسجيل متحكمات الخدمات
    Get.lazyPut<ServicesDashboardController>(() => ServicesDashboardController());
     Get.lazyPut<ScheduleController>(() => ScheduleController());
     LibraryBinding().dependencies();
     Get.lazyPut<ExamSearchController>(() => ExamSearchController());
     Get.lazyPut<ExamRepository>(() => ExamRepository());
     Get.lazyPut<ExamController>(() => ExamController(repository: Get.find<ExamRepository>()));
     ExamBinding().dependencies();
  }
}
