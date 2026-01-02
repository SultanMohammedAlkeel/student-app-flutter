import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/services/storage_service.dart';

class ApiService {
  final Dio dio = Dio();
  final StorageService _storage = Get.find<StorageService>();
  final Rx<Uint8List?> cachedImage = Rx<Uint8List?>(null);
    final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

  // static final baseUrl = 'http://192.168.1.9:8000/api/';
  
  ApiService() {
    _initDio();
  }

  void _initDio() {
    dio.options.baseUrl = _apiUrlService.apiUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Add interceptors
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }
  // تحديث baseUrl عند تغيير عنوان الـ API
  void updateBaseUrl() {
    dio.options.baseUrl = _apiUrlService.apiUrl;
  }
  Future<bool> hasInternetConnection() async {
    try {
            final uri = Uri.parse(_apiUrlService.currentApiUrl);

      final result = await InternetAddress.lookup(uri.host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<Response> uploadProfileImage({required File file}) async {
    print('API - بدء رفع الصورة إلى السيرفر');
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      print('API - إرسال الطلب إلى السيرفر');
      final response = await dio.post(
        '/profile/upload-image',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer ${await _storage.read('auth_token')}'
        }),
      );

      print('API - تم استلام الاستجابة بنجاح');
      return response;
    } on DioException catch (e) {
      print('API - خطأ في الاتصال: ${e.message}');
      throw _handleError(e);
    }
  }

