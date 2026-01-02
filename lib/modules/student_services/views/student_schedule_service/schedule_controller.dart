import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/services/storage_service.dart';

import '../../../../core/network/api_service.dart';
import 'schedule_model.dart';

class ScheduleController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // حالة الجدول الدراسي
  final Rx<Schedule> schedule = Schedule.empty().obs;

  // قوائم البيانات المرتبطة بالجدول
  final RxList<Course> courses = <Course>[].obs;
  final RxList<Hall> halls = <Hall>[].obs;
  final RxList<Teacher> teachers = <Teacher>[].obs;
  final RxList<Department> departments = <Department>[].obs;

  // حالة التحميل والخطأ
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // حالة التخزين المحلي
  final RxBool isUsingLocalData = false.obs;
  final RxBool isDarkMode = false.obs;

  // قوائم ثابتة
  final RxList<String> days = <String>[
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس'
  ].obs;
  final RxList<String> periods =
      <String>['08:00 - 10:00', '10:00 - 12:00', '12:00 - 02:00'].obs;

  // تاريخ آخر تحديث
  final Rx<DateTime> lastUpdated = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    loadSchedule();
  }

  // تحميل وضع السمة (داكن/فاتح)
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('dark_mode') ?? false;
  }

  final selectedDayIndex = 0.obs;

  // أيام الأسبوع

  // تحميل الجدول الدراسي
  Future<void> loadSchedule() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // محاولة تحميل البيانات من التخزين المحلي أولاً
      final localSchedule = await _loadLocalSchedule();

      if (localSchedule != null) {
        schedule.value = localSchedule;
        isUsingLocalData.value = true;
        lastUpdated.value = localSchedule.lastUpdated;

        // تحميل البيانات المرتبطة من التخزين المحلي
        await _loadLocalRelatedData();
      }

      // إذا كان هناك اتصال بالإنترنت، حاول تحديث البيانات من الخادم
      if (await _apiService.hasInternetConnection()&&localSchedule == null) {
        await _fetchScheduleFromServer();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء تحميل الجدول الدراسي: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث الجدول الدراسي من الخادم
  Future<void> refreshSchedule() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      if (await _apiService.hasInternetConnection()) {
        await _fetchScheduleFromServer();
        Get.snackbar(
          'تم التحديث',
          'تم تحديث الجدول الدراسي بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'لا يوجد اتصال بالإنترنت';
        Get.snackbar(
          'خطأ في التحديث',
          'لا يمكن تحديث الجدول الدراسي بدون اتصال بالإنترنت',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء تحديث الجدول الدراسي: $e';
      Get.snackbar(
        'خطأ في التحديث',
        'حدث خطأ أثناء تحديث الجدول الدراسي',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // جلب الجدول الدراسي من الخادم
  Future<void> _fetchScheduleFromServer() async {
    try {
      final response = await _apiService.getSchedule();

      if (response.statusCode == 200 && response.data != null) {
        final scheduleData = Schedule.fromJson(response.data);
        schedule.value = scheduleData;
        lastUpdated.value = DateTime.now();
        isUsingLocalData.value = false;

        // تحديث البيانات المرتبطة
        await _fetchRelatedData();

        // حفظ البيانات محلياً
        await _saveLocalSchedule(scheduleData);
        await _saveLocalRelatedData();
      } else {
        throw 'فشل في جلب الجدول الدراسي من الخادم';
      }
    } catch (e) {
      // إذا فشل جلب البيانات من الخادم ولم تكن هناك بيانات محلية
      if (!isUsingLocalData.value) {
        hasError.value = true;
        errorMessage.value = 'فشل في جلب الجدول الدراسي: $e';
      }
      // إذا كانت هناك بيانات محلية، استمر في استخدامها
    }
  }
  void navigateToSchedule() {
    Get.toNamed('/schedule');
  }
  // جلب البيانات المرتبطة (المقررات، القاعات، المدرسين، الأقسام)
  Future<void> _fetchRelatedData() async {
    try {
      // هنا يمكن إضافة طلبات API لجلب البيانات المرتبطة
      // مثال: جلب المقررات
      // final coursesResponse = await _apiService.getCourses();
      // if (coursesResponse.statusCode == 200 && coursesResponse.data != null) {
      //   courses.value = (coursesResponse.data as List)
      //       .map((item) => Course.fromJson(item))
      //       .toList();
      // }

      // في هذه النسخة، نفترض أن البيانات المرتبطة تأتي مع الجدول الدراسي
      // أو يتم إنشاؤها من بيانات الجدول
    } catch (e) {
      print('خطأ في جلب البيانات المرتبطة: $e');
    }
  }

  // تحميل الجدول الدراسي من التخزين المحلي
  Future<Schedule?> _loadLocalSchedule() async {
    try {
      final scheduleJson = await _storageService.read('student_schedule');
      if (scheduleJson != null) {
        return Schedule.fromJson(scheduleJson);
      }
      return null;
    } catch (e) {
      print('خطأ في تحميل الجدول الدراسي من التخزين المحلي: $e');
      return null;
    }
  }

  // تحميل البيانات المرتبطة من التخزين المحلي
  Future<void> _loadLocalRelatedData() async {
    try {
      final coursesJson =
          await _storageService.read('student_schedule_courses');
      if (coursesJson != null) {
        courses.value =
            (coursesJson as List).map((item) => Course.fromJson(item)).toList();
      }

      final hallsJson = await _storageService.read('student_schedule_halls');
      if (hallsJson != null) {
        halls.value =
            (hallsJson as List).map((item) => Hall.fromJson(item)).toList();
      }

      final teachersJson =
          await _storageService.read('student_schedule_teachers');
      if (teachersJson != null) {
        teachers.value = (teachersJson as List)
            .map((item) => Teacher.fromJson(item))
            .toList();
      }

      final departmentsJson =
          await _storageService.read('student_schedule_departments');
      if (departmentsJson != null) {
        departments.value = (departmentsJson as List)
            .map((item) => Department.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('خطأ في تحميل البيانات المرتبطة من التخزين المحلي: $e');
    }
  }

  // حفظ الجدول الدراسي في التخزين المحلي
  Future<void> _saveLocalSchedule(Schedule scheduleData) async {
    try {
      await _storageService.write('student_schedule', scheduleData.toJson());
    } catch (e) {
      print('خطأ في حفظ الجدول الدراسي في التخزين المحلي: $e');
    }
  }

  // حفظ البيانات المرتبطة في التخزين المحلي
  Future<void> _saveLocalRelatedData() async {
    try {
      if (courses.isNotEmpty) {
        await _storageService.write('student_schedule_courses',
            courses.map((course) => course.toJson()).toList());
      }

      if (halls.isNotEmpty) {
        await _storageService.write('student_schedule_halls',
            halls.map((hall) => hall.toJson()).toList());
      }

      if (teachers.isNotEmpty) {
        await _storageService.write('student_schedule_teachers',
            teachers.map((teacher) => teacher.toJson()).toList());
      }

      if (departments.isNotEmpty) {
        await _storageService.write('student_schedule_departments',
            departments.map((department) => department.toJson()).toList());
      }
    } catch (e) {
      print('خطأ في حفظ البيانات المرتبطة في التخزين المحلي: $e');
    }
  }

  // الحصول على اسم المقرر من معرفه
  String getCourseNameById(String courseId) {
    if (courseId.isEmpty) return '-';

    final course = courses.firstWhereOrNull((c) => c.id.toString() == courseId);
    return course?.name ?? courseId;
  }

  // الحصول على اسم القاعة من معرفها
  String getHallNameById(String hallId) {
    if (hallId.isEmpty) return '-';

    final hall = halls.firstWhereOrNull((h) => h.id.toString() == hallId);
    return hall?.name ?? hallId;
  }

  // الحصول على اسم المدرس من معرفه
  String getTeacherNameById(String teacherId) {
    if (teacherId.isEmpty) return '-';

    final teacher =
        teachers.firstWhereOrNull((t) => t.id.toString() == teacherId);
    return teacher?.name ?? teacherId;
  }

  // الحصول على نوع القاعة من معرفها
  String getHallTypeById(String hallId) {
    if (hallId.isEmpty) return '';

    final hall = halls.firstWhereOrNull((h) => h.id.toString() == hallId);
    return hall?.type ?? '';
  }

  // التحقق مما إذا كانت القاعة معمل
  bool isLabHall(String hallId) {
    final hallType = getHallTypeById(hallId);
    return hallType.contains('معمل');
  }

  // الحصول على محاضرات اليوم
  List<Map<String, dynamic>> getTodayLectures() {
    final today = DateTime.now().weekday;
    // تحويل رقم اليوم في الأسبوع إلى فهرس في مصفوفة الأيام
    // السبت = 0، الأحد = 1، ... الخميس = 5
    int dayIndex;

    switch (today) {
      case DateTime.saturday:
        dayIndex = 0;
        break;
      case DateTime.sunday:
        dayIndex = 1;
        break;
      case DateTime.monday:
        dayIndex = 2;
        break;
      case DateTime.tuesday:
        dayIndex = 3;
        break;
      case DateTime.wednesday:
        dayIndex = 4;
        break;
      case DateTime.thursday:
        dayIndex = 5;
        break;
      default:
        // الجمعة ليس يوم دراسي
        return [];
    }

    List<Map<String, dynamic>> todayLectures = [];

    if (schedule.value.schedule.length > dayIndex) {
      final daySchedule = schedule.value.schedule[dayIndex];

      for (var periodIndex = 0;
          periodIndex < daySchedule.length;
          periodIndex++) {
        final periodCells = daySchedule[periodIndex];

        if (periodCells.isNotEmpty && !periodCells.first.isEmpty) {
          final cell = periodCells.first;

          todayLectures.add({
            'period': periods[periodIndex],
            'periodIndex': periodIndex,
            'course': getCourseNameById(cell.course),
            'courseId': cell.course,
            'hall': getHallNameById(cell.hall),
            'hallId': cell.hall,
            'teacher': getTeacherNameById(cell.teacher),
            'teacherId': cell.teacher,
            'isLab': isLabHall(cell.hall),
          });
        }
      }
    }

    return todayLectures;
  }

  // الحصول على محاضرات الغد
  List<Map<String, dynamic>> getTomorrowLectures() {
    final today = DateTime.now().weekday;
    // تحويل رقم اليوم في الأسبوع إلى فهرس في مصفوفة الأيام للغد
    int tomorrowIndex;

    switch (today) {
      case DateTime.friday:
        tomorrowIndex = 0; // بعد الجمعة يأتي السبت
        break;
      case DateTime.saturday:
        tomorrowIndex = 1; // بعد السبت يأتي الأحد
        break;
      case DateTime.sunday:
        tomorrowIndex = 2; // بعد الأحد يأتي الاثنين
        break;
      case DateTime.monday:
        tomorrowIndex = 3; // بعد الاثنين يأتي الثلاثاء
        break;
      case DateTime.tuesday:
        tomorrowIndex = 4; // بعد الثلاثاء يأتي الأربعاء
        break;
      case DateTime.wednesday:
        tomorrowIndex = 5; // بعد الأربعاء يأتي الخميس
        break;
      case DateTime.thursday:
        return []; // بعد الخميس يأتي الجمعة وهو ليس يوم دراسي
      default:
        return [];
    }

    List<Map<String, dynamic>> tomorrowLectures = [];

    if (schedule.value.schedule.length > tomorrowIndex) {
      final daySchedule = schedule.value.schedule[tomorrowIndex];

      for (var periodIndex = 0;
          periodIndex < daySchedule.length;
          periodIndex++) {
        final periodCells = daySchedule[periodIndex];

        if (periodCells.isNotEmpty && !periodCells.first.isEmpty) {
          final cell = periodCells.first;

          tomorrowLectures.add({
            'period': periods[periodIndex],
            'periodIndex': periodIndex,
            'course': getCourseNameById(cell.course),
            'courseId': cell.course,
            'hall': getHallNameById(cell.hall),
            'hallId': cell.hall,
            'teacher': getTeacherNameById(cell.teacher),
            'teacherId': cell.teacher,
            'isLab': isLabHall(cell.hall),
          });
        }
      }
    }

    return tomorrowLectures;
  }

  // دالة للحصول على جدول يوم محدد
  List<Map<String, dynamic>> getScheduleForDay(int day) {
    final dayIndex = day; // تحويل رقم اليوم إلى فهرس (0-6)
// selectedDayIndex.value=day;
    if (schedule.value.schedule.length > dayIndex) {
      final daySchedule = schedule.value.schedule[dayIndex];
      List<Map<String, dynamic>> lectures = [];

      for (var periodIndex = 0;
          periodIndex < daySchedule.length;
          periodIndex++) {
        final periodCells = daySchedule[periodIndex];

        if (periodCells.isNotEmpty && !periodCells.first.isEmpty) {
          final cell = periodCells.first;

          lectures.add({
            'period': periods[periodIndex],
            'periodIndex': periodIndex,
            'course': getCourseNameById(cell.course),
            'courseId': cell.course,
            'hall': getHallNameById(cell.hall),
            'hallId': cell.hall,
            'teacher': getTeacherNameById(cell.teacher),
            'teacherId': cell.teacher,
            'isLab': isLabHall(cell.hall),
          });
        }
      }

      return lectures;
    }

    return [];
  }
}
