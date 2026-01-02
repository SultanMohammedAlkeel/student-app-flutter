import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:icons_plus/icons_plus.dart' as ico_plus;
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'media_preview_controller.dart';

class AnimatedMediaPlaceholder extends StatefulWidget {
  final ChatMediaModel chatMedia;
  final MediaPreviewController controller;
  final VoidCallback onTap;
  final bool isdark;
  final Color? textColr;

  const AnimatedMediaPlaceholder({
    Key? key,
    required this.chatMedia,
    required this.controller,
    this.textColr,
    required this.onTap,
    this.isdark = false,
  }) : super(key: key);

  @override
  State<AnimatedMediaPlaceholder> createState() =>
      _AnimatedMediaPlaceholderState();
}

class _AnimatedMediaPlaceholderState extends State<AnimatedMediaPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MediaPreviewController _Mediacontroller = MediaPreviewController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 80, // تقليل الارتفاع ليتناسب مع مشغل الصوت الجديد
          minHeight: 80,
        ),
        child: _buildPlaceholderContent(widget.textColr!),
      ),
    );
  }

  Widget _buildPlaceholderContent(Color themecolor) {
    final String? fileUrl = widget.chatMedia.fileUrl;

    if (fileUrl == null) {
      return _buildDefaultPlaceholder();
    }

    // تحديد نوع الملف
    final String fileExtension = _getFileExtension(fileUrl).toLowerCase();

    // إذا كان الملف صورة
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(fileExtension)) {
      return _buildImagePlaceholder();
    }

    // إذا كان الملف فيديو
    if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(fileExtension)) {
      return _buildVideoPlaceholder(themecolor);
    }

    // إذا كان الملف صوتي
    if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(fileExtension)) {
      return _buildAudioPlaceholder(themecolor);
    }

    // أي نوع آخر من الملفات
    return _buildFilePlaceholder(fileExtension, themecolor);
  }

  Widget _buildDefaultPlaceholder() {
      final HomeController _homeController = Get.find<HomeController>();

    final Color textColor = widget.isdark ? Colors.white : Colors.black87;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _homeController.getPrimaryColor().withOpacity(0.7),
            _homeController.getPrimaryColor().withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة الملف
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textColor, // Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // نص الملف
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملف',
                  style: TextStyle(
                    color: textColor, // Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقر للتحميل',
                  style: TextStyle(
                    color: textColor, // Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة التحميل
          Icon(
            Icons.download,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final Color textColor = widget.isdark ? Colors.white : Colors.black87;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.6),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة الصورة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textColor, // Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image,
              color: textColor, // Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // نص الصورة
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صورة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقر لعرض الصورة',
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة العرض
          Icon(
            Icons.visibility,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(Color themecolor) {
    Color textColor =
        Get.isDarkMode ? Colors.white : const Color.fromARGB(221, 71, 68, 68);

    // final Color
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            Colors.transparent.withOpacity(0.3)
            // Colors.red.withOpacity(0.6),
            // Colors.red.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة الفيديو
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                  221, 71, 68, 68), // Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ico_plus.Bootstrap.play_circle_fill,
              // Icons.play_circle_fill,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // نص الفيديو
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فيديو',
                  style: TextStyle(
                    color:
                        textColor, // widget.isdark ? Colors.black : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقر لتشغيل الفيديو',
                  style: TextStyle(
                    color: textColor, // Colors.white,
                    //  widget.isdark
                    //     ? Colors.white
                    //     : Colors.black, // .fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة التشغيل
          Icon(
            ico_plus.FontAwesome.video_solid,
            // Icons.video_chat,
            color: textColor,
            // widget.isdark
            //     ? const Color.fromARGB(221, 9, 5, 5)
            //     : Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlaceholder(Color themecolor) {
    final Color textColor =
        Get.isDarkMode ? Colors.white : const Color.fromARGB(221, 96, 94, 94);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(195, 22, 23, 22).withOpacity(0.1),
            Color.fromARGB(255, 22, 35, 35).withOpacity(0.2)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // زر التشغيل/الإيقاف (على طراز واتساب)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                  221, 96, 94, 94), // Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ico_plus.FontAwesome.play_solid,
              // Icons.play_arrow,
              color: Colors.white,
              size: 15,
            ),
          ),

          const SizedBox(width: 12),

          // عرض الشكل الموجي والتقدم (على طراز واتساب)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الشكل الموجي للصوت
                Container(
                  height: 30,
                  child: _buildWaveformPlaceholder(),
                ),

                const SizedBox(
                  height: 9,
                  width: 10,
                ),

                // نص الملف الصوتي
                // Text(
                //   'انقر لتشغيل الملف الصوتي',
                //   style: TextStyle(
                //     color: widget.isdark
                //         ? Color.fromRGBO(255, 255, 255, 1)
                //         : NeumorphicColors.defaultTextColor,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(
            height: 60.h,
          ),
          Icon(
            ico_plus.Bootstrap.music_note,
            // Icons.music_note_sharp,
            color: textColor, // : Colors.black,
            // Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformPlaceholder() {
    final Color textColor =
        widget.isdark ? Colors.white : Color.fromARGB(221, 92, 92, 92);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 30),
          painter: WaveformPlaceholderPainter(
            color: textColor, // Colors.white.withOpacity(0.5),
            progress: _animation.value,
          ),
        );
      },
    );
  }

  Widget _buildFilePlaceholder(String fileExtension, Color themecolor) {
    final Color textColor =
        Get.isDarkMode ? Colors.white : const Color.fromARGB(221, 96, 94, 94);
    final Color fileColor = _getFileColor(fileExtension);
    final IconData fileIcon = _getFileIcon(fileExtension);
    final IconData file_optionIcon = _getFileIconOpetion(fileExtension);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fileColor.withOpacity(0.6),
            fileColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة الملف
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? Colors.black12
                  : Colors
                      .transparent, // const Color.fromARGB(221, 172, 166, 166),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fileIcon,
              color: textColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // نص الملف
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileExtension.toUpperCase(),
                  style: TextStyle(
                    color: textColor, // Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقر لفتح الملف',
                  style: TextStyle(
                    color: textColor, // Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة الفتح
          Icon(
            file_optionIcon,

            // ico_plus.Bootstrap.file_earmark_pdf_fill,
            color: textColor, // Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  // الحصول على امتداد الملف
  String _getFileExtension(String fileUrl) {
    final parts = fileUrl.split('.');
    if (parts.length > 1) {
      return parts.last;
    }
    return '';
  }

  IconData _getFileIconOpetion(String fileExtension) {
    if (['pdf'].contains(fileExtension)) {
      return ico_plus.FontAwesome.file_pdf_solid;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return ico_plus.FontAwesome.file_word_solid;
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return ico_plus.FontAwesome.file_excel_solid;
    } else if (['ppt', 'pptx'].contains(fileExtension)) {
      return ico_plus.FontAwesome.file_powerpoint_solid;
    } else if (['zip', 'rar', '7z'].contains(fileExtension)) {
      return ico_plus.FontAwesome.file_zipper_solid;
    } else if (['txt', 'rtf'].contains(fileExtension)) {
      return ico_plus.Bootstrap.file_text;
    } else {
      return ico_plus.FontAwesome.file_solid;
    }
  }

  // الحصول على أيقونة الملف
  IconData _getFileIcon(String fileExtension) {
    if (['pdf'].contains(fileExtension)) {
      return ico_plus.Bootstrap.filetype_pdf; // .picture_as_pdf;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return ico_plus.Bootstrap.filetype_doc; //Icons.description;
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return ico_plus.Bootstrap.filetype_xlsx; //Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(fileExtension)) {
      return ico_plus.Bootstrap.filetype_pptx; //Icons.slideshow;
    } else if (['zip', 'rar', '7z'].contains(fileExtension)) {
      return ico_plus.Bootstrap.file_zip; //Icons.folder_zip;
    } else if (['txt', 'rtf'].contains(fileExtension)) {
      return ico_plus.Bootstrap.filetype_txt; //Icons.text_snippet;
    } else {
      return ico_plus.FontAwesome.file_solid; //Icons.insert_drive_file;
    }
  }

  // الحصول على لون الملف
  Color _getFileColor(String fileExtension) {
      final HomeController _homeController = Get.find<HomeController>();

    if (['pdf'].contains(fileExtension)) {
      return Colors.red;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return Colors.blue;
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return Colors.green;
    } else if (['ppt', 'pptx'].contains(fileExtension)) {
      return Colors.orange;
    } else if (['zip', 'rar', '7z'].contains(fileExtension)) {
      return Colors.purple;
    } else if (['txt', 'rtf'].contains(fileExtension)) {
      return Colors.teal;
    } else {
      return _homeController.getPrimaryColor();
    }
  }
}

// رسام الشكل الموجي للصوت (محاكاة لشكل واتساب)
class WaveformPlaceholderPainter extends CustomPainter {
  final Color color;
  final double progress;

  WaveformPlaceholderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 3.0;
    final space = 2.0;
    final barCount = (size.width / (barWidth + space)).floor();

    // إنشاء ارتفاعات عشوائية للأشرطة لمحاكاة الشكل الموجي
    for (int i = 0; i < barCount; i++) {
      // استخدام دالة جيب لإنشاء نمط موجي أكثر طبيعية
      final normalizedPosition = i / barCount;

      // تعديل الارتفاع ليكون متحركاً
      final amplitude =
          0.4 + 0.6 * (0.5 + 0.5 * sin(normalizedPosition * 10 + progress * 5));

      final height = size.height * amplitude;
      final left = i * (barWidth + space);

      final top = (size.height - height) / 2;
      final bottom = top + height;

      canvas.drawLine(
        Offset(left + barWidth / 2, top),
        Offset(left + barWidth / 2, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPlaceholderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}
