// ignore_for_file: unused_element

import 'package:get/get.dart';
import 'package:student_app/core/services/api_url_service.dart';

class MessageModel {
  final int id;
  final int chatId;
  final String content;
  final DateTime createdAt;
  final bool isMine;
  final bool isRead;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final int? reciver_id;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.isRead,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.reciver_id,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        id: json['id'],
        chatId: json['chat_id'],
        content: json['content'] ?? '', // تحويل null إلى سلسلة فارغة
        reciver_id: json['receiver_id'] != null
            ? int.parse(json['receiver_id'].toString())
            : null,
        createdAt: DateTime.parse(json['created_at']),
        isMine: json['is_mine'] == 1 ||
            json['is_mine'] == true, // تحويل من int أو bool
        isRead: json['is_read'] == 1 ||
            json['is_read'] == true, // تحويل من int أو bool
        fileUrl: _fixFileUrl(json['file_url']),
        fileType: json['file_type'],
        fileSize: json[
            'file_size'] // != null ? int.parse(json['file_size'].toString()) : null,
        );
  }

  // static String? _fixFileUrl(String? url) {
  //   if (url == null) return null;
  //   if (url.startsWith('http')) return url;
  //   if (url.startsWith('/')) url = url.substring(1);
  //   return 'http://192.168.1.9:8000/$url'; // استخدم عنوان الخادم الخاص بك
  // }
    static String? _fixFileUrl(String? url) {
    if (url == null) return null;
    final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();
    return _apiUrlService.getImageUrl(url);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'receiver_id': reciver_id,
      'content': content,
      'created_at': createdAt,
      'is_mine': isMine,
      'is_read': isRead,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }
}
