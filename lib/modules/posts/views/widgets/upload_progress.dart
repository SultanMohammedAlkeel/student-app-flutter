import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class UploadProgressOverlay extends StatefulWidget {
  final double progress;
  final String fileName;
  final String fileType;
  final VoidCallback onCancel;
  final bool isUploading;

  const UploadProgressOverlay({
    Key? key,
    required this.progress,
    required this.fileName,
    required this.fileType,
    required this.onCancel,
    required this.isUploading,
  }) : super(key: key);

  @override
  State<UploadProgressOverlay> createState() => _UploadProgressOverlayState();
}

class _UploadProgressOverlayState extends State<UploadProgressOverlay> with SingleTickerProviderStateMixin {
  HomeController homeController = Get.find<HomeController>();

  late AnimationController _animationController;
  String _currentStage = 'تجهيز الملفات';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(UploadProgressOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // تحديث مرحلة الرفع بناءً على التقدم
    _updateStage();
  }
  
  void _updateStage() {
    final progress = widget.progress;
    
    if (progress < 0.2) {
      _currentStage = 'تجهيز الملفات';
    } else if (progress < 0.5) {
      _currentStage = 'ضغط الملفات';
    } else if (progress < 0.8) {
      _currentStage = 'رفع المحتوى';
    } else {
      _currentStage = 'معالجة المنشور';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isUploading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: widget.isUploading ? _buildUploadingContent() : const SizedBox(),
    );
  }
  
  Widget _buildUploadingContent() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عنوان الرفع
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: homeController.getPrimaryColor().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getFileTypeIcon(),
                      color: homeController.getPrimaryColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'جاري رفع المنشور',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.fileName,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // رسوم متحركة للرفع
              SizedBox(
                height: 100,
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/uploading.json',
                    height: 100,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cloud_upload,
                        size: 60,
                        color: homeController.getPrimaryColor().withOpacity(0.5),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // مرحلة الرفع الحالية
              Text(
                _currentStage,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: homeController.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // شريط التقدم
              Stack(
                children: [
                  // شريط التقدم
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 5),
              
              // نسبة التقدم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _getEstimatedTimeRemaining(),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // زر إلغاء الرفع
              NeumorphicButton(
                style: NeumorphicStyle(
                  depth: 2,
                  intensity: 0.7,
                  color: Colors.red.withOpacity(0.8),
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onPressed: widget.onCancel,
                child: const Text(
                  'إلغاء الرفع',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // الحصول على الوقت المتبقي التقديري
  String _getEstimatedTimeRemaining() {
    if (widget.progress < 0.05) {
      return 'جاري التقدير...';
    }
    
    final remainingProgress = 1.0 - widget.progress;
    int estimatedSeconds = (remainingProgress * 60).round(); // افتراض أن الرفع الكامل يستغرق دقيقة
    
    if (estimatedSeconds < 5) {
      return 'اكتمال خلال لحظات';
    } else if (estimatedSeconds < 60) {
      return 'متبقي $estimatedSeconds ثانية';
    } else {
      final minutes = (estimatedSeconds / 60).floor();
      final seconds = estimatedSeconds % 60;
      return 'متبقي $minutes:${seconds.toString().padLeft(2, '0')} دقيقة';
    }
  }
  
  // الحصول على أيقونة نوع الملف
  IconData _getFileTypeIcon() {
    switch (widget.fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
}
