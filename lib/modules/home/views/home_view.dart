import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/home/views/widgets/bottom_nav_bar.dart';
import 'package:student_app/modules/home/views/widgets/drawer_menu.dart'; // هذا لم يعد مستخدمًا، يمكن إزالته إذا لم يكن هناك استخدام آخر
import 'package:student_app/modules/dashboard/views/home_page.dart'; // هذا لم يعد مستخدمًا، يمكن إزالته إذا لم يكن هناك استخدام آخر
import 'package:student_app/modules/home/views/pages/posts_page.dart';
import 'package:student_app/modules/home/views/pages/profile_page.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/colors.dart'; // هذا لم يعد مستخدمًا، يمكن إزالته إذا لم يكن هناك استخدام آخر
import '../../chats/views/pages/chat_page.dart';
import '../../settings/views/widgets/custom_drawer_updated.dart';
import '../../student_services/views/services_dashboard_view.dart';
import 'widgets/app_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ServicesDashboardView(),
      ChatPage(),
      const PostsView(),
      ProfilePage(),
    ];

    return Obx(() {
      final isDarkMode = Get.isDarkMode;

      return NeumorphicTheme(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: NeumorphicThemeData(
          baseColor: AppConstants.lightBackgroundColor,
          lightSource: LightSource.topLeft,
          depth: AppConstants.lightDepth,
          intensity: AppConstants.lightIntensity,
        ),
        darkTheme: NeumorphicThemeData(
          baseColor: AppConstants.darkBackgroundColor,
          lightSource: LightSource.topLeft,
          depth: AppConstants.darkDepth,
          intensity: AppConstants.darkIntensity,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppConstants.getBackgroundColor(isDarkMode),
            appBar: const HomeAppBar(),
            drawer: const CustomDrawer(),
            body: SafeArea(
              child: PageView.builder( // استبدال IndexedStack بـ PageView.builder
                controller: controller.pageController, // ربط المتحكم
                itemCount: pages.length,
                onPageChanged: controller.onPageChanged, // تحديث currentIndex عند السحب
                itemBuilder: (context, index) {
                  return pages[index];
                },
              ),
            ),
            bottomNavigationBar: const HomeBottomNavBar(),
          ),
        ),
      );
    });
  }
}
