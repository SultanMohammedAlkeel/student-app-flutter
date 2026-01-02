import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../../core/network/api_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {

  final ApiService _apiService = Get.find();
  final StorageService _storage = Get.find<StorageService>();

 
  // جلب بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final userJson = _storage.read<Map<String, dynamic>>('current_user');
    if (userJson != null) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  // تسجيل الخروج
  Future<void> logout() async {
   final response =await _apiService.get('/logout');
    if (response.statusCode == 200) {
      // تسجيل الخروج بنجاح
      return;
    } else {
      throw Exception('فشل تسجيل الخروج');
    }

  }

  // تحديث بيانات المستخدم
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _apiService.put(
        '/users/${user.id}',
        data: user.toJson(),
      );

      final updatedUser = UserModel.fromJson(response.data['data']);

      // تحديث البيانات المحلية
      await _storage.write('current_user', updatedUser.toJson());

      return updatedUser;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> fetchStudentData(int studentId) async {
  try {
    final response = await _apiService.postWithToken(
      '/students/get-by-id',
      data: {'student_id': studentId},
    );

    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('No student data found');
  } on DioException catch (e) {
    print('Error fetching student data: ${e.response?.data}');
    throw Exception('Failed to load student data: ${e.message}');
  }
}

  // معالجة أخطاء API
  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'حدث خطأ غير متوقع';
    } else {
      return 'حدث خطأ في الاتصال بالخادم';
    }
  }
}
