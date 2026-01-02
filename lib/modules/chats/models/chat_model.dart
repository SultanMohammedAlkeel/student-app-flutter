import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';

class ChatModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastMessageTime; // أو DateTime إذا كنت تريد تحويله
  final int unreadCount;
  final bool isOnline;
  final int isBlocked;
  final String type;

  ChatModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.type,
    this.lastMessage,
    this.lastMessageTime, // أضف هذا السطر
    this.isBlocked = 0,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      imageUrl: _fixImageUrl(json['image_url']),
      type: json['type'] ?? 'individual',
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
      isBlocked: json['is_blocked'] ?? false,
      isOnline: json['is_online'] ?? false,
    );
  }
  // static String? _fixImageUrl(String? url) {
  //   if (url == null) return null;
  //   if (url.startsWith('http')) return url;
  //   if (url.startsWith('/')) url = url.substring(1);
  //   return 'http://192.168.1.9:8000/$url'; // استخدم عنوان الخادم الخاص بك
  // }
  static String? _fixImageUrl(String? url) {
    if (url == null) return null;
    final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();
    return _apiUrlService.getImageUrl(url);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'type': type,
      'last_message': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unread_count': unreadCount,
      'is_blocked': isBlocked,
      'is_online': isOnline,
    };
  }

  ChatModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? type,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    int? isBlocked,
    bool? isTyping,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
