import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../home/controllers/home_controller.dart';
import '../../../controllers/media_preview_controller.dart';

class ImagePlayerWidget extends StatefulWidget {
  final Post post;
  final String imageUrl;
  final MediaPreviewController controller;
  final bool showControls;
  final bool isVisible;

  const ImagePlayerWidget({
    Key? key,
    required this.post,
    required this.imageUrl,
    required this.controller,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<ImagePlayerWidget> createState() => _ImagePlayerWidgetState();
}

class _ImagePlayerWidgetState extends State<ImagePlayerWidget>
    with SingleTickerProviderStateMixin {
  HomeController homeController = Get.find<HomeController>();

  bool _isFullScreen = false;
  bool _isHovering = false;
  bool _showControls = false;
  bool _isImageLoaded = false;
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;

  // متغيرات للرسوم المتحركة
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _loadImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImagePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغير الرابط، إعادة تحميل الصورة
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }

    // إذا تغيرت حالة الرؤية، تحديث الحالة
    if (oldWidget.isVisible != widget.isVisible) {
      _handleVisibilityChange();
    }
  }

  // التعامل مع تغيير حالة الرؤية
  void _handleVisibilityChange() {
    // يمكن إضافة منطق خاص بالرؤية هنا إذا لزم الأمر
    // مثل إيقاف الرسوم المتحركة عندما تكون غير مرئية
  }

  // تحميل الصورة
  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isImageLoaded = false;
      _loadingProgress = 0.0;
    });

    widget.controller.setLoading(true);

    try {
      // محاكاة تقدم التحميل
      _simulateLoadingProgress();

      // محاولة تحميل الصورة من الكاش أولاً
      //final cachedPath = await widget.controller.loadFile(widget.imageUrl);

      if (!mounted) return;

      setState(() {
        _isImageLoaded = true;
        _isLoading = false;
        _loadingProgress = 1.0;
      });

      widget.controller.setInitialized(true);
      widget.controller.setLoading(false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isImageLoaded = false;
        _isLoading = false;
        _hasError = true;
        _loadingProgress = 0.0;
      });

      widget.controller.setLoading(false);
      widget.controller.setError(true);
      widget.controller
          .showErrorMessage('فشل في تحميل الصورة: ${e.toString()}');
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
        maxHeight: 400,
      ),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || !_isImageLoaded) {
      return _buildErrorWidget();
    }

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;
        setState(() => _isHovering = true);
        _showControlsTemporarily();
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => _isHovering = false);
      },
      child: GestureDetector(
        onTap: () {
          if (!mounted) return;
          setState(() => _showControls = !_showControls);
          if (_showControls) {
            _showControlsTemporarily();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الصورة نفسها
            _buildImage(),

            // أزرار التحكم
            if (_showControls || _isHovering) _buildControls(),

            // مؤشر التحميل
            if (widget.controller.isDownloading) _buildDownloadIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isFullScreen ? _buildFullScreenImage() : _buildNormalImage(),
      ),
    );
  }

  Widget _buildNormalImage() {
    // التحقق مما إذا كانت الصورة موجودة في الكاش
    final cachedPath = widget.controller.getCachedFilePath(widget.imageUrl);

    if (cachedPath != null && File(cachedPath).existsSync()) {
      // استخدام الصورة المحلية إذا كانت موجودة في الكاش
      return Image.file(
        File(cachedPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        ),
      );
    } else {
      // استخدام CachedNetworkImage إذا لم تكن الصورة موجودة في الكاش
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: homeController.getPrimaryColor(),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        ),
      );
    }
  }

  Widget _buildFullScreenImage() {
    // التحقق مما إذا كانت الصورة موجودة في الكاش
    final cachedPath = widget.controller.getCachedFilePath(widget.imageUrl);

    return Container(
      color: Colors.black,
      child: PhotoView(
        imageProvider: cachedPath != null && File(cachedPath).existsSync()
            ? FileImage(File(cachedPath)) as ImageProvider
            : CachedNetworkImageProvider(widget.imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            color: homeController.getPrimaryColor(),
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Row(
        children: [
          // زر التحميل
          _buildControlButton(
            icon: Icons.download,
            tooltip: 'تحميل',
            onPressed: () => widget.controller.downloadFile(),
          ),

          const SizedBox(width: 8),

          // زر المشاركة
          _buildControlButton(
            icon: Icons.share,
            tooltip: 'مشاركة',
            onPressed: () => widget.controller.shareFile(),
          ),

          const SizedBox(width: 8),

          // زر العرض بملء الشاشة
          _buildControlButton(
            icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            tooltip: _isFullScreen ? 'إلغاء ملء الشاشة' : 'ملء الشاشة',
            onPressed: _toggleFullScreen,
          ),

          const SizedBox(width: 8),

          // زر فتح في تطبيق خارجي
          _buildControlButton(
            icon: Icons.open_in_new,
            tooltip: 'فتح في تطبيق خارجي',
            onPressed: () => widget.controller.openFileExternally(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 250,
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
          Center(
            child: Icon(
              Icons.image,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
          ),

          // مؤشر التقدم
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                CircularProgressIndicator(
                  value: _loadingProgress,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'جاري تحميل الصورة... ${(_loadingProgress * 100).toStringAsFixed(0)}%',
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
      height: 250,
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
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              'حدث خطأ أثناء تحميل الصورة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  widget.controller.setError(false);
                  _loadImage();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: homeController.getPrimaryColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadIndicator() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: widget.controller.downloadProgress,
                color: homeController.getPrimaryColor(),
              ),
              const SizedBox(height: 15),
              Text(
                'جاري التحميل... ${(widget.controller.downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    if (!mounted) return;
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showControlsTemporarily() {
    if (!mounted) return;
    setState(() {
      _showControls = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showControls = false;
      });
    });
  }
}