  /// تحديث بيانات الملف الشخصي
  Future<Response> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
    File? image,
  }) async {
    try {
      final formData = FormData();

      if (name != null) formData.fields.add(MapEntry('name', name));
      if (email != null) formData.fields.add(MapEntry('email', email));
      if (phoneNumber != null) formData.fields.add(MapEntry('phone_number', phoneNumber));
      if (currentPassword != null) formData.fields.add(MapEntry('current_password', currentPassword));
      if (newPassword != null) {
        formData.fields.add(MapEntry('new_password', newPassword));
        formData.fields.add(MapEntry('new_password_confirmation', newPasswordConfirmation ?? newPassword));
      }
      
      if (image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      final response = await dio.post(
        '/profile/update',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer ${await _storage.read('auth_token')}'
        }),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// تحديث معلومات التواصل
  Future<Response> updateContactInfo({
    String? email,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;

      final response = await dio.post(
        '/profile/update-contact',
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer ${await _storage.read('auth_token')}'
        }),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// تغيير كلمة المرور
  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };

      final response = await dio.post(
        '/profile/change-password',
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer ${await _storage.read('auth_token')}'
        }),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<Response> getCurrentUser() async {
    try {
      final response = await dio.get(
        '/user',
        options: Options(headers: {
          'Authorization': 'Bearer ${await _storage.read('auth_token')}'
        }),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
            options.baseUrl = _apiUrlService.apiUrl;

    // Add auth token if exists
    final token = await _storage.read('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('Sending request to ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');

    return handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('Received response: ${response.statusCode}');
    debugPrint('Response data: ${response.data}');
    return handler.next(response);
  }

  Future<void> _onError(
      DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('Error occurred: ${err.message}');
    debugPrint('Error response: ${err.response?.data}');

    // Handle token expiration (401 Unauthorized)
    if (err.response?.statusCode == 401) {
      // You can add token refresh logic here if needed
      return handler.reject(err);
    }

    return handler.next(err);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: responseType,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> postWithToken(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    bool requiresAuth = true,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final options = Options(headers: headers ?? {});

      if (requiresAuth) {
        final token = await getToken();
        if (token != null) {
          options.headers?['Authorization'] = 'Bearer $token';
        }
      }

      return await dio.post(
        path,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getWithToken(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      final options = Options(headers: headers);
      if (requiresAuth) {
        final token = await getToken();
        if (token != null) {
          options.headers?['Authorization'] = 'Bearer $token';
        }
      }
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file with progress tracking
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Map<String, dynamic>? headers,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final token = await getToken();
      final requestHeaders = headers ?? {};

      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      return await dio.post(
        path,
        data: formData,
        options: Options(
          headers: requestHeaders,
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write('auth_token', token);
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> saveStudentData(Map<String, dynamic> data) async {
    await _storage.write('student_data', data);
  }

  Future<void> getStudentData() async {
    await _storage.read('student_data');
  }

  Future<void> clearToken() async {
    await _storage.remove('auth_token');
    dio.options.headers.remove('Authorization');
  }

  Future<String?> getToken() async {
    return await _storage.read('auth_token');
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        return errorData['message'] ??
            errorData['error'] ??
            'حدث خطأ في الخادم (${e.response?.statusCode})';
      }
      return 'حدث خطأ غير متوقع (${e.response?.statusCode})';
    } else {
      return 'حدث خطأ في الاتصال بالخادم: ${e.message}';
    }
  }

  // الحصول على بيانات الطالب الحالي
  Future<Response> getCurrentStudent() async {
    return await get('/students/me');
  }

  // الحصول على الجدول الدراسي
  Future<Response> getSchedule() async {
    final options = Options(headers: {});

    final token = await getToken();
    if (token != null) {
      options.headers?['Authorization'] = 'Bearer $token';
    }
    return await get('/student/schedule', headers: options.headers);
  }

  // الحصول على الدرجات
  Future<Response> getGrades() async {
    return await get('/student/grades');
  }

  // الحصول على قائمة الكتب
  Future<Response> getBooks({String? category, String? search}) async {
    return await get('/books', queryParameters: {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
    });
  }

  // الحصول على فئات الكتب
  Future<Response> getBookCategories() async {
    return await get('/books/categories');
  }

  // الحصول على نماذج الامتحانات
  Future<Response> getExams({String? type}) async {
    return await get('/exams', queryParameters: {
      if (type != null) 'type': type,
    });
  }

  // الحصول على تفاصيل امتحان
  Future<Response> getExamDetails(int examId) async {
    return await get('/exams/$examId');
  }

  // تسجيل نتيجة امتحان
  Future<Response> submitExamResult(
      int examId, Map<String, dynamic> result) async {
    return await post('/exams/$examId/submit', data: result);
  }

  // معالجة الأخطاء
  String handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.data != null && error.response!.data is Map) {
          final errorData = error.response!.data as Map;
          if (errorData.containsKey('message')) {
            return errorData['message'].toString();
          } else if (errorData.containsKey('error')) {
            return errorData['error'].toString();
          }
        }
        return 'خطأ في الاستجابة: ${error.response!.statusCode}';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'انتهت مهلة الاتصال';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة استلام البيانات';
      } else if (error.type == DioExceptionType.sendTimeout) {
        return 'انتهت مهلة إرسال البيانات';
      } else {
        return 'خطأ في الاتصال: ${error.message}';
      }
    }
    return 'حدث خطأ غير متوقع';
  }



// دوال API الخاصة بوحدة المساعدة والدعم
// يجب إضافة هذه الدوال إلى ملف ApiService الموجود لديك

/// إرسال شكوى أو ملاحظة
Future<Response> submitComplaintFeedback({
  required String type, // 'complaint' أو 'feedback'
  required String title,
  required String description,
}) async {
  try {
    final data = {
      'type': type,
      'title': title,
      'description': description,
    };

    final response = await postWithToken(
      '/complaints-feedback',
      data: data,
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على جميع الشكاوى والملاحظات للمستخدم الحالي
Future<Response> getUserComplaintsFeedback({
  int? page,
  int? limit,
  String? type, // 'complaint' أو 'feedback' أو null للكل
  String? status, // 'pending', 'in_progress', 'resolved', 'closed'
}) async {
  try {
    final queryParams = <String, dynamic>{};
    
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;

    final response = await getWithToken(
      '/complaints-feedback',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على تفاصيل شكوى أو ملاحظة محددة
Future<Response> getComplaintFeedbackDetails(int id) async {
  try {
    final response = await getWithToken(
      '/complaints-feedback/$id',
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// تحديث شكوى أو ملاحظة (للمستخدم)
Future<Response> updateComplaintFeedback({
  required int id,
  String? title,
  String? description,
}) async {
  try {
    final data = <String, dynamic>{};
    
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;

    final response = await put(
      '/complaints-feedback/$id',
      data: data,
      headers: {
        'Authorization': 'Bearer ${await getToken()}'
      },
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// حذف شكوى أو ملاحظة
Future<Response> deleteComplaintFeedback(int id) async {
  try {
    final response = await delete(
      '/complaints-feedback/$id',
      headers: {
        'Authorization': 'Bearer ${await getToken()}'
      },
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على إحصائيات الشكاوى والملاحظات للمستخدم
Future<Response> getComplaintsFeedbackStats() async {
  try {
    final response = await getWithToken(
      '/complaints-feedback/stats',
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// البحث في الشكاوى والملاحظات
Future<Response> searchComplaintsFeedback({
  required String query,
  String? type,
  String? status,
  int? page,
  int? limit,
}) async {
  try {
    final queryParams = <String, dynamic>{
      'search': query,
    };
    
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await getWithToken(
      '/complaints-feedback/search',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// تقييم جودة الدعم (اختياري)
Future<Response> rateSupport({
  required int complaintFeedbackId,
  required int rating, // من 1 إلى 5
  String? comment,
}) async {
  try {
    final data = {
      'complaint_feedback_id': complaintFeedbackId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    };

    final response = await postWithToken(
      '/complaints-feedback/rate',
      data: data,
      requiresAuth: true,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على معلومات التواصل (إذا كانت محفوظة في الخادم)
Future<Response> getContactInfo() async {
  try {
    final response = await get('/contact-info');
    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على الأسئلة الشائعة (إذا كانت محفوظة في الخادم)
Future<Response> getFAQ({
  String? category,
  String? search,
}) async {
  try {
    final queryParams = <String, dynamic>{};
    
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;

    final response = await get(
      '/faq',
      queryParameters: queryParams,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// الحصول على دليل الاستخدام (إذا كان محفوظاً في الخادم)
Future<Response> getUserGuide({
  String? section,
  String? search,
}) async {
  try {
    final queryParams = <String, dynamic>{};
    
    if (section != null) queryParams['section'] = section;
    if (search != null) queryParams['search'] = search;

    final response = await get(
      '/user-guide',
      queryParameters: queryParams,
    );

    return response;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

}

