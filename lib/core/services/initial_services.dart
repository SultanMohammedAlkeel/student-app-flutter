import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/themes/app_theme.dart';
import '../../app/routes/app_pages.dart';
import '../network/api_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class InitialServices {
  static Future<void> init() async {
    await GetStorage.init(); // تهيئة GetStorage أولاً
    await initBasicServices();
  }

  static Future<void> initBasicServices() async {

    // تهيئة الخدمات الأساسية بالترتيب الصحيح
    await _initSharedPreferences();
    await _initStorageService();
    await _initThemeService();
    await _initAuthService();
    await _initApiService();
  }

  static Future<void> checkAuthStatus() async {
    final authService = Get.find<AuthService>();
    if (authService.isLoggedInSync()) {
      await Get.offAllNamed(AppRoutes.home);
    } else {
      await Get.offAllNamed(AppRoutes.login);
    }
  }

  static Future<void> _initSharedPreferences() async {
    await Get.putAsync(() => SharedPreferences.getInstance(), permanent: true);
  }

  static Future<void> _initStorageService() async {
    await Get.putAsync(
        () => StorageService().init(Get.find<SharedPreferences>()),
        permanent: true);
  }

  static Future<void> _initThemeService() async {
    await Get.putAsync<AppThemeService>(() async {
      final service = AppThemeService();
      service.onInit();
      return service;
    }, permanent: true);
  }

  static Future<void> _initAuthService() async {
    Get.put(AuthService(), permanent: true);
  }

  static Future<void> _initApiService() async {
    Get.put(ApiService(), permanent: true);
  } 
}
