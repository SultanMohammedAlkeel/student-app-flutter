import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/data/models/user_model.dart';
import 'package:student_app/data/repositories/auth_repository.dart';


class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _rememberMeKey = 'remember_me';
  static const _rememberedEmailKey = 'remembered_email';
  static const _studentKey = 'student_data';
  static final StorageService _storage = StorageService();
/////////////////////////////////////////////////////
//// Save and retrieve student data
/////////////////////////////////////////////////////
  static Future<void> saveStudentData(Map<String, dynamic> student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentKey, jsonEncode(student));
    await _storage.write(_studentKey, jsonEncode(student));
  }

  static Future<Map<String, dynamic>?> getStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final studentString = prefs.getString(_studentKey);
    if (studentString != null && studentString.isNotEmpty) {
      return jsonDecode(studentString);
    }
    return null;
  }

  static Future<void> clearStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentKey);
  }

  ////////////////////////////////////////////////////////////////

  static Future<void> saveAuthData(
      String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    _storage.write('current_user', user);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      if (userString != null && userString.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(userString));
      }
      return null;
    } catch (e) {
      print('Error getting user from cache: $e');
      return null;
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  bool isLoggedInSync() {
    final prefs = Get.find<SharedPreferences>();
    final token = prefs.getString(_tokenKey);
    final userString = prefs.getString(_userKey);
    return token != null && userString != null && userString.isNotEmpty;
  }

  static Future<void> clearAuthData() async {
   // await logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
   // await _storage.remove('current_user');
  }

  static Future<void> setRememberMeStatus(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
  }

  static Future<bool> getRememberMeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> setRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedEmailKey, email);
  }

  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberedEmailKey);
  }

  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_rememberedEmailKey);
  }

  static Future<void> logout() async {
    final authRepo = Get.find<AuthRepository>();
    await authRepo.logout();
    await clearAuthData();
  }

  static saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    _storage.write('current_user', user);
  }

  int currentUserId() {
    final prefs = Get.find<SharedPreferences>();
    final userString = prefs.getString(_userKey);
    if (userString != null && userString.isNotEmpty) {
      final user = UserModel.fromJson(jsonDecode(userString));
      return user.id ?? 0;
    }
    return 0;
  }
}
