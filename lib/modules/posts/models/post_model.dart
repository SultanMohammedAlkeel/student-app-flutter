import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';

class Post {
  final int id;
  final int senderId;
  final String content;
  final String? fileUrl;
  final String fileType;
  final int fileSize;
  final int viewsCount;
  final int likesCount;
  final int commentsCount;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String userImage;
  final bool isLiked;
  final bool isSaved;
  final bool hasMedia;

  Post({
    required this.id,
    required this.senderId,
    required this.content,
    this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.viewsCount,
    required this.likesCount,
    required this.commentsCount,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userImage,
    required this.isLiked,
    required this.isSaved,
    required this.hasMedia,
  });

  static String _parseDateTime(dynamic value) {
    try {
      if (value == null) return DateTime.now().toIso8601String();

      // تحويل التاريخ من السيرفر إلى التوقيت المحلي
      final dateTime = DateTime.parse(value.toString()).toLocal();
      return dateTime.toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _parseInt(json['id']),
      senderId: _parseInt(json['sender_id']),
      content: json['content']?.toString() ?? '',
      fileUrl: fileUrlToServer(json['file_url']?.toString()),
      fileType: json['file_type']?.toString() ?? 'نص',
      fileSize: _parseInt(json['file_size']),
      viewsCount: _parseInt(json['views_count']),
      likesCount: _parseInt(json['likes_count']),
      commentsCount: _parseInt(json['comments_count']),
      isDeleted: _parseBool(json['deleted']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      userName: json['user_name']?.toString() ?? 'مستخدم',
      userImage: json['user_image']?.toString() ?? 'images/profiles/default.png',
      isLiked: _parseBool(json['is_liked']),
      isSaved: _parseBool(json['is_saved']),
      hasMedia: _parseBool(json['file_url'] == null ? false : true),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  Post copyWith({
    int? id,
    int? senderId,
    String? content,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    int? viewsCount,
    int? likesCount,
    int? commentsCount,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? userName,
    String? userImage,
    bool? isLiked,
    bool? isSaved,
    bool? hasMedia,
  }) {
    return Post(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      hasMedia: hasMedia ?? this.hasMedia,
    );
  }

  static String fileUrlToServer(String? serverUrl) {
    if (serverUrl == null || serverUrl.isEmpty) return '';
    
    final apiUrlService = Get.find<ApiUrlService>();
    
    // إذا كان الرابط يحتوي بالفعل على http (رابط كامل)
    if (serverUrl.startsWith('http')) {
      return serverUrl;
    }
    
    // إزالة / من البداية إذا كانت موجودة
    if (serverUrl.startsWith('/')) {
      serverUrl = serverUrl.substring(1);
    }
    
    return '${apiUrlService.apiBaseUrl}$serverUrl';
  }
}