import 'dart:io';
import 'package:icons_plus/icons_plus.dart' as ico_plus;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:video_player/video_player.dart' as video_lib;
import 'package:chewie/chewie.dart';
import 'package:lottie/lottie.dart';
import '../media_preview_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

// صفحة منفصلة لعرض الفيديو بملء الشاشة

class ChatVideoPlayer extends StatefulWidget {
  final ChatMediaModel media;
  final String videoUrl;
  final MediaPreviewController controller;
  final bool autoPlay;
  final bool showControls;
  final bool isVisible;

  const ChatVideoPlayer({
    Key? key,
    required this.media,
    required this.videoUrl,
    required this.controller,
    this.autoPlay = false,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
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

  // متغير لتتبع حالة التشغيل في الخلفية
  bool _isPlayingInBackground = false;

  // متغير لحفظ الاتجاه الأصلي للشاشة
  DeviceOrientation? _originalOrientation;

  // متغير لتخزين حالة ملء الشاشة
  final RxBool _isFullScreenRx = false.obs;

  // معرف فريد للمكون
  final String _uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

  // متغير لتتبع ما إذا كان المكون مثبتاً
  bool _isMounted = true;

  // متغير لتتبع نسبة الرؤية
  double _visibilityFraction = 1.0;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // تأخير تهيئة مشغل الفيديو لتجنب الأخطاء أثناء بناء واجهة المستخدم
    Future.delayed(Duration.zero, () {
      if (_isMounted) {
        _initializeVideoPlayer();
      }
    });

    //
    //
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);

    // إيقاف التشغيل في الخلفية
    if (_isPlayingInBackground) {
      _stopBackgroundPlayback();
    }

    try {
      _videoController?.pause();
      _videoController?.dispose();
      _chewieController?.dispose();
      _animationController.dispose();
    } catch (e) {
      print('خطأ في تنظيف موارد مشغل الفيديو: $e');
    }

    // إيقاف منع الشاشة من الإغلاق عند الخروج
    try {
      WakelockPlus.disable();
    } catch (e) {
      print('خطأ في تعطيل WakelockPlus: $e');
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(ChatVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيرت حالة الرؤية، تحديث حالة التشغيل
    if (oldWidget.isVisible != widget.isVisible) {
      _handleVisibilityChange();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_isMounted) return;

    // التعامل مع تغييرات دورة حياة التطبيق
    if (state == AppLifecycleState.paused) {
      // التطبيق في الخلفية
      if (_isVideoPlaying && !_isPlayingInBackground) {
        _videoController?.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      // التطبيق في المقدمة مرة أخرى
      if (_isVideoPlaying && widget.isVisible) {
        _videoController?.play();
      }
    }
  }

  // التعامل مع تغيير حالة الرؤية
  void _handleVisibilityChange() {
    if (!_isMounted) return;

    if (widget.isVisible) {
      // إذا كان الفيديو مرئياً وكان يعمل قبل الاختفاء، استئناف التشغيل
      if (_isVideoPlaying && _videoController != null) {
        _videoController!.play();
      }
    } else {
      // إذا لم يعد الفيديو مرئياً ولم يكن في وضع التشغيل في الخلفية، إيقاف التشغيل مؤقتاً
      if (_videoController != null &&
          _videoController!.value.isPlaying &&
          !_isPlayingInBackground) {
        _videoController!.pause();
      }
    }
  }

  // التعامل مع تغيير نسبة الرؤية
  void _onVisibilityChanged(double visibilityFraction) {
    if (!_isMounted) return;

    _visibilityFraction = visibilityFraction;

    // إذا كان التشغيل في الخلفية مفعلاً، لا نتأثر بنسبة الرؤية
    if (_isPlayingInBackground) {
      if (_isVideoPlaying &&
          _videoController != null &&
          !_videoController!.value.isPlaying) {
        _videoController!.play();
      }
      return;
    }

    // إذا كان الفيديو غير مرئي تماماً، إيقاف التشغيل مؤقتاً
    if (visibilityFraction < 0.1) {
      if (_videoController != null && _videoController!.value.isPlaying) {
        _videoController!.pause();
      }
    } else if (_isVideoPlaying) {
      // إذا كان الفيديو مرئياً جزئياً على الأقل وكان يعمل، استئناف التشغيل
      if (_videoController != null && !_videoController!.value.isPlaying) {
        _videoController!.play();
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
      final HomeController _homeController = Get.find<HomeController>();

    if (!_isMounted) return;

    try {
      widget.controller.setLoading(true);
      _isInitializing = true;
      _loadingProgress = 0.0;

      if (_isMounted) {
        setState(() {});
      }

      // محاولة تحميل الفيديو من الكاش أولاً
      final cachedPath = await widget.controller.loadFile(widget.videoUrl);

      if (!_isMounted) return;

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

      if (!_isMounted) return;

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
            color: _homeController.getPrimaryColor(),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: _homeController.getPrimaryColor(),
          handleColor: _homeController.getPrimaryColor(),
          backgroundColor: Colors.grey.shade300,
          bufferedColor: _homeController.getPrimaryColor().withOpacity(0.5),
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
              onTap: (_) => _toggleLooping(),
              iconData: Icons.loop,
              title: 'تكرار',
            ),
            OptionItem(
              onTap: (_) => _changePlaybackSpeed(),
              iconData: Icons.speed,
              title: 'سرعة التشغيل',
            ),
            OptionItem(
              onTap: (_) => _toggleBackgroundPlayback(),
              iconData: _isPlayingInBackground
                  ? Icons.visibility_off
                  : Icons.visibility,
              title: _isPlayingInBackground
                  ? 'إيقاف التشغيل في الخلفية'
                  : 'تشغيل في الخلفية',
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
        try {
          WakelockPlus.enable();
        } catch (e) {
          print('خطأ في تمكين WakelockPlus: $e');
        }
      }

      if (_isMounted) {
        setState(() {});
      }
    } catch (e) {
      if (!_isMounted) return;

      _isInitializing = false;
      widget.controller.setLoading(false);
      widget.controller.setError(true);
      widget.controller
          .showErrorMessage('خطأ في تهيئة مشغل الفيديو: ${e.toString()}');
      print('خطأ في تهيئة مشغل الفيديو: $e');

      if (_isMounted) {
        setState(() {});
      }
    }
  }

  // محاكاة تقدم التحميل
  void _simulateLoadingProgress() {
    Future.doWhile(() async {
      if (!_isMounted || !_isInitializing) return false;

      await Future.delayed(const Duration(milliseconds: 100));

      if (!_isMounted || !_isInitializing) return false;

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
    if (_videoController == null || !_isMounted) return;

    try {
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
        } else if (!_isFullScreen && !_isPlayingInBackground) {
          // لا نقوم بتعطيل Wakelock إذا كنا في وضع ملء الشاشة أو التشغيل في الخلفية
          WakelockPlus.disable();
        }
      }

      // تحديث موضع التشغيل
      final position = _videoController!.value.position;
      if (position != _videoPosition) {
        setState(() {
          _videoPosition = position;
        });

        // تحديث التقدم في وحدة التحكم
        if (_videoDuration.inMilliseconds > 0) {
          widget.controller.progress.value =
              position.inMilliseconds / _videoDuration.inMilliseconds;
        }
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
    } catch (e) {
      print('خطأ في مستمع الفيديو: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // العرض العادي
    return VisibilityDetector(
      key: Key('video-player-${widget.media.id}'),
      onVisibilityChanged: (info) {
        _onVisibilityChanged(info.visibleFraction);
      },
      child: Container(
        width: double.infinity,
        height: 250,
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: _buildVideoContent(),
      ),
    );
  }

  // بناء مشغل الفيديو بملء الشاشة

  Widget _buildVideoContent() {
      final HomeController _homeController = Get.find<HomeController>();

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
            if (_isMounted) {
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
                    _isVideoPlaying
                        ? ico_plus.FontAwesome.pause_solid
                        : ico_plus.FontAwesome.play_solid,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            SizedBox(
              height: 20.h,
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
                            height: 3,
                            width: double.infinity,
                            color: Colors.grey.shade700,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerRight,
                              widthFactor: _videoBuffered,
                              child: Container(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),

                          // شريط التقدم
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 5),
                              trackShape: CustomTrackShape(),
                            ),
                            child: Slider(
                              value: _videoPosition.inMilliseconds.toDouble(),
                              min: 0,
                              max: _videoDuration.inMilliseconds.toDouble(),
                              activeColor: _homeController.getPrimaryColor(),
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

                          // زر التشغيل في الخلفية
                          IconButton(
                            icon: Icon(
                              _isPlayingInBackground
                                  ? ico_plus.Bootstrap.eye_slash
                                  : ico_plus.Bootstrap.eye,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _toggleBackgroundPlayback,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),

                          // زر ملء الشاشة
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // مؤشر التحميل
            if (widget.controller.isDownloading) _buildDownloadIndicator(),

            // مؤشر التشغيل في الخلفية
            if (_isPlayingInBackground)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ico_plus.Bootstrap.eye_slash,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'تشغيل في الخلفية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            const Color.fromARGB(2, 54, 235, 244).withOpacity(0.6),
            const Color.fromARGB(17, 133, 54, 244).withOpacity(0.3),
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
                  ico_plus.Bootstrap.film,
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
      final HomeController _homeController = Get.find<HomeController>();

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
                if (!_isMounted) return;
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
                foregroundColor: _homeController.getPrimaryColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadIndicator() {
      final HomeController _homeController = Get.find<HomeController>();

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
                color: _homeController.getPrimaryColor(),
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
    if (_videoController == null || !_isMounted) return;

    try {
      if (_isVideoPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } catch (e) {
      print('خطأ في تبديل حالة التشغيل: $e');
    }
  }

  // تقديم أو إرجاع الفيديو
  void _seekVideo(int seconds) {
    if (_videoController == null || !_isMounted) return;

    try {
      final position = _videoController!.value.position;
      final newPosition = position + Duration(seconds: seconds);
      _videoController!.seekTo(newPosition);
    } catch (e) {
      print('خطأ في تقديم/إرجاع الفيديو: $e');
    }
  }

  // تبديل حالة التكرار
  void _toggleLooping() {
    if (_chewieController == null || !_isMounted) return;

    try {
      setState(() {
        _chewieController!.setLooping(!_chewieController!.looping);
      });
    } catch (e) {
      print('خطأ في تبديل حالة التكرار: $e');
    }
  }

  // تغيير سرعة التشغيل
  void _changePlaybackSpeed() {
    if (_videoController == null || !_isMounted) return;

    try {
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
    } catch (e) {
      print('خطأ في تغيير سرعة التشغيل: $e');
    }
  }

  // تبديل حالة التشغيل في الخلفية
  void _toggleBackgroundPlayback() {
    if (_videoController == null || !_isMounted) return;

    try {
      setState(() {
        _isPlayingInBackground = !_isPlayingInBackground;
      });

      if (_isPlayingInBackground) {
        _startBackgroundPlayback();
      } else {
        _stopBackgroundPlayback();
      }

      // عرض رسالة للمستخدم
      widget.controller.showInfoMessage(
        'تشغيل في الخلفية',
        _isPlayingInBackground
            ? 'تم تفعيل التشغيل في الخلفية'
            : 'تم إيقاف التشغيل في الخلفية',
      );
    } catch (e) {
      print('خطأ في تبديل حالة التشغيل في الخلفية: $e');
    }
  }

  // بدء التشغيل في الخلفية
  void _startBackgroundPlayback() {
    if (!_isMounted) return;

    try {
      // تمكين منع الشاشة من الإغلاق
      WakelockPlus.enable();

      // تشغيل الفيديو إذا لم يكن يعمل
      if (!_isVideoPlaying && _videoController != null) {
        _videoController!.play();
      }
    } catch (e) {
      print('خطأ في بدء التشغيل في الخلفية: $e');
    }
  }

  // إيقاف التشغيل في الخلفية
  void _stopBackgroundPlayback() {
    if (!_isMounted) return;

    try {
      // تعطيل منع الشاشة من الإغلاق إذا لم نكن في وضع ملء الشاشة
      if (!_isFullScreen) {
        WakelockPlus.disable();
      }
    } catch (e) {
      print('خطأ في إيقاف التشغيل في الخلفية: $e');
    }
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
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 9;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
