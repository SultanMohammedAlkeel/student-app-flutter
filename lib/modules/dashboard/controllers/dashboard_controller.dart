import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../views/widgets/futuristic_data_chart.dart';
import '../views/widgets/futuristic_radar_chart.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/themes/colors.dart';

class HomePageController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // بيانات المستخدم
  final Rx<String> userName = ''.obs;
  final Rx<String> userAvatar = ''.obs;
  final Rx<String> userLevel = ''.obs;
  final Rx<String> userMajor = ''.obs;
  final Rx<String> userCollege = ''.obs;
  
  // بيانات الفصل الدراسي
  final Rx<String> semesterName = ''.obs;
  final Rx<String> semesterProgress = '0'.obs;
  final Rx<double> semesterProgressValue = 0.0.obs;
  final Rx<int> notificationsCount = 0.obs;
  // قائمة الخدمات
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  
  // حالة الوضع الداكن
  final Rx<bool> isDarkMode = false.obs;
  
  // محاضرات اليوم
  final RxList<Map<String, dynamic>> todayLectures = <Map<String, dynamic>>[].obs;
  
  // المهام القادمة
  final RxList<Map<String, dynamic>> upcomingTasks = <Map<String, dynamic>>[].obs;
  
  // بيانات الأداء الأكاديمي
  final RxList<DataPoint> academicPerformance = <DataPoint>[].obs;
  
  // بيانات مهارات الطالب
  final RxList<RadarDataSet> studentSkills = <RadarDataSet>[].obs;

  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadSemesterData();
    loadServices();
    loadTodayLectures();
    loadUpcomingTasks();
    loadAcademicPerformance();
    loadStudentSkills();
    
    // التحقق من وضع السمة
    isDarkMode.value = Get.isDarkMode;
  }
  
  // تحميل بيانات المستخدم من التخزين المحلي
  void loadUserData() {
    try {
      final userData = _storageService.read('user_data');
      if (userData != null) {
        userName.value = userData['name'] ?? 'مستخدم جديد';
        userAvatar.value = userData['avatar'] ?? '';
        userLevel.value = userData['level'] ?? 'المستوى الأول';
        userMajor.value = userData['major'] ?? 'علوم الحاسب';
        userCollege.value = userData['college'] ?? 'كلية الحاسبات والمعلومات';
      } else {
        // بيانات افتراضية للعرض
        userName.value = 'أحمد محمد';
        userAvatar.value = 'assets/images/avatar.png';
        userLevel.value = 'المستوى الرابع';
        userMajor.value = 'هندسة البرمجيات';
        userCollege.value = 'كلية الحاسبات والمعلومات';
      }
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
      // بيانات افتراضية للعرض
      userName.value = 'أحمد محمد';
      userAvatar.value = 'assets/images/avatar.png';
      userLevel.value = 'المستوى الرابع';
      userMajor.value = 'هندسة البرمجيات';
      userCollege.value = 'كلية الحاسبات والمعلومات';
    }
  }
  
  // تحميل بيانات الفصل الدراسي من التخزين المحلي
  void loadSemesterData() {
    try {
      final semesterData = _storageService.read('semester_data');
      if (semesterData != null) {
        semesterName.value = semesterData['name'] ?? 'الفصل الدراسي الحالي';
        semesterProgress.value = semesterData['progress'] ?? '0';
        semesterProgressValue.value = double.tryParse(semesterData['progress'] ?? '0') ?? 0.0;
        semesterProgressValue.value = semesterProgressValue.value / 100;
      } else {
        // بيانات افتراضية للعرض
        semesterName.value = 'الفصل الدراسي الثاني 1446هـ';
        semesterProgress.value = '65';
        semesterProgressValue.value = 0.65;
      }
    } catch (e) {
      print('خطأ في تحميل بيانات الفصل الدراسي: $e');
      // بيانات افتراضية للعرض
      semesterName.value = 'الفصل الدراسي الثاني 1446هـ';
      semesterProgress.value = '65';
      semesterProgressValue.value = 0.65;
    }
  }
  
