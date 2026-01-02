import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/chats/controllers/create_new_chat_controller.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class CreateNewChatPage extends GetView<CreateNewChatController> {
  const CreateNewChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final HomeController _homeController = Get.find<HomeController>();

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
              'إضافة محادثة جديدة',
              style: TextStyle(color: textColor),
            ),

            //backgroundColor: backgroundColor,
            centerTitle: true,
            buttonStyle: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              depth: 2,
              intensity: 0.7,
              color: backgroundColor,
            ),
            iconTheme: IconThemeData(color: secondaryTextColor),
          ),
          body: Column(
            children: [
              // شريط البحث والتصفية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // شريط البحث
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: -2,
                        intensity: 0.7,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                        color: backgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          onChanged: (value) =>
                              controller.searchQuery.value = value,
                          decoration: InputDecoration(
                            fillColor: backgroundColor,
                            hintText: 'البحث عن مستخدم...',
                            hintStyle: TextStyle(
                                color: secondaryTextColor, fontSize: 14),
                            prefixIcon: Icon(Icons.search,
                                color: secondaryTextColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // تصفية نوع المستخدم
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.userTypes.length,
                        itemBuilder: (context, index) {
                          final type = controller.userTypes[index];
                          return Obx(() {
                            final isSelected =
                                controller.selectedUserType.value == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: NeumorphicButton(
                                onPressed: () {
                                  controller.selectedUserType.value = type;
                                },
                                style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12)),
                                  depth: isSelected ? -2 : 2,
                                  intensity: 0.7,
                                  color: isSelected
                                      ? _homeController.getPrimaryColor()
                                      : backgroundColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : textColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // قائمة المستخدمين
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: _homeController.getPrimaryColor()),
                          const SizedBox(height: 16),
                          Text(
                            'جاري تحميل المستخدمين...',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        ],
                      ),
                    );
                  }
                  if (controller.filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: secondaryTextColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.isNotEmpty
                                ? 'لا توجد نتائج للبحث'
                                : 'لا توجد مستخدمون متاحون',
                            style: TextStyle(
                              fontSize: 18,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.searchQuery.isNotEmpty
                                ? 'جرب البحث بكلمات مختلفة'
                                : 'جميع المستخدمين موجودون في قائمة الدردشات',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = controller.filteredUsers[index];
                        final userType = controller.getSafeString(user['user']);
                        final userName = controller.getSafeString(user['name']);
                        final userEmail =
                            controller.getSafeString(user['email']);
                        final imageUrl =
                            controller.getSafeString(user['image_url']);
                        final isOnline = user['isOnline'] ?? false;

                        return Neumorphic(
                          margin: const EdgeInsets.only(bottom: 12),
                          style: NeumorphicStyle(
                            depth: isDarkMode ? 2 : 4,
                            intensity: isDarkMode ? 0.3 : 0.7,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20),
                            ),
                            color: backgroundColor,
                            lightSource: LightSource.topLeft,
                          ),
                          child: InkWell(
                            onTap: () => controller.addUserToContacts(user),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: controller
                                            .getUserTypeColor(userType)
                                            .withOpacity(0.1),
                                        backgroundImage: imageUrl.isNotEmpty
                                            ? NetworkImage(imageUrl)
                                            : null,
                                        child: imageUrl.isEmpty
                                            ? Text(
                                                userName.isNotEmpty
                                                    ? userName[0].toUpperCase()
                                                    : '؟',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: controller
                                                      .getUserTypeColor(
                                                          userType),
                                                ),
                                              )
                                            : null,
                                      ),
                                      if (isOnline)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: backgroundColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName.isNotEmpty
                                              ? userName
                                              : 'مستخدم غير معروف',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // ashrf
                                        // if (userEmail.isNotEmpty)
                                        //   Text(
                                        //     userEmail,
                                        //     style: TextStyle(
                                        //       fontSize: 14,
                                        //       color: secondaryTextColor,
                                        //     ),
                                        //     maxLines: 1,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              controller
                                                  .getUserTypeIcon(userType),
                                              size: 16,
                                              color: controller
                                                  .getUserTypeColor(userType),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              userType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: controller
                                                    .getUserTypeColor(userType),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
