import 'package:get/get.dart';
import 'package:student_app/core/services/initial_services.dart';

import '../../../core/network/api_service.dart';
import '../../../core/network/profile_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => LoginController());
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut(() => RegisterController());
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => InitialServices()); 
    Get.lazyPut(()=> ProfileService());
        Get.lazyPut(() => HomeController());

    // تم تهيئته مسبقاً في InitialServices
    // لا نحتاج لإعادة تهيئة AuthRepository مرة أخرى
    // Get.lazyPut(() => SharedPreferences); // تم تهيئته مسبقاً في InitialServices
  }
}