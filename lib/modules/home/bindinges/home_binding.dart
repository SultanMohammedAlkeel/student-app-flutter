import 'package:get/get.dart';
import 'package:student_app/core/network/profile_service.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/repositories/posts_repository.dart';
import 'package:student_app/modules/settings/api/controllers/api_settings_controller.dart';
import 'package:student_app/modules/student_services/bindings/student_services_binding.dart';

import '../../../core/services/app_settings_storage_service.dart';
import '../../chats/controllers/chat_controller.dart';
import '../../chats/repositories/chat_repository.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/controllers/university_controller.dart';
import '../../posts/controllers/posts_controller.dart';
import '../../settings/help_support_module/controllers/help_support_controller.dart';
import '../../student_services/views/attendance_service/attendance_binding.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => StorageService());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ProfileService());
    Get.lazyPut(() => PostsController());
    Get.lazyPut(() => PostsRepository());
    Get.lazyPut(() => ChatRepository());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ProfileService());
    Get.lazyPut(() => ApiSettingsController());
    Get.lazyPut<HomePageController>(() => HomePageController(), fenix: true);
    Get.lazyPut<UniversityController>(() => UniversityController(),
        fenix: true);
    Get.lazyPut<HelpSupportController>(() => HelpSupportController(),
        fenix: true);

    StudentServicesBinding().dependencies();
    AttendanceBinding().dependencies();
  }
}
