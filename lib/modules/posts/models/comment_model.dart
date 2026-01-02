import 'package:intl/intl.dart';

class Comment {
  final int id;
  final int postId; // تغيير من optional إلى required
  final String content;
  final DateTime createdAt;
  final String userName;
  final String userImage;
  final int userId; // إضافة معرف المستخدم

  Comment({
    required this.id,
    required this.postId, // تغيير إلى required
    required this.content,
    required this.createdAt,
    required this.userName,
    required this.userImage,
    required this.userId, // إضافة جديد
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    try {
      return Comment(
        id: _parseInt(json['id']),
        postId: _parseInt(json['post_id']),
        content: _parseString(json['content']),
        createdAt: _parseDateTime(json['created_at']),
        userName: _parseUserName(json),
        userImage: _parseUserImage(json),
        userId: _parseInt(json['user_id'] ?? json['user']?['id']),
      );
    } catch (e) {
      throw FormatException('Failed to parse Comment: $e');
    }
  }

  // --- دوال مساعدة للتحليل الآمن ---

  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      throw FormatException('Invalid date format: $dateString');
    }
  }

  static String _parseString(dynamic value) {
    if (value == null) throw FormatException('Value cannot be null');
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) throw FormatException('Value cannot be null');
    final parsedValue = int.tryParse(value.toString());
    if (parsedValue == null) {
      throw FormatException('Invalid integer: $value');
    }
    return parsedValue;
  }

  static String _parseUserName(Map<String, dynamic> json) {
    final name = json['user_name'] ?? json['user']?['name'];
    if (name == null || name.toString().isEmpty) {
      return 'مستخدم غير معروف';
    }
    return name.toString();
  }

  static String _parseUserImage(Map<String, dynamic> json) {
    final image = json['user_image'] ?? json['user']?['image_url'];
    return image?.toString() ?? '';
  }

  // --- دوال مساعدة للتنسيق ---

  String get formattedDate {
    return DateFormat('yyyy/MM/dd HH:mm').format(createdAt);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) return 'قبل ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'قبل ${difference.inHours} ساعة';
    if (difference.inDays == 1) return 'بالأمس';
    if (difference.inDays < 7) return 'قبل ${difference.inDays} أيام';
    
    return formattedDate;
  }
}