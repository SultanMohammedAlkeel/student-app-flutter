import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:video_player/video_player.dart' as video_lib;
import 'package:chewie/chewie.dart';
import 'package:lottie/lottie.dart';
import '../../../controllers/media_preview_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Post post;
  final String videoUrl;
  final MediaPreviewController controller;
  final bool autoPlay;
  final bool showControls;
  final bool isVisible;

  const VideoPlayerWidget({
    Key? key,
    required this.post,
    required this.videoUrl,
    required this.controller,
    this.autoPlay = false,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
        HomeController homeController = Get.find<HomeController>();

  video_lib.VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // متغيرات للتحكم في عرض الفيديو
  bool _isVideoPlaying = false;
  bool _showVideoControls = false;
  bool _isFullScreen = false;
  Duration _videoDuration = Duration.zero;
  Duration _videoPosition = Duration.zero;
  double _videoBuffered = 0.0;

  // متغير لتتبع سرعة التشغيل الحالية
  double _currentPlaybackSpeed = 1.0;
  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // متغيرات للرسوم المتحركة
  late AnimationController _animationController;

  // متغير لتتبع حالة التحميل
  bool _isInitializing = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _animationController.dispose();
    // إيقاف منع الشاشة من الإغلاق عند الخروج
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيرت حالة الرؤية، تحديث حالة التشغيل
    if (oldWidget.isVisible != widget.isVisible) {
      _handleVisibilityChange();
    }
  }

  // التعامل مع تغيير حالة الرؤية
  void _handleVisibilityChange() {
    if (!mounted) return;

    if (widget.isVisible) {
      // إذا كان الفيديو مرئياً وكان يعمل قبل الاختفاء، استئناف التشغيل
      if (_isVideoPlaying && _videoController != null) {
        _videoController!.play();
      }
    } else {
      // إذا لم يعد الفيديو مرئياً، إيقاف التشغيل مؤقتاً
      if (_videoController != null && _videoController!.value.isPlaying) {
        _videoController!.pause();
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (!mounted) return;

    widget.controller.setLoading(true);
    _isInitializing = true;
    _loadingProgress = 0.0;

    try {
      // محاولة تحميل الفيديو من الكاش أولاً
      final cachedPath = await widget.controller.loadFile(widget.videoUrl);

      if (cachedPath != null) {
        // استخدام الملف المحلي إذا كان موجوداً
        _videoController =
            video_lib.VideoPlayerController.file(File(cachedPath));
      } else {
        // استخدام الرابط إذا لم يكن الملف موجوداً محلياً
        _videoController =
            video_lib.VideoPlayerController.network(widget.videoUrl);
      }

      // إضافة مستمعين لحالة الفيديو
      _videoController!.addListener(_videoListener);

      // محاكاة تقدم التحميل
      _simulateLoadingProgress();

      await _videoController!.initialize();

      if (!mounted) return;

      // تحديث مدة الفيديو
      _videoDuration = _videoController!.value.duration;

      // إعداد مشغل Chewie للعرض في وضع ملء الشاشة
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: widget.autoPlay && widget.isVisible,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Center(
          child: CircularProgressIndicator(
            color: homeController.getPrimaryColor(),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: homeController.getPrimaryColor(),
          handleColor: homeController.getPrimaryColor(),
          backgroundColor: Colors.grey.shade300,
          bufferedColor: homeController.getPrimaryColor().withOpacity(0.5),
        ),
        // إضافة أزرار تحكم إضافية
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: (_) => widget.controller.openFileExternally(),
              iconData: Icons.open_in_new,
              title: 'فتح في تطبيق خارجي',
            ),
            OptionItem(
              onTap: (_) => widget.controller.downloadFile(),
              iconData: Icons.download,
              title: 'تحميل الفيديو',
            ),
            OptionItem(
              onTap: (_) => widget.controller.shareFile(),
              iconData: Icons.share,
              title: 'مشاركة',
            ),
            OptionItem(
              onTap: (_) => _toggleFullScreenMode(),
              iconData: Icons.fullscreen,
              title: 'ملء الشاشة',
            ),
            OptionItem(
              onTap: (_) => _toggleLooping(),
              iconData: Icons.loop,
              title: 'تكرار',
            ),
            OptionItem(
              onTap: (_) => _changePlaybackSpeed(),
              iconData: Icons.speed,
              title: 'سرعة التشغيل',
            ),
          ];
        },
      );

      _isInitializing = false;
      _loadingProgress = 1.0;
      widget.controller.setInitialized(true);
      widget.controller.setLoading(false);

      // تشغيل الفيديو تلقائياً إذا كان مطلوباً وكان مرئياً
      if (widget.autoPlay && widget.isVisible) {
        _videoController!.play();
        _isVideoPlaying = true;
        // منع الشاشة من الإغلاق أثناء تشغيل الفيديو
        WakelockPlus.enable();
      }

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      _isInitializing = false;
      widget.controller.setLoading(false);
      widget.controller.setError(true);
      widget.controller
          .showErrorMessage('خطأ في تهيئة مشغل الفيديو: ${e.toString()}');
      print('خطأ في تهيئة مشغل الفيديو: $e');
    }
  }

  // محاكاة تقدم التحميل
  void _simulateLoadingProgress() {
    Future.doWhile(() async {
      if (!mounted || !_isInitializing) return false;

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted || !_isInitializing) return false;

      setState(() {
        _loadingProgress = _loadingProgress + 0.01;
        if (_loadingProgress > 0.95) {
          _loadingProgress = 0.95;
        }
      });

      return _isInitializing;
    });
  }

  // مستمع لحالة الفيديو
  void _videoListener() {
    if (_videoController == null || !mounted) return;

    // تحديث حالة التشغيل
    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _isVideoPlaying) {
      setState(() {
        _isVideoPlaying = isPlaying;
      });
      widget.controller.setPlaying(isPlaying);

      // التحكم في منع الشاشة من الإغلاق
      if (isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }

    // تحديث موضع التشغيل
    final position = _videoController!.value.position;
    if (position != _videoPosition) {
      setState(() {
        _videoPosition = position;
      });
    }

    // تحديث نسبة التخزين المؤقت
    if (_videoController!.value.buffered.isNotEmpty) {
      final bufferedEnd = _videoController!.value.buffered.last.end;
      final bufferedPercent =
          bufferedEnd.inMilliseconds / _videoDuration.inMilliseconds;
      if (bufferedPercent != _videoBuffered) {
        setState(() {
          _videoBuffered = bufferedPercent;
        });
      }
    }

    // تحديث سرعة التشغيل الحالية
    final playbackSpeed = _videoController!.value.playbackSpeed;
    if (playbackSpeed != _currentPlaybackSpeed) {
      setState(() {
        _currentPlaybackSpeed = playbackSpeed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: _buildVideoContent(),
    );
  }

  Widget _buildVideoContent() {
    if (widget.controller.isLoading || _isInitializing) {
      return _buildLoadingWidget();
    }

    if (widget.controller.hasError ||
        _videoController == null ||
        !widget.controller.isInitialized) {
      return _buildErrorWidget();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showVideoControls = !_showVideoControls;
        });

        // إخفاء أزرار التحكم بعد 3 ثوانٍ
        if (_showVideoControls) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showVideoControls = false;
              });
            }
          });
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الفيديو نفسه
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: video_lib.VideoPlayer(_videoController!),
            ),

            // زر التشغيل/الإيقاف المركزي
            if (!_isVideoPlaying || _showVideoControls)
              GestureDetector(
                onTap: _toggleVideoPlayback,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

            // شريط التقدم بأسلوب يوتيوب
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showVideoControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شريط التقدم
                      Stack(
                        children: [
                          // شريط التخزين المؤقت
                          Container(
                            height: 4,
                            width: double.infinity,
                            color: Colors.grey.shade700,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _videoBuffered,
                              child: Container(
                                color: Colors.grey.shade400,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 12),
                                    trackShape: CustomTrackShape(),
                                  ),
                                  child: Slider(
                                    value: _videoPosition.inMilliseconds
                                        .toDouble(),
                                    min: 0,
                                    max: _videoDuration.inMilliseconds
                                        .toDouble(),
                                    activeColor: homeController.getPrimaryColor(),
                                    inactiveColor: Colors.transparent,
                                    onChanged: (value) {
                                      final newPosition =
                                          Duration(milliseconds: value.toInt());
                                      _videoController!.seekTo(newPosition);
                                      setState(() {
                                        _videoPosition = newPosition;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // شريط التقدم
                        ],
                      ),

                      // الوقت وأزرار التحكم
                      Row(
                        children: [
                          // الوقت الحالي / المدة الإجمالية
                          Text(
                            '${_formatDuration(_videoPosition)} / ${_formatDuration(_videoDuration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const Spacer(),
                          // أزرار التحكم الإضافية
                          IconButton(
                            icon: const Icon(Icons.replay_10,
                                color: Colors.white, size: 20),
                            onPressed: () => _seekVideo(-10),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _toggleVideoPlayback,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.forward_10,
                                color: Colors.white, size: 20),
                            onPressed: () => _seekVideo(10),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          // زر سرعة التشغيل
                          InkWell(
                            onTap: _changePlaybackSpeed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_currentPlaybackSpeed}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // زر ملء الشاشة
                          IconButton(
                            icon: const Icon(Icons.fullscreen,
                                color: Colors.white, size: 20),
                            onPressed: _toggleFullScreenMode,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // مؤشر التحميل
            if (widget.controller.isDownloading) _buildDownloadIndicator(),
          ],
        ),
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
            Colors.red.withOpacity(0.6),
            Colors.red.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // الرسوم المتحركة المتموجة
          Center(
            child: Lottie.asset(
              'assets/animations/video_loading.json',
              width: 120,
              height: 120,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.movie,
                  size: 60,
                  color: Colors.white,
                );
              },
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
                  'جاري تحميل الفيديو... ${(_loadingProgress * 100).toStringAsFixed(0)}%',
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
              'حدث خطأ أثناء تحميل الفيديو',
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
                  _isInitializing = true;
                });
                _initializeVideoPlayer();
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

  // تبديل حالة التشغيل
  void _toggleVideoPlayback() {
    if (_videoController == null) return;

    if (_isVideoPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
  }

  // تقديم أو إرجاع الفيديو
  void _seekVideo(int seconds) {
    if (_videoController == null) return;

    final position = _videoController!.value.position;
    final newPosition = position + Duration(seconds: seconds);
    _videoController!.seekTo(newPosition);
  }

  // تبديل وضع ملء الشاشة
  void _toggleFullScreenMode() {
    // تنفيذ وضع ملء الشاشة
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    // يمكن استخدام مكتبة مثل wakelock_plus للتحكم في وضع ملء الشاشة
  }

  // تبديل حالة التكرار
  void _toggleLooping() {
    if (_chewieController == null) return;

    setState(() {
      _chewieController!.setLooping(!_chewieController!.looping);
    });
  }

  // تغيير سرعة التشغيل
  void _changePlaybackSpeed() {
    if (_videoController == null) return;

    // الحصول على الفهرس الحالي
    int currentIndex = _playbackSpeeds.indexOf(_currentPlaybackSpeed);
    if (currentIndex == -1) currentIndex = 2; // افتراضي 1.0x

    // الانتقال إلى السرعة التالية
    int nextIndex = (currentIndex + 1) % _playbackSpeeds.length;
    double newSpeed = _playbackSpeeds[nextIndex];

    // تطبيق السرعة الجديدة
    _videoController!.setPlaybackSpeed(newSpeed);

    // عرض رسالة للمستخدم
    widget.controller.showInfoMessage(
      'سرعة التشغيل',
      'تم تغيير سرعة التشغيل إلى ${newSpeed}x',
    );
  }

  // تنسيق المدة
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}

// شكل مخصص لشريط التقدم
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
