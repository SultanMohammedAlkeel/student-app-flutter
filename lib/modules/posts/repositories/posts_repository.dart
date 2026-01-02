import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:student_app/core/network/api_service.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/modules/posts/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../models/comment_model.dart';

class PostsRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();
  
  // تخزين مؤقت للنتائج
  final Map<String, dynamic> _cache = {};
  final Duration _cacheDuration = Duration(minutes: 5);

  // الحصول على جميع المنشورات
  Future<List<Post>> getPosts({int? offset}) async {
    try {
      final response = await _apiService.get(
        '/posts',
        queryParameters: offset != null ? {'offset': offset} : null,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المنشورات');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المنشورات');
    }
  }
  
  // الحصول على منشورات الكلية
  Future<List<Post>> getCollegePosts({int? offset}) async {
    try {
      final response = await _apiService.get(
        '/posts/college',
        queryParameters: offset != null ? {'offset': offset} : null,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل منشورات الكلية');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل منشورات الكلية');
    }
  }
  
  // الحصول على المنشورات المحفوظة
  Future<List<Post>> getSavedPosts({int? offset}) async {
    try {
      final response = await _apiService.get(
        '/posts/saved',
        queryParameters: offset != null ? {'offset': offset} : null,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المنشورات المحفوظة');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المنشورات المحفوظة');
    }
  }
  
  // الحصول على منشورات المستخدم الحالي
  Future<List<Post>> getMyPosts({int? offset}) async {
    try {
      final response = await _apiService.get(
        '/posts/my',
        queryParameters: offset != null ? {'offset': offset} : null,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل منشوراتك');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل منشوراتك');
    }
  }
  
  // الحصول على المزيد من المنشورات (للتحميل المتدرج)
  Future<List<Post>> getMorePosts(int lastPostId) async {
    try {
      final response = await _apiService.get(
        '/posts',
        queryParameters: {'last_id': lastPostId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المزيد من المنشورات');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المزيد من المنشورات');
    }
  }
  
  // الحصول على المزيد من منشورات الكلية
  Future<List<Post>> getMoreCollegePosts(int lastPostId) async {
    try {
      final response = await _apiService.get(
        '/posts/college',
        queryParameters: {'last_id': lastPostId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المزيد من منشورات الكلية');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المزيد من منشورات الكلية');
    }
  }
  
  // الحصول على المزيد من المنشورات المحفوظة
  Future<List<Post>> getMoreSavedPosts(int lastPostId) async {
    try {
      final response = await _apiService.get(
        '/posts/saved',
        queryParameters: {'last_id': lastPostId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المزيد من المنشورات المحفوظة');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المزيد من المنشورات المحفوظة');
    }
  }
  
  // الحصول على المزيد من منشورات المستخدم الحالي
  Future<List<Post>> getMoreMyPosts(int lastPostId) async {
    try {
      final response = await _apiService.get(
        '/posts/my',
        queryParameters: {'last_id': lastPostId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل المزيد من منشوراتك');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل المزيد من منشوراتك');
    }
  }

  // الحصول على تعليقات منشور معين
  Future<List<Comment>> getPostComments(int postId) async {
    try {
      final response = await _apiService.get(
        '/posts/comments',
        queryParameters: {'post_id': postId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((comment) => Comment.fromJson(comment))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل التعليقات');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في تحميل التعليقات');
    }
  }
  
  // تسجيل مشاهدة منشور
  Future<void> recordView(int postId) async {
    try {
      await _apiService.post(
        '/posts/view',
        data: {'post_id': postId},
        headers: _authHeader(),
      );
    } catch (e) {
      print('خطأ في تسجيل المشاهدة: $e');
    }
  }
  
  // تبديل حالة الإعجاب بمنشور
  Future<Post> toggleLike(int postId) async {
    try {
      final response = await _apiService.post(
        '/posts/like',
        data: {'post_id': postId},
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        final responseData = response.data['data'] ?? response.data;
        return Post.fromJson({
          ...responseData,
          'id': postId,
        });
      }
      throw Exception(response.data['message'] ?? 'فشل في تحديث الإعجاب');
    } catch (e) {
      throw Exception('حدث خطأ في الإعجاب: ${e.toString()}');
    }
  }
  
  // تبديل حالة حفظ منشور
  Future<Post> toggleSave(int postId) async {
    final response = await _apiService.post(
      '/posts/save',
      data: {'post_id': postId},
      headers: _authHeader(),
    );
    
    if (response.data['success'] == true) {
      final responseData = response.data['data'] ?? response.data;
      return Post.fromJson({
        'id': postId,
        'is_saved': responseData['is_saved'],
      });
    }
    throw Exception('فشل في تحديث الحفظ: ${response.data['message'] ?? 'سبب غير معروف'}');
  }

  // إضافة تعليق على منشور
  Future<Comment> addComment(int postId, String content) async {
    try {
      final response = await _apiService.post(
        '/posts/comment',
        data: {
          'post_id': postId,
          'comment': content,
        },
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في إضافة التعليق');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في إضافة التعليق');
    }
  }

  // رفع ملف واحد مع تتبع التقدم
  Future<Map<String,dynamic>> uploadFile(File file, String fileType, {Function(double)? onProgress}) async {
    try {
      // تحديد امتداد الملف المناسب
      String extension = path.extension(file.path);
      if (extension.isEmpty) {
        extension = _getDefaultExtension(fileType);
      }
      
      // إنشاء اسم الملف
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}$extension';

      // إنشاء FormData لرفع الملف
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'type': fileType,
      });

      // رفع الملف مع تتبع التقدم
      final response = await _apiService.uploadFile(
        '/posts/upload-file',
        formData: formData,
        headers: _authHeader(),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'فشل في رفع الملف');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception('حجم الملف كبير جداً');
      }
      throw _handleError(e, 'فشل في رفع الملف');
    }
  }
  
  // إنشاء منشور جديد
  Future<Post> createPost({
    required String content,
    String? fileUrl,
    String? fileType, 
    int? filesize,
  }) async {
    try {
      final response = await _apiService.post(
        '/posts/create',
        data: {
          'content': content,
          'file_url': fileUrl,
          'file_type': fileType,
          'file_size': filesize,
        },
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        // مسح التخزين المؤقت للبحث عند إنشاء منشور جديد
        _clearSearchCache();
        return Post.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في إنشاء المنشور');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في إنشاء المنشور');
    }
  }
  
  // حذف منشور
  Future<bool> deletePost(int postId) async {
    try {
      final response = await _apiService.delete(
        '/posts/$postId',
        headers: _authHeader(),
      );
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في حذف المنشور');
    }
  }

  // البحث في المنشورات (الكل)
  Future<List<Post>> searchPosts(String query, Map<String, dynamic> filters, {int page = 1, int limit = 20}) async {
    try {
      // التحقق من التخزين المؤقت
      final cacheKey = 'search_posts_${query}_${json.encode(filters)}_$page';
      if (_cache.containsKey(cacheKey)) {
        final cacheData = _cache[cacheKey];
        final cacheTime = cacheData['time'] as DateTime;
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          return cacheData['data'] as List<Post>;
        }
      }
      
      // إضافة الاستعلام والفلاتر إلى معلمات الطلب
      final queryParameters = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };
      
      // إضافة الفلاتر إلى معلمات الطلب
      queryParameters.addAll(filters);
      
      final response = await _apiService.get(
        '/posts/search',
        queryParameters: queryParameters,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        final posts = (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
          
        // تخزين النتائج في التخزين المؤقت
        _cache[cacheKey] = {
          'data': posts,
          'time': DateTime.now(),
        };
          
        return posts;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في البحث');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في البحث');
    }
  }
  
  // البحث في محتوى المنشورات فقط
  Future<List<Post>> searchPostsByContent(String query, Map<String, dynamic> filters, {int page = 1, int limit = 20}) async {
    try {
      // التحقق من التخزين المؤقت
      final cacheKey = 'search_content_${query}_${json.encode(filters)}_$page';
      if (_cache.containsKey(cacheKey)) {
        final cacheData = _cache[cacheKey];
        final cacheTime = cacheData['time'] as DateTime;
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          return cacheData['data'] as List<Post>;
        }
      }
      
      // إضافة الاستعلام والفلاتر إلى معلمات الطلب
      final queryParameters = <String, dynamic>{
        'q': query,
        'type': 'content',
        'page': page,
        'limit': limit,
      };
      
      // إضافة الفلاتر إلى معلمات الطلب
      queryParameters.addAll(filters);
      
      final response = await _apiService.get(
        '/posts/search',
        queryParameters: queryParameters,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        final posts = (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
          
        // تخزين النتائج في التخزين المؤقت
        _cache[cacheKey] = {
          'data': posts,
          'time': DateTime.now(),
        };
          
        return posts;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في البحث');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في البحث');
    }
  }
  
  // البحث عن المستخدمين
  Future<List<UserModel>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    try {
      // التحقق من التخزين المؤقت
      final cacheKey = 'search_users_${query}_$page';
      if (_cache.containsKey(cacheKey)) {
        final cacheData = _cache[cacheKey];
        final cacheTime = cacheData['time'] as DateTime;
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          return cacheData['data'] as List<UserModel>;
        }
      }
      
      final response = await _apiService.get(
        '/users/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        final users = (response.data['data'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
          
        // تخزين النتائج في التخزين المؤقت
        _cache[cacheKey] = {
          'data': users,
          'time': DateTime.now(),
        };
          
        return users;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في البحث عن المستخدمين');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في البحث عن المستخدمين');
    }
  }
  
  // جلب منشورات مستخدم معين
  Future<List<Post>> getUserPosts(int userId, {int page = 1, int limit = 10, int? lastId}) async {
    try {
      // التحقق من التخزين المؤقت
      final cacheKey = 'user_posts_${userId}_${page}_$lastId';
      if (_cache.containsKey(cacheKey)) {
        final cacheData = _cache[cacheKey];
        final cacheTime = cacheData['time'] as DateTime;
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          return cacheData['data'] as List<Post>;
        }
      }
      
      // بناء معلمات الطلب
      final queryParameters = <String, dynamic>{};
      
      if (lastId != null) {
        queryParameters['last_id'] = lastId;
      } else {
        queryParameters['page'] = page;
        queryParameters['limit'] = limit;
      }
      
      final response = await _apiService.get(
        '/posts/user/$userId',
        queryParameters: queryParameters,
        headers: _authHeader(),
      );
      
      if (response.data['success'] == true) {
        final posts = (response.data['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
          
        // تخزين النتائج في التخزين المؤقت
        _cache[cacheKey] = {
          'data': posts,
          'time': DateTime.now(),
        };
          
        return posts;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في جلب منشورات المستخدم');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'فشل في جلب منشورات المستخدم');
    }
  }

  // إنشاء رأس طلب مع توكن المصادقة
  Map<String, String> _authHeader() {
    final token = _storage.read('auth_token');
    return {'Authorization': 'Bearer $token'};
  }

  // معالجة أخطاء الاتصال
  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response?.statusCode == 401) {
      Get.offAllNamed('/login');
      return Exception('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
    }
    return Exception(e.response?.data['message'] ?? defaultMessage);
  }
  
  // الحصول على امتداد افتراضي حسب نوع الملف
  String _getDefaultExtension(String fileType) {
    switch (fileType) {
      case 'image':
        return '.jpg';
      case 'video':
        return '.mp4';
      case 'audio':
        return '.mp3';
      case 'pdf':
        return '.pdf';
      case 'word':
        return '.docx';
      case 'excel':
        return '.xlsx';
      case 'powerpoint':
        return '.pptx';
      case 'archive':
        return '.zip';
      default:
        return '.bin';
    }
  }
  
  // مسح التخزين المؤقت للبحث
  void _clearSearchCache() {
    final keysToRemove = _cache.keys.where((key) => 
      key.startsWith('search_posts_') || 
      key.startsWith('search_content_') || 
      key.startsWith('search_users_') ||
      key.startsWith('user_posts_')
    ).toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
}