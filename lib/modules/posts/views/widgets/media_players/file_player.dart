import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/models/post_model.dart';

import '../../../controllers/media_preview_controller.dart';

class FilePlayer extends StatefulWidget {
  final Post post;
  final String fileUrl;
  final MediaPreviewController controller;
  final bool showControls;
  final bool isVisible;

  const FilePlayer({
    Key? key,
    required this.post,
    required this.fileUrl,
    required this.controller,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<FilePlayer> createState() => _FilePlayerState();
}

class _FilePlayerState extends State<FilePlayer>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;
  bool _isFileReady = false;

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
  void didUpdateWidget(FilePlayer oldWidget) {
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
      // final cachedPath = await widget.controller.loadFile(widget.fileUrl);

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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 200, // تقليل الارتفاع للملفات
        minHeight: 120, // ضمان ارتفاع أدنى
      ),
      child: _buildFileContent(),
    );
  }

  Widget _buildFileContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getFileColor().withOpacity(0.2),
            _getFileColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getFileColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // معلومات الملف
          Row(
            children: [
              // أيقونة الملف
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getFileColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getFileIcon(),
                    color: _getFileColor(),
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(width: 16),

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
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // نوع الملف والحجم
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getFileColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getFileExtension().toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: _getFileColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // حجم الملف (إذا كان متوفراً)
                        // ignore: unnecessary_null_comparison
                        if (widget.post.fileSize != null)
                          Text(
                            _formatFileSize(widget.post.fileSize),
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // شريط الحالة
          if (_isFileReady)
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getFileColor(),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // زر التحميل
              _buildActionButton(
                icon: Icons.download,
                label: 'تحميل',
                onPressed: () => widget.controller.downloadFile(),
              ),

              // زر الفتح
              _buildActionButton(
                icon: Icons.open_in_new,
                label: 'فتح',
                onPressed: () => widget.controller.openFileExternally(),
              ),

              // زر المشاركة
              _buildActionButton(
                icon: Icons.share,
                label: 'مشاركة',
                onPressed: () => widget.controller.shareFile(),
              ),

              // زر معلومات الملف
              _buildActionButton(
                icon: Icons.info_outline,
                label: 'معلومات',
                onPressed: () => _showFileInfo(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _getFileColor(),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: _getFileColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getFileColor().withOpacity(0.3),
            _getFileColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          Center(
            child: Icon(
              _getFileIcon(),
              size: 50,
              color: Colors.white.withOpacity(0.5),
            ),
          ),

          // مؤشر التقدم
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                CircularProgressIndicator(
                  value: _loadingProgress,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'جاري تحميل الملف... ${(_loadingProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 14,
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
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.7),
            Colors.red.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 10),
            const Text(
              'حدث خطأ أثناء تحميل الملف',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _hasError = false;
                  widget.controller.setError(false);
                  _loadFile();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getFileColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getFileIcon(),
                        color: _getFileColor(),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
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
                          _getFileExtension().toUpperCase(),
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
              const SizedBox(height: 20),
              _buildInfoRow('نوع الملف', _getFileTypeName()),
              _buildInfoRow(
                  'الحجم',
                  // ignore: unnecessary_null_comparison
                  widget.post.fileSize != null
                      ? _formatFileSize(widget.post.fileSize)
                      : 'غير معروف'),
              _buildInfoRow('الرابط', widget.fileUrl),
              _buildInfoRow('حالة التحميل', _isFileReady ? 'جاهز' : 'غير جاهز'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => widget.controller.downloadFile(),
                    icon: const Icon(Icons.download),
                    label: const Text(
                      'تحميل',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getFileColor(),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'إغلاق',
                      style: TextStyle(fontFamily: 'Tajawal'),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
    if (widget.post.fileUrl == null) return 'ملف';

    final fileName = widget.post.fileUrl!.split('/').last;

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
    if (widget.post.fileUrl == null) return '';

    final fileName = widget.post.fileUrl!.split('/').last;
    final parts = fileName.split('.');

    if (parts.length > 1) {
      return parts.last.toLowerCase();
    } else {
      return '';
    }
  }

  // الحصول على أيقونة الملف
  IconData _getFileIcon() {
    final extension = _getFileExtension();

    if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(extension)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Icons.slideshow;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return Icons.folder_zip;
    } else if (['txt', 'rtf'].contains(extension)) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // الحصول على لون الملف
  Color _getFileColor() {
      final HomeController homeController = Get.find<HomeController>();

    final extension = _getFileExtension();

    if (['pdf'].contains(extension)) {
      return Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      return Colors.blue;
    } else if (['xls', 'xlsx'].contains(extension)) {
      return Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Colors.orange;
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return Colors.purple;
    } else if (['txt', 'rtf'].contains(extension)) {
      return Colors.teal;
    } else {
      return homeController.getPrimaryColor();
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
