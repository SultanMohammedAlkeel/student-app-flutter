import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'schedule_model.dart';

class ScheduleStorageService {
  final StorageService _storageService = Get.find<StorageService>();
  
  // مفاتيح التخزين
  static const String _scheduleKey = 'student_schedule';
  static const String _coursesKey = 'student_schedule_courses';
  static const String _hallsKey = 'student_schedule_halls';
  static const String _teachersKey = 'student_schedule_teachers';
  static const String _departmentsKey = 'student_schedule_departments';
  static const String _lastUpdatedKey = 'student_schedule_last_updated';
  
  // حفظ الجدول الدراسي في التخزين المحلي
  Future<void> saveSchedule(Schedule schedule) async {
    try {
      // حفظ الجدول في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_scheduleKey, jsonEncode(schedule.toJson()));
      
      // حفظ تاريخ آخر تحديث
      await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
      
      // حفظ الجدول في StorageService أيضاً للنسخ الاحتياطي
      await _storageService.write(_scheduleKey, schedule.toJson());
      await _storageService.write(_lastUpdatedKey, DateTime.now().toIso8601String());
      
      print('تم حفظ الجدول الدراسي في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ الجدول الدراسي: $e');
      throw Exception('فشل في حفظ الجدول الدراسي: $e');
    }
  }
  
