import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/network/api_service.dart';

class ProfileService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  /// رفع صورة الملف الشخصي
  Future<Map<String, dynamic>> uploadProfileImage({required File file}) async {
    try {
      final response = await _apiService.uploadProfileImage(file: file);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // تحديث بيانات المستخدم في التخزين المحلي
          await _updateLocalUserData(data['user']);
          return {
            'success': true,
            'message': data['message'],
            'image_url': data['image_url'],
            'user': data['user'],
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'فشل في رفع الصورة',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء رفع الصورة: ${e.toString()}',
      };
    }
  }


  /// تحديث بيانات الملف الشخصي
  Future<Map<String, dynamic>> updateProfile({
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
      if (phoneNumber != null)
        formData.fields.add(MapEntry('phone_number', phoneNumber));
      if (currentPassword != null)
        formData.fields.add(MapEntry('current_password', currentPassword));
      if (newPassword != null) {
        formData.fields.add(MapEntry('new_password', newPassword));
        formData.fields.add(MapEntry('new_password_confirmation',
            newPasswordConfirmation ?? newPassword));
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

      final response = await _apiService.post(
        '/profile/update',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // تحديث بيانات المستخدم في التخزين المحلي
          await _updateLocalUserData(data['user']);
          return {
            'success': true,
            'message': data['message'],
            'user': data['user'],
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'فشل في تحديث البيانات',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تحديث البيانات: ${e.toString()}',
      };
    }
  }

  /// تحديث معلومات التواصل
  Future<Map<String, dynamic>> updateContactInfo({
    String? email,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;

      final response = await _apiService.post(
        '/profile/update-contact',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          // تحديث بيانات المستخدم في التخزين المحلي
          await _updateLocalUserData(responseData['user']);
          return {
            'success': true,
            'message': responseData['message'],
            'user': responseData['user'],
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'فشل في تحديث معلومات التواصل',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تحديث معلومات التواصل: ${e.toString()}',
      };
    }
  }

  /// تغيير كلمة المرور
  Future<Map<String, dynamic>> changePassword({
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

      final response = await _apiService.post(
        '/profile/change-password',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'],
            'requires_relogin': true,
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'فشل في تغيير كلمة المرور',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تغيير كلمة المرور: ${e.toString()}',
      };
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/user');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // تحديث بيانات المستخدم في التخزين المحلي
          await _updateLocalUserData(data['user']);
          await _updateLocalStudentData(data['student']);

          return {
            'success': true,
            'user': data['user'],
            'student': data['student'],
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'فشل في جلب بيانات المستخدم',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء جلب بيانات المستخدم: ${e.toString()}',
      };
    }
  }

  /// تحديث بيانات المستخدم في التخزين المحلي
  Future<void> _updateLocalUserData(Map<String, dynamic> userData) async {
    try {
      final existingData =
          await _storage.read<Map<String, dynamic>>('user_data') ?? {};
      existingData.addAll(userData);
      await _storage.write('user_data', existingData);
    } catch (e) {
      debugPrint('Error updating local user data: $e');
    }
  }

  /// تحديث بيانات الطالب في التخزين المحلي
  Future<void> _updateLocalStudentData(Map<String, dynamic> studentData) async {
    try {
      final existingData =
          await _storage.read<Map<String, dynamic>>('student_data') ?? {};
      existingData.addAll(studentData);
      await _storage.write('student_data', existingData);
    } catch (e) {
      debugPrint('Error updating local student data: $e');
    }
  }

  /// التحقق من صحة البيانات قبل الإرسال
  Map<String, String?> validateProfileData({
    String? name,
    String? email,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) {
    final errors = <String, String?>{};

    if (name != null && name.trim().isEmpty) {
      errors['name'] = 'يجب إدخال اسم المستخدم';
    }

    if (email != null) {
      if (email.trim().isEmpty) {
        errors['email'] = 'يجب إدخال البريد الإلكتروني';
      } else if (!GetUtils.isEmail(email)) {
        errors['email'] = 'البريد الإلكتروني غير صحيح';
      }
    }

    if (phoneNumber != null && phoneNumber.trim().isEmpty) {
      errors['phoneNumber'] = 'يجب إدخال رقم الهاتف';
    }

    if (newPassword != null) {
      if (currentPassword == null || currentPassword.trim().isEmpty) {
        errors['currentPassword'] = 'يجب إدخال كلمة المرور الحالية';
      }

      if (newPassword.length < 8) {
        errors['newPassword'] =
            'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل';
      }

      if (newPasswordConfirmation != newPassword) {
        errors['newPasswordConfirmation'] = 'تأكيد كلمة المرور غير متطابق';
      }
    }

    return errors;
  }

  /// التحقق من صحة معلومات التواصل
  Map<String, String?> validateContactInfo({
    String? email,
    String? phoneNumber,
  }) {
    final errors = <String, String?>{};

    if (email != null) {
      if (email.trim().isEmpty) {
        errors['email'] = 'يجب إدخال البريد الإلكتروني';
      } else if (!GetUtils.isEmail(email)) {
        errors['email'] = 'البريد الإلكتروني غير صحيح';
      }
    }

    if (phoneNumber != null && phoneNumber.trim().isEmpty) {
      errors['phoneNumber'] = 'يجب إدخال رقم الهاتف';
    }

    return errors;
  }

  /// التحقق من صحة كلمة المرور
  Map<String, String?> validatePasswordChange({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    final errors = <String, String?>{};

    if (currentPassword.trim().isEmpty) {
      errors['currentPassword'] = 'يجب إدخال كلمة المرور الحالية';
    }

    if (newPassword.length < 8) {
      errors['newPassword'] =
          'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل';
    }

    if (newPasswordConfirmation != newPassword) {
      errors['newPasswordConfirmation'] = 'تأكيد كلمة المرور غير متطابق';
    }

    return errors;
  }
}
