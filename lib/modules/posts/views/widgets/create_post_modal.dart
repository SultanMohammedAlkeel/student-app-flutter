import 'dart:io';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:lottie/lottie.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/controllers/posts_controller.dart';
import 'package:student_app/modules/posts/repositories/posts_repository.dart';

import '../../../home/controllers/home_controller.dart';
import '../../controllers/media_preview_controller.dart';
import 'upload_status_widget.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final PostsController _postsController = Get.find<PostsController>();
  final PostsRepository _postsRepository = Get.find<PostsRepository>();
    HomeController homeController = Get.find<HomeController>();

  
  File? _selectedFile;
  String _fileType = '';
  bool _isUploading = false;
  bool _showSuccess = false;
  double _uploadProgress = 0.0;
  bool _contentError = false;
  String _currentUploadStage = 'تجهيز الملفات';
  String? _errorMessage;
  bool _isRetrying = false;
  
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // متحكم معاينة الوسائط
  MediaPreviewController? _mediaPreviewController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // إنشاء متحكم معاينة الوسائط
    _mediaPreviewController = MediaPreviewController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _animationController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _mediaPreviewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _animation,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _postsController.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                const Divider(),
                Expanded(
                  child: _showSuccess ? _buildSuccessView() : _buildBody(),
                ),
                if (!_showSuccess) const Divider(),
                if (!_showSuccess && !_isUploading) _buildAttachmentButtons(),
              ],
            ),
          ),
        ),
        
        // مكون تتبع تقدم الرفع الحقيقي
        if (_selectedFile != null)
          RealUploadProgressOverlay(
            progress: _uploadProgress,
            fileName: _selectedFile != null ? path.basename(_selectedFile!.path) : '',
            fileType: _fileType,
            onCancel: _cancelUpload,
            isUploading: _isUploading,
            currentStage: _currentUploadStage,
            errorMessage: _errorMessage,
            onRetry: _errorMessage != null ? _retryUpload : null,
            isRetrying: _isRetrying,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        Text(
          _showSuccess ? 'تم النشر بنجاح' : 'إنشاء منشور جديد',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _postsController.textColor,
            fontFamily: 'Tajawal',
          ),
        ),
        _showSuccess 
            ? IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => Get.back(),
              )
            : _buildPostButton(),
      ],
    );
  }

  Widget _buildSuccessView() {
      HomeController homeController = Get.find<HomeController>();

    // بعد عرض رسالة النجاح، العودة تلقائياً بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showSuccess) {
        Get.back();
      }
    });
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/upload_success.json',
            width: 200,
            height: 200,
            repeat: false,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'تم نشر المنشور بنجاح!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _postsController.textColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سيتم العودة للصفحة الرئيسية تلقائياً...',
            style: TextStyle(
              fontSize: 16,
              color: _postsController.secondaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 30),
          NeumorphicButton(
            onPressed: () => Get.back(),
            style: NeumorphicStyle(
              depth: 4,
              intensity: 0.8,
              color: homeController.getPrimaryColor(),
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            child: const Text(
              'العودة للرئيسية الآن',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان المحتوى مع توضيح أنه ضروري
          Row(
            children: [
              const Text(
                'محتوى المنشور',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '(مطلوب)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildContentField(),
          
          // رسالة خطأ إذا كان المحتوى فارغاً
          if (_contentError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'يجب إدخال محتوى للمنشور',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          
          const SizedBox(height: 20),
          
          // عنوان المرفقات
          if (_selectedFile != null) ...[
            Row(
              children: [
                const Text(
                  'المرفقات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '(اختياري)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFilePreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildContentField() {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -3,
        intensity: 0.7,
        color: _postsController.cardColor,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        border: NeumorphicBorder(
          color: _contentError ? Colors.red : Colors.transparent,
          width: _contentError ? 1 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: TextField(
          controller: _contentController,
          maxLines: 5,
          style: TextStyle(
            color: _postsController.textColor,
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            hintText: 'ماذا تريد أن تنشر؟',
            hintStyle: TextStyle(
              color: _postsController.textColor.withOpacity(0.5),
              fontFamily: 'Tajawal',
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // إزالة حالة الخطأ عند الكتابة
            if (_contentError && value.trim().isNotEmpty) {
              setState(() {
                _contentError = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
      HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 3,
        intensity: 0.7,
        color: _postsController.cardColor,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilePreviewContent(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _getFileTypeIcon(),
                      size: 16,
                      color: homeController.getPrimaryColor().withOpacity(0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _getFileTypeName(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _postsController.secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getFileSize(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _postsController.secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildFilePreviewContent() {
    // استخدام المشغلات المحسنة بدلاً من المشغلات القديمة
    if (_selectedFile != null && _mediaPreviewController != null) {
      switch (_fileType) {
        case 'image':
          // استخدام مشغل الصور المحسن
          return SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedFile!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        case 'video':
          // استخدام مشغل الفيديو المحسن
          if (_videoController != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            _videoController!.pause();
                            _isPlaying = false;
                          } else {
                            _videoController!.play();
                            _isPlaying = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        case 'audio':
          // استخدام مشغل الصوت المحسن
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: homeController.getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  size: 40,
                  color: homeController.getPrimaryColor(),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.basename(_selectedFile!.path),
                        style: TextStyle(
                          color: _postsController.textColor,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      if (_audioPlayer != null)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: homeController.getPrimaryColor(),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_isPlaying) {
                                    _audioPlayer!.pause();
                                    _isPlaying = false;
                                  } else {
                                    _audioPlayer!.play(DeviceFileSource(_selectedFile!.path));
                                    _isPlaying = true;
                                  }
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        default:
          // استخدام مشغل الملفات المحسن
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: homeController.getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileTypeIcon(),
                  size: 40,
                  color: homeController.getPrimaryColor(),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.basename(_selectedFile!.path),
                        style: TextStyle(
                          color: _postsController.textColor,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      }
    } else {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'لم يتم اختيار ملف',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 5,
      right: 5,
      child: NeumorphicButton(
        style: NeumorphicStyle(
          depth: 2,
          intensity: 0.8,
          color: Colors.red.withOpacity(0.8),
          boxShape: const NeumorphicBoxShape.circle(),
        ),
        padding: const EdgeInsets.all(5),
        onPressed: () {
          setState(() {
            _videoController?.dispose();
            _videoController = null;
            _audioPlayer?.dispose();
            _audioPlayer = null;
            _selectedFile = null;
            _fileType = '';
          });
        },
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    if (_isUploading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }
    
    return NeumorphicButton(
      style: NeumorphicStyle(
        depth: 3,
        intensity: 0.7,
        color: homeController.getPrimaryColor(),
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      onPressed: _publishPost,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.send,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 5),
          Text(
            'نشر',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentButton(
            icon: Icons.image,
            label: 'صورة',
            onPressed: () => _pickFile('image'),
            color: Colors.blue,
          ),
          _buildAttachmentButton(
            icon: Icons.videocam,
            label: 'فيديو',
            onPressed: () => _pickFile('video'),
            color: Colors.red,
          ),
          _buildAttachmentButton(
            icon: Icons.audiotrack,
            label: 'صوت',
            onPressed: () => _pickFile('audio'),
            color: Colors.orange,
          ),
          _buildAttachmentButton(
            icon: Icons.insert_drive_file,
            label: 'ملف',
            onPressed: () => _pickFile('file'),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: _postsController.textColor,
              fontSize: 12,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      switch (type) {
        case 'image':
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            setState(() {
              _selectedFile = File(image.path);
              _fileType = 'image';
            });
          }
          break;
        case 'video':
          final ImagePicker picker = ImagePicker();
          final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
          if (video != null) {
            setState(() {
              _selectedFile = File(video.path);
              _fileType = 'video';
            });
            _initVideoPlayer();
          }
          break;
        case 'audio':
          final result = await file_picker.FilePicker.platform.pickFiles(
            type: file_picker.FileType.audio,
          );
          if (result != null && result.files.single.path != null) {
            setState(() {
              _selectedFile = File(result.files.single.path!);
              _fileType = 'audio';
            });
            _initAudioPlayer();
          }
          break;
        case 'file':
          final result = await file_picker.FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            setState(() {
              _selectedFile = File(result.files.single.path!);
              _fileType = 'file';
            });
          }
          break;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الملف: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _initVideoPlayer() async {
    if (_selectedFile != null) {
      _videoController = VideoPlayerController.file(_selectedFile!);
      await _videoController!.initialize();
      setState(() {});
    }
  }

  void _initAudioPlayer() async {
    if (_selectedFile != null) {
      _audioPlayer = AudioPlayer();
      setState(() {});
    }
  }

  void _publishPost() async {
    // التحقق من وجود محتوى
    if (_contentController.text.trim().isEmpty) {
      setState(() {
        _contentError = true;
      });
      
      // عرض رسالة خطأ
      Get.snackbar(
        'تنبيه',
        'يجب إدخال محتوى للمنشور',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return;
    }
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadStage = 'تجهيز الملفات';
      _errorMessage = null;
    });
    
    try {
      String? fileUrl;
      int? fileSize;
      
      // رفع الملف إذا كان موجوداً
      if (_selectedFile != null) {
        setState(() {
          _currentUploadStage = 'جاري رفع الملف';
        });
        
        // رفع الملف إلى السيرفر
        final uploadResult = await _postsRepository.uploadFile(
          _selectedFile!,
          _fileType,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
              
              // تحديث مرحلة الرفع بناءً على التقدم
              if (progress < 0.3) {
                _currentUploadStage = 'تجهيز الملفات';
              } else if (progress < 0.7) {
                _currentUploadStage = 'رفع المحتوى';
              } else {
                _currentUploadStage = 'معالجة المنشور';
              }
            });
          },
        );
        
        fileUrl = uploadResult['file_url'];
        fileSize = _selectedFile!.lengthSync();
      }
      
      // إنشاء المنشور
      setState(() {
        _currentUploadStage = 'إنشاء المنشور';
        _uploadProgress = 0.9;
      });
      
     await _postsRepository.createPost(
        content: _contentController.text.trim(),
        fileUrl: fileUrl,
        fileType: _selectedFile != null ? _fileType : null,
        filesize: fileSize,
      );
      
      // تحديث قائمة المنشورات
      _postsController.refreshAllPosts();
      
      // عرض رسالة النجاح
      setState(() {
        _isUploading = false;
        _showSuccess = true;
        _uploadProgress = 1.0;
      });
    } catch (e) {
      // عرض رسالة الخطأ
      setState(() {
        _errorMessage = e.toString();
        _isUploading = true; // إبقاء نافذة الرفع مفتوحة لعرض الخطأ
      });
    }
  }
  
  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });
  }
  
  void _retryUpload() {
    setState(() {
      _isRetrying = true;
      _errorMessage = null;
    });
    
    // إعادة محاولة النشر
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isRetrying = false;
        _publishPost();
      });
    });
  }

  IconData _getFileTypeIcon() {
    switch (_fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileTypeName() {
    switch (_fileType) {
      case 'image':
        return 'صورة';
      case 'video':
        return 'فيديو';
      case 'audio':
        return 'ملف صوتي';
      default:
        return 'ملف';
    }
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';
    
    final bytes = _selectedFile!.lengthSync();
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