  // استرجاع الجدول الدراسي من التخزين المحلي
  Future<Schedule?> getSchedule() async {
    try {
      // محاولة استرجاع الجدول من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = prefs.getString(_scheduleKey);
      
      if (scheduleJson != null && scheduleJson.isNotEmpty) {
        return Schedule.fromJson(jsonDecode(scheduleJson));
      }
      
      // إذا لم يتم العثور على الجدول في SharedPreferences، حاول من StorageService
      final storageSchedule = await _storageService.read(_scheduleKey);
      if (storageSchedule != null) {
        return Schedule.fromJson(storageSchedule);
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع الجدول الدراسي: $e');
      return null;
    }
  }
  
  // حفظ المقررات في التخزين المحلي
  Future<void> saveCourses(List<Course> courses) async {
    try {
      final coursesJson = courses.map((course) => course.toJson()).toList();
      
      // حفظ المقررات في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_coursesKey, jsonEncode(coursesJson));
      
      // حفظ المقررات في StorageService أيضاً
      await _storageService.write(_coursesKey, coursesJson);
      
      print('تم حفظ المقررات في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ المقررات: $e');
    }
  }
  
  // استرجاع المقررات من التخزين المحلي
  Future<List<Course>?> getCourses() async {
    try {
      // محاولة استرجاع المقررات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_coursesKey);
      
      if (coursesJson != null && coursesJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(coursesJson);
        return decodedList.map((item) => Course.fromJson(item)).toList();
      }
      
      // إذا لم يتم العثور على المقررات في SharedPreferences، حاول من StorageService
      final storageCourses = await _storageService.read(_coursesKey);
      if (storageCourses != null) {
        return (storageCourses as List).map((item) => Course.fromJson(item)).toList();
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع المقررات: $e');
      return null;
    }
  }
  
  // حفظ القاعات في التخزين المحلي
  Future<void> saveHalls(List<Hall> halls) async {
    try {
      final hallsJson = halls.map((hall) => hall.toJson()).toList();
      
      // حفظ القاعات في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_hallsKey, jsonEncode(hallsJson));
      
      // حفظ القاعات في StorageService أيضاً
      await _storageService.write(_hallsKey, hallsJson);
      
      print('تم حفظ القاعات في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ القاعات: $e');
    }
  }
  
  // استرجاع القاعات من التخزين المحلي
  Future<List<Hall>?> getHalls() async {
    try {
      // محاولة استرجاع القاعات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hallsJson = prefs.getString(_hallsKey);
      
      if (hallsJson != null && hallsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(hallsJson);
        return decodedList.map((item) => Hall.fromJson(item)).toList();
      }
      
      // إذا لم يتم العثور على القاعات في SharedPreferences، حاول من StorageService
      final storageHalls = await _storageService.read(_hallsKey);
      if (storageHalls != null) {
        return (storageHalls as List).map((item) => Hall.fromJson(item)).toList();
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع القاعات: $e');
      return null;
    }
  }
  
  // حفظ المدرسين في التخزين المحلي
  Future<void> saveTeachers(List<Teacher> teachers) async {
    try {
      final teachersJson = teachers.map((teacher) => teacher.toJson()).toList();
      
      // حفظ المدرسين في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_teachersKey, jsonEncode(teachersJson));
      
      // حفظ المدرسين في StorageService أيضاً
      await _storageService.write(_teachersKey, teachersJson);
      
      print('تم حفظ المدرسين في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ المدرسين: $e');
    }
  }
  
  // استرجاع المدرسين من التخزين المحلي
  Future<List<Teacher>?> getTeachers() async {
    try {
      // محاولة استرجاع المدرسين من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = prefs.getString(_teachersKey);
      
      if (teachersJson != null && teachersJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(teachersJson);
        return decodedList.map((item) => Teacher.fromJson(item)).toList();
      }
      
      // إذا لم يتم العثور على المدرسين في SharedPreferences، حاول من StorageService
      final storageTeachers = await _storageService.read(_teachersKey);
      if (storageTeachers != null) {
        return (storageTeachers as List).map((item) => Teacher.fromJson(item)).toList();
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع المدرسين: $e');
      return null;
    }
  }
  
  // حفظ الأقسام في التخزين المحلي
  Future<void> saveDepartments(List<Department> departments) async {
    try {
      final departmentsJson = departments.map((department) => department.toJson()).toList();
      
      // حفظ الأقسام في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_departmentsKey, jsonEncode(departmentsJson));
      
      // حفظ الأقسام في StorageService أيضاً
      await _storageService.write(_departmentsKey, departmentsJson);
      
      print('تم حفظ الأقسام في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ الأقسام: $e');
    }
  }
  
  // استرجاع الأقسام من التخزين المحلي
  Future<List<Department>?> getDepartments() async {
    try {
      // محاولة استرجاع الأقسام من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final departmentsJson = prefs.getString(_departmentsKey);
      
      if (departmentsJson != null && departmentsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(departmentsJson);
        return decodedList.map((item) => Department.fromJson(item)).toList();
      }
      
      // إذا لم يتم العثور على الأقسام في SharedPreferences، حاول من StorageService
      final storageDepartments = await _storageService.read(_departmentsKey);
      if (storageDepartments != null) {
        return (storageDepartments as List).map((item) => Department.fromJson(item)).toList();
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع الأقسام: $e');
      return null;
    }
  }
  
  // الحصول على تاريخ آخر تحديث
  Future<DateTime?> getLastUpdated() async {
    try {
      // محاولة استرجاع تاريخ آخر تحديث من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedString = prefs.getString(_lastUpdatedKey);
      
      if (lastUpdatedString != null && lastUpdatedString.isNotEmpty) {
        return DateTime.parse(lastUpdatedString);
      }
      
      // إذا لم يتم العثور على تاريخ آخر تحديث في SharedPreferences، حاول من StorageService
      final storageLastUpdated = await _storageService.read(_lastUpdatedKey);
      if (storageLastUpdated != null) {
        return DateTime.parse(storageLastUpdated);
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع تاريخ آخر تحديث: $e');
      return null;
    }
  }
  
  // مسح جميع بيانات الجدول الدراسي من التخزين المحلي
  Future<void> clearAllScheduleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduleKey);
      await prefs.remove(_coursesKey);
      await prefs.remove(_hallsKey);
      await prefs.remove(_teachersKey);
      await prefs.remove(_departmentsKey);
      await prefs.remove(_lastUpdatedKey);
      
      await _storageService.remove(_scheduleKey);
      await _storageService.remove(_coursesKey);
      await _storageService.remove(_hallsKey);
      await _storageService.remove(_teachersKey);
      await _storageService.remove(_departmentsKey);
      await _storageService.remove(_lastUpdatedKey);
      
      print('تم مسح جميع بيانات الجدول الدراسي من التخزين المحلي');
    } catch (e) {
      print('خطأ في مسح بيانات الجدول الدراسي: $e');
    }
  }
}
