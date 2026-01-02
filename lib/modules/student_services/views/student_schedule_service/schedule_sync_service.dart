import 'package:get/get.dart';

import '../../../../core/network/api_service.dart';
import 'schedule_model.dart';
import 'schedule_storage_service.dart';


class ScheduleSyncService {
  final ApiService _apiService = Get.find<ApiService>();
  final ScheduleStorageService _storageService = Get.find<ScheduleStorageService>();
  
  // حالة المزامنة
  final RxBool isSyncing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUsingLocalData = false.obs;
  
  // مزامنة الجدول الدراسي (جلب من الخادم وحفظ محلياً)
  Future<Schedule?> syncSchedule() async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        final localSchedule = await _storageService.getSchedule();
        if (localSchedule != null) {
          isUsingLocalData.value = true;
          return localSchedule;
        } else {
          throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محلية');
        }
      }
      
      // جلب الجدول الدراسي من الخادم
      final response = await _apiService.getSchedule();
      
      if (response.statusCode == 200 && response.data != null) {
        final scheduleData = Schedule.fromJson(response.data);
        
        // حفظ الجدول الدراسي محلياً
        await _storageService.saveSchedule(scheduleData);
        
        // جلب وحفظ البيانات المرتبطة إذا كانت متوفرة في الاستجابة
        if (response.data['courses'] != null) {
          final courses = (response.data['courses'] as List)
              .map((item) => Course.fromJson(item))
              .toList();
          await _storageService.saveCourses(courses);
        }
        
        if (response.data['halls'] != null) {
          final halls = (response.data['halls'] as List)
              .map((item) => Hall.fromJson(item))
              .toList();
          await _storageService.saveHalls(halls);
        }
        
        if (response.data['teachers'] != null) {
          final teachers = (response.data['teachers'] as List)
              .map((item) => Teacher.fromJson(item))
              .toList();
          await _storageService.saveTeachers(teachers);
        }
        
        if (response.data['departments'] != null) {
          final departments = (response.data['departments'] as List)
              .map((item) => Department.fromJson(item))
              .toList();
          await _storageService.saveDepartments(departments);
        }
        
        isUsingLocalData.value = false;
        return scheduleData;
      } else {
        // إذا فشل الطلب، حاول استخدام البيانات المحلية
        final localSchedule = await _storageService.getSchedule();
        if (localSchedule != null) {
          isUsingLocalData.value = true;
          return localSchedule;
        } else {
          throw Exception('فشل في جلب الجدول الدراسي من الخادم: ${response.statusCode}');
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      
      // محاولة استخدام البيانات المحلية في حالة الخطأ
      final localSchedule = await _storageService.getSchedule();
      if (localSchedule != null) {
        isUsingLocalData.value = true;
        return localSchedule;
      }
      
      return null;
    } finally {
      isSyncing.value = false;
    }
  }
  
  // جلب محاضرات اليوم من الخادم
  Future<List<Map<String, dynamic>>?> syncTodayLectures() async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات اليوم من الجدول المخزن
      }
      
      // جلب محاضرات اليوم من الخادم
      final response = await _apiService.get('/student/schedule/today');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['lectures'] != null) {
          final lectures = (response.data['lectures'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          
          isUsingLocalData.value = false;
          return lectures;
        }
        
        return [];
      } else {
        // إذا فشل الطلب، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات اليوم من الجدول المخزن
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      isUsingLocalData.value = true;
      return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات اليوم من الجدول المخزن
    } finally {
      isSyncing.value = false;
    }
  }
  
  // جلب محاضرات الغد من الخادم
  Future<List<Map<String, dynamic>>?> syncTomorrowLectures() async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات الغد من الجدول المخزن
      }
      
      // جلب محاضرات الغد من الخادم
      final response = await _apiService.get('/student/schedule/tomorrow');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['lectures'] != null) {
          final lectures = (response.data['lectures'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          
          isUsingLocalData.value = false;
          return lectures;
        }
        
        return [];
      } else {
        // إذا فشل الطلب، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات الغد من الجدول المخزن
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      isUsingLocalData.value = true;
      return null; // سيتم استخدام الوظيفة المحلية لاستخراج محاضرات الغد من الجدول المخزن
    } finally {
      isSyncing.value = false;
    }
  }
  
  // التحقق من وجود تحديثات للجدول الدراسي
  Future<bool> checkForUpdates() async {
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        return false;
      }
      
      // الحصول على تاريخ آخر تحديث محلي
      final lastUpdated = await _storageService.getLastUpdated();
      
      if (lastUpdated == null) {
        // إذا لم يكن هناك تاريخ تحديث محلي، فهناك تحديثات
        return true;
      }
      
      // جلب معلومات الجدول من الخادم للتحقق من تاريخ التحديث
      final response = await _apiService.get('/student/schedule');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['last_updated'] != null) {
          final serverLastUpdated = DateTime.parse(response.data['last_updated']);
          
          // مقارنة تاريخ التحديث المحلي مع تاريخ التحديث على الخادم
          return serverLastUpdated.isAfter(lastUpdated);
        }
      }
      
      return false;
    } catch (e) {
      print('خطأ في التحقق من وجود تحديثات: $e');
      return false;
    }
  }
  
  // مسح التخزين المؤقت وإعادة تحميل البيانات
  Future<Schedule?> clearCacheAndReload() async {
    try {
      // مسح جميع بيانات الجدول الدراسي من التخزين المحلي
      await _storageService.clearAllScheduleData();
      
      // إعادة تحميل البيانات من الخادم
      return await syncSchedule();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'فشل في مسح التخزين المؤقت وإعادة التحميل: $e';
      return null;
    }
  }
}
