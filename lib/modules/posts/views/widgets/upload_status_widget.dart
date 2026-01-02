import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';

import '../../../home/controllers/home_controller.dart';

class RealUploadProgressOverlay extends StatefulWidget {
  final double progress;
  final String fileName;
  final String fileType;
  final VoidCallback onCancel;
  final bool isUploading;
  final String currentStage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const RealUploadProgressOverlay({
    Key? key,
    required this.progress,
    required this.fileName,
    required this.fileType,
    required this.onCancel,
    required this.isUploading,
    required this.currentStage,
    this.errorMessage,
    this.onRetry,
    this.isRetrying = false,
  }) : super(key: key);

  @override
  State<RealUploadProgressOverlay> createState() =>
      _RealUploadProgressOverlayState();
}

class _RealUploadProgressOverlayState extends State<RealUploadProgressOverlay>
    with SingleTickerProviderStateMixin {
  HomeController homeController = Get.find<HomeController>();

  late AnimationController _animationController;

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
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isUploading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: widget.isUploading ? _buildUploadingContent() : const SizedBox(),
    );
  }

  Widget _buildUploadingContent() {
    final bool hasError =
        widget.errorMessage != null && widget.errorMessage!.isNotEmpty;

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
                      color: hasError
                          ? Colors.red.withOpacity(0.1)
                          : homeController.getPrimaryColor().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasError ? Icons.error_outline : _getFileTypeIcon(),
                      color: hasError
                          ? Colors.red
                          : homeController.getPrimaryColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasError ? 'خطأ في الرفع' : 'جاري رفع المنشور',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: hasError ? Colors.red : Colors.black87,
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

              // رسوم متحركة للرفع أو رسالة الخطأ
              if (hasError) _buildErrorContent() else _buildProgressContent(),

              const SizedBox(height: 20),

              // أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasError && widget.onRetry != null)
                    Expanded(
                      child: NeumorphicButton(
                        style: NeumorphicStyle(
                          depth: 2,
                          intensity: 0.7,
                          color: homeController.getPrimaryColor(),
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(10)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: widget.isRetrying ? null : widget.onRetry,
                        child: Center(
                          child: widget.isRetrying
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (hasError && widget.onRetry != null)
                    const SizedBox(width: 10),
                  Expanded(
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        depth: 2,
                        intensity: 0.7,
                        color: hasError
                            ? Colors.grey[300]
                            : Colors.red.withOpacity(0.8),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: widget.onCancel,
                      child: Center(
                        child: Text(
                          hasError ? 'إغلاق' : 'إلغاء الرفع',
                          style: TextStyle(
                            color: hasError ? Colors.black87 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.red.withOpacity(0.8),
        ),
        const SizedBox(height: 15),
        Text(
          widget.errorMessage ?? 'حدث خطأ أثناء رفع الملف',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'يمكنك إعادة المحاولة أو إلغاء الرفع',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressContent() {
    return Column(
      children: [
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

        const SizedBox(height: 15),

        // مرحلة الرفع الحالية
        Text(
          widget.currentStage,
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    homeController.getPrimaryColor()),
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
      ],
    );
  }

  // الحصول على الوقت المتبقي التقديري
  String _getEstimatedTimeRemaining() {
    if (widget.progress < 0.05) {
      return 'جاري التقدير...';
    }

    final remainingProgress = 1.0 - widget.progress;
    int estimatedSeconds =
        (remainingProgress * 60).round(); // افتراض أن الرفع الكامل يستغرق دقيقة

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
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.table_chart;
      case 'powerpoint':
        return Icons.slideshow;
      case 'archive':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
// import 'package:get/get.dart';
// import 'package:student_app/core/themes/colors.dart';
// import 'package:lottie/lottie.dart';

// import '../../controllers/posts_controller.dart';

// class UploadStatusWidget extends StatelessWidget {
//   final String fileId;
//   final String fileName;
//   final IconData fileIcon;
//   final PostsController controller;

//   const UploadStatusWidget({
//     Key? key,
//     required this.fileId,
//     required this.fileName,
//     required this.fileIcon,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final progress = controller.getFileUploadProgress(fileId);
//       final isUploading = controller.isFileUploading(fileId);
//       final isUploaded = controller.isFileUploaded(fileId);
//       final isFailed = controller.isFileUploadFailed(fileId);

//       return AnimatedContainer(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//         margin: const EdgeInsets.symmetric(vertical: 5),
//         decoration: BoxDecoration(
//           color: _getBackgroundColor(isUploading, isUploaded, isFailed),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               _buildStatusIcon(isUploading, isUploaded, isFailed),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       fileName,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: controller.textColor,
//                         fontFamily: 'Tajawal',
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 5),
//                     if (isUploading) ...[
//                       LinearProgressIndicator(
//                         value: progress,
//                         backgroundColor: Colors.grey[300],
//                         valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                         '${(progress * 100).toInt()}% مكتمل',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: controller.secondaryTextColor,
//                           fontFamily: 'Tajawal',
//                         ),
//                       ),
//                     ] else if (isUploaded) ...[
//                       Text(
//                         'تم الرفع بنجاح',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.green,
//                           fontFamily: 'Tajawal',
//                         ),
//                       ),
//                     ] else if (isFailed) ...[
//                       Text(
//                         'فشل الرفع',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.red,
//                           fontFamily: 'Tajawal',
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       GestureDetector(
//                         onTap: () {
//                           // إعادة محاولة الرفع
//                         },
//                         child: Text(
//                           'إعادة المحاولة',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: homeController.getPrimaryColor(),
//                             decoration: TextDecoration.underline,
//                             fontFamily: 'Tajawal',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               if (isUploaded)
//                 Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                 ),
//               if (isFailed)
//                 Icon(
//                   Icons.error,
//                   color: Colors.red,
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildStatusIcon(bool isUploading, bool isUploaded, bool isFailed) {
//     if (isUploading) {
//       return SizedBox(
//         width: 30,
//         height: 30,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
//         ),
//       );
//     } else if (isUploaded) {
//       return Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: Colors.green.withOpacity(0.2),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           fileIcon,
//           color: Colors.green,
//           size: 18,
//         ),
//       );
//     } else if (isFailed) {
//       return Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: Colors.red.withOpacity(0.2),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           fileIcon,
//           color: Colors.red,
//           size: 18,
//         ),
//       );
//     } else {
//       return Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: homeController.getPrimaryColor().withOpacity(0.2),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           fileIcon,
//           color: homeController.getPrimaryColor(),
//           size: 18,
//         ),
//       );
//     }
//   }

//   Color _getBackgroundColor(bool isUploading, bool isUploaded, bool isFailed) {
//     if (isUploaded) {
//       return Colors.green.withOpacity(0.1);
//     } else if (isFailed) {
//       return Colors.red.withOpacity(0.1);
//     } else {
//       return Get.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
//     }
//   }
// }

// class UploadSuccessAnimation extends StatelessWidget {
//   final VoidCallback onAnimationComplete;

//   const UploadSuccessAnimation({
//     Key? key,
//     required this.onAnimationComplete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black.withOpacity(0.5),
//       child: Center(
//         child: Container(
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset(
//                 'assets/animations/upload_success.json',
//                 width: 120,
//                 height: 120,
//                 repeat: false,
//                 onLoaded: (composition) {
//                   Future.delayed(composition.duration, () {
//                     onAnimationComplete();
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'تم النشر بنجاح!',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class UploadingBottomSheet extends StatelessWidget {
//   final PostsController controller;

//   const UploadingBottomSheet({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: controller.cardColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.cloud_upload,
//                 color: homeController.getPrimaryColor(),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 'جاري رفع المنشور...',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: controller.textColor,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Get.back(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Obx(() {
//             final totalFiles = controller.uploadingFiles.length + 
//                               controller.uploadedFiles.length + 
//                               controller.failedUploads.length;
            
//             final completedFiles = controller.uploadedFiles.length;
//             final progress = totalFiles > 0 ? completedFiles / totalFiles : 0.0;
            
//             return Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'التقدم الكلي',
//                       style: TextStyle(
//                         color: controller.textColor,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                     Text(
//                       '${(progress * 100).toInt()}%',
//                       style: TextStyle(
//                         color: homeController.getPrimaryColor(),
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: Colors.grey[300],
//                     valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
//                     minHeight: 10,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'تفاصيل الرفع',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: controller.textColor,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // هنا يمكن إضافة قائمة بالملفات التي يتم رفعها
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
