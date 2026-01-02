import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/models/message_model.dart';

import 'package:file_picker/file_picker.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/chats/views/widgets/chat_tab_bar.dart';
import 'package:student_app/modules/chats/views/widgets/message_bubble.dart';
import 'package:student_app/modules/chats/views/widgets/neumorphic_appBar.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final isDarkMode = NeumorphicTheme.isUsingDark(context);

    // تحسين ألوان الخلفية للتوافق مع HomeView
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
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              // Search bar at the top
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -2,
                    intensity: 0.7,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                    color: backgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: secondaryTextColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'بحث في المجموعات',
                              hintStyle: TextStyle(
                                  color: secondaryTextColor, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: TextStyle(color: textColor, fontSize: 14),
                            onChanged: (value) =>
                                controller.searchQuery.value = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tab bar with text only
              ChatTabBar(
                onTabChanged: (index) => controller.changeCategory(index),
                currentIndex: controller.currentCategoryIndex,
                // tabs: const ['الكل', 'المجموعات العامة', 'المجموعات الخاصة'],
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: _homeController.getPrimaryColor(),
                      ),
                    );
                  }

                  // تصفية المجموعات فقط
                  final groups = controller.filteredChats
                      .where((chat) => chat.type == 'group')
                      .toList();

                  if (groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/no_results.json',
                            width: 200,
                            height: 200,
                            repeat: true,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'لا توجد مجموعات',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'قم بإنشاء مجموعة جديدة أو انضم إلى مجموعة موجودة',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        controller.isScrolling.value = true;
                        controller.lastScrollTime.value = DateTime.now();
                      } else if (scrollNotification is ScrollEndNotification) {
                        controller.isScrolling.value = false;
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: controller.chatListScrollController,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return _buildGroupItem(context, group, textColor,
                            secondaryTextColor, backgroundColor);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
          floatingActionButton: Obx(() {
            return AnimatedOpacity(
              opacity: controller.isScrolling.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: NeumorphicFloatingActionButton(
                style: NeumorphicStyle(
                  color: _homeController.getPrimaryColor(),
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 4,
                  intensity: 0.6,
                ),
                child: const Icon(
                  Icons.group_add,
                  color: Colors.white,
                ),
                onPressed: _showCreateGroupDialog,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, dynamic group, Color textColor,
      Color secondaryTextColor, Color backgroundColor) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
  final HomeController _homeController = Get.find<HomeController>();

    return Neumorphic(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        onTap: () => Get.to(() => GroupChatDetailPage(groupId: group.id)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Group image
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    _homeController.getPrimaryColor().withOpacity(0.1),
                backgroundImage: group.imageUrl != null
                    ? NetworkImage(group.imageUrl!)
                    : null,
                child: group.imageUrl == null
                    ? Icon(
                        Icons.group,
                        color: _homeController.getPrimaryColor(),
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Group details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          group.lastMessageTime != null
                              ? _formatTime(group.lastMessageTime!)
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.lastMessage ?? 'لا توجد رسائل بعد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        if (group.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _homeController.getPrimaryColor(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              group.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // عدد الأعضاء
                    Text(
                      '${group.membersCount ?? 0} عضو',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();

      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        // Today, show time only
        return DateFormat('hh:mm a').format(dateTime);
      } else if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day - 1) {
        // Yesterday
        return 'أمس';
      } else if (now.difference(dateTime).inDays < 7) {
        // Within a week, show day name
        return DateFormat('EEEE', 'ar').format(dateTime);
      } else {
        // Older, show date
        return DateFormat('yyyy/MM/dd').format(dateTime);
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showCreateGroupDialog() {
    final controller = Get.find<ChatController>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final isPublic = true.obs;
    final selectedImage = Rx<File?>(null);
  final HomeController _homeController = Get.find<HomeController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إنشاء مجموعة جديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // صورة المجموعة
                Center(
                  child: Obx(() {
                    return GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );

                        if (pickedFile != null) {
                          selectedImage.value = File(pickedFile.path);
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _homeController
                              .getPrimaryColor()
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                          image: selectedImage.value != null
                              ? DecorationImage(
                                  image: FileImage(selectedImage.value!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImage.value == null
                            ? Icon(
                                Icons.add_a_photo,
                                color: _homeController.getPrimaryColor(),
                                size: 40,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // اسم المجموعة
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المجموعة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // وصف المجموعة
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف المجموعة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // نوع المجموعة
                Obx(() {
                  return Row(
                    children: [
                      const Text('نوع المجموعة:'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: true,
                        groupValue: isPublic.value,
                        onChanged: (value) {
                          isPublic.value = value!;
                        },
                      ),
                      const Text('عامة'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: false,
                        groupValue: isPublic.value,
                        onChanged: (value) {
                          isPublic.value = value!;
                        },
                      ),
                      const Text('خاصة'),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                // أزرار الإلغاء والإنشاء
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى إدخال اسم المجموعة',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // // إنشاء المجموعة
                        // controller.createGroup(
                        //   name: nameController.text.trim(),
                        //   description: descriptionController.text.trim(),
                        //   isPublic: isPublic.value,
                        //   image: selectedImage.value,
                        // );

                        Get.back();
                      },
                      child: const Text('إنشاء'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupChatDetailPage extends StatelessWidget {
  final int groupId;

  const GroupChatDetailPage({Key? key, required this.groupId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);

    // تحسين ألوان الخلفية للتوافق مع HomeView
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final controller = Get.find<ChatController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMessages(groupId);
    });
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
          appBar: NeumorphicApp_Bar(
            color: backgroundColor,
            title: Obx(() {
              final group = controller.chats.firstWhere(
                (c) => c.id == groupId,
                orElse: () => controller.chats.first,
              );

              return GestureDetector(
                onTap: () {
                  // فتح صفحة معلومات المجموعة
                  _showGroupInfo(context, group);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          _homeController.getPrimaryColor().withOpacity(0.1),
                      backgroundImage: group.imageUrl != null
                          ? NetworkImage(group.imageUrl!)
                          : null,
                      child: group.imageUrl == null
                          ? Icon(
                              Icons.group,
                              color: _homeController.getPrimaryColor(),
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${0} عضو',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            leading: NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.circle(),
                depth: -2,
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Get.back(),
            ),
            actions: [
              NeumorphicButton(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: -2,
                  color: Colors.transparent,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.more_vert, color: textColor),
                onPressed: () {
                  // Show group options menu
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.search,
                                color: _homeController.getPrimaryColor()),
                            title: Text(
                              'بحث في المجموعة',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to search page
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.group,
                                color: _homeController.getPrimaryColor()),
                            title: Text(
                              'معلومات المجموعة',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              final group = controller.chats.firstWhere(
                                (c) => c.id == groupId,
                                orElse: () => controller.chats.first,
                              );
                              _showGroupInfo(context, group);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.notifications,
                                color: _homeController.getPrimaryColor()),
                            title: Text(
                              'كتم الإشعارات',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Mute notifications
                            },
                          ),
                          ListTile(
                            leading:
                                Icon(Icons.exit_to_app, color: Colors.orange),
                            title: Text(
                              'مغادرة المجموعة',
                              style: TextStyle(color: Colors.orange),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Show leave confirmation
                              _showLeaveGroupConfirmation(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'حذف المجموعة',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Show delete confirmation
                              _showDeleteGroupConfirmation(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // الرسائل
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Lottie.asset('assets/progresses/loading_6.json');
                    }

                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/start_chat.json',
                              width: 200,
                              height: 200,
                              repeat: true,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'لا توجد رسائل بعد',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ابدأ المحادثة الآن',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: controller.messagesScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe = message.isMine;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // إظهار اسم المرسل في المجموعة إذا لم تكن الرسالة مني
                            if (!isMe &&
                                (index == 0 ||
                                    controller.messages[index - 1].isMine))
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8, bottom: 4),
                                child: Text(
                                  'اسم المرسل', // يجب استبداله باسم المرسل الفعلي
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            MessageBubble(
                              message: message,
                              isMe: isMe,
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ),

              // معاينة المرفق
              Obx(() {
                if (controller.isAttachmentSelected.value) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // معاينة مصغرة للمرفق
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildAttachmentPreview(controller),
                        ),
                        const SizedBox(width: 12),
                        // معلومات المرفق
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getAttachmentTypeText(
                                    controller.selectedFileType.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.selectedFilePath.value
                                    .split('/')
                                    .last,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // زر إزالة المرفق
                        IconButton(
                          icon: Icon(Icons.close,
                              color: textColor.withOpacity(0.7)),
                          onPressed: controller.clearAttachment,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // حقل إدخال الرسالة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // زر إضافة مرفق
                    NeumorphicButton(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 2,
                        intensity: 0.7,
                        color: backgroundColor,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.attach_file,
                        color: textColor.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        _showAttachmentOptions(context, controller);
                      },
                    ),
                    const SizedBox(width: 8),
                    // حقل إدخال النص
                    Expanded(
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: -2,
                          intensity: 0.7,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20),
                          ),
                          color: backgroundColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالة...',
                              hintStyle: TextStyle(
                                color: textColor.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                            maxLines: 5,
                            minLines: 1,
                            textDirection: TextDirection.rtl,
                            onChanged: (value) {
                              // تحديث حالة الإدخال
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // زر تسجيل الصوت
                    Obx(() {
                      final hasText =
                          controller.messageController.text.trim().isNotEmpty;
                      final hasAttachment =
                          controller.isAttachmentSelected.value;

                      if (!hasText && !hasAttachment) {
                        return NeumorphicButton(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: 2,
                            intensity: 0.7,
                            color: _homeController.getPrimaryColor(),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            controller.isRecording.value
                                ? Icons.stop
                                : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: controller.isRecording.value
                              ? controller.stopRecording
                              : controller.startRecording,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // زر الإرسال
                    Obx(() {
                      final hasText =
                          controller.messageController.text.trim().isNotEmpty;
                      final hasAttachment =
                          controller.isAttachmentSelected.value;

                      if (hasText || hasAttachment) {
                        return NeumorphicButton(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: 2,
                            intensity: 0.7,
                            color: _homeController.getPrimaryColor(),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => controller.sendMessage(groupId),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              // عرض مدة التسجيل
              Obx(() {
                if (controller.isRecording.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color:
                        isDarkMode ? Colors.red.shade900 : Colors.red.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic,
                          color: isDarkMode ? Colors.white : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'جاري التسجيل: ${controller.recordingDuration.value.toStringAsFixed(1)} ثانية',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: controller.cancelRecording,
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  // عرض خيارات المرفقات
  void _showAttachmentOptions(BuildContext context, ChatController controller) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إرسال مرفق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.image,
                  label: 'صورة',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'كاميرا',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.video_library,
                  label: 'فيديو',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickVideo();
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.insert_drive_file,
                  label: 'ملف',
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickFile();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء خيار مرفق
  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
  final HomeController _homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _homeController.getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: _homeController.getPrimaryColor(),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // بناء معاينة المرفق
  Widget _buildAttachmentPreview(ChatController controller) {
    final fileType = controller.selectedFileType.value;

    if (fileType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          controller.selectedFile.value!,
          fit: BoxFit.cover,
        ),
      );
    } else if (fileType == 'video') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.black,
          child: const Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    } else if (fileType == 'audio') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.blue.shade100,
          child: const Icon(
            Icons.audiotrack,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.insert_drive_file,
            color: Colors.grey,
            size: 30,
          ),
        ),
      );
    }
  }

  // الحصول على نص وصفي لنوع المرفق
  String _getAttachmentTypeText(String fileType) {
    switch (fileType) {
      case 'image':
        return 'صورة';
      case 'video':
        return 'فيديو';
      case 'audio':
        return 'تسجيل صوتي';
      case 'file':
        return 'ملف';
      default:
        return 'مرفق';
    }
  }

  // عرض معلومات المجموعة
  void _showGroupInfo(BuildContext context, dynamic group) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
  final HomeController _homeController = Get.find<HomeController>();

    Get.to(
      () => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'معلومات المجموعة',
              style: TextStyle(color: textColor),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المجموعة
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        _homeController.getPrimaryColor().withOpacity(0.1),
                    backgroundImage: group.imageUrl != null
                        ? NetworkImage(group.imageUrl!)
                        : null,
                    child: group.imageUrl == null
                        ? Icon(
                            Icons.group,
                            color: _homeController.getPrimaryColor(),
                            size: 60,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // اسم المجموعة
                Center(
                  child: Text(
                    group.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                // وصف المجموعة
                Center(
                  child: Text(
                    group.description ?? 'لا يوجد وصف',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // معلومات المجموعة
                _buildInfoItem(
                  context: context,
                  icon: Icons.people,
                  title: 'الأعضاء',
                  subtitle: '${group.membersCount ?? 0} عضو',
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'تاريخ الإنشاء',
                  subtitle:
                      _formatDate(group.createdAt ?? DateTime.now().toString()),
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.public,
                  title: 'نوع المجموعة',
                  subtitle: group.isPublic ? 'عامة' : 'خاصة',
                ),
                const SizedBox(height: 20),
                // قائمة الأعضاء
                Text(
                  'الأعضاء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                // قائمة وهمية للأعضاء
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5, // عدد وهمي للأعضاء
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _homeController.getPrimaryColor().withOpacity(0.1),
                        child: Text(
                          'U${index + 1}',
                          style: TextStyle(
                              color: _homeController.getPrimaryColor()),
                        ),
                      ),
                      title: Text(
                        'عضو ${index + 1}',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        index == 0 ? 'مشرف' : 'عضو',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      trailing: index == 0
                          ? Icon(Icons.star, color: Colors.amber)
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.exit_to_app,
                      label: 'مغادرة المجموعة',
                      color: Colors.orange,
                      onTap: () => _showLeaveGroupConfirmation(context),
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.delete,
                      label: 'حذف المجموعة',
                      color: Colors.red,
                      onTap: () => _showDeleteGroupConfirmation(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء عنصر معلومات
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
  final HomeController _homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: _homeController.getPrimaryColor(),
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء زر إجراء
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // عرض تأكيد مغادرة المجموعة
  void _showLeaveGroupConfirmation(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    Get.dialog(
      AlertDialog(
        title: const Text('مغادرة المجموعة'),
        content: const Text('هل أنت متأكد من رغبتك في مغادرة هذه المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // العودة إلى قائمة المجموعات
              Get.snackbar(
                'تمت المغادرة',
                'لقد غادرت المجموعة بنجاح',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'مغادرة',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  // عرض تأكيد حذف المجموعة
  void _showDeleteGroupConfirmation(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    Get.dialog(
      AlertDialog(
        title: const Text('حذف المجموعة'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذه المجموعة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // العودة إلى قائمة المجموعات
              Get.snackbar(
                'تم الحذف',
                'تم حذف المجموعة بنجاح',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // تنسيق التاريخ
  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy/MM/dd', 'ar').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
