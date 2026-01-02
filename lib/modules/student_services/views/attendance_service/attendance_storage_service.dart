import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'attendance_model.dart';

class AttendanceStorageService {
  final StorageService _storageService = Get.find<StorageService>();
  
  // مفاتيح التخزين
  static const String _attendanceDataKey = 'student_attendance_data';
  static const String _courseAttendanceKey = 'course_attendance_details';
  static const String _lastUpdatedKey = 'attendance_last_updated';
  
  // حفظ بيانات الحضور في التخزين المحلي
  Future<void> saveAttendanceData(AttendanceData attendanceData) async {
    try {
      // حفظ البيانات في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_attendanceDataKey, jsonEncode(attendanceData.toJson()));
      
      // حفظ تاريخ آخر تحديث
      await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
      
      // حفظ البيانات في StorageService أيضاً للنسخ الاحتياطي
      await _storageService.write(_attendanceDataKey, attendanceData.toJson());
      await _storageService.write(_lastUpdatedKey, DateTime.now().toIso8601String());
      
      print('تم حفظ بيانات الحضور في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ بيانات الحضور: $e');
      throw Exception('فشل في حفظ بيانات الحضور: $e');
    }
  }
  
  // استرجاع بيانات الحضور من التخزين المحلي
  Future<AttendanceData?> getAttendanceData() async {
    try {
      // محاولة استرجاع البيانات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString(_attendanceDataKey);
      
      if (attendanceJson != null && attendanceJson.isNotEmpty) {
        return AttendanceData.fromJson(jsonDecode(attendanceJson));
      }
      
      // إذا لم يتم العثور على البيانات في SharedPreferences، حاول من StorageService
      final storageAttendance = await _storageService.read(_attendanceDataKey);
      if (storageAttendance != null) {
        return AttendanceData.fromJson(storageAttendance);
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع بيانات الحضور: $e');
      return null;
    }
  }
  
  // حفظ تفاصيل حضور مقرر معين
  Future<void> saveCourseAttendanceDetails(int courseId, CourseAttendanceDetails details) async {
    try {
      final key = '${_courseAttendanceKey}_$courseId';
      
      // حفظ التفاصيل في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(details.toJson()));
      
      // حفظ التفاصيل في StorageService أيضاً
      await _storageService.write(key, details.toJson());
      
      print('تم حفظ تفاصيل حضور المقرر $courseId في التخزين المحلي بنجاح');
    } catch (e) {
      print('خطأ في حفظ تفاصيل حضور المقرر: $e');
    }
  }
  
  // استرجاع تفاصيل حضور مقرر معين
  Future<CourseAttendanceDetails?> getCourseAttendanceDetails(int courseId) async {
    try {
      final key = '${_courseAttendanceKey}_$courseId';
      
      // محاولة استرجاع التفاصيل من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final detailsJson = prefs.getString(key);
      
      if (detailsJson != null && detailsJson.isNotEmpty) {
        return CourseAttendanceDetails.fromJson(jsonDecode(detailsJson));
      }
      
      // إذا لم يتم العثور على التفاصيل في SharedPreferences، حاول من StorageService
      final storageDetails = await _storageService.read(key);
      if (storageDetails != null) {
        return CourseAttendanceDetails.fromJson(storageDetails);
      }
      
      return null;
    } catch (e) {
      print('خطأ في استرجاع تفاصيل حضور المقرر: $e');
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
  
  // مسح جميع بيانات الحضور من التخزين المحلي
  Future<void> clearAllAttendanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // مسح البيانات الرئيسية
      await prefs.remove(_attendanceDataKey);
      await prefs.remove(_lastUpdatedKey);
      
      // مسح تفاصيل المقررات
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(_courseAttendanceKey)) {
          await prefs.remove(key);
        }
      }
      
      // مسح من StorageService أيضاً
      await _storageService.remove(_attendanceDataKey);
      await _storageService.remove(_lastUpdatedKey);
      
      print('تم مسح جميع بيانات الحضور من التخزين المحلي');
    } catch (e) {
      print('خطأ في مسح بيانات الحضور: $e');
    }
  }
  
  // حفظ مقرر واحد في قائمة المقررات المحفوظة
  Future<void> saveCourseAttendance(CourseAttendance courseAttendance) async {
    try {
      // استرجاع البيانات الحالية
      AttendanceData? currentData = await getAttendanceData();
      
      if (currentData != null) {
        // البحث عن المقرر وتحديثه أو إضافته
        List<CourseAttendance> updatedCourses = List.from(currentData.coursesAttendance);
        int existingIndex = updatedCourses.indexWhere((course) => course.courseId == courseAttendance.courseId);
        
        if (existingIndex != -1) {
          updatedCourses[existingIndex] = courseAttendance;
        } else {
          updatedCourses.add(courseAttendance);
        }
        
        // إنشاء بيانات محدثة
        AttendanceData updatedData = AttendanceData(
          studentInfo: currentData.studentInfo,
          coursesAttendance: updatedCourses,
          summary: currentData.summary,
          lastUpdated: DateTime.now(),
        );
        
        // حفظ البيانات المحدثة
        await saveAttendanceData(updatedData);
      }
    } catch (e) {
      print('خطأ في حفظ بيانات المقرر: $e');
    }
  }
  
  // التحقق من وجود بيانات محلية
  Future<bool> hasLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_attendanceDataKey);
    } catch (e) {
      return false;
    }
  }
  
  // حساب حجم البيانات المحفوظة (تقريبي)
  Future<int> getDataSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSize = 0;
      
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(_attendanceDataKey) || 
            key.startsWith(_courseAttendanceKey) || 
            key == _lastUpdatedKey) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

