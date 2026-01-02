import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/chats/models/message_model.dart';
import 'package:student_app/modules/chats/views/widgets/animated_media_placeholder.dart';
import 'package:student_app/modules/chats/views/widgets/media_players/chat_audio_player.dart';
import 'package:student_app/modules/chats/views/widgets/media_players/chat_file_player.dart';
import 'package:student_app/modules/chats/views/widgets/media_players/chat_image_player.dart';
import 'package:student_app/modules/chats/views/widgets/media_players/chat_video_player.dart';

import 'package:visibility_detector/visibility_detector.dart';
// import 'animated_media_placeholder.dart';
import 'media_preview_controller.dart';

class MediaPreview extends StatefulWidget {
  final ChatMediaModel chat;
  final bool autoPlay;
  final bool showControls;
  final bool isdarkMode;
  final Color textCol;

  const MediaPreview({
    Key? key,
    required this.chat,
    this.autoPlay = false,
    this.textCol = Colors.white,
    this.isdarkMode = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => MediaPreviewState();

  // طريقة ثابتة لتحميل الملف
  static Future<void> downloadFile(ChatMediaModel chat) async {
    final controller = MediaPreviewController();
    await controller.downloadFileFromChat(chat);
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
    _controller.setChat(widget.chat);

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
  static Future<void> downloadFileStatic(ChatMediaModel chat) async {
    final controller = MediaPreviewController();
    await controller.downloadFileFromChat(chat);
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
          if (widget.chat.fileUrl != null) _buildMediaContent(),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    // إذا لم يتم تحميل الوسائط بعد، عرض الرسوم المتحركة المتموجة
    if (!_isMediaLoaded) {
      return AnimatedMediaPlaceholder(
        textColr: widget.textCol,
        chatMedia: widget.chat,
        controller: _controller,
        isdark: widget.isdarkMode,
        onTap: () {
          setState(() {
            _isMediaLoaded = true;
          });
        },
      );
    }

    // تحديد نوع الوسائط وعرض المشغل المناسب
    return _buildMediaPlayer();
  }

  Widget _buildMediaPlayer() {
    final String? fileUrl = widget.chat.fileUrl;

    // إذا لم يكن هناك ملف
    if (fileUrl == null) {
      return const SizedBox.shrink();
    }

    // تحديد نوع الملف
    final String fileExtension = _getFileExtension(fileUrl).toLowerCase();

    // إذا كان الملف صورة
    // if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(fileExtension)) {
    //   return ChatImagePlayer(
    //     media: widget.chat,
    //     imageUrl: fileUrl,
    //     controller: _controller,
    //     showControls: widget.showControls,
    //     fit: BoxFit.cover,
    //   );
    // }

    // إذا كان الملف فيديو
    if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(fileExtension)) {
      return //Lottie.asset('assets/animations/audio_wave.json');
          ChatVideoPlayer(
        media: widget.chat,
        videoUrl: fileUrl,
        controller: _controller,
        autoPlay: widget.autoPlay,
        showControls: widget.showControls,
        isVisible: _isVisible,
      );
    }

    // إذا كان الملف صوتي
    if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(fileExtension)) {
      return ChatAudioPlayer(
        media: widget.chat,
        audioUrl: fileUrl,
        controller: _controller,
        autoPlay: widget.autoPlay,
        showControls: widget.showControls,
        isVisible: _isVisible,
      );
    }

    // أي نوع آخر من الملفات
    return ChatFilePlayer(
      media: widget.chat,
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
