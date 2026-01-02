import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../home/controllers/home_controller.dart';

class MediaPreviewController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isPlaying = false.obs;
  final RxBool _isDownloading = false.obs;
  final RxDouble _downloadProgress = 0.0.obs;
  final Rx<Post?> _post = Rx<Post?>(null);
  final Dio _dio = Dio();
  
  // كاش للملفات المحملة
  final Map<String, String> _fileCache = {};
  
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasError => _hasError.value;
  bool get isPlaying => _isPlaying.value;
  bool get isDownloading => _isDownloading.value;
  double get downloadProgress => _downloadProgress.value;
  Post? get post => _post.value;
  
  void setLoading(bool value) {
    _isLoading.value = value;
  }
  
  void setInitialized(bool value) {
    _isInitialized.value = value;
  }
  
  void setError(bool value) {
    _hasError.value = value;
  }
  
  void setPlaying(bool value) {
    _isPlaying.value = value;
  }
  
  void setPost(Post post) {
    _post.value = post;
  }
  
  // التحقق من وجود الملف في الكاش
  bool isFileCached(String url) {
    return _fileCache.containsKey(url) && File(_fileCache[url]!).existsSync();
  }
  
  // الحصول على مسار الملف من الكاش
  String? getCachedFilePath(String url) {
    return _fileCache[url];
  }
  
  // تحميل الملف مع دعم الكاش
  Future<String?> loadFile(String url, {bool forceDownload = false}) async {
    // التحقق من وجود الملف في الكاش
    if (!forceDownload && isFileCached(url)) {
      return _fileCache[url];
    }
    
    try {
      _isDownloading.value = true;
      _downloadProgress.value = 0.0;
      
      // الحصول على مسار التخزين
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;

      final savePath = '${directory.path}/$fileName';
      
      // التحقق مما إذا كان الملف موجوداً بالفعل
      if (await File(savePath).exists()) {
        _isDownloading.value = false;
        _downloadProgress.value = 1.0;
        
        // إضافة الملف إلى الكاش
        _fileCache[url] = savePath;
        
        return savePath;
      }
      
      // تحميل الملف
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress.value = received / total;
          }
        },
      );
      
      _isDownloading.value = false;
      _downloadProgress.value = 1.0;
      
      // إضافة الملف إلى الكاش
      _fileCache[url] = savePath;
      
      return savePath;
    } catch (e) {
      _isDownloading.value = false;
      showErrorMessage('فشل في تحميل الملف: ${e.toString()}');
      return null;
    }
  }
  
  // تحميل الملف للمستخدم
  Future<void> downloadFile() async {
    if (_post.value == null || _post.value!.fileUrl == null) {
      showErrorMessage('لا يوجد ملف للتحميل');
      return;
    }
    
    try {
      final url = _post.value!.fileUrl!;
      
      // تحميل الملف إذا لم يكن موجوداً بالفعل
      final filePath = await loadFile(url);
      
      if (filePath == null) {
        showErrorMessage('فشل في تحميل الملف');
        return;
      }
      
      showSuccessMessage(
        'تم التحميل بنجاح',
        'تم حفظ الملف في: $filePath',
      );
      
      // فتح الملف بعد التحميل
      await OpenFile.open(filePath);
    } catch (e) {
      showErrorMessage('فشل في تحميل الملف: ${e.toString()}');
    }
  }
  
  // تحميل الملف من منشور
  Future<void> downloadFileFromPost(Post post) async {
    setPost(post);
    await downloadFile();
  }
  
  // مشاركة الملف
  Future<void> shareFile() async {
    if (_post.value == null) {
      showErrorMessage('لا يوجد محتوى للمشاركة');
      return;
    }
    
    try {
      final String? fileUrl = _post.value!.fileUrl;
      final String? content = _post.value!.content;
      
      // إذا كان هناك ملف، تحميله أولاً ثم مشاركته
      if (fileUrl != null) {
        final filePath = await loadFile(fileUrl);
        
        if (filePath != null) {
          // مشاركة الملف مع النص
          if (content != null && content.isNotEmpty) {
            await Share.shareXFiles(
              [XFile(filePath)],
              text: content,
            );
          } else {
            await Share.shareXFiles([XFile(filePath)]);
          }
          return;
        }
      }
      
      // إذا لم يكن هناك ملف أو فشل التحميل، مشاركة النص فقط
      String shareText = '';
      
      if (content != null && content.isNotEmpty) {
        shareText += content;
      }
      
      if (fileUrl != null) {
        if (shareText.isNotEmpty) {
          shareText += '\n\n';
        }
        shareText += 'رابط الملف: $fileUrl';
      }
      
      await Share.share(shareText);
    } catch (e) {
      showErrorMessage('فشل في مشاركة المحتوى: ${e.toString()}');
    }
  }
  
  // فتح الملف في متصفح أو تطبيق خارجي
  Future<void> openFileExternally() async {
    if (_post.value == null || _post.value!.fileUrl == null) {
      showErrorMessage('لا يوجد ملف للفتح');
      return;
    }
    
    try {
      final url = _post.value!.fileUrl!;
      
      // محاولة فتح الملف المحلي إذا كان موجوداً
      if (isFileCached(url)) {
        final filePath = getCachedFilePath(url);
        if (filePath != null) {
          await OpenFile.open(filePath);
          return;
        }
      }
      
      // إذا لم يكن الملف موجوداً محلياً، فتح الرابط في المتصفح
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // إذا فشل فتح الرابط، محاولة تحميل الملف
        showInfoMessage('جاري تحميل الملف...', 'سيتم فتح الملف بعد اكتمال التحميل');
        final filePath = await loadFile(url, forceDownload: true);
        if (filePath != null) {
          await OpenFile.open(filePath);
        } else {
          showErrorMessage('لا يمكن فتح الرابط: $url');
        }
      }
    } catch (e) {
      showErrorMessage('فشل في فتح الملف: ${e.toString()}');
    }
  }
  
  // عرض رسالة خطأ
  void showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  
  // عرض رسالة نجاح
  void showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  
  // عرض رسالة معلومات
  void showInfoMessage(String title, String message) {
      HomeController homeController = Get.find<HomeController>();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: homeController.getPrimaryColor(),
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
  
  @override
  void onClose() {
    // تنظيف الموارد عند إغلاق المتحكم
    _isLoading.value = false;
    _isInitialized.value = false;
    _hasError.value = false;
    _isPlaying.value = false;
    _isDownloading.value = false;
    _downloadProgress.value = 0.0;
    super.onClose();
  }
}
