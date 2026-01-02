import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/models/post_model.dart';

import '../../../home/controllers/home_controller.dart';
import '../../controllers/media_preview_controller.dart';

class AnimatedMediaPlaceholder extends StatefulWidget {
  final Post post;
  final MediaPreviewController controller;
  final VoidCallback onTap;

  const AnimatedMediaPlaceholder({
    Key? key,
    required this.post,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedMediaPlaceholder> createState() => _AnimatedMediaPlaceholderState();
}

class _AnimatedMediaPlaceholderState extends State<AnimatedMediaPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
          maxHeight: 250,
          minHeight: 120,
        ),
        child: _buildPlaceholderContent(),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    final String? fileUrl = widget.post.fileUrl;

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
      return _buildVideoPlaceholder();
    }

    // إذا كان الملف صوتي
    if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(fileExtension)) {
      return _buildAudioPlaceholder();
    }

    // أي نوع آخر من الملفات
    return _buildFilePlaceholder(fileExtension);
  }

  Widget _buildDefaultPlaceholder() {
      HomeController homeController = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            homeController.getPrimaryColor().withOpacity(0.5),
            homeController.getPrimaryColor().withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.insert_drive_file,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
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
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          _buildWaveAnimation(Colors.white.withOpacity(0.2)),
          
          // أيقونة الصورة
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'صورة',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // زر التشغيل
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.6),
            Colors.red.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          _buildWaveAnimation(Colors.white.withOpacity(0.2)),
          
          // أيقونة الفيديو
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.movie,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'فيديو',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // زر التشغيل
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlaceholder() {
      HomeController homeController = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            homeController.getPrimaryColor().withOpacity(0.7),
            homeController.getPrimaryColor().withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          _buildWaveAnimation(Colors.white.withOpacity(0.2)),
          
          // أيقونة الصوت
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.audiotrack,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'ملف صوتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // زر التشغيل
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePlaceholder(String fileExtension) {
    final Color fileColor = _getFileColor(fileExtension);
    
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
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          _buildWaveAnimation(Colors.white.withOpacity(0.1)),
          
          // أيقونة الملف
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFileIcon(fileExtension),
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fileExtension.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // زر التشغيل
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveAnimation(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            color: color,
            amplitude: 20 * _animation.value,
            frequency: 0.5,
            phase: _animationController.value * 2 * 3.14159,
          ),
          child: Container(),
        );
      },
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

  // الحصول على أيقونة الملف
  IconData _getFileIcon(String fileExtension) {
    if (['pdf'].contains(fileExtension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(fileExtension)) {
      return Icons.slideshow;
    } else if (['zip', 'rar', '7z'].contains(fileExtension)) {
      return Icons.folder_zip;
    } else if (['txt', 'rtf'].contains(fileExtension)) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // الحصول على لون الملف
  Color _getFileColor(String fileExtension) {
      HomeController homeController = Get.find<HomeController>();

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
      return homeController.getPrimaryColor();
    }
  }
}

// رسام الموجات المتحركة
class WavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;

  WavePainter({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = 0; x < size.width; x++) {
      final y = size.height / 2 + amplitude * sin(frequency * x + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.amplitude != amplitude ||
      oldDelegate.frequency != frequency ||
      oldDelegate.color != color;
}
