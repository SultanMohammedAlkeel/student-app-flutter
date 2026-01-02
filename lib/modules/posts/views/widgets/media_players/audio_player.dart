import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart' hide Rx;
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:lottie/lottie.dart';
import '../../../../home/controllers/home_controller.dart';
import '../../../controllers/media_preview_controller.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Post post;
  final String audioUrl;
  final MediaPreviewController controller;
  final bool autoPlay;
  final bool showControls;
  final bool isVisible;

  const AudioPlayerWidget({
    Key? key,
    required this.post,
    required this.audioUrl,
    required this.controller,
    this.autoPlay = false,
    this.showControls = true,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  HomeController homeController = Get.find<HomeController>();

  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  double _loadingProgress = 0.0;

  // متغيرات للرسوم المتحركة
  late AnimationController _animationController;

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
      duration: const Duration(milliseconds: 300),
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
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
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

      // محاولة تحميل الملف الصوتي من الكاش أولاً
      final cachedPath = await widget.controller.loadFile(widget.audioUrl);

      if (cachedPath != null) {
        // استخدام الملف المحلي إذا كان موجوداً
        await _audioPlayer.setFilePath(cachedPath);
      } else {
        // استخدام الرابط إذا لم يكن الملف موجوداً محلياً
        await _audioPlayer.setUrl(widget.audioUrl);
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
        maxHeight: 300, // تقليل الارتفاع للصوت
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
            homeController.getPrimaryColor().withOpacity(0.7),
            homeController.getPrimaryColor().withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // معلومات الملف الصوتي
          Row(
            children: [
              // أيقونة الصوت
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // اسم الملف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAudioFileName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ملف صوتي',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // شريط التقدم
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data ??
                  PositionData(
                    position: Duration.zero,
                    bufferedPosition: Duration.zero,
                    duration: Duration.zero,
                  );

              return ProgressBar(
                progress: positionData.position,
                buffered: positionData.bufferedPosition,
                total: positionData.duration,
                progressBarColor: Colors.white,
                baseBarColor: Colors.white.withOpacity(0.24),
                bufferedBarColor: Colors.white.withOpacity(0.5),
                thumbColor: Colors.white,
                barHeight: 4.0,
                thumbRadius: 6.0,
                timeLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                ),
                onSeek: (duration) {
                  _audioPlayer.seek(duration);
                },
              );
            },
          ),

          const SizedBox(height: 8),

          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر الإرجاع 10 ثوانٍ
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => _seekAudio(-10),
                iconSize: 24,
              ),

              const SizedBox(width: 16),

              // زر التشغيل/الإيقاف
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayback,
                  iconSize: 28,
                ),
              ),

              const SizedBox(width: 16),

              // زر التقديم 10 ثوانٍ
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => _seekAudio(10),
                iconSize: 24,
              ),
            ],
          ),

          // أزرار إضافية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر تغيير السرعة
              _buildSmallButton(
                icon: Icons.speed,
                label: '${_currentPlaybackSpeed}x',
                onPressed: _changePlaybackSpeed,
              ),

              const SizedBox(width: 8),

              // زر التكرار
              _buildSmallButton(
                icon: Icons.loop,
                label: 'تكرار',
                isActive: _isLooping,
                onPressed: _toggleLooping,
              ),

              const SizedBox(width: 8),

              // زر التحميل
              _buildSmallButton(
                icon: Icons.download,
                label: 'تحميل',
                onPressed: () => widget.controller.downloadFile(),
              ),

              const SizedBox(width: 8),

              // زر المشاركة
              _buildSmallButton(
                icon: Icons.share,
                label: 'مشاركة',
                onPressed: () => widget.controller.shareFile(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.yellow : Colors.white,
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.yellow : Colors.white,
                fontFamily: 'Tajawal',
                fontSize: 10,
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
            homeController.getPrimaryColor().withOpacity(0.7),
            homeController.getPrimaryColor().withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // رسم بياني للصوت (تمثيل بصري)
          Center(
            child: Lottie.asset(
              'assets/animations/audio_wave.json',
              width: 100,
              height: 50,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.audiotrack,
                  size: 50,
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
                const SizedBox(height: 50),
                CircularProgressIndicator(
                  value: _loadingProgress,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'جاري تحميل الملف الصوتي... ${(_loadingProgress * 100).toStringAsFixed(0)}%',
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
              'حدث خطأ أثناء تحميل الملف الصوتي',
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
                  _isLoading = true;
                  widget.controller.setError(false);
                });
                _initializeAudioPlayer();
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

  // تبديل حالة التشغيل
  void _togglePlayback() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  // تقديم أو إرجاع الصوت
  void _seekAudio(int seconds) {
    final position = _audioPlayer.position;
    final newPosition = position + Duration(seconds: seconds);
    _audioPlayer.seek(newPosition);
  }

  // تبديل حالة التكرار
  void _toggleLooping() {
    setState(() {
      _isLooping = !_isLooping;
      _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    });

    // عرض رسالة للمستخدم
    widget.controller.showInfoMessage(
      'تكرار',
      _isLooping ? 'تم تفعيل التكرار' : 'تم إلغاء التكرار',
    );
  }

  // تغيير سرعة التشغيل
  void _changePlaybackSpeed() {
    // الحصول على الفهرس الحالي
    int currentIndex = _playbackSpeeds.indexOf(_currentPlaybackSpeed);
    if (currentIndex == -1) currentIndex = 2; // افتراضي 1.0x

    // الانتقال إلى السرعة التالية
    int nextIndex = (currentIndex + 1) % _playbackSpeeds.length;
    double newSpeed = _playbackSpeeds[nextIndex];

    // تطبيق السرعة الجديدة
    _audioPlayer.setSpeed(newSpeed);

    setState(() {
      _currentPlaybackSpeed = newSpeed;
    });

    // عرض رسالة للمستخدم
    widget.controller.showInfoMessage(
      'سرعة التشغيل',
      'تم تغيير سرعة التشغيل إلى ${newSpeed}x',
    );
  }

  // الحصول على اسم الملف الصوتي
  String _getAudioFileName() {
    if (widget.post.fileUrl == null) return 'ملف صوتي';

    final fileName = widget.post.fileUrl!.split('/').last;

    // إزالة الامتداد
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }

    return fileName;
  }
}

// فئة لتخزين بيانات الموضع
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
