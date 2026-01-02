import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart'hide Rx;

import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/chats/models/chat_media_model.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../media_preview_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:icons_plus/icons_plus.dart' as ico_plus;

class ChatAudioPlayer extends StatefulWidget {
  final ChatMediaModel media;
  final String audioUrl;
  final MediaPreviewController controller;
  final bool autoPlay;
  final bool showControls;
  final bool isVisible;

  const ChatAudioPlayer({
    Key? key,
    required this.media,
    required this.audioUrl,
    required this.controller,
    this.autoPlay = false,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<ChatAudioPlayer> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<ChatAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  double _loadingProgress = 0.0;
  bool _isDownloaded = false;

  // متغيرات للرسوم المتحركة
  late AnimationController _animationController;
  late Animation<double> _animation;

  // متغير لتتبع حالة التكرار
  bool _isLooping = false;

  // متغير لتتبع سرعة التشغيل الحالية
  double _currentPlaybackSpeed = 1.0;
  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatAudioPlayer oldWidget) {
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
      // إذا كان الصوت مرئياً وكان يعمل قبل الاختفاء، استئناف التشغيل
      if (_isPlaying) {
        _audioPlayer.play();
      }
    } else {
      // إذا لم يعد الصوت مرئياً، إيقاف التشغيل مؤقتاً
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      }
    }
  }

  Future<void> _initializeAudioPlayer() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingProgress = 0.0;
    });

    widget.controller.setLoading(true);

    try {
      // محاكاة تقدم التحميل
      _simulateLoadingProgress();

      // تحقق مما إذا كان الملف محمل مسبقاً
      final cachedPath =
          await widget.controller.getCachedFilePath(widget.audioUrl);
      if (cachedPath != null && File(cachedPath).existsSync()) {
        setState(() {
          _isDownloaded = true;
        });

        // استخدام الملف المحلي إذا كان موجوداً
        await _audioPlayer.setFilePath(cachedPath);
      } else {
        // إذا لم يكن الملف محملاً، تحميله قبل التشغيل
        setState(() {
          _isDownloaded = false;
        });

        // تحميل الملف أولاً (إجباري قبل التشغيل)
        final downloadedPath = await widget.controller.loadFile(widget.audioUrl,
            forceDownload: true, showNotifications: false);
        if (downloadedPath != null) {
          setState(() {
            _isDownloaded = true;
          });
          await _audioPlayer.setFilePath(downloadedPath);
        } else {
          throw Exception('فشل في تحميل الملف الصوتي');
        }
      }

      // إضافة مستمعين لحالة التشغيل
      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;

        final isPlaying = state.playing;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
          widget.controller.setPlaying(isPlaying);

          // تشغيل أو إيقاف الرسوم المتحركة بناءً على حالة التشغيل
          if (isPlaying) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
          }
        }
      });

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _loadingProgress = 1.0;
      });

      widget.controller.setInitialized(true);
      widget.controller.setLoading(false);

      // تشغيل الصوت تلقائياً إذا كان مطلوباً وكان مرئياً
      if (widget.autoPlay && widget.isVisible) {
        _audioPlayer.play();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _loadingProgress = 0.0;
      });

      widget.controller.setLoading(false);
      widget.controller.setError(true);
      widget.controller
          .showErrorMessage('خطأ في تهيئة مشغل الصوت: ${e.toString()}');
      print('خطأ في تهيئة مشغل الصوت: $e');
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

  // تبديل حالة التشغيل
  void _togglePlayback() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  // تغيير موضع التشغيل
  void _seekAudio(int seconds) {
    final position = _audioPlayer.position;
    final newPosition = position + Duration(seconds: seconds);
    _audioPlayer.seek(newPosition);
  }

  // تغيير موضع التشغيل بناءً على النسبة المئوية
  void _seekToPercent(double percent) {
    if (_audioPlayer.duration != null) {
      final newPosition = _audioPlayer.duration! * percent;
      _audioPlayer.seek(newPosition);
    }
  }

  // تغيير سرعة التشغيل
  void _changePlaybackSpeed() {
    final currentIndex = _playbackSpeeds.indexOf(_currentPlaybackSpeed);
    final nextIndex = (currentIndex + 1) % _playbackSpeeds.length;
    final newSpeed = _playbackSpeeds[nextIndex];

    setState(() {
      _currentPlaybackSpeed = newSpeed;
    });

    _audioPlayer.setSpeed(newSpeed);
  }

  // تبديل حالة التكرار
  void _toggleLooping() {
    setState(() {
      _isLooping = !_isLooping;
    });

    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
  }

  // الحصول على اسم الملف الصوتي
  String _getAudioFileName() {
    if (widget.media.fileName != null && widget.media.fileName!.isNotEmpty) {
      return widget.media.fileName!;
    }

    final uri = Uri.parse(widget.audioUrl);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }

    return 'ملف صوتي';
  }

  // الحصول على حالة التشغيل الحالية
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 90, // زيادة الارتفاع لتجنب مشكلة تجاوز الحدود
      ),
      child: _buildAudioContent(),
    );
  }

  Widget _buildAudioContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || !_isInitialized) {
      return _buildErrorWidget();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(195, 22, 23, 22).withOpacity(0.1),
            Color.fromARGB(255, 22, 35, 35).withOpacity(0.2)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: StreamBuilder<PositionData>(
        stream: _positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data ??
              PositionData(
                position: Duration.zero,
                bufferedPosition: Duration.zero,
                duration: Duration.zero,
              );

          // حساب نسبة التقدم
          final progress = positionData.duration.inMilliseconds > 0
              ? positionData.position.inMilliseconds /
                  positionData.duration.inMilliseconds
              : 0.0;

          return Column(
            mainAxisSize:
                MainAxisSize.min, // تقليل حجم العمود للحد الأدنى المطلوب
            children: [
              // عرض الوقت المنقضي والمدة الكلية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الوقت المنقضي
                  Text(
                    _formatDuration(positionData.position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),

                  // المدة الكلية
                  Text(
                    _formatDuration(positionData.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // عرض الشكل الموجي والتقدم مع زر التشغيل في النهاية
              LayoutBuilder(builder: (context, constraints) {
                return Row(
                  children: [
                    // الشكل الموجي والتقدم
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragStart: (details) {
                          // إيقاف التشغيل مؤقتاً أثناء السحب
                          if (_audioPlayer.playing) {
                            _audioPlayer.pause();
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          // حساب النسبة المئوية من موقع اللمس
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final Offset localPosition =
                              box.globalToLocal(details.globalPosition);
                          final double percent =
                              localPosition.dx / box.size.width;

                          // التأكد من أن النسبة في النطاق المسموح به
                          final double clampedPercent = percent.clamp(0.0, 1.0);

                          // تحديث موضع التشغيل
                          _seekToPercent(clampedPercent);
                        },
                        onHorizontalDragEnd: (details) {
                          // استئناف التشغيل بعد انتهاء السحب إذا كان يعمل قبل ذلك
                          if (_isPlaying) {
                            _audioPlayer.play();
                          }
                        },
                        onTapDown: (details) {
                          // حساب النسبة المئوية من موقع النقر
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final Offset localPosition =
                              box.globalToLocal(details.globalPosition);
                          final double percent =
                              localPosition.dx / box.size.width;

                          // التأكد من أن النسبة في النطاق المسموح به
                          final double clampedPercent = percent.clamp(0.0, 1.0);

                          // تحديث موضع التشغيل
                          _seekToPercent(clampedPercent);
                        },
                        child: Container(
                          height: 40,
                          child: Stack(
                            clipBehavior:
                                Clip.none, // تجنب قص العناصر خارج الحدود
                            alignment: Alignment.centerLeft,
                            children: [
                              // الشكل الموجي الكامل (خلفية)
                              _buildAnimatedWaveform(
                                  Colors.white.withOpacity(0.3)),

                              // الشكل الموجي المكتمل (حسب التقدم)
                              ClipRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: _buildAnimatedWaveform(Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // زر التشغيل/الإيقاف في نهاية خط التقدم
                    GestureDetector(
                      onTap: _togglePlayback,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying
                              ? ico_plus.FontAwesome.pause_solid
                              : ico_plus.FontAwesome.play_solid,
                          // Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),

                    // زر التحميل (إذا لم يكن الملف محملاً بالفعل)
                    if (!_isDownloaded)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: IconButton(
                          icon: const Icon(Icons.download,
                              color: Colors.white, size: 20),
                          onPressed: () => widget.controller.downloadFile(),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          iconSize: 20,
                        ),
                      ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // بناء الشكل الموجي المتحرك للصوت
  Widget _buildAnimatedWaveform(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 40),
          painter: AnimatedWaveformPainter(
            color: color,
            progress: _isPlaying
                ? _animation.value
                : 0.5, // استخدام قيمة الرسوم المتحركة فقط عند التشغيل
          ),
        );
      },
    );
  }

  // تنسيق المدة الزمنية
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildLoadingWidget() {
      final HomeController _homeController = Get.find<HomeController>();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Color.fromARGB(195, 154, 231, 185).withOpacity(0.5),
            // Color.fromARGB(255, 217, 234, 234).withOpacity(0.2)
            _homeController.getPrimaryColor().withOpacity(0.1),
            _homeController.getPrimaryColor().withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة التحميل
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // نص التحميل
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جاري تحميل الملف الصوتي...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // أيقونة الخطأ
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // رسالة الخطأ
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حدث خطأ أثناء تحميل الملف الصوتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (!mounted) return;
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                      widget.controller.setError(false);
                    });
                    _initializeAudioPlayer();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// رسام الشكل الموجي المتحرك للصوت
class AnimatedWaveformPainter extends CustomPainter {
  final Color color;
  final double progress;

  AnimatedWaveformPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 3.0;
    final space = 2.0;
    final barCount = (size.width / (barWidth + space)).floor();

    // إنشاء ارتفاعات عشوائية للأشرطة لمحاكاة الشكل الموجي
    for (int i = 0; i < barCount; i++) {
      // استخدام دالة جيب لإنشاء نمط موجي أكثر طبيعية
      final normalizedPosition = i / barCount;

      // تعديل الارتفاع ليكون متحركاً
      final amplitude = 0.4 +
          0.6 * (0.5 + 0.5 * math.sin(normalizedPosition * 10 + progress * 5));

      final height = size.height * amplitude;
      final left = i * (barWidth + space);

      final top = (size.height - height) / 2;
      final bottom = top + height;

      canvas.drawLine(
        Offset(left + barWidth / 2, top),
        Offset(left + barWidth / 2, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AnimatedWaveformPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}

// كلاس لتخزين بيانات الموضع
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}
