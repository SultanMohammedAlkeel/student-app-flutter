import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'dart:io';
import '../media_preview_controller.dart';
import 'package:icons_plus/icons_plus.dart' as ico_plus;

class ChatFilePlayer extends StatefulWidget {
  final ChatMediaModel media;
  final String fileUrl;
  final MediaPreviewController controller;
  final bool showControls;
  final bool isVisible;

  const ChatFilePlayer({
    Key? key,
    required this.media,
    required this.fileUrl,
    required this.controller,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<ChatFilePlayer> createState() => _FilePlayerState();
}

class _FilePlayerState extends State<ChatFilePlayer>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;
  bool _isFileReady = false;
  bool _showActions = false;

  // متغيرات للرسوم المتحركة
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // بدء تشغيل الرسوم المتحركة
    _animationController.repeat(reverse: true);

    _loadFile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatFilePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغير الرابط، إعادة تحميل الملف
    if (oldWidget.fileUrl != widget.fileUrl) {
      _loadFile();
    }
  }

  // تحميل الملف
  Future<void> _loadFile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isFileReady = false;
      _loadingProgress = 0.0;
    });

    widget.controller.setLoading(true);

    try {
      // محاكاة تقدم التحميل
      _simulateLoadingProgress();

      // محاولة تحميل الملف من الكاش أولاً
      final cachedPath = await widget.controller.loadFile(widget.fileUrl);

      if (!mounted) return;

      setState(() {
        _isFileReady = true;
        _isLoading = false;
        _loadingProgress = 1.0;
      });

      widget.controller.setInitialized(true);
      widget.controller.setLoading(false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFileReady = false;
        _isLoading = false;
        _hasError = true;
        _loadingProgress = 0.0;
      });

      widget.controller.setLoading(false);
      widget.controller.setError(true);
      widget.controller.showErrorMessage('فشل في تحميل الملف: ${e.toString()}');
    }
  }

  // محاكاة تقدم التحميل
  void _simulateLoadingProgress() {
    Future.doWhile(() async {
      if (!mounted || !_isLoading) return false;

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted || !_isLoading) return false;

      setState(() {
        _loadingProgress = _loadingProgress + 0.01;
        if (_loadingProgress > 0.95) {
          _loadingProgress = 0.95;
        }
      });

      return _isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    // تعديل الارتفاع الأقصى بناءً على حالة عرض الإجراءات
    final double maxHeight = _showActions ? 130 : 120;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: maxHeight.h, // ارتفاع ديناميكي بناءً على حالة عرض الإجراءات
        minHeight: 80, // ضمان ارتفاع أدنى
      ),
      child: _buildFileContent(),
    );
  }

  Widget _buildFileContent() {
    final Color fileColor = _getFileColor();

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                fileColor.withOpacity(0.6),
                fileColor.withOpacity(0.3),
              ]),
          //color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _getFileColor().withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getFileColor().withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.only(top: 5, right: 5),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // تقليل حجم العمود للحد الأدنى المطلوب
          children: [
            // معلومات الملف
            Row(
              children: [
                // أيقونة الملف
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: _getFileColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getFileIcon(),
                      color: Colors.white, //_getFileColor(),
                      size: 24,
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // معلومات الملف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // اسم الملف
                      Text(
                        _getFileName(),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getFileColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // حجم الملف (إذا كان متوفراً)
                          if (widget.media.fileSize != null)
                            Text(
                              _formatFileSize(widget.media.fileSize!),
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),

                // زر الإجراءات الرئيسي
                IconButton(
                  icon: Icon(
                    _showActions
                        ? ico_plus.FontAwesome.xmark_solid
                        : ico_plus.FontAwesome.ellipsis_vertical_solid,
                    //Icons.close : Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _showActions = !_showActions;
                    });
                  },
                  padding: EdgeInsets.zero, // تقليل الحشو لتوفير المساحة
                  constraints: BoxConstraints.tightFor(
                      width: 30.w, height: 33.h), // تقليل حجم الزر
                ),
              ],
            ),

            // أزرار الإجراءات (تظهر/تختفي بناءً على حالة _showActions)
            if (_showActions)
              Padding(
                padding: const EdgeInsets.only(top: 10), // تقليل الحشو العلوي
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionIconButton(
                      icon:
                          ico_plus.Bootstrap.download, //Icons.download_rounded,
                      label: 'تحميل',
                      onPressed: () => widget.controller.downloadFile(),
                    ),
                    _buildActionIconButton(
                      icon: ico_plus.Bootstrap.box_arrow_up_left,
                      //Icons.open_in_new_rounded,
                      label: 'فتح',
                      onPressed: () => widget.controller.openFileExternally(),
                    ),
                    _buildActionIconButton(
                      icon: Icons.share_rounded,
                      label: 'مشاركة',
                      onPressed: () => widget.controller.shareFile(),
                    ),
                    _buildActionIconButton(
                      icon: ico_plus.Bootstrap.info_circle_fill,
                      //Icons.info_outline_rounded,
                      label: 'معلومات',
                      onPressed: () => _showFileInfo(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 6, vertical: 2), // تقليل الحشو
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white, // _getFileColor(),
              size: 20,
            ),
            const SizedBox(height: 2), // تقليل المسافة
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11, // تقليل حجم الخط
                color: Colors.white, // _getFileColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // أيقونة الملف
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getFileColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getFileIcon(),
                color: _getFileColor().withOpacity(0.5),
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // معلومات التحميل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'جاري تحميل الملف...',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getFileColor()),
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // أيقونة الخطأ
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // رسالة الخطأ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'حدث خطأ أثناء تحميل الملف',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'انقر لإعادة المحاولة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // زر إعادة المحاولة
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.red,
            ),
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _hasError = false;
                widget.controller.setError(false);
                _loadFile();
              });
            },
          ),
        ],
      ),
    );
  }

  // عرض معلومات الملف
  void _showFileInfo() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getFileColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getFileIcon(),
                        color: _getFileColor(),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFileName(),
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getFileTypeName(),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: _getFileColor(),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('نوع الملف', _getFileTypeName()),
              _buildInfoRow(
                  'الحجم',
                  widget.media.fileSize != null
                      ? _formatFileSize(widget.media.fileSize!)
                      : 'غير معروف'),
              _buildInfoRow('الرابط', widget.fileUrl),
              _buildInfoRow('حالة التحميل', _isFileReady ? 'جاهز' : 'غير جاهز'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'إغلاق',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.controller.downloadFile();
                      Get.back();
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text(
                      'تحميل',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getFileColor(),
                      foregroundColor: Colors.white,
                      elevation: 0,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Tajawal',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // الحصول على اسم الملف
  String _getFileName() {
    if (widget.media.fileName != null && widget.media.fileName!.isNotEmpty) {
      return widget.media.fileName!;
    }

    if (widget.media.fileUrl == null) return 'ملف';

    final fileName = widget.media.fileUrl!.split('/').last;

    // إزالة الامتداد
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }

    return fileName;
  }

  // الحصول على امتداد الملف
  String _getFileExtension() {
    if (widget.media.fileUrl == null) return '';

    final fileName = widget.media.fileUrl!.split('/').last;
    final parts = fileName.split('.');

    if (parts.length > 1) {
      return parts.last.toLowerCase();
    } else {
      return '';
    }
  }

  // الحصول على أيقونة الملف
  IconData _getFileIcon() {
    final fileExtension = _getFileExtension();

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

  // الحصول على لون الملف
  Color _getFileColor() {
    final extension = _getFileExtension();
  final HomeController _homeController = Get.find<HomeController>();

    if (['pdf'].contains(extension)) {
      return Colors.red.shade700;
    } else if (['doc', 'docx'].contains(extension)) {
      return Colors.blue.shade700;
    } else if (['xls', 'xlsx'].contains(extension)) {
      return Colors.green.shade700;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Colors.orange.shade700;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return Colors.purple.shade700;
    } else if (['txt', 'rtf'].contains(extension)) {
      return Colors.teal.shade700;
    } else {
      return _homeController.getPrimaryColor();
    }
  }

  // الحصول على اسم نوع الملف
  String _getFileTypeName() {
    final extension = _getFileExtension();

    if (['pdf'].contains(extension)) {
      return 'ملف PDF';
    } else if (['doc', 'docx'].contains(extension)) {
      return 'مستند Word';
    } else if (['xls', 'xlsx'].contains(extension)) {
      return 'جدول Excel';
    } else if (['ppt', 'pptx'].contains(extension)) {
      return 'عرض تقديمي PowerPoint';
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return 'ملف مضغوط';
    } else if (['txt', 'rtf'].contains(extension)) {
      return 'ملف نصي';
    } else {
      return 'ملف ' + _getFileExtension().toUpperCase();
    }
  }

  // تنسيق حجم الملف
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }
}
