import 'package:get/get.dart';

class ChatMediaModel {
  final int id;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;
  final int? fileSize;
  final String? thumbnailUrl;
  final bool isLocal;
  final String? localPath;
  
  ChatMediaModel({
    required this.id,
    this.fileUrl,
    this.fileType,
    this.fileName,
    this.fileSize,
    this.thumbnailUrl,
    this.isLocal = false,
    this.localPath,
  });
  
  // تحديد نوع الملف من الامتداد
  static String getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }
  
  // تحويل حجم الملف إلى صيغة مقروءة
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // إنشاء نسخة جديدة مع تحديث البيانات
  ChatMediaModel copyWith({
    int? id,
    String? fileUrl,
    String? fileType,
    String? fileName,
    int? fileSize,
    String? thumbnailUrl,
    bool? isLocal,
    String? localPath,
  }) {
    return ChatMediaModel(
      id: id ?? this.id,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isLocal: isLocal ?? this.isLocal,
      localPath: localPath ?? this.localPath,
    );
  }
}

// وحدة تحكم معاينة الوسائط
class ChatMediaPreviewController extends GetxController {
  final Rx<ChatMediaModel?> currentMedia = Rx<ChatMediaModel?>(null);
  final RxBool isPlaying = false.obs;
  final RxBool isFullScreen = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxDouble volume = 1.0.obs;
  final RxBool isMuted = false.obs;
  
  void setMedia(ChatMediaModel media) {
    currentMedia.value = media;
  }
  
  void clearMedia() {
    currentMedia.value = null;
    isPlaying.value = false;
    isFullScreen.value = false;
    progress.value = 0.0;
  }
  
  void togglePlay() {
    isPlaying.value = !isPlaying.value;
  }
  
  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
  }
  
  void updateProgress(double value) {
    progress.value = value;
  }
  
  void setVolume(double value) {
    volume.value = value;
    isMuted.value = value == 0;
  }
  
  void toggleMute() {
    if (isMuted.value) {
      isMuted.value = false;
      volume.value = 1.0;
    } else {
      isMuted.value = true;
      volume.value = 0.0;
    }
  }
}
