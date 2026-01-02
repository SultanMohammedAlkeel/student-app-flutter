import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/storage_service.dart';
import '../../../../core/network/api_service.dart';
import 'attendance_model.dart';
import 'attendance_storage_service.dart';
import 'attendance_sync_service.dart';

class AttendanceController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final AttendanceStorageService _attendanceStorage = Get.find<AttendanceStorageService>();
  final AttendanceSyncService _syncService = Get.find<AttendanceSyncService>();

  // حالة بيانات الحضور
  final Rx<AttendanceData> attendanceData = AttendanceData.empty().obs;
  final Rx<CourseAttendanceDetails> selectedCourseDetails = CourseAttendanceDetails(
    courseInfo: CourseInfo(id: 0, name: '', code: '', level: ''),
    attendanceSummary: AttendanceSummary(
      totalCourses: 0,
      totalLectures: 0,
      totalAttended: 0,
      totalAbsent: 0,
      overallPercentage: 0.0,
    ),
    lectures: [],
  ).obs;

  // حالة التحميل والخطأ
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // حالة التخزين المحلي
  final RxBool isUsingLocalData = false.obs;
  final RxBool isDarkMode = false.obs;

  // تاريخ آخر تحديث
  final Rx<DateTime> lastUpdated = DateTime.now().obs;

  // المقرر المحدد حالياً
  final RxInt selectedCourseId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    loadAttendanceData();
  }

  // تحميل وضع السمة (داكن/فاتح)
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('dark_mode') ?? false;
  }

  // تحميل بيانات الحضور
  Future<void> loadAttendanceData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // محاولة تحميل البيانات من التخزين المحلي أولاً
      final localData = await _attendanceStorage.getAttendanceData();

      if (localData != null) {
        attendanceData.value = localData;
        isUsingLocalData.value = true;
        lastUpdated.value = localData.lastUpdated;
      }

      // إذا كان هناك اتصال بالإنترنت، حاول تحديث البيانات من الخادم
      if (await _apiService.hasInternetConnection() && localData == null) {
        await _fetchAttendanceFromServer();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء تحميل بيانات الحضور: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث بيانات الحضور من الخادم
  Future<void> refreshAttendanceData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      if (await _apiService.hasInternetConnection()) {
        await _fetchAttendanceFromServer();
        Get.snackbar(
          'تم التحديث',
          'تم تحديث بيانات الحضور بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'لا يوجد اتصال بالإنترنت';
        Get.snackbar(
          'خطأ في التحديث',
          'لا يمكن تحديث بيانات الحضور بدون اتصال بالإنترنت',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء تحديث بيانات الحضور: $e';
      Get.snackbar(
        'خطأ في التحديث',
        'حدث خطأ أثناء تحديث بيانات الحضور',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // جلب بيانات الحضور من الخادم
  Future<void> _fetchAttendanceFromServer() async {
    try {
      final data = await _syncService.syncAttendanceData();

      if (data != null) {
        attendanceData.value = data;
        lastUpdated.value = DateTime.now();
        isUsingLocalData.value = false;
      } else {
        throw 'فشل في جلب بيانات الحضور من الخادم';
      }
    } catch (e) {
      // إذا فشل جلب البيانات من الخادم ولم تكن هناك بيانات محلية
      if (!isUsingLocalData.value) {
        hasError.value = true;
        errorMessage.value = 'فشل في جلب بيانات الحضور: $e';
      }
      // إذا كانت هناك بيانات محلية، استمر في استخدامها
    }
  }

  // تحميل تفاصيل مقرر معين
  Future<void> loadCourseDetails(int courseId) async {
    selectedCourseId.value = courseId;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // محاولة تحميل التفاصيل من التخزين المحلي أولاً
      final localDetails = await _attendanceStorage.getCourseAttendanceDetails(courseId);

      if (localDetails != null) {
        selectedCourseDetails.value = localDetails;
        isUsingLocalData.value = true;
      }

      // إذا كان هناك اتصال بالإنترنت، حاول تحديث التفاصيل من الخادم
      if (await _apiService.hasInternetConnection()) {
        final serverDetails = await _syncService.syncCourseAttendanceDetails(courseId);
        if (serverDetails != null) {
          selectedCourseDetails.value = serverDetails;
          isUsingLocalData.value = false;
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء تحميل تفاصيل المقرر: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // الانتقال إلى صفحة تفاصيل المقرر
  void navigateToCourseDetails(CourseAttendance course) {
    Get.toNamed('/attendance/course-details', arguments: {
      'courseId': course.courseId,
      'courseName': course.courseName,
      'courseCode': course.courseCode,
    });
  }

  // الحصول على لون حالة الحضور
  Color getAttendanceStatusColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  // الحصول على نص حالة الحضور
  String getAttendanceStatusText(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  // الحصول على أيقونة حالة الحضور
  IconData getAttendanceStatusIcon(double percentage) {
    if (percentage >= 90) return Icons.sentiment_very_satisfied;
    if (percentage >= 80) return Icons.sentiment_satisfied;
    if (percentage >= 70) return Icons.sentiment_neutral;
    if (percentage >= 60) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  // فلترة المقررات حسب حالة الحضور
  List<CourseAttendance> getFilteredCourses(String filter) {
    switch (filter) {
      case 'excellent':
        return attendanceData.value.coursesAttendance
            .where((course) => course.attendancePercentage >= 90)
            .toList();
      case 'good':
        return attendanceData.value.coursesAttendance
            .where((course) => course.attendancePercentage >= 70 && course.attendancePercentage < 90)
            .toList();
      case 'poor':
        return attendanceData.value.coursesAttendance
            .where((course) => course.attendancePercentage < 70)
            .toList();
      default:
        return attendanceData.value.coursesAttendance;
    }
  }

  // ترتيب المقررات
  List<CourseAttendance> getSortedCourses(String sortBy) {
    List<CourseAttendance> courses = List.from(attendanceData.value.coursesAttendance);
    
    switch (sortBy) {
      case 'name':
        courses.sort((a, b) => a.courseName.compareTo(b.courseName));
        break;
      case 'percentage_high':
        courses.sort((a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));
        break;
      case 'percentage_low':
        courses.sort((a, b) => a.attendancePercentage.compareTo(b.attendancePercentage));
        break;
      case 'lectures':
        courses.sort((a, b) => b.totalLectures.compareTo(a.totalLectures));
        break;
      default:
        // الترتيب الافتراضي حسب اسم المقرر
        courses.sort((a, b) => a.courseName.compareTo(b.courseName));
    }
    
    return courses;
  }

  // البحث في المقررات
  List<CourseAttendance> searchCourses(String query) {
    if (query.isEmpty) {
      return attendanceData.value.coursesAttendance;
    }
    
    return attendanceData.value.coursesAttendance
        .where((course) =>
            course.courseName.toLowerCase().contains(query.toLowerCase()) ||
            course.courseCode.toLowerCase().contains(query.toLowerCase()) ||
            course.teacherName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // الحصول على إحصائيات سريعة
  Map<String, int> getQuickStats() {
    final courses = attendanceData.value.coursesAttendance;
    
    return {
      'excellent': courses.where((c) => c.attendancePercentage >= 90).length,
      'good': courses.where((c) => c.attendancePercentage >= 70 && c.attendancePercentage < 90).length,
      'poor': courses.where((c) => c.attendancePercentage < 70).length,
      'total': courses.length,
    };
  }

  // مسح البيانات المحلية
  Future<void> clearLocalData() async {
    try {
      await _attendanceStorage.clearAllAttendanceData();
      attendanceData.value = AttendanceData.empty();
      selectedCourseDetails.value = CourseAttendanceDetails(
        courseInfo: CourseInfo(id: 0, name: '', code: '', level: ''),
        attendanceSummary: AttendanceSummary(
          totalCourses: 0,
          totalLectures: 0,
          totalAttended: 0,
          totalAbsent: 0,
          overallPercentage: 0.0,
        ),
        lectures: [],
      );
      
      Get.snackbar(
        'تم المسح',
        'تم مسح البيانات المحلية بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء مسح البيانات المحلية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // التحقق من وجود تحديثات
  Future<bool> checkForUpdates() async {
    return await _syncService.checkForUpdates();
  }

  // تبديل وضع السمة
  void toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode.value);
  }
}

