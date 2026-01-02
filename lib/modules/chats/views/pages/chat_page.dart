// ignore_for_file: deprecated_member_use
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:icons_plus/icons_plus.dart' as ico_plus;
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:student_app/app/routes/app_pages.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/constants/chat_constants.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/views/widgets/chat_tab_bar.dart';
import 'package:student_app/modules/chats/views/widgets/message_bubble.dart';
import 'package:student_app/modules/chats/views/widgets/neumorphic_appBar.dart';
import 'package:student_app/modules/chats/views/widgets/scroll_to_bottom_button.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final HomeController _homeController = Get.find<HomeController>();

    // تحسين ألوان الخلفية للتوافق مع HomeView
    final backgroundColor = Get.isDarkMode
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
                              fillColor: Get.isDarkMode
                                  ? AppConstants.darkBackgroundColor
                                  : AppConstants.lightBackgroundColor,
                              hintText: 'بحث',
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
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    print('تحديث قائمة المحادثات يدوياً');
                    await controller.loadChats();
                  },
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: Lottie.asset(
                            'assets/animations/loading_posts.json'),
                      );
                    }
                    if (controller.filteredChats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: secondaryTextColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد محادثات',
                              style: TextStyle(
                                fontSize: 18,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اضغط على + لإضافة محادثة جديدة',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor.withOpacity(0.7),
                              ),
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
                        } else if (scrollNotification
                            is ScrollEndNotification) {
                          controller.isScrolling.value = false;
                        }
                        return true;
                      },
                      child: ListView.builder(
                        controller: controller
                            .chatListScrollController, // استخدام وحدة تحكم التمرير المخصصة لقائمة الدردشات
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        itemCount: controller.filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = controller.filteredChats[index];
                          return _buildChatItem(context, chat, textColor,
                              secondaryTextColor, backgroundColor);
                        },
                        scrollDirection: Axis.vertical,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          floatingActionButton: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.showFabMenu.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: NeumorphicFloatingActionButton(
                      style: NeumorphicStyle(
                        color: _homeController.getPrimaryColor(),
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 4,
                        intensity: 0.3,
                      ),
                      child: const Icon(
                        ico_plus.Bootstrap.person_x,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.blockedUsers);
                        controller.toggleFabMenu();
                      },
                    ),
                  ),
                if (controller.showFabMenu.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: NeumorphicFloatingActionButton(
                      style: NeumorphicStyle(
                        color: _homeController.getPrimaryColor(),
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 4,
                        intensity: 0.3,
                      ),
                      child: const Icon(
                        ico_plus.Bootstrap.chat_text,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        print("الضغط على زر إنشاء محادثة جديدة");
                        final result =
                            await Get.toNamed(AppRoutes.createNewChat);
                        print(
                            "النتيجة المستلمة من صفحة إنشاء المحادثة: $result");
                        if (result != null &&
                            result is Map &&
                            result["updated"] == true) {
                          print("تم استقبال تحديث من صفحة إنشاء المحادثة");
                          await controller.loadChats();
                          controller.chats.refresh();
                          print("تم تحديث قائمة المحادثات بنجاح");
                          Get.snackbar(
                            "تم التحديث",
                            "تم تحديث قائمة المحادثات بنجاح",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.shade100,
                            colorText: Colors.green.shade800,
                            duration: const Duration(seconds: 1),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        } else {
                          print("لم يتم استقبال تحديث أو تم إلغاء العملية");
                        }
                        controller.toggleFabMenu();
                      },
                    ),
                  ),
                AnimatedOpacity(
                  opacity: controller.isScrolling.value ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: NeumorphicFloatingActionButton(
                    style: NeumorphicStyle(
                      color: _homeController.getPrimaryColor(),
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 4,
                      intensity: 0.3,
                    ),
                    child: Icon(
                      controller.showFabMenu.value
                          ? Icons.close
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.toggleFabMenu();
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, dynamic chat, Color textColor,
      Color secondaryTextColor, Color backgroundColor) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final ChatController controller = Get.find<ChatController>();
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
        onTap: () {
          print("#######################");
          print(chat.isBlocked);
          print("#######################");

          if (chat.isBlocked == 1) {
            Get.snackbar(
              "المستخدم محظور",
              "لا يمكنك الدردشة مع هذا المستخدم.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );
            return;
          }
          Get.to(() => ChatDetailPage(
                chatId: chat.id,
                isdarkMode: isDarkMode,
              ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Profile image with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        _homeController.getPrimaryColor().withOpacity(0.1),
                    backgroundImage:
                        chat.imageUrl != null && chat.imageUrl!.isNotEmpty
                            ? NetworkImage('${chat.imageUrl}')
                            : null,
                    child: chat.imageUrl == null || chat.imageUrl!.isEmpty
                        ? Text(
                            chat.name.isNotEmpty
                                ? chat.name[0].toUpperCase()
                                : '؟',
                            style: TextStyle(
                              color: _homeController.getPrimaryColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  if (chat.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
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
              // Chat details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
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
                          chat.lastMessageTime != null
                              ? _formatTime(chat.lastMessageTime!)
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
                            chat.lastMessage ?? 'لا توجد رسائل',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontStyle: chat.lastMessage == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _homeController.getPrimaryColor(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'متصل الآن';
      } else if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24 && dateTime.day == now.day) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day - 1) {
        return 'امس  ${DateFormat('hh:mm a').format(dateTime)}';
      } else if (difference.inDays < 2) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        final arabicNumbers = [
          '0',
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9'
        ];
        String toArabic(int number) {
          return number.toString().split('').map((digit) {
            return arabicNumbers[int.parse(digit)];
          }).join();
        }

        return '${toArabic(dateTime.year)}/${toArabic(dateTime.month)}/${toArabic(dateTime.day)}';
      }
    } catch (e) {
      // إزالة جزء الوقت من النص في حالة الخطأ
      final parts = dateTimeString.split(' ');
      return parts[0]; // نعيد الجزء الأول فقط (التاريخ بدون الوقت)
    }
  }
}

class ChatDetailPage extends StatelessWidget {
  final int chatId;
  final isdarkMode;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    this.isdarkMode = false,
  }) : super(key: key);

  Widget _buildBackgroundImage(BuildContext context, String assetImage) {
    final isDarkMode = isdarkMode;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetImage),
          fit: BoxFit.cover,
          // opacity: isDarkMode ? 0.15 : 0.1,
        ),
        // color: isDarkMode
        //     ? AppConstants.darkBackgroundColor
        //     : AppConstants.lightBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isdarkMode;
    final backgroundColor = Get.isDarkMode
        ? const Color.fromARGB(255, 16, 39, 53)
        : AppConstants.lightBackgroundColor;
    //.withOpacity(0.1); //AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final ChatController controller = Get.find<ChatController>();
    String assetImage = Get.isDarkMode
        ? 'assets/images/bg_theme/chat_bg_dark.png'
        : 'assets/images/bg_theme/chat_bg_light.png';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMessages(chatId);
    });
    final HomeController _homeController = Get.find<HomeController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: NeumorphicTheme(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: NeumorphicThemeData(
          baseColor: backgroundColor,
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
        child: Container(
          color: Get.isDarkMode
              ? AppConstants.lightBackgroundColor.withOpacity(0.3)
              : const Color.fromARGB(255, 213, 220, 228).withOpacity(0.8),
          child: SafeArea(
            child: WillPopScope(
              onWillPop: () async {
                //Get.toNamed(AppRoutes.chat);
                Get.back();
                // Get.offAll(
                //     () => ChatPage()); // Navigate to ChatPage and clear stack
                return false;
              },
              child: Scaffold(
                // backgroundColor: Colors.transparent, // تغيير لون الخلفية إلى شفاف
                appBar: NeumorphicApp_Bar(
                  color: backgroundColor,
                  title: Obx(() {
                    final chat = controller.chats.firstWhere(
                      (c) => c.id == chatId,
                      orElse: () => controller.chats.first,
                    );

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: _homeController
                              .getPrimaryColor()
                              .withOpacity(0.1),
                          backgroundImage: chat.imageUrl != null
                              ? NetworkImage(chat.imageUrl!)
                              : null,
                          child: chat.imageUrl == null
                              ? Text(
                                  chat.name.isNotEmpty
                                      ? chat.name[0].toUpperCase()
                                      : '',
                                  style: TextStyle(
                                    color: _homeController.getPrimaryColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (chat.isOnline)
                                Text(
                                  'متصل الآن',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  // leading: IconButton(
                  //   icon: Icon(Icons.arrow_back, color: textColor),
                  //   padding: const EdgeInsets.all(10),
                  //   onPressed: () => Get.back(),
                  // ),
                  actions: [
                    PopupMenuButton<String>(
                      padding: const EdgeInsets.all(8),
                      icon: Icon(
                        ico_plus.Bootstrap.three_dots_vertical,
                        size: 20,
                      ),
                      onSelected: (value) {
                        controller.isKeabordTap.value = false;
                        if (value == 'search') {
                          controller.searchText.value = ' ';
                        } else if (value == 'mute') {
                          // كتم الإشعارات
                        } else if (value == 'delete') {
                          // حذف المحادثة
                        } else if (value == 'block') {
                          controller.blockUser(chatId);
                          Get.back();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'search',
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(ico_plus.FontAwesome.searchengin_brand,
                                    color: _homeController.getPrimaryColor(),
                                    size: 20),
                                const SizedBox(width: 8),
                                Text('بحث في المحادثة'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'mute',
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(ico_plus.Bootstrap.bell_fill,
                                    color: _homeController.getPrimaryColor(),
                                    size: 20),
                                const SizedBox(width: 8),
                                Text('كتم الإشعارات'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(ico_plus.Bootstrap.trash,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text('مسح محتوى المحادثة',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'block',
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(ico_plus.Bootstrap.eye_slash,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text('حظر',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                      ],
                      constraints: BoxConstraints(maxWidth: 200),
                      offset: Offset(20, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      color: backgroundColor,
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    // الخلفية مع الصورة
                    _buildBackgroundImage(context, assetImage),

                    // محتوى الدردشة
                    Column(
                      children: [
                        Obx(() {
                          if (controller.searchText.isNotEmpty) {
                            return _buildSearchBar(context, controller);
                          }
                          return const SizedBox.shrink();
                        }),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return Lottie.asset(
                                    'assets/animations/loading_6.json');
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
                              return NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  if (scrollNotification
                                      is ScrollUpdateNotification) {
                                    controller.isScrolling.value = true;
                                    controller.lastScrollTime.value =
                                        DateTime.now();
                                  } else if (scrollNotification
                                      is ScrollEndNotification) {
                                    controller.isScrolling.value = false;
                                  }
                                  return true;
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ListView.builder(
                                      controller:
                                          controller.messagesScrollController,
                                      padding: const EdgeInsets.all(16),
                                      itemCount: controller.messages.length,
                                      itemBuilder: (context, index) {
                                        final message =
                                            controller.messages[index];
                                        final isMe = message.isMine;
                                        return MessageBubble(
                                          message: message,
                                          isMe: isMe,
                                          isdark: isDarkMode,
                                          onReply: (message) {
                                            controller.replyToMessage(message);
                                          },
                                          onForward: (message) {
                                            controller
                                                .showForwardDialog(message);
                                          },
                                          onDelete: (message) {
                                            controller.deleteMessage(message);
                                          },
                                        );
                                      },
                                    ),
                                    Obx(() => ScrollToBottomButton(
                                          isVisible: controller
                                                  .showScrollToBottomButton
                                                  .value &&
                                              !controller.isScrolling.value,
                                          onPressed: () =>
                                              controller.scrollToBottom(),
                                        )),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        Obx(() {
                          if (controller.isAttachmentSelected.value) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: backgroundColor.withOpacity(0.8),
                                border: Border(
                                  top: BorderSide(
                                    color: Get.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _buildAttachmentPreview(controller),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getAttachmentTypeText(controller
                                              .selectedFileType.value),
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
                                  IconButton(
                                    icon: Icon(ico_plus.Bootstrap.x_circle,
                                        color: textColor.withOpacity(0.7)),
                                    onPressed: controller.clearAttachment,
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: backgroundColor.withOpacity(0.9),
                            border: Border(
                              top: BorderSide(
                                color: Colors.transparent,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
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
                                  ico_plus.FontAwesome.paperclip_solid,
                                  color: textColor.withOpacity(0.7),
                                  size: 20,
                                ),
                                onPressed: () {
                                  controller.isKeabordTap.value = false;
                                  _showAttachmentOptions(context, controller);
                                  controller.isKeabordTap.value = false;
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Neumorphic(
                                  style: NeumorphicStyle(
                                    depth: -2,
                                    intensity: 0.7,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(20),
                                    ),
                                    color: Get.isDarkMode
                                        ? backgroundColor
                                        : AppColors.lightBackground,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            keyboardAppearance:
                                                Brightness.light,
                                            focusNode: FocusNode(
                                                canRequestFocus: controller
                                                    .isKeabordTap.value),
                                            onTap: () {
                                              controller.OpenKeabord();
                                            },
                                            controller:
                                                controller.messageController,
                                            decoration: InputDecoration(
                                              fillColor: Get.isDarkMode
                                                  ? Colors.transparent
                                                  : AppColors.lightBackground,
                                              hintText: 'اكتب رسالة...',
                                              hintStyle: TextStyle(
                                                color:
                                                    textColor.withOpacity(0.5),
                                                fontSize: 14,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              overflow: TextOverflow.ellipsis,
                                              color: textColor,
                                              fontSize: 14,
                                            ),
                                            maxLines: 5,
                                            minLines: 1,
                                            textDirection: TextDirection.rtl,
                                            onChanged: (value) {
                                              //controller.playKeySound();
                                              controller.changeText(value);
                                            },
                                          ),
                                        ),
                                        Obx(() {
                                          // الأيقونة التي ستعرض: إما لوحة المفاتيح، أو أيقونة متحركة، أو أيقونة ثابتة
                                          Widget iconToShow;
                                          int animationIconIndex =
                                              8; // فهرس الأيقونة التي نريدها متحركة (آخر أيقونة في القائمة)

                                          if (controller.isEmojiVisible.value) {
                                            // إذا كانت لوحة الإيموجي ظاهرة، اعرض أيقونة لوحة المفاتيح
                                            iconToShow = Icon(
                                              Icons.keyboard,
                                              color: textColor.withOpacity(0.7),
                                              size: 20,
                                            );
                                          } else if (controller
                                                  .currentEmojiIconIndex
                                                  .value ==
                                              animationIconIndex) {
                                            // إذا كان الدور على الأيقونة المتحركة، اعرض Lottie
                                            // تأكد من تعديل المسار لملف Lottie الصحيح
                                            iconToShow = Lottie.asset(
                                              'assets/animations/cool_emoji.json', // <-- تأكد من صحة المسار
                                              height:
                                                  30.h, // اضبط الحجم حسب الحاجة
                                              width: 30.w,
                                              repeat: true, // اجعلها تتكرر
                                            );
                                          } else {
                                            // وإلا، اعرض الأيقونة الثابتة من القائمة
                                            iconToShow = Icon(
                                              controller.emojiAnimationIcons[
                                                  controller
                                                      .currentEmojiIconIndex
                                                      .value],
                                              color: textColor.withOpacity(0.7),
                                              size: 20,
                                            );
                                          }

                                          return IconButton(
                                            icon:
                                                iconToShow, // استخدم الأيقونة المحددة
                                            onPressed: () => controller
                                                .toggleEmojiKeyboard(),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Obx(() {
                                final hasText = controller.isContainText.value;
                                final hasAttachment =
                                    controller.isAttachmentSelected.value;
                                final isRecording =
                                    controller.isRecording.value;
                                final hasEmoji =
                                    controller.isEmojiVisible.value;

                                if (hasText ||
                                    hasAttachment ||
                                    isRecording ||
                                    hasEmoji) {
                                  return NeumorphicButton(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.circle(),
                                      depth: 2,
                                      intensity: 0.4,
                                      color: Get.isDarkMode
                                          ? _homeController.getPrimaryColor()
                                          : const Color.fromARGB(
                                              255, 1, 124, 102),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: isRecording
                                        ? Icon(
                                            ico_plus.Bootstrap.stop_fill,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Icon(
                                            ico_plus.Bootstrap.send_fill,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                    onPressed: () {
                                      if (isRecording) {
                                        controller.stopRecording();
                                      } else {
                                        controller.sendMessage(chatId);
                                        controller.isKeabordTap.value = false;
                                      }
                                    },
                                  );
                                } else {
                                  return NeumorphicButton(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.circle(),
                                      depth: 2,
                                      intensity: 0.4,
                                      color: Get.isDarkMode
                                          ? _homeController.getPrimaryColor()
                                          : const Color.fromARGB(
                                              255, 1, 124, 102),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      ico_plus.Bootstrap.mic,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: controller.startRecording,
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                        Obx(() {
                          if (controller.isRecording.value) {
                            return _buildRecordingIndicator(
                                context, controller);
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    Obx(
                      () => controller.isEmojiVisible.value
                          ? Positioned(
                              bottom: kToolbarHeight,
                              left: 0,
                              right: 0,
                              child: EmojiPicker(
                                onEmojiSelected: (category, emoji) {
                                  controller.messageController.text +=
                                      emoji.emoji;
                                },
                                config: Config(
                                    // إعدادات حديثة
                                    skinToneConfig:
                                        const SkinToneConfig(enabled: true),
                                    categoryViewConfig:
                                        const CategoryViewConfig(
                                      backgroundColor: Color(0xFFF2F2F2),
                                      // showBackspaceButton: true,

                                      backspaceColor: Colors.red,
                                    ),
                                    emojiViewConfig: const EmojiViewConfig(
                                      columns: 9,
                                      emojiSizeMax: 32.0,
                                      backgroundColor: Color(0xFFF2F2F2),
                                    ),
                                    searchViewConfig: SearchViewConfig(
                                        backgroundColor: Colors.transparent)
                                    // swapCategoryAndBottomBar: false,
                                    ),
                              ))
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ChatController controller) {
    final isDarkMode = Get.isDarkMode; //.isUsingDark(context);
    final backgroundColor = Get.isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDarkMode ? Colors.grey.shade800 : Colors.transparent,
      child: Row(
        children: [
          // زر الإغلاق
          IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: controller.closeSearch,
          ),
          // نص نتائج البحث
          Obx(() {
            return Text(
              '${controller.currentSearchIndex.value + 1}/${controller.searchMessagesResults.length}',
              style: TextStyle(color: textColor),
            );
          }),
          SizedBox(width: 8),
          // أزرار التنقل
          IconButton(
            icon: Icon(Icons.arrow_upward, color: textColor),
            onPressed: () => controller.navigateSearchResult(false),
          ),
          IconButton(
            icon: Icon(Icons.arrow_downward, color: textColor),
            onPressed: () => controller.navigateSearchResult(true),
          ),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث في المحادثة...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              style: TextStyle(color: textColor),
              onChanged: controller.searchInMessages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator(
      BuildContext context, ChatController controller) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);

    return Container(
      padding: const EdgeInsets.all(8),
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Row(
        children: [
          // أيقونة التسجيل
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.red),
          ),
          const SizedBox(width: 8),
          // مؤشر الوقت
          Obx(() => Text(
                _formatDuration(Duration(
                    seconds: controller.recordingDuration.value.toInt())),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const Spacer(),
          // زر الإلغاء
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            onPressed: () => controller.cancelRecording(),
          ),
          // زر الإرسال
          TextButton.icon(
            icon: const Icon(Icons.send, color: Colors.green),
            label: const Text('إرسال', style: TextStyle(color: Colors.green)),
            onPressed: () => controller.stopRecording(),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showAttachmentOptions(BuildContext context, ChatController controller) {
    final isDarkMode = Get.isDarkMode;
    // NeumorphicTheme.isUsingDark(context);
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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إرفاق',
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
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.photo,
                  label: 'الصور',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.videocam,
                  label: 'فيديو',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickVideo();
                  },
                ),
                _buildAttachmentOption(
                  context: context,
                  icon: Icons.insert_drive_file,
                  label: 'ملف',
                  color: Colors.orange,
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

  // بناء خيار المرفق
  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    // final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final textColor = Get.isDarkMode ? Colors.white : Colors.black87;

    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // بناء معاينة المرفق
  Widget _buildAttachmentPreview(ChatController controller) {
    final fileType = controller.selectedFileType.value;

    if (fileType == 'image' && controller.selectedFile.value != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          controller.selectedFile.value!,
          fit: BoxFit.cover,
        ),
      );
    } else if (fileType == 'video') {
      return const Icon(Icons.video_library, size: 30);
    } else if (fileType == 'audio') {
      return const Icon(Icons.audiotrack, size: 30);
    } else {
      return const Icon(Icons.insert_drive_file, size: 30);
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
}
