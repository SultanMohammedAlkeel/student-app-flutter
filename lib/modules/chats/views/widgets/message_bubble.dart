import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart' as ico_plus;
import 'package:lottie/lottie.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/constants/chat_constants.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/chats/models/message_model.dart';
import 'package:student_app/modules/chats/views/widgets/media_preview.dart';
import 'package:student_app/modules/chats/views/widgets/media_preview_controller.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final Color? color;
  final Function(MessageModel)? onReply;
  final Function(MessageModel)? onForward;
  final Function(MessageModel)? onDelete;
  // ignore: prefer_typing_uninitialized_variables
  final isdark;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.isdark = false,
    this.color,
    this.onReply,
    this.onForward,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  final MediaPreviewController _mediaController = MediaPreviewController();

  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.fileUrl != null) {
      _initializeMediaController();
    }
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  void _initializeMediaController() {
    final chat = ChatMediaModel(
      id: widget.message.id,
      fileUrl: widget.message.fileUrl,
      fileType: _getFileTypeFromUrl(widget.message.fileUrl ?? ''),
      fileSize: null,
    );
    _mediaController.setChat(chat);
  }

  String _getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp']
        .contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isdark; //NeumorphicTheme.isUsingDark(context);
    final ChatController controller = Get.find<ChatController>();

    final isSearchResult = controller.searchText.isNotEmpty &&
        widget.message.content
            .toLowerCase()
            .contains(controller.searchText.value.toLowerCase());
    // الألوان الأصلية
    final myMessageBubbleColor = isDarkMode
        ? ChatConstants.senderBubbleDark
        : const Color.fromARGB(243, 255, 255, 255);

    // const Color.fromARGB(177, 144, 255, 188);

    final receiverBubbleColor = isDarkMode
        ? ChatConstants.receiverBubbleDark
        : ChatConstants.senderBubbleLight;

    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final bool hasMedia = widget.message.fileUrl != null;
    final bool isEmptyMessage = widget.message.content.trim().isEmpty;

    return GestureDetector(
      onLongPress: () {
        print("Long press detected"); // للتأكد من استدعاء الحدث
        setState(() {
          _showOptions = true;
        });
        _showMessageOptions(context);
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && widget.onReply != null) {
          widget.onReply!(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
          color: Colors.transparent,
          shadowColor: widget.isMe ? myMessageBubbleColor : receiverBubbleColor,
          child: InkWell(
            onLongPress: () {
              print("Inner long press detected"); // للتأكد من استدعاء الحدث
              setState(() {
                _showOptions = true;
              });
              controller.isKeabordTap.value = false;
              _showMessageOptions(context);
            },
            child: ChatBubble(
              shadowColor: Colors.transparent,
              clipper: ChatBubbleClipper9(
                type: widget.isMe
                    ? BubbleType.receiverBubble
                    : BubbleType.sendBubble,
              ),
              alignment: widget.isMe ? Alignment.topLeft : Alignment.topRight,
              margin: const EdgeInsets.only(top: 5),
              backGroundColor: isSearchResult.obs.value
                  ? Colors.yellow.withOpacity(0.3)
                  : widget.isMe
                      ? myMessageBubbleColor
                      : receiverBubbleColor,
              child: Container(
                constraints: BoxConstraints(
                  // تعديل حجم الفقاعة بناءً على محتوى الرسالة
                  maxWidth: hasMedia
                      ? MediaQuery.of(context).size.width * 0.7
                      : _isLongText(widget.message.content.trim())
                          ? MediaQuery.of(context).size.width * 0.7
                          : widget.message.content.trim().length < 10
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.width * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض الوسائط أولاً (إذا كانت موجودة)
                    if (hasMedia) _buildMediaContentInline(context),

                    // إضافة مساحة بين الوسائط والنص إذا كان هناك محتوى نصي ووسائط
                    if (!isEmptyMessage && hasMedia) const SizedBox(height: 9),

                    // نص الرسالة (إذا كان موجودًا)
                    if (!isEmptyMessage)
                      Container(
                        width: double.infinity,
                        child: Text(
                          _isLongText(widget.message.content.trim())
                              ? '\t\n${widget.message.content.trim()}'
                              : widget.message.content.trim(),
                          style: TextStyle(
                            color: textColor,
                            fontSize:
                                _getTextSize(widget.message.content.trim()),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                    // الوقت وعلامة القراءة

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // الوقت وعلامة القراءة (في الشمال)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (hasMedia)
                              SizedBox(
                                height: 10,
                              ),
                            Text(
                              '${widget.message.createdAt.hour}:${widget.message.createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            if (widget.isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                widget.message.isRead
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 12,
                                color: widget.message.isRead
                                    ? Colors.blue
                                    : textColor.withOpacity(0.7),
                              ),
                            ],
                          ],
                        ),
                        // مساحة فارغة للمحاذاة (يمكن إضافة عناصر أخرى هنا إذا لزم الأمر)
                        // const SizedBox(width: 50),
                      ],
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

  double _getTextSize(String message) {
    if (message.length < 10 || message.length < 20) {
      return 16.0;
    } else if (message.length < 30) {
      return 14.0;
    } else {
      return 13.0;
    }
  }

  bool _isLongText(String message) {
    bool signal = false;
    if (message.length > 50) {
      signal = true;
    } else {
      signal = false;
    }
    return signal;
  }

  // فتح الصورة بالحجم الكامل
  void _openFullSizeImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title:
                const Text('عرض الصورة', style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'فشل تحميل الصورة',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    final isDarkMode = widget.isdark; // NeumorphicTheme.isUsingDark(context);
    _mediaController.isDarkOrLight(isDarkMode);
    final myMessageBubbleColor = isDarkMode
        ? ChatConstants.senderBubbleDark
        : ChatConstants.receiverBubbleLight;

    // const Color.fromARGB(177, 144, 255, 188);

    final receiverBubbleColor = isDarkMode
        ? ChatConstants.receiverBubbleDark
        : ChatConstants.senderBubbleLight;

    final String fileUrl = widget.message.fileUrl!;
    final String fileType = _getFileTypeFromUrl(fileUrl);

    return ChatBubble(
      clipper: ChatBubbleClipper10(
        type: widget.isMe ? BubbleType.sendBubble : BubbleType.receiverBubble,
      ),
      alignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
      margin: const EdgeInsets.only(top: 10),
      backGroundColor: widget.isMe ? myMessageBubbleColor : receiverBubbleColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment:
              widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (fileType != 'image')
              MediaPreview(
                textCol: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black87.withOpacity(0.7),
                chat: ChatMediaModel(
                  id: widget.message.id,
                  fileUrl: fileUrl,
                ),
                isdarkMode: widget.isdark,
              )
            else
              GestureDetector(
                onTap: () => _openFullSizeImage(context, fileUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: 400.w, // حجم ثابت للعرض
                    height: 200.h, // حجم ثابت للارتفاع
                    child: Image.network(
                      fileUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.message.createdAt.hour}:${widget.message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black87.withOpacity(0.7),
                    ),
                  ),
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      widget.message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: widget.message.isRead
                          ? Colors.blue
                          : isDarkMode
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black87.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة جديدة لعرض الوسائط داخل فقاعة واحدة مع النص
  Widget _buildMediaContentInline(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final String fileUrl = widget.message.fileUrl!;
    final String fileType = _getFileTypeFromUrl(fileUrl);

    if (fileType != 'image') {
      return MediaPreview(
          chat: ChatMediaModel(id: widget.message.id, fileUrl: fileUrl));
    } else {
      return GestureDetector(
        onTap: () => _openFullSizeImage(context, fileUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: 400.w, // حجم ثابت للعرض
            height: 200.h, // حجم ثابت للارتفاع
            child: Image.network(
              fileUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  // عرض مربع حوار تأكيد الحذف
  void _showDeleteConfirmation(BuildContext context) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor
        : AppConstants.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'تأكيد الحذف',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Lottie.asset(
            'assets/animations/delete_warning.json',
            height: 50.h,
            width: 50.w,
          ),
          content: Text(
            'هل أنت متأكد من حذف هذه الرسالة؟',
            style: TextStyle(
              color: textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق مربع الحوار
              },
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق مربع الحوار التأكيدي

                // عرض رسوم متحركة Lottie في نافذة منبثقة
                _showDeleteAnimation(context, () {
                  // استدعاء دالة الحذف بعد انتهاء الرسوم المتحركة
                  if (widget.onDelete != null) {
                    widget.onDelete!(widget.message);
                  }
                });
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة جديدة لعرض رسوم متحركة Lottie بعد تأكيد الحذف
  void _showDeleteAnimation(
      BuildContext context, VoidCallback onAnimationComplete) {
    final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor = isDarkMode
        ? AppConstants.darkBackgroundColor.withOpacity(0.9)
        : AppConstants.lightBackgroundColor.withOpacity(0.9);

    // إنشاء مؤقت لإغلاق النافذة المنبثقة تلقائيًا بعد انتهاء الرسوم المتحركة
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق النافذة المنبثقة بالنقر خارجها
      builder: (BuildContext context) {
        // إنشاء مؤقت لإغلاق النافذة المنبثقة تلقائيًا بعد انتهاء الرسوم المتحركة
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop(); // إغلاق النافذة المنبثقة
          onAnimationComplete(); // استدعاء دالة الحذف بعد إغلاق النافذة المنبثقة
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // استخدام Lottie لعرض الرسوم المتحركة
                Lottie.asset(
                  'assets/animations/delete_success.json', // مسار ملف الرسوم المتحركة
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  repeat: false, // عدم تكرار الرسوم المتحركة
                ),
                SizedBox(height: 16),
                Text(
                  'تم الحذف بنجاح',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessageOptions(BuildContext context) {
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
            _buildOptionItem(
              icon: Icons.reply,
              label: 'الرد',
              onTap: () {
                Navigator.pop(context);
                if (widget.onReply != null) {
                  widget.onReply!(widget.message);
                }
              },
            ),
            _buildOptionItem(
              icon: Icons.forward,
              label: 'توجيه',
              onTap: () {
                Navigator.pop(context);
                if (widget.onForward != null) {
                  widget.onForward!(widget.message);
                }
              },
            ),
            _buildOptionItem(
              icon: Icons.content_copy,
              label: 'نسخ',
              onTap: () {
                Navigator.pop(context);
                if (widget.message.content.isNotEmpty) {
                  Clipboard.setData(
                      ClipboardData(text: widget.message.content));
                  Get.snackbar(
                    messageText: Lottie.asset(
                      'assets/animations/upload_success.json',
                      height: 40.h,
                      width: 40.w,
                      fit: BoxFit.contain,
                      repeat: false, // عدم تكرار الرسوم المتحركة
                    ),
                    titleText: Text(
                      'تم النسخ',
                      textAlign: TextAlign.center,
                    ),
                    widget.message.id.toString(),
                    'تم نسخ محتوى الرسالة',
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
            ),
            if (widget.isMe)
              _buildOptionItem(
                icon: Icons.delete,
                label: 'حذف',
                onTap: () {
                  Navigator.pop(context); // إغلاق قائمة الخيارات
                  _showDeleteConfirmation(context); // عرض مربع حوار تأكيد الحذف
                },
                isDestructive: true,
              ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _showOptions = false;
      });
    });
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
      final HomeController _homeController = Get.find<HomeController>();

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : _homeController.getPrimaryColor(),
      ),
      title: Text(
        label,
        style: TextStyle(
            color: isDestructive
                ? Colors.red
                : Get.isDarkMode
                    ? Colors.white
                    : Colors.black
            // : Colors.white,
            ),
      ),
      onTap: onTap,
    );
  }
}