// تحميل قائمة الخدمات
void loadServices() {
  services.value = ServiceModel.getDefaultServices();
}



  // إنشاء قائمة الخدمات الافتراضية
  static List<ServiceModel> getDefaultServices() {
    return [
      ServiceModel(
        id: '1',
        title: 'الجدول الدراسي',
        description: 'عرض جدول المحاضرات الأسبوعي وجدول الامتحانات',
        icon: Icons.calendar_today_rounded,
        color: Color(0xFF4285F4), // أزرق Google
        secondaryColor: Color(0xFF8AB4F8),
        lottieAsset: 'assets/animations/schedule.json',
        notificationsCount: 2,
        isAnimated: true,
        route: '/schedule',
      ),
      ServiceModel(
        id: '2',
        title: 'المكتبة الإلكترونية',
        description: 'تصفح الكتب الإلكترونية والمراجع العلمية',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF0F9D58), // أخضر Google
        secondaryColor: Color(0xFF81C995),
        lottieAsset: 'assets/animations/library.json',
        notificationsCount: 3,
        isAnimated: true,
        route: '/library',
      ),
      ServiceModel(
        id: '3',
        title: 'الدرجات والتقييمات',
        description: 'عرض النتائج والتقييمات الدراسية',
        icon: Icons.grade_rounded,
        color: Color(0xFFFFB900), // أصفر Microsoft
        secondaryColor: Color(0xFFFFD566),
        lottieAsset: 'assets/animations/grades.json',
        notificationsCount: 1,
        route: '/grades',
      ),
      ServiceModel(
        id: '4',
        title: 'نماذج الامتحانات',
        description: 'نماذج اختبارات سابقة واختبارات تجريبية',
        icon: Icons.assignment_rounded,
        color: Color(0xFF9C27B0), // بنفسجي Material
        secondaryColor: Color(0xFFBA68C8),
        lottieAsset: 'assets/animations/exams.json',
        route: '/exams',
      ),
      ServiceModel(
        id: '5',
        title: 'المهام والمذاكرة',
        description: 'تنظيم المهام الدراسية وجدول المذاكرة',
        icon: Icons.task_alt_rounded,
        color: Color(0xFFEA4335), // أحمر Google
        secondaryColor: Color(0xFFF28B82),
        lottieAsset: 'assets/animations/tasks.json',
        notificationsCount: 5,
        isAnimated: true,
        route: '/tasks',
      ),
      ServiceModel(
        id: '6',
        title: 'الأنشطة والفعاليات',
        description: 'فعاليات وأنشطة الجامعة والكليات',
        icon: Icons.event_rounded,
        color: Color(0xFF00ACC1), // تركواز Material
        secondaryColor: Color(0xFF4DD0E1),
        lottieAsset: 'assets/animations/events.json',
        notificationsCount: 2,
        route: '/events',
      ),
      ServiceModel(
        id: '7',
        title: 'معلومات الجامعة',
        description: 'معلومات عن الكليات والأقسام والمرافق',
        icon: Icons.school_rounded,
        color: Color(0xFF3F51B5), // نيلي Material
        secondaryColor: Color(0xFF7986CB),
        lottieAsset: 'assets/animations/university.json',
        route: '/university',
      ),
      ServiceModel(
        id: '8',
        title: 'الخدمات الإضافية',
        description: 'خدمات الطلاب الإضافية والمتنوعة',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF757575), // رمادي Material
        secondaryColor: Color(0xFFBDBDBD),
        route: '/more-services',
      ),
      ServiceModel(
        id: '9',
        title: 'النظام الأكاديمي',
        description: 'التسجيل في المواد ومتابعة السجل الأكاديمي',
        icon: Icons.school_rounded,
        color: Color(0xFF607D8B), // أزرق رمادي Material
        secondaryColor: Color(0xFF90A4AE),
        route: '/academic',
      ),
      ServiceModel(
        id: '10',
        title: 'المنح والمساعدات',
        description: 'المنح الدراسية والمساعدات المالية',
        icon: Icons.attach_money_rounded,
        color: Color(0xFF4CAF50), // أخضر Material
        secondaryColor: Color(0xFF81C784),
        route: '/scholarships',
      ),
      ServiceModel(
        id: '11',
        title: 'الدعم الفني',
        description: 'الدعم الفني وحل المشكلات التقنية',
        icon: Icons.support_rounded,
        color: Color(0xFFFF9800), // برتقالي Material
        secondaryColor: Color(0xFFFFB74D),
        route: '/support',
      ),
      ServiceModel(
        id: '12',
        title: 'المركز الإعلامي',
        description: 'أخبار الجامعة والفعاليات الإعلامية',
        icon: Icons.newspaper_rounded,
        color: Color(0xFFE91E63), // وردي Material
        secondaryColor: Color(0xFFF06292),
        route: '/media-center',
      ),
    ];
  }

  // تحميل محاضرات اليوم
  void loadTodayLectures() {
    try {
      final lecturesData = _storageService.read('today_lectures');
      if (lecturesData != null && lecturesData is List) {
        todayLectures.value = List<Map<String, dynamic>>.from(lecturesData);
      } else {
        // بيانات افتراضية للعرض
        todayLectures.value = [
          {
            'title': 'هندسة البرمجيات المتقدمة',
            'time': '10:00 - 11:30',
            'location': 'مبنى A - قاعة 305',
            'instructor': 'د. محمد أحمد',
            'color': AppColors.blueAccent,
            'isUpcoming': true,
          },
          {
            'title': 'تطوير تطبيقات الويب',
            'time': '12:00 - 13:30',
            'location': 'مبنى B - معمل 102',
            'instructor': 'د. سارة خالد',
            'color': AppColors.highPriority,
            'isUpcoming': false,
          },
          {
            'title': 'الذكاء الاصطناعي',
            'time': '14:00 - 15:30',
            'location': 'مبنى C - قاعة 201',
            'instructor': 'د. أحمد علي',
            'color': AppColors.lowPriority,
            'isUpcoming': false,
          },
        ];
      }
    } catch (e) {
      print('خطأ في تحميل محاضرات اليوم: $e');
      // بيانات افتراضية للعرض
      todayLectures.value = [
        {
          'title': 'هندسة البرمجيات المتقدمة',
          'time': '10:00 - 11:30',
          'location': 'مبنى A - قاعة 305',
          'instructor': 'د. محمد أحمد',
          'color': AppColors.blueAccent.value,
          'isUpcoming': true,
        },
        {
          'title': 'تطوير تطبيقات الويب',
          'time': '12:00 - 13:30',
          'location': 'مبنى B - معمل 102',
          'instructor': 'د. سارة خالد',
          'color': AppColors.mediumPriority,
          'isUpcoming': false,
        },
        {
          'title': 'الذكاء الاصطناعي',
          'time': '14:00 - 15:30',
          'location': 'مبنى C - قاعة 201',
          'instructor': 'د. أحمد علي',
          'color': AppColors.lowPriority,
          'isUpcoming': false,
        },
      ];
    }
  }
  
  // تحميل المهام القادمة
  void loadUpcomingTasks() {
    try {
      final tasksData = _storageService.read('upcoming_tasks');
      if (tasksData != null && tasksData is List) {
        upcomingTasks.value = List<Map<String, dynamic>>.from(tasksData);
      } else {
        // بيانات افتراضية للعرض
        upcomingTasks.value = [
          {
            'title': 'تسليم مشروع هندسة البرمجيات',
            'dueDate': 'اليوم - 23:59',
            'course': 'هندسة البرمجيات المتقدمة',
            'priority': 'عالية',
            'color': AppColors.error,
            'progress': 0.8,
          },
          {
            'title': 'اختبار قصير في الذكاء الاصطناعي',
            'dueDate': 'غداً - 10:00',
            'course': 'الذكاء الاصطناعي',
            'priority': 'متوسطة',
            'color': AppColors.mediumPriority,
            'progress': 0.6,
          },
          {
            'title': 'قراءة الفصل السابع',
            'dueDate': 'بعد غد',
            'course': 'تطوير تطبيقات الويب',
            'priority': 'منخفضة',
            'color': AppColors.blueAccent.value,
            'progress': 0.3,
          },
        ];
      }
    } catch (e) {
      print('خطأ في تحميل المهام القادمة: $e');
      // بيانات افتراضية للعرض
      upcomingTasks.value = [
        {
          'title': 'تسليم مشروع هندسة البرمجيات',
          'dueDate': 'اليوم - 23:59',
          'course': 'هندسة البرمجيات المتقدمة',
          'priority': 'عالية',
          'color': AppColors.blueAccent,
          'progress': 0.8,
        },
        {
          'title': 'اختبار قصير في الذكاء الاصطناعي',
          'dueDate': 'غداً - 10:00',
          'course': 'الذكاء الاصطناعي',
          'priority': 'متوسطة',
          'color': AppColors.mediumPriority,
          'progress': 0.6,
        },
        {
          'title': 'قراءة الفصل السابع',
          'dueDate': 'بعد غد',
          'course': 'تطوير تطبيقات الويب',
          'priority': 'منخفضة',
          'color': AppColors.blueAccent.value,
          'progress': 0.3,
        },
      ];
    }
  }
  
  // تحميل بيانات الأداء الأكاديمي
  void loadAcademicPerformance() {
    academicPerformance.value = [
      DataPoint(label: 'الفصل 1', value: 4.2),
      DataPoint(label: 'الفصل 2', value: 4.5),
      DataPoint(label: 'الفصل 3', value: 4.3),
      DataPoint(label: 'الفصل 4', value: 4.7),
      DataPoint(label: 'الفصل 5', value: 4.8),
    ];
  }
  
  // تحميل بيانات مهارات الطالب
  void loadStudentSkills() {
    studentSkills.value = [
      RadarDataSet(
        name: 'المهارات الحالية',
        values: [0.8, 0.7, 0.9, 0.6, 0.85],
        color: AppColors.blueAccent,
      ),
      RadarDataSet(
        name: 'المهارات المستهدفة',
        values: [0.9, 0.85, 0.95, 0.8, 0.9],
        color: AppColors.blueAccent,
      ),
    ];
  }
  
  // تبديل وضع السمة
  void toggleTheme() {
    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
    isDarkMode.value = Get.isDarkMode;
  }
  
  // الانتقال إلى صفحة الخدمة
  void navigateToService(ServiceModel service) {
    Get.toNamed(service.route);
  }
  
  // إضافة مهمة جديدة
  void addNewTask() {
    Get.toNamed('/tasks/add');
  }
}
