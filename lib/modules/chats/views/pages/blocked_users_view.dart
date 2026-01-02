import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/controllers/blocked_users_controller.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class BlockedUsersView extends GetView<BlockedUsersController> {
  const BlockedUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
  final HomeController _homeController = Get.find<HomeController>();

    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: NeumorphicTheme(
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
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: NeumorphicAppBar(
            title: Text(
              'المستخدمون المحظورون',
              style: TextStyle(color: textColor),
            ),
            centerTitle: true,
            buttonStyle: NeumorphicStyle(
              color: backgroundColor,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 4,
              intensity: 0.6,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Get.back(),
            ),
            // onPop: () => Get.back(),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                    color: _homeController.getPrimaryColor()),
              );
            } else if (controller.blockedUsers.isEmpty) {
              return Center(
                child: Text(
                  'لا يوجد مستخدمون محظورون حاليًا.',
                  style: TextStyle(color: secondaryTextColor),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: controller.blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.blockedUsers[index];
                  return Neumorphic(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    style: NeumorphicStyle(
                      depth: isDarkMode ? 2 : 4,
                      intensity: isDarkMode ? 0.3 : 0.7,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12)),
                      color: backgroundColor,
                      lightSource: LightSource.topLeft,
                    ),
                    child: ListTile(
                      leading: Neumorphic(
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.circle(),
                          depth: 2,
                          intensity: 0.3,
                          color: _homeController.getPrimaryColor().withOpacity(0.1),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                                color: _homeController.getPrimaryColor(),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title:
                          Text(user.name, style: TextStyle(color: textColor)),
                      trailing: NeumorphicButton(
                        onPressed: () => controller.unblockUser(user.id),
                        style: NeumorphicStyle(
                          color: _homeController.getPrimaryColor(),
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(8)),
                          depth: 4,
                          intensity: 0.3,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          'رفع الحظر',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }),
        ),
      ),
    );
  }
}
