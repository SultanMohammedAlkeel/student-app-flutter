import 'package:flutter/material.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:student_app/modules/posts/views/widgets/media_players/audio_player.dart';
import 'package:student_app/modules/posts/views/widgets/media_players/file_player.dart';
import 'package:student_app/modules/posts/views/widgets/media_players/image_player.dart';
import 'package:student_app/modules/posts/views/widgets/media_players/video_player.dart';

import 'package:visibility_detector/visibility_detector.dart';
import 'animated_media_placeholder.dart';
import '../../controllers/media_preview_controller.dart';

class MediaPreview extends StatefulWidget {
  final Post post;
  final bool autoPlay;
  final bool showControls;

  const MediaPreview({
    Key? key,
    required this.post,
    this.autoPlay = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => MediaPreviewState();

  // طريقة ثابتة لتحميل الملف
  static Future<void> downloadFile(Post post) async {
    final controller = MediaPreviewController();
    await controller.downloadFileFromPost(post);
  }
}

class MediaPreviewState extends State<MediaPreview> {
  final MediaPreviewController _controller = MediaPreviewController();
  bool _isMediaLoaded = false;
  bool _isVisible = false;
  final String _uniqueKey = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _controller.setPost(widget.post);
    
    // تحميل مسبق للوسائط إذا كان التشغيل التلقائي مفعلاً
    if (widget.autoPlay) {
      _isMediaLoaded = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // طريقة لتحميل الملف
  Future<void> downloadFile() async {
    await _controller.downloadFile();
  }

  // طريقة ثابتة لتحميل الملف بدون حالة
  static Future<void> downloadFileStatic(Post post) async {
    final controller = MediaPreviewController();
    await controller.downloadFileFromPost(post);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_uniqueKey),
      onVisibilityChanged: (info) {
        if (mounted) {
          setState(() {
            _isVisible = info.visibleFraction > 0.3;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض الوسائط
          if (widget.post.fileUrl != null)
            _buildMediaContent(),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    // إذا لم يتم تحميل الوسائط بعد، عرض الرسوم المتحركة المتموجة
    // if (!_isMediaLoaded) {
    //   return AnimatedMediaPlaceholder(
    //     post: widget.post,
    //     controller: _controller,
    //     onTap: () {
    //       setState(() {
    //         _isMediaLoaded = true;
    //       });
    //     },
    //   );
    // }

    // تحديد نوع الوسائط وعرض المشغل المناسب
    return _buildMediaPlayer();
  }

  Widget _buildMediaPlayer() {
    final String? fileUrl = widget.post.fileUrl;

    // إذا لم يكن هناك ملف
    if (fileUrl == null) {
      return const SizedBox.shrink();
    }

    // تحديد نوع الملف
    final String fileExtension = _getFileExtension(fileUrl).toLowerCase();

    // إذا كان الملف صورة
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(fileExtension)) {
      return ImagePlayerWidget(
        post: widget.post,
        imageUrl: fileUrl,
        controller: _controller,
        showControls: widget.showControls,
      );
    }

    // إذا كان الملف فيديو
    if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(fileExtension)) {
      return VideoPlayerWidget(
        post: widget.post,
        videoUrl: fileUrl,
        controller: _controller,
        autoPlay: widget.autoPlay,
        showControls: widget.showControls,
        isVisible: _isVisible,
      );
    }

    // إذا كان الملف صوتي
    if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(fileExtension)) {
      return AudioPlayerWidget(
        post: widget.post,
        audioUrl: fileUrl,
        controller: _controller,
        autoPlay: widget.autoPlay,
        showControls: widget.showControls,
        isVisible: _isVisible,
      );
    }

    // أي نوع آخر من الملفات
    return FilePlayer(
      post: widget.post,
      fileUrl: fileUrl,
      controller: _controller,
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
}