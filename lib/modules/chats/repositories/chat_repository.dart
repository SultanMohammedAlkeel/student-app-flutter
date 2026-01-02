// modules/chats/repositories/chat_repository.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:student_app/core/network/api_service.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'package:student_app/modules/chats/models/chat_model.dart';
import 'package:student_app/modules/chats/models/message_model.dart';

class ChatRepository {
  final ApiService _apiService = Get.find<ApiService>();

  /// جلب المستخدمين المتاحين للدردشة
  Future<List<Map<String, dynamic>>> getAvailableUsers({String? type}) async {
    try {
      print('جلب المستخدمين المتاحين من الخادم...');
      print('نوع التصفية: $type');

      String url = '/chat/available-users';
      if (type != null && type.isNotEmpty && type != 'الكل') {
        url += '?type=$type';
      }

      final response = await _apiService.get(url);

      print('استجابة الخادم للمستخدمين المتاحين: ${response.statusCode}');
      print('بيانات المستخدمين: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usersData = response.data['data'] ?? [];

        final List<Map<String, dynamic>> users = usersData.map((userData) {
          return Map<String, dynamic>.from(userData);
        }).toList();

        print('تم جلب ${users.length} مستخدم متاح');
        return users;
      } else {
        print('فشل في جلب المستخدمين المتاحين: ${response.data}');
        throw Exception('فشل في جلب المستخدمين المتاحين');
      }
    } catch (e) {
      print('خطأ في جلب المستخدمين المتاحين: $e');
      throw e;
    }
  }

  /// إضافة مستخدم جديد إلى قائمة الاتصالات (نفس منطق ContactController)
  Future<bool> addContact(int friendId, String friendType) async {
    try {
      print('إضافة مستخدم جديد إلى قائمة الاتصالات...');
      print('معرف المستخدم: $friendId، النوع: $friendType');

      final response = await _apiService.post('/chat/add-contact', data: {
        'friend_id': friendId,
        'friend_type': friendType,
      });

      print('استجابة إضافة المستخدم: ${response.statusCode}');
      print('بيانات الاستجابة: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('تم إضافة المستخدم بنجاح إلى قائمة الاتصالات');
        return true;
      } else {
        print('فشل في إضافة المستخدم: ${response.data}');
        return false;
      }
    } catch (e) {
      print('خطأ في إضافة المستخدم: $e');
      return false;
    }
  }

  /// إنشاء محادثة جديدة (للاستخدام المستقبلي)
  Future<ChatModel?> createChat(List<int> participants) async {
    try {
      print('إنشاء محادثة جديدة مع المشاركين: $participants');

      final response = await _apiService.post('/chat/create', data: {
        'participants': participants,
      });

      print('استجابة إنشاء المحادثة: ${response.statusCode}');
      print('بيانات الاستجابة: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('تم إنشاء المحادثة بنجاح');
        return ChatModel.fromJson(response.data['data']);
      } else {
        print('فشل في إنشاء المحادثة: ${response.data}');
        return null;
      }
    } catch (e) {
      print('خطأ في إنشاء المحادثة: $e');
      return null;
    }
  }

  /// حظر/إلغاء حظر مستخدم
  Future<bool> blockUser(int contactId) async {
    try {
      final response = await _apiService.post('/chat/block-user', data: {
        'contact_id': contactId,
      });

      return response.data != null && response.data['success'] == true;
    } catch (e) {
      print('خطأ في حظر المستخدم: $e');
      throw Exception('فشل في حظر المستخدم: ${e.toString()}');
    }
  }

  Future<bool> unblockUser(int contactId) async {
    try {
      final response = await _apiService.post(
        '/chat/unblock-user',
        data: {
          'contact_id': contactId,
        },
      );
      return response.data != null && response.data['success'] == true;
    } catch (e) {
      print('خطأ في إلغاء حظر المستخدم: $e');
      throw Exception('فشل في إلغاء حظر المستخدم: ${e.toString()}');
    }
  }

  // جلب حالة الاتصال للمستخدمين
  Future<Map<int, bool>> getUsersOnlineStatus() async {
    try {
      final response = await _apiService.getWithToken('/users/online-status');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data ?? {};
        final Map<int, bool> result = {};

        data.forEach((key, value) {
          final userId = int.tryParse(key);
          if (userId != null) {
            result[userId] = value == true;
          }
        });

        return result;
      }

      return {};
    } catch (e) {
      print('Error fetching online status: $e');
      return {};
    }
  }

  // تحديث حالة اتصال المستخدم
  Future<bool> updateUserOnlineStatus(int userId, bool isOnline) async {
    try {
      final response = await _apiService.postWithToken(
        '/users/$userId/online-status',
        data: {
          'is_online': isOnline,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating online status: $e');
      return false;
    }
  }

  // الحصول على قائمة المجموعات
  Future<List<dynamic>> getGroups() async {
    try {
      final response = await _apiService.getWithToken('/groups');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  // الحصول على قائمة القنوات
  Future<List<dynamic>> getChannels() async {
    try {
      final response = await _apiService.getWithToken('/groups?type=channel');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching channels: $e');
      return [];
    }
  }

  // الحصول على تفاصيل مجموعة محددة
  Future<dynamic> getGroupDetails(int groupId) async {
    try {
      final response = await _apiService.getWithToken('/groups/$groupId');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching group details: $e');
      rethrow;
    }
  }

  // إرسال رسالة إلى مجموعة
  Future<dynamic> sendGroupMessage({
    required int groupId,
    required String message,
    String? filePath,
    String? fileType,
    int? replyToId,
  }) async {
    try {
      if (filePath != null) {
        final file = await MultipartFile.fromFile(filePath);

        // إنشاء FormData مع معلومات إضافية عن نوع الملف
        final formData = FormData.fromMap({
          'content': message,
          'file': file,
          'file_type': fileType ?? _getFileTypeFromPath(filePath),
          if (replyToId != null) 'reply_to_id': replyToId,
        });

        final response = await _apiService.postWithToken(
          '/groups/$groupId/messages',
          data: formData,
        );

        return response.data['data'];
      } else {
        final response = await _apiService.postWithToken(
          '/groups/$groupId/messages',
          data: {
            'content': message,
            if (replyToId != null) 'reply_to_id': replyToId,
          },
        );

        return response.data['data'];
      }
    } catch (e) {
      print('Error sending group message: $e');
      rethrow;
    }
  }

  // إنشاء مجموعة جديدة
  Future<dynamic> createGroup({
    required String name,
    String? description,
    required String type,
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final image = await MultipartFile.fromFile(imagePath);

        final formData = FormData.fromMap({
          'name': name,
          'type': type,
          'image': image,
          if (description != null) 'description': description,
        });

        final response = await _apiService.postWithToken(
          '/groups',
          data: formData,
        );

        return response.data['data'];
      } else {
        final response = await _apiService.postWithToken(
          '/groups',
          data: {
            'name': name,
            'type': type,
            if (description != null) 'description': description,
          },
        );

        return response.data['data'];
      }
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  // الحصول على رسائل المجموعة
  Future<List<dynamic>> getGroupMessages(int groupId) async {
    try {
      final response =
          await _apiService.getWithToken('/groups/$groupId/messages');

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['data'] ?? [];
        return messagesJson;
      } else {
        throw Exception(
            'Failed to load group messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGroupMessages: $e');
      rethrow;
    }
  }

  // إضافة عضو إلى المجموعة
  Future<bool> addGroupMember(int groupId, int userId,
      {bool isAdmin = false}) async {
    try {
      final response = await _apiService.postWithToken(
        '/groups/$groupId/members',
        data: {
          'user_id': userId,
          'is_admin': isAdmin,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding group member: $e');
      return false;
    }
  }

  // إزالة عضو من المجموعة
  Future<bool> removeGroupMember(int groupId, int userId) async {
    try {
      final response = await _apiService.delete(
        '/groups/$groupId/members',
        data: {
          'user_id': userId,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing group member: $e');
      return false;
    }
  }

  // مغادرة المجموعة
  Future<bool> leaveGroup(int groupId) async {
    try {
      final response = await _apiService.postWithToken(
        '/groups/$groupId/leave',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error leaving group: $e');
      return false;
    }
  }

  final StorageService _storageService = Get.find<StorageService>();

  // مفاتيح التخزين المحلي
  static const String CACHED_CHATS_KEY = 'cached_chats';
  static const String CACHED_MESSAGES_PREFIX = 'cached_messages_';
  static const String LAST_FETCH_TIME_PREFIX = 'last_fetch_time_';

  Future<List<ChatModel>> getChats() async {
    // محاولة استرجاع البيانات المخزنة محليًا أولاً
    List<ChatModel> cachedChats = _getCachedChats();

    // إذا كانت هناك بيانات مخزنة، نعرضها فورًا
    if (cachedChats.isNotEmpty) {
      print('استرجاع ${cachedChats.length} محادثة من التخزين المحلي');
    }

    try {
      // محاولة جلب البيانات الحديثة من الخادم
      final response = await _apiService.getWithToken('/chat');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["users"] ?? [];
        final List<int> blockedUserIds =
            response.data["blocked_users"]?.cast<int>() ?? [];
        final List<ChatModel> serverChats =
            data.map((json) => ChatModel.fromJson(json)).toList();

        // تصفية المستخدمين المحظورين من قائمة الدردشات
        final List<ChatModel> filteredChats = serverChats
            .where((chat) => !blockedUserIds.contains(chat.id))
            .toList();

        // تخزين البيانات الجديدة محليًا (بعد التصفية)
        _cacheChats(filteredChats);

        print("تم تحديث ${filteredChats.length} محادثة في التخزين المحلي");
        return filteredChats;
      }

      // إذا فشل الاتصال بالخادم ولكن لدينا بيانات مخزنة، نعيد البيانات المخزنة
      if (cachedChats.isNotEmpty) {
        return cachedChats;
      }

      return [];
    } catch (e) {
      print('خطأ في جلب المحادثات: $e');

      // في حالة حدوث خطأ، نعيد البيانات المخزنة محليًا إذا كانت موجودة
      if (cachedChats.isNotEmpty) {
        return cachedChats;
      }

      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(int chatId) async {
    // محاولة استرجاع الرسائل المخزنة محليًا أولاً
    List<MessageModel> cachedMessages = _getCachedMessages(chatId);

    // إذا كانت هناك رسائل مخزنة، نعرضها فورًا
    if (cachedMessages.isNotEmpty) {
      print(
          'استرجاع ${cachedMessages.length} رسالة من التخزين المحلي للمحادثة $chatId');
    }

    try {
      // محاولة جلب الرسائل الحديثة من الخادم
      final response = await _apiService.getWithToken('/chat/$chatId/messages');

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data;
        print('Raw messages data: $messagesJson');

        final List<MessageModel> serverMessages = messagesJson.map((json) {
          try {
            return MessageModel.fromJson(json);
          } catch (e) {
            print('Error parsing message: $e');
            print('Problematic message: $json');
            throw e;
          }
        }).toList();

        // تخزين الرسائل الجديدة محليًا
        _cacheMessages(chatId, serverMessages);

        print(
            'تم تحديث ${serverMessages.length} رسالة في التخزين المحلي للمحادثة $chatId');
        return serverMessages;
      } else {
        // إذا فشل الاتصال بالخادم ولكن لدينا رسائل مخزنة، نعيد الرسائل المخزنة
        if (cachedMessages.isNotEmpty) {
          return cachedMessages;
        }

        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMessages: $e');

      // في حالة حدوث خطأ، نعيد الرسائل المخزنة محليًا إذا كانت موجودة
      if (cachedMessages.isNotEmpty) {
        return cachedMessages;
      }

      rethrow;
    }
  }

  Future<MessageModel> sendMessage({
    required int contactId,
    required String message,
    String? filePath,
    String? fileType,
  }) async {
    try {
      MessageModel newMessage;

      if (filePath != null) {
        final file = await MultipartFile.fromFile(filePath);

        // إنشاء FormData مع معلومات إضافية عن نوع الملف
        final formData = FormData.fromMap({
          'contact_id': contactId,
          'message': message,
          'file': file,
          'has_media': 1,
          'file_type': fileType ?? _getFileTypeFromPath(filePath),
        });

        final response = await _apiService.postWithToken(
          '/chat/send-messages',
          data: formData,
        );

        newMessage = MessageModel.fromJson(response.data);
      } else {
        final response = await _apiService.postWithToken(
          '/chat/send-messages',
          data: {
            'contact_id': contactId,
            'message': message,
            'has_media': 0,
          },
        );

        newMessage = MessageModel.fromJson(response.data);
      }

      // تحديث الرسائل المخزنة محليًا بإضافة الرسالة الجديدة
      List<MessageModel> cachedMessages = _getCachedMessages(contactId);
      cachedMessages.add(newMessage);
      _cacheMessages(contactId, cachedMessages);

      return newMessage;
    } catch (e) {
      rethrow;
    }
  }

  // تحديد نوع الملف من المسار
  String _getFileTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp']
        .contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  Future<bool> markAsRead(int messageId) async {
    try {
      final response = await _apiService.postWithToken(
        'chat/messages/$messageId/read',
      );

      // تحديث حالة الرسالة في التخزين المحلي
      _updateMessageReadStatus(messageId, true);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete(
        'chat/messages/$messageId',
      );

      // حذف الرسالة من التخزين المحلي
      _deleteMessageFromCache(messageId);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ============ وظائف التخزين المحلي ============

  // تخزين قائمة المحادثات محليًا
  void _cacheChats(List<ChatModel> chats) {
    try {
      // تحويل قائمة المحادثات إلى قائمة من JSON
      final List<Map<String, dynamic>> chatsJson =
          chats.map((chat) => chat.toJson()).toList();

      // تخزين القائمة في GetStorage
      _storageService.write(CACHED_CHATS_KEY, chatsJson);

      // تخزين وقت آخر تحديث
      _storageService.write(LAST_FETCH_TIME_PREFIX + 'chats',
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('خطأ في تخزين المحادثات محليًا: $e');
    }
  }

  // استرجاع قائمة المحادثات من التخزين المحلي
  List<ChatModel> _getCachedChats() {
    try {
      // استرجاع قائمة JSON من GetStorage
      final List<dynamic>? chatsJson =
          _storageService.read<List<dynamic>>(CACHED_CHATS_KEY);

      if (chatsJson == null || chatsJson.isEmpty) {
        return [];
      }

      // تحويل قائمة JSON إلى قائمة من ChatModel
      return chatsJson.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في استرجاع المحادثات من التخزين المحلي: $e');
      return [];
    }
  }

  // تخزين رسائل محادثة محليًا
  void _cacheMessages(int chatId, List<MessageModel> messages) {
    try {
      // تحويل قائمة الرسائل إلى قائمة من JSON
      final List<Map<String, dynamic>> messagesJson =
          messages.map((message) => message.toJson()).toList();

      // تخزين القائمة في GetStorage
      _storageService.write(
          CACHED_MESSAGES_PREFIX + chatId.toString(), messagesJson);

      // تخزين وقت آخر تحديث
      _storageService.write(
          LAST_FETCH_TIME_PREFIX + 'messages_' + chatId.toString(),
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('خطأ في تخزين الرسائل محليًا: $e');
    }
  }

  // استرجاع رسائل محادثة من التخزين المحلي
  List<MessageModel> _getCachedMessages(int chatId) {
    try {
      // استرجاع قائمة JSON من GetStorage
      final List<dynamic>? messagesJson = _storageService
          .read<List<dynamic>>(CACHED_MESSAGES_PREFIX + chatId.toString());

      if (messagesJson == null || messagesJson.isEmpty) {
        return [];
      }

      // تحويل قائمة JSON إلى قائمة من MessageModel
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في استرجاع الرسائل من التخزين المحلي: $e');
      return [];
    }
  }

  // تحديث حالة قراءة الرسالة في التخزين المحلي
  void _updateMessageReadStatus(int messageId, bool isRead) {
    try {
      // البحث عن الرسالة في جميع المحادثات المخزنة
      for (int chatId in _getAllCachedChatIds()) {
        List<MessageModel> messages = _getCachedMessages(chatId);
        bool updated = false;

        for (int i = 0; i < messages.length; i++) {
          if (messages[i].id == messageId) {
            // إنشاء نسخة جديدة من الرسالة مع تحديث حالة القراءة
            final updatedMessage = MessageModel(
              id: messages[i].id,
              chatId: messages[i].chatId,
              content: messages[i].content,
              createdAt: messages[i].createdAt,
              isMine: messages[i].isMine,
              isRead: isRead,
              fileUrl: messages[i].fileUrl,
              fileType: messages[i].fileType,
              fileSize: messages[i].fileSize,
              reciver_id: messages[i].reciver_id,
            );

            messages[i] = updatedMessage;
            updated = true;
            break;
          }
        }

        if (updated) {
          _cacheMessages(chatId, messages);
          break;
        }
      }
    } catch (e) {
      print('خطأ في تحديث حالة قراءة الرسالة في التخزين المحلي: $e');
    }
  }

  // حذف رسالة من التخزين المحلي
  void _deleteMessageFromCache(int messageId) {
    try {
      // البحث عن الرسالة في جميع المحادثات المخزنة
      for (int chatId in _getAllCachedChatIds()) {
        List<MessageModel> messages = _getCachedMessages(chatId);
        int initialLength = messages.length;

        messages.removeWhere((message) => message.id == messageId);

        if (messages.length < initialLength) {
          _cacheMessages(chatId, messages);
          break;
        }
      }
    } catch (e) {
      print('خطأ في حذف الرسالة من التخزين المحلي: $e');
    }
  }

  // الحصول على قائمة معرفات المحادثات المخزنة محليًا
  List<int> _getAllCachedChatIds() {
    try {
      List<ChatModel> chats = _getCachedChats();
      return chats.map((chat) => chat.id).toList();
    } catch (e) {
      print('خطأ في الحصول على معرفات المحادثات المخزنة: $e');
      return [];
    }
  }
}

/*
// modules/chats/repositories/chat_repository.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:student_app/core/network/api_service.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'package:student_app/modules/chats/models/chat_model.dart';
import 'package:student_app/modules/chats/models/message_model.dart';

class ChatRepository {
  final ApiService _apiService = Get.find<ApiService>();

 

 /// جلب المستخدمين المتاحين للدردشة
  Future<List<Map<String, dynamic>>> getAvailableUsers({String? type}) async {
    try {
      print('جلب المستخدمين المتاحين من الخادم...');
      print('نوع التصفية: $type');
      
      String url = '/chat/available-users';
      if (type != null && type.isNotEmpty && type != 'الكل') {
        url += '?type=$type';
      }
      
      final response = await _apiService.get(url);
      
      print('استجابة الخادم للمستخدمين المتاحين: ${response.statusCode}');
      print('بيانات المستخدمين: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usersData = response.data['data'] ?? [];
        
        final List<Map<String, dynamic>> users = usersData.map((userData) {
          return Map<String, dynamic>.from(userData);
        }).toList();
        
        print('تم جلب ${users.length} مستخدم متاح');
        return users;
      } else {
        print('فشل في جلب المستخدمين المتاحين: ${response.data}');
        throw Exception('فشل في جلب المستخدمين المتاحين');
      }
    } catch (e) {
      print('خطأ في جلب المستخدمين المتاحين: $e');
      throw e;
    }
  }

  /// إضافة مستخدم جديد إلى قائمة الاتصالات (نفس منطق ContactController)
  Future<bool> addContact(int friendId, String friendType) async {
    try {
      print('إضافة مستخدم جديد إلى قائمة الاتصالات...');
      print('معرف المستخدم: $friendId، النوع: $friendType');
      
      final response = await _apiService.post('/chat/add-contact', data:{
        'friend_id': friendId,
        'friend_type': friendType,
      });
      
      print('استجابة إضافة المستخدم: ${response.statusCode}');
      print('بيانات الاستجابة: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('تم إضافة المستخدم بنجاح إلى قائمة الاتصالات');
        return true;
      } else {
        print('فشل في إضافة المستخدم: ${response.data}');
        return false;
      }
    } catch (e) {
      print('خطأ في إضافة المستخدم: $e');
      return false;
    }
  }

  /// إنشاء محادثة جديدة (للاستخدام المستقبلي)
  Future<ChatModel?> createChat(List<int> participants) async {
    try {
      print('إنشاء محادثة جديدة مع المشاركين: $participants');
      
      final response = await _apiService.post('/chat/create',data: {
        'participants': participants,
      });
      
      print('استجابة إنشاء المحادثة: ${response.statusCode}');
      print('بيانات الاستجابة: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('تم إنشاء المحادثة بنجاح');
        return ChatModel.fromJson(response.data['data']);
      } else {
        print('فشل في إنشاء المحادثة: ${response.data}');
        return null;
      }
    } catch (e) {
      print('خطأ في إنشاء المحادثة: $e');
      return null;
    }
  }

  /// حظر/إلغاء حظر مستخدم
  Future<bool> blockUser(int contactId) async {
    try {
      final response = await _apiService.post('/chat/block-user', data: {
        'contact_id': contactId,
      });
      
      return response.data != null && response.data['success'] == true;
    } catch (e) {
      print('خطأ في حظر المستخدم: $e');
      throw Exception('فشل في حظر المستخدم: ${e.toString()}');
    }
  }


  Future<bool> unblockUser(int contactId) async {
    try {
      final response = await _apiService.post(
        '/chat/unblock-user',
        data: {
          'contact_id': contactId,
        },
      );
      return response.data != null && response.data['success'] == true;
    } catch (e) {
      print('خطأ في إلغاء حظر المستخدم: $e');
      throw Exception('فشل في إلغاء حظر المستخدم: ${e.toString()}');
    }
  }


  // جلب حالة الاتصال للمستخدمين
  Future<Map<int, bool>> getUsersOnlineStatus() async {
    try {
      final response = await _apiService.getWithToken('/users/online-status');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data ?? {};
        final Map<int, bool> result = {};

        data.forEach((key, value) {
          final userId = int.tryParse(key);
          if (userId != null) {
            result[userId] = value == true;
          }
        });

        return result;
      }

      return {};
    } catch (e) {
      print('Error fetching online status: $e');
      return {};
    }
  }

  // تحديث حالة اتصال المستخدم
  Future<bool> updateUserOnlineStatus(int userId, bool isOnline) async {
    try {
      final response = await _apiService.postWithToken(
        '/users/$userId/online-status',
        data: {
          'is_online': isOnline,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating online status: $e');
      return false;
    }
  }

  // الحصول على قائمة المجموعات
  Future<List<dynamic>> getGroups() async {
    try {
      final response = await _apiService.getWithToken('/groups');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  // الحصول على قائمة القنوات
  Future<List<dynamic>> getChannels() async {
    try {
      final response = await _apiService.getWithToken('/groups?type=channel');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching channels: $e');
      return [];
    }
  }

  // الحصول على تفاصيل مجموعة محددة
  Future<dynamic> getGroupDetails(int groupId) async {
    try {
      final response = await _apiService.getWithToken('/groups/$groupId');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching group details: $e');
      rethrow;
    }
  }

  // إرسال رسالة إلى مجموعة
  Future<dynamic> sendGroupMessage({
    required int groupId,
    required String message,
    String? filePath,
    String? fileType,
    int? replyToId,
  }) async {
    try {
      if (filePath != null) {
        final file = await MultipartFile.fromFile(filePath);

        // إنشاء FormData مع معلومات إضافية عن نوع الملف
        final formData = FormData.fromMap({
          'content': message,
          'file': file,
          'file_type': fileType ?? _getFileTypeFromPath(filePath),
          if (replyToId != null) 'reply_to_id': replyToId,
        });

        final response = await _apiService.postWithToken(
          '/groups/$groupId/messages',
          data: formData,
        );

        return response.data['data'];
      } else {
        final response = await _apiService.postWithToken(
          '/groups/$groupId/messages',
          data: {
            'content': message,
            if (replyToId != null) 'reply_to_id': replyToId,
          },
        );

        return response.data['data'];
      }
    } catch (e) {
      print('Error sending group message: $e');
      rethrow;
    }
  }

  // إنشاء مجموعة جديدة
  Future<dynamic> createGroup({
    required String name,
    String? description,
    required String type,
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final image = await MultipartFile.fromFile(imagePath);

        final formData = FormData.fromMap({
          'name': name,
          'type': type,
          'image': image,
          if (description != null) 'description': description,
        });

        final response = await _apiService.postWithToken(
          '/groups',
          data: formData,
        );

        return response.data['data'];
      } else {
        final response = await _apiService.postWithToken(
          '/groups',
          data: {
            'name': name,
            'type': type,
            if (description != null) 'description': description,
          },
        );

        return response.data['data'];
      }
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  // الحصول على رسائل المجموعة
  Future<List<dynamic>> getGroupMessages(int groupId) async {
    try {
      final response =
          await _apiService.getWithToken('/groups/$groupId/messages');

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['data'] ?? [];
        return messagesJson;
      } else {
        throw Exception(
            'Failed to load group messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGroupMessages: $e');
      rethrow;
    }
  }

  // إضافة عضو إلى المجموعة
  Future<bool> addGroupMember(int groupId, int userId,
      {bool isAdmin = false}) async {
    try {
      final response = await _apiService.postWithToken(
        '/groups/$groupId/members',
        data: {
          'user_id': userId,
          'is_admin': isAdmin,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding group member: $e');
      return false;
    }
  }

  // إزالة عضو من المجموعة
  Future<bool> removeGroupMember(int groupId, int userId) async {
    try {
      final response = await _apiService.delete(
        '/groups/$groupId/members',
        data: {
          'user_id': userId,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing group member: $e');
      return false;
    }
  }

  // مغادرة المجموعة
  Future<bool> leaveGroup(int groupId) async {
    try {
      final response = await _apiService.postWithToken(
        '/groups/$groupId/leave',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error leaving group: $e');
      return false;
    }
  }


  final StorageService _storageService = Get.find<StorageService>();

  // مفاتيح التخزين المحلي
  static const String CACHED_CHATS_KEY = 'cached_chats';
  static const String CACHED_MESSAGES_PREFIX = 'cached_messages_';
  static const String LAST_FETCH_TIME_PREFIX = 'last_fetch_time_';

  Future<List<ChatModel>> getChats() async {
    // محاولة استرجاع البيانات المخزنة محليًا أولاً
    List<ChatModel> cachedChats = _getCachedChats();
    
    // إذا كانت هناك بيانات مخزنة، نعرضها فورًا
    if (cachedChats.isNotEmpty) {
      print('استرجاع ${cachedChats.length} محادثة من التخزين المحلي');
    }
    
    try {
      // محاولة جلب البيانات الحديثة من الخادم
      final response = await _apiService.getWithToken('/chat');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['users'] ?? [];
        final List<ChatModel> serverChats = data.map((json) => ChatModel.fromJson(json)).toList();
        
        // تخزين البيانات الجديدة محليًا
        _cacheChats(serverChats);
        
        print('تم تحديث ${serverChats.length} محادثة في التخزين المحلي');
        return serverChats;
      }
      
      // إذا فشل الاتصال بالخادم ولكن لدينا بيانات مخزنة، نعيد البيانات المخزنة
      if (cachedChats.isNotEmpty) {
        return cachedChats;
      }
      
      return [];
    } catch (e) {
      print('خطأ في جلب المحادثات: $e');
      
      // في حالة حدوث خطأ، نعيد البيانات المخزنة محليًا إذا كانت موجودة
      if (cachedChats.isNotEmpty) {
        return cachedChats;
      }
      
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(int chatId) async {
    // محاولة استرجاع الرسائل المخزنة محليًا أولاً
    List<MessageModel> cachedMessages = _getCachedMessages(chatId);
    
    // إذا كانت هناك رسائل مخزنة، نعرضها فورًا
    if (cachedMessages.isNotEmpty) {
      print('استرجاع ${cachedMessages.length} رسالة من التخزين المحلي للمحادثة $chatId');
    }
    
    try {
      // محاولة جلب الرسائل الحديثة من الخادم
      final response = await _apiService.getWithToken('/chat/$chatId/messages');

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data;
        print('Raw messages data: $messagesJson');

        final List<MessageModel> serverMessages = messagesJson.map((json) {
          try {
            return MessageModel.fromJson(json);
          } catch (e) {
            print('Error parsing message: $e');
            print('Problematic message: $json');
            throw e;
          }
        }).toList();
        
        // تخزين الرسائل الجديدة محليًا
        _cacheMessages(chatId, serverMessages);
        
        print('تم تحديث ${serverMessages.length} رسالة في التخزين المحلي للمحادثة $chatId');
        return serverMessages;
      } else {
        // إذا فشل الاتصال بالخادم ولكن لدينا رسائل مخزنة، نعيد الرسائل المخزنة
        if (cachedMessages.isNotEmpty) {
          return cachedMessages;
        }
        
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMessages: $e');
      
      // في حالة حدوث خطأ، نعيد الرسائل المخزنة محليًا إذا كانت موجودة
      if (cachedMessages.isNotEmpty) {
        return cachedMessages;
      }
      
      rethrow;
    }
  }

  Future<MessageModel> sendMessage({
    required int contactId,
    required String message,
    String? filePath,
    String? fileType,
  }) async {
    try {
      MessageModel newMessage;
      
      if (filePath != null) {
        final file = await MultipartFile.fromFile(filePath);

        // إنشاء FormData مع معلومات إضافية عن نوع الملف
        final formData = FormData.fromMap({
          'contact_id': contactId,
          'message': message,
          'file': file,
          'has_media': 1,
          'file_type': fileType ?? _getFileTypeFromPath(filePath),
        });

        final response = await _apiService.postWithToken(
          '/chat/send-messages',
          data: formData,
        );

        newMessage = MessageModel.fromJson(response.data);
      } else {
        final response = await _apiService.postWithToken(
          '/chat/send-messages',
          data: {
            'contact_id': contactId,
            'message': message,
            'has_media': 0,
          },
        );

        newMessage = MessageModel.fromJson(response.data);
      }
      
      // تحديث الرسائل المخزنة محليًا بإضافة الرسالة الجديدة
      List<MessageModel> cachedMessages = _getCachedMessages(contactId);
      cachedMessages.add(newMessage);
      _cacheMessages(contactId, cachedMessages);
      
      return newMessage;
    } catch (e) {
      rethrow;
    }
  }

  // تحديد نوع الملف من المسار
  String _getFileTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp']
        .contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  Future<bool> markAsRead(int messageId) async {
    try {
      final response = await _apiService.postWithToken(
        'chat/messages/$messageId/read',
      );
      
      // تحديث حالة الرسالة في التخزين المحلي
      _updateMessageReadStatus(messageId, true);
      
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete(
        'chat/messages/$messageId',
      );
      
      // حذف الرسالة من التخزين المحلي
      _deleteMessageFromCache(messageId);
      
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ============ وظائف التخزين المحلي ============

  // تخزين قائمة المحادثات محليًا
  void _cacheChats(List<ChatModel> chats) {
    try {
      // تحويل قائمة المحادثات إلى قائمة من JSON
      final List<Map<String, dynamic>> chatsJson = chats.map((chat) => chat.toJson()).toList();
      
      // تخزين القائمة في GetStorage
      _storageService.write(CACHED_CHATS_KEY, chatsJson);
      
      // تخزين وقت آخر تحديث
      _storageService.write(LAST_FETCH_TIME_PREFIX + 'chats', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('خطأ في تخزين المحادثات محليًا: $e');
    }
  }

  // استرجاع قائمة المحادثات من التخزين المحلي
  List<ChatModel> _getCachedChats() {
    try {
      // استرجاع قائمة JSON من GetStorage
      final List<dynamic>? chatsJson = _storageService.read<List<dynamic>>(CACHED_CHATS_KEY);
      
      if (chatsJson == null || chatsJson.isEmpty) {
        return [];
      }
      
      // تحويل قائمة JSON إلى قائمة من ChatModel
      return chatsJson.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في استرجاع المحادثات من التخزين المحلي: $e');
      return [];
    }
  }

  // تخزين رسائل محادثة محليًا
  void _cacheMessages(int chatId, List<MessageModel> messages) {
    try {
      // تحويل قائمة الرسائل إلى قائمة من JSON
      final List<Map<String, dynamic>> messagesJson = messages.map((message) => message.toJson()).toList();
      
      // تخزين القائمة في GetStorage
      _storageService.write(CACHED_MESSAGES_PREFIX + chatId.toString(), messagesJson);
      
      // تخزين وقت آخر تحديث
      _storageService.write(LAST_FETCH_TIME_PREFIX + 'messages_' + chatId.toString(), DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('خطأ في تخزين الرسائل محليًا: $e');
    }
  }

  // استرجاع رسائل محادثة من التخزين المحلي
  List<MessageModel> _getCachedMessages(int chatId) {
    try {
      // استرجاع قائمة JSON من GetStorage
      final List<dynamic>? messagesJson = _storageService.read<List<dynamic>>(CACHED_MESSAGES_PREFIX + chatId.toString());
      
      if (messagesJson == null || messagesJson.isEmpty) {
        return [];
      }
      
      // تحويل قائمة JSON إلى قائمة من MessageModel
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في استرجاع الرسائل من التخزين المحلي: $e');
      return [];
    }
  }

  // تحديث حالة قراءة الرسالة في التخزين المحلي
  void _updateMessageReadStatus(int messageId, bool isRead) {
    try {
      // البحث عن الرسالة في جميع المحادثات المخزنة
      for (int chatId in _getAllCachedChatIds()) {
        List<MessageModel> messages = _getCachedMessages(chatId);
        bool updated = false;
        
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].id == messageId) {
            // إنشاء نسخة جديدة من الرسالة مع تحديث حالة القراءة
            final updatedMessage = MessageModel(
              id: messages[i].id,
              chatId: messages[i].chatId,
              content: messages[i].content,
              createdAt: messages[i].createdAt,
              isMine: messages[i].isMine,
              isRead: isRead,
              fileUrl: messages[i].fileUrl,
              fileType: messages[i].fileType,
              fileSize: messages[i].fileSize,
              reciver_id: messages[i].reciver_id,
            );
            
            messages[i] = updatedMessage;
            updated = true;
            break;
          }
        }
        
        if (updated) {
          _cacheMessages(chatId, messages);
          break;
        }
      }
    } catch (e) {
      print('خطأ في تحديث حالة قراءة الرسالة في التخزين المحلي: $e');
    }
  }

  // حذف رسالة من التخزين المحلي
  void _deleteMessageFromCache(int messageId) {
    try {
      // البحث عن الرسالة في جميع المحادثات المخزنة
      for (int chatId in _getAllCachedChatIds()) {
        List<MessageModel> messages = _getCachedMessages(chatId);
        int initialLength = messages.length;
        
        messages.removeWhere((message) => message.id == messageId);
        
        if (messages.length < initialLength) {
          _cacheMessages(chatId, messages);
          break;
        }
      }
    } catch (e) {
      print('خطأ في حذف الرسالة من التخزين المحلي: $e');
    }
  }

  // الحصول على قائمة معرفات المحادثات المخزنة محليًا
  List<int> _getAllCachedChatIds() {
    try {
      List<ChatModel> chats = _getCachedChats();
      return chats.map((chat) => chat.id).toList();
    } catch (e) {
      print('خطأ في الحصول على معرفات المحادثات المخزنة: $e');
      return [];
    }
  }



}*/
