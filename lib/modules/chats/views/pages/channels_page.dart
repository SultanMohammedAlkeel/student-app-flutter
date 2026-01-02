import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/models/message_model.dart';
import 'package:student_app/modules/chats/views/widgets/chat_tab_bar.dart';
import 'package:student_app/modules/chats/views/widgets/neumorphic_appBar.dart';

import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ChannelsPage extends StatelessWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
  final HomeController _homeController = Get.find<HomeController>();

    // تحسين ألوان الخلفية للتوافق مع HomeView
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
                              hintText: 'بحث في القنوات',
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
                currentIndex: 2.obs,
                //tabs: const ['الكل', 'القنوات العامة', 'القنوات الخاصة'],
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

                  // تصفية القنوات فقط
                  final channels = controller.filteredChats
                      .where((chat) => chat.type == 'channel')
                      .toList();

                  if (channels.isEmpty) {
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
                            'لا توجد قنوات',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'قم بإنشاء قناة جديدة أو انضم إلى قناة موجودة',
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
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        final channel = channels[index];
                        return _buildChannelItem(context, channel, textColor,
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
                  Icons.add_comment,
                  color: Colors.white,
                ),
                onPressed: _showCreateChannelDialog,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChannelItem(BuildContext context, dynamic channel,
      Color textColor, Color secondaryTextColor, Color backgroundColor) {
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
        onTap: () => Get.to(() => ChannelDetailPage(channelId: channel.id)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Channel image
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    _homeController.getPrimaryColor().withOpacity(0.1),
                backgroundImage: channel.imageUrl != null
                    ? NetworkImage(channel.imageUrl!)
                    : null,
                child: channel.imageUrl == null
                    ? Icon(
                        Icons.campaign,
                        color: _homeController.getPrimaryColor(),
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Channel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            channel.name,
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
                          channel.lastMessageTime != null
                              ? _formatTime(channel.lastMessageTime!)
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
                            channel.lastMessage ?? 'لا توجد منشورات بعد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        if (channel.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _homeController.getPrimaryColor(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              channel.unreadCount.toString(),
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
                    // عدد المشتركين
                    Text(
                      '${channel.membersCount ?? 0} مشترك',
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

  void _showCreateChannelDialog() {
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
                  'إنشاء قناة جديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // صورة القناة
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
                // اسم القناة
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القناة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // وصف القناة
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف القناة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // نوع القناة
                Obx(() {
                  return Row(
                    children: [
                      const Text('نوع القناة:'),
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
                            'يرجى إدخال اسم القناة',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // إنشاء القناة
                        // controller.createChannel(
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

class ChannelDetailPage extends StatelessWidget {
  final int channelId;

  const ChannelDetailPage({Key? key, required this.channelId})
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
      controller.loadMessages(channelId);
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
              final channel = controller.chats.firstWhere(
                (c) => c.id == channelId,
                orElse: () => controller.chats.first,
              );

              return GestureDetector(
                onTap: () {
                  // فتح صفحة معلومات القناة
                  _showChannelInfo(context, channel);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          _homeController.getPrimaryColor().withOpacity(0.1),
                      backgroundImage: channel.imageUrl != null
                          ? NetworkImage(channel.imageUrl!)
                          : null,
                      child: channel.imageUrl == null
                          ? Icon(
                              Icons.campaign,
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
                            channel.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${'channel.members' ?? 0} مشترك',
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
                  // Show channel options menu
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
                              'بحث في القناة',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to search page
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.info_outline,
                                color: _homeController.getPrimaryColor()),
                            title: Text(
                              'معلومات القناة',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              final channel = controller.chats.firstWhere(
                                (c) => c.id == channelId,
                                orElse: () => controller.chats.first,
                              );
                              _showChannelInfo(context, channel);
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
                              'مغادرة القناة',
                              style: TextStyle(color: Colors.orange),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Show leave confirmation
                              _showLeaveChannelConfirmation(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'حذف القناة',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Show delete confirmation
                              _showDeleteChannelConfirmation(context);
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
              // المنشورات
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
                              'assets/animations/empty_posts.json',
                              width: 200,
                              height: 200,
                              repeat: true,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'لا توجد منشورات بعد',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'كن أول من ينشر في هذه القناة',
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
                        return _buildChannelPost(
                            context, message, textColor, backgroundColor);
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

              // حقل إدخال المنشور
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
                              hintText: 'اكتب منشوراً...',
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
                          onPressed: () => controller.sendMessage(channelId),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء منشور القناة
  Widget _buildChannelPost(BuildContext context, MessageModel message,
      Color textColor, Color backgroundColor) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
  final HomeController _homeController = Get.find<HomeController>();
    return Neumorphic(
      margin: const EdgeInsets.only(bottom: 16),
      style: NeumorphicStyle(
        depth: isDarkMode ? 2 : 4,
        intensity: isDarkMode ? 0.3 : 0.7,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(16),
        ),
        color: backgroundColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الناشر
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // فتح صفحة الملف الشخصي للناشر
                    //Get.toNamed('/profile/${message.senderId}');
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        _homeController.getPrimaryColor().withOpacity(0.1),
                    // backgroundImage: message.senderAvatar != null
                    //     ? NetworkImage(message.senderAvatar!)
                    //     : null,
                    child: message == null
                        ? Icon(
                            Icons.person,
                            color: _homeController.getPrimaryColor(),
                            size: 20,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //message.senderName ??
                        'مستخدم',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'date',
                        //_formatDateTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // خيارات المنشور
                if (message.isMine)
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: textColor.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      _showPostOptions(context, message);
                    },
                  ),
              ],
            ),

            // محتوى المنشور
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),

            // مرفقات المنشور
            // if (message.media != null && message.media!.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 8),
            //     child: _buildPostMedia(message.media!),
            //   ),

            // أزرار التفاعل
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // زر الإعجاب
                      _buildInteractionButton(
                        icon: Icons.thumb_up_outlined,
                        count: 0, //message.likesCount ?? 0,
                        isActive: false, // message.isLiked ?? false,
                        onTap: () {
                          // تنفيذ الإعجاب
                        },
                      ),
                      const SizedBox(width: 16),
                      // زر التعليق
                      _buildInteractionButton(
                        icon: Icons.comment_outlined,
                        count: 0, // message.commentsCount ?? 0,
                        onTap: () {
                          // فتح التعليقات
                        },
                      ),
                    ],
                  ),
                  // زر المشاركة
                  _buildInteractionButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      // مشاركة المنشور
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء وسائط المنشور
  Widget _buildPostMedia(List<ChatMediaModel> mediaList) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

    // عرض أول وسائط فقط
    final media = mediaList.first;

    switch (media.fileType) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            media.fileUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        );
      case 'video':
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 50,
            ),
          ),
        );
      case 'audio':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.audiotrack,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.fileName ?? 'تسجيل صوتي',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.play_arrow,
                color: Colors.blue,
                size: 30,
              ),
            ],
          ),
        );
      case 'file':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insert_drive_file,
                color: Colors.grey,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.fileName ?? 'ملف',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      media.fileSize != null
                          ? ChatMediaModel.formatFileSize(media.fileSize!)
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.download,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // بناء زر التفاعل
  Widget _buildInteractionButton({
    required IconData icon,
    int count = 0,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
      final HomeController _homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? _homeController.getPrimaryColor() : Colors.grey,
            size: 20,
          ),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? _homeController.getPrimaryColor()
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // عرض خيارات المنشور
  void _showPostOptions(BuildContext context, MessageModel message) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
  final HomeController _homeController = Get.find<HomeController>();

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
            ListTile(
              leading:
                  Icon(Icons.edit, color: _homeController.getPrimaryColor()),
              title: Text(
                'تعديل المنشور',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                // تنفيذ تعديل المنشور
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'حذف المنشور',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                // عرض تأكيد الحذف
                _showDeletePostConfirmation(context, message);
              },
            ),
          ],
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

  // عرض معلومات القناة
  void _showChannelInfo(BuildContext context, dynamic channel) {
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
              'معلومات القناة',
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
                // صورة القناة
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        _homeController.getPrimaryColor().withOpacity(0.1),
                    backgroundImage: channel.imageUrl != null
                        ? NetworkImage(channel.imageUrl!)
                        : null,
                    child: channel.imageUrl == null
                        ? Icon(
                            Icons.campaign,
                            color: _homeController.getPrimaryColor(),
                            size: 60,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // اسم القناة
                Center(
                  child: Text(
                    channel.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                // وصف القناة
                Center(
                  child: Text(
                    channel.description ?? 'لا يوجد وصف',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // معلومات القناة
                _buildInfoItem(
                  context: context,
                  icon: Icons.people,
                  title: 'المشتركين',
                  subtitle: '${channel.membersCount ?? 0} مشترك',
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'تاريخ الإنشاء',
                  subtitle: _formatDate(
                      channel.createdAt ?? DateTime.now().toString()),
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.public,
                  title: 'نوع القناة',
                  subtitle: channel.isPublic ? 'عامة' : 'خاصة',
                ),
                const SizedBox(height: 20),
                // قائمة المشرفين
                Text(
                  'المشرفون',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                // قائمة وهمية للمشرفين
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2, // عدد وهمي للمشرفين
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _homeController.getPrimaryColor().withOpacity(0.1),
                        child: Text(
                          'A${index + 1}',
                          style: TextStyle(
                              color: _homeController.getPrimaryColor()),
                        ),
                      ),
                      title: Text(
                        'مشرف ${index + 1}',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        index == 0 ? 'مالك القناة' : 'مشرف',
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
                      label: 'مغادرة القناة',
                      color: Colors.orange,
                      onTap: () => _showLeaveChannelConfirmation(context),
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.delete,
                      label: 'حذف القناة',
                      color: Colors.red,
                      onTap: () => _showDeleteChannelConfirmation(context),
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

  // عرض تأكيد مغادرة القناة
  void _showLeaveChannelConfirmation(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    Get.dialog(
      AlertDialog(
        title: const Text('مغادرة القناة'),
        content: const Text('هل أنت متأكد من رغبتك في مغادرة هذه القناة؟'),
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
              Get.back(); // العودة إلى قائمة القنوات
              Get.snackbar(
                'تمت المغادرة',
                'لقد غادرت القناة بنجاح',
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

  // عرض تأكيد حذف القناة
  void _showDeleteChannelConfirmation(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    Get.dialog(
      AlertDialog(
        title: const Text('حذف القناة'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذه القناة؟ لا يمكن التراجع عن هذا الإجراء.'),
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
              Get.back(); // العودة إلى قائمة القنوات
              Get.snackbar(
                'تم الحذف',
                'تم حذف القناة بنجاح',
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

  // عرض تأكيد حذف المنشور
  void _showDeletePostConfirmation(BuildContext context, MessageModel message) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    Get.dialog(
      AlertDialog(
        title: const Text('حذف المنشور'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنشور؟'),
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
              // تنفيذ حذف المنشور
              Get.snackbar(
                'تم الحذف',
                'تم حذف المنشور بنجاح',
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

  // تنسيق التاريخ والوقت
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();

      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        // اليوم
        return DateFormat('hh:mm a').format(dateTime);
      } else if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day - 1) {
        // أمس
        return 'أمس ${DateFormat('hh:mm a').format(dateTime)}';
      } else {
        // تاريخ آخر
        return DateFormat('yyyy/MM/dd hh:mm a').format(dateTime);
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
