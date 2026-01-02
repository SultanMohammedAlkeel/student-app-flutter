// في ملف main.dart

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'core/services/auth_service.dart'; // تأكد من هذا الاستيراد
import 'core/services/initial_services.dart';
import 'core/services/storage_service.dart'; // تأكد من هذا الاستيراد

// Make main async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // 1. تهيئة SharedPreferences أولاً
  final prefs = await SharedPreferences.getInstance();
  
  // 2. تهيئة ApiUrlService معتمداً على SharedPreferences
  final apiUrlService = ApiUrlService();
  await apiUrlService.onInit();
  Get.put(apiUrlService);

  // 3. تهيئة StorageService
  Get.put(StorageService());

  // تهيئة الخدمات الأساسية أولاً
  await InitialServices.initBasicServices();
  await InitialServices.init();

  // ربط AuthService و StorageService
  // تأكد من أن StorageService تم ربطها أولاً إذا كانت AuthService تعتمد عليها
  // await Get.putAsync(() => AuthService.()); // تهيئة AuthService

  // تحديد المسار الأولي قبل تشغيل التطبيق
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  // استخدم Get.find<AuthService>() للوصول إلى AuthService المهيأة
  final bool isLoggedIn = Get.find<AuthService>().isLoggedInSync();

  String initialRoute;
  if (!hasSeenOnboarding) {
    initialRoute = AppRoutes.onboarding;
  } else {
    initialRoute = isLoggedIn ? AppRoutes.home : AppRoutes.login;
  }
  // await Get.putAsync(() => ApiUrlService().onInit());

  runApp(MyApp(initialRoute: initialRoute)); // Pass initialRoute to MyApp
}

class MyApp extends StatelessWidget {
  final String initialRoute; // Receive initialRoute

  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Student App',
          theme: Get.find<AppThemeService>().lightTheme,
          darkTheme: Get.find<AppThemeService>().darkTheme,
          themeMode: Get.find<AppThemeService>().themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          getPages: AppPages.pages,
          defaultTransition: Transition.fadeIn,
          builder: (context, widget) {
            return NeumorphicTheme(
              themeMode: Get.find<AppThemeService>().themeMode,
              theme: Get.find<AppThemeService>().lightNeumorphicTheme,
              darkTheme: Get.find<AppThemeService>().darkNeumorphicTheme,
              child: AnimationLimiter(
                child: widget!,
              ),
            );
          },
        );
      },
    );
  }
}
