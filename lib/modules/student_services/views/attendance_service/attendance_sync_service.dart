import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import 'attendance_model.dart';
import 'attendance_storage_service.dart';

class AttendanceSyncService {
  final ApiService _apiService = Get.find<ApiService>();
  final AttendanceStorageService _storageService = Get.find<AttendanceStorageService>();
  
  // حالة المزامنة
  final RxBool isSyncing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUsingLocalData = false.obs;
  
  // مزامنة بيانات الحضور (جلب من الخادم وحفظ محلياً)
  Future<AttendanceData?> syncAttendanceData() async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        final localData = await _storageService.getAttendanceData();
        if (localData != null) {
          isUsingLocalData.value = true;
          return localData;
        } else {
          throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محلية');
        }
      }
      
      // جلب بيانات الحضور من الخادم
      final response = await _apiService.get('/student/attendance');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          final attendanceData = AttendanceData.fromJson(response.data['data']);
          
          // حفظ البيانات محلياً
          await _storageService.saveAttendanceData(attendanceData);
          
          isUsingLocalData.value = false;
          return attendanceData;
        } else {
          throw Exception(response.data['message'] ?? 'فشل في جلب بيانات الحضور');
        }
      } else {
        // إذا فشل الطلب، حاول استخدام البيانات المحلية
        final localData = await _storageService.getAttendanceData();
        if (localData != null) {
          isUsingLocalData.value = true;
          return localData;
        } else {
          throw Exception('فشل في جلب بيانات الحضور من الخادم: ${response.statusCode}');
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      
      // محاولة استخدام البيانات المحلية في حالة الخطأ
      final localData = await _storageService.getAttendanceData();
      if (localData != null) {
        isUsingLocalData.value = true;
        return localData;
      }
      
      return null;
    } finally {
      isSyncing.value = false;
    }
  }
  
  // جلب تفاصيل حضور مقرر معين
  Future<CourseAttendanceDetails?> syncCourseAttendanceDetails(int courseId) async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        final localDetails = await _storageService.getCourseAttendanceDetails(courseId);
        if (localDetails != null) {
          isUsingLocalData.value = true;
          return localDetails;
        } else {
          throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محلية للمقرر');
        }
      }
      
      // جلب تفاصيل المقرر من الخادم
      final response = await _apiService.get('/student/attendance/course/$courseId');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          final courseDetails = CourseAttendanceDetails.fromJson(response.data['data']);
          
          // حفظ التفاصيل محلياً
          await _storageService.saveCourseAttendanceDetails(courseId, courseDetails);
          
          isUsingLocalData.value = false;
          return courseDetails;
        } else {
          throw Exception(response.data['message'] ?? 'فشل في جلب تفاصيل المقرر');
        }
      } else {
        // إذا فشل الطلب، حاول استخدام البيانات المحلية
        final localDetails = await _storageService.getCourseAttendanceDetails(courseId);
        if (localDetails != null) {
          isUsingLocalData.value = true;
          return localDetails;
        } else {
          throw Exception('فشل في جلب تفاصيل المقرر من الخادم: ${response.statusCode}');
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      
      // محاولة استخدام البيانات المحلية في حالة الخطأ
      final localDetails = await _storageService.getCourseAttendanceDetails(courseId);
      if (localDetails != null) {
        isUsingLocalData.value = true;
        return localDetails;
      }
      
      return null;
    } finally {
      isSyncing.value = false;
    }
  }
  
  // جلب إحصائيات الحضور العامة
  Future<Map<String, dynamic>?> syncAttendanceStatistics() async {
    isSyncing.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // التحقق من وجود اتصال بالإنترنت
      final hasConnection = await _apiService.hasInternetConnection();
      
      if (!hasConnection) {
        // إذا لم يكن هناك اتصال، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم حساب الإحصائيات من البيانات المحلية
      }
      
      // جلب الإحصائيات من الخادم
      final response = await _apiService.get('/student/attendance/statistics');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          isUsingLocalData.value = false;
          return response.data['data'];
        } else {
          throw Exception(response.data['message'] ?? 'فشل في جلب إحصائيات الحضور');
        }
      } else {
        // إذا فشل الطلب، استخدم البيانات المحلية
        isUsingLocalData.value = true;
        return null; // سيتم حساب الإحصائيات من البيانات المحلية
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      isUsingLocalData.value = true;
      return null; // سيتم حساب الإحصائيات من البيانات المحلية
    } finally {
      isSyncing.value = false;
    }
  }
  
  // التحقق من وجود تحديثات لبيانات الحضور
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
      
      // يمكن إضافة طلب للخادم للتحقق من تاريخ آخر تحديث
      // في الوقت الحالي، سنعتبر أن هناك تحديثات إذا مر أكثر من ساعة
      final now = DateTime.now();
      final difference = now.difference(lastUpdated);
      
      return difference.inHours >= 1;
    } catch (e) {
      print('خطأ في التحقق من وجود تحديثات: $e');
      return false;
    }
  }
  
  // مسح التخزين المؤقت وإعادة تحميل البيانات
  Future<AttendanceData?> clearCacheAndReload() async {
    try {
      // مسح جميع بيانات الحضور من التخزين المحلي
      await _storageService.clearAllAttendanceData();
      
      // إعادة تحميل البيانات من الخادم
      return await syncAttendanceData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'فشل في مسح التخزين المؤقت وإعادة التحميل: $e';
      return null;
    }
  }
  
  // تحديث بيانات مقرر واحد
  Future<CourseAttendance?> updateSingleCourse(int courseId) async {
    try {
      final courseDetails = await syncCourseAttendanceDetails(courseId);
      
      if (courseDetails != null) {
        // تحويل تفاصيل المقرر إلى CourseAttendance
        final courseAttendance = CourseAttendance(
          courseId: courseDetails.courseInfo.id,
          courseName: courseDetails.courseInfo.name,
          courseCode: courseDetails.courseInfo.code,
          teacherName: '', // سيتم تحديثه من البيانات الأساسية
          totalLectures: courseDetails.attendanceSummary.totalLectures,
          attendedLectures: courseDetails.attendanceSummary.totalAttended,
          absentLectures: courseDetails.attendanceSummary.totalAbsent,
          attendancePercentage: courseDetails.attendanceSummary.overallPercentage,
          lectures: courseDetails.lectures,
        );
        
        // حفظ المقرر في البيانات المحلية
        await _storageService.saveCourseAttendance(courseAttendance);
        
        return courseAttendance;
      }
      
      return null;
    } catch (e) {
      print('خطأ في تحديث بيانات المقرر: $e');
      return null;
    }
  }
}

