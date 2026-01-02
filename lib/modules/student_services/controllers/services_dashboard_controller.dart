import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../views/attendance_service/attendance_controller.dart';
import '../views/student_schedule_service/schedule_controller.dart';
class ServicesDashboardController extends GetxController {
  ScheduleController schedulecontroller = Get.find<ScheduleController>();
  final AttendanceController _attendanceController = Get.find<AttendanceController>(); // جلب متحكم الحضور

  // حالة التحميل
  final isLoading = false.obs;

  // وضع الظلام
  final isDarkMode = false.obs;

  // بيانات الطالب
  final student = StudentModel(
    id: '',
    name: '',
    department: '',
    profileImage: '',
    attendanceRate: 0.0, // تغيير إلى double
  ).obs;

  // التنويهات
  final notifications = <NotificationModel>[].obs;

  // الخدمات الرئيسية
  final primaryServices = <ServiceModel>[].obs;

  // الخدمات الثانوية
  final secondaryServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // تهيئة بيانات اللغة الع
    // تحميل البيانات
    loadData();
    // الاستماع لتغيرات نسبة الحضور في AttendanceController
    ever(_attendanceController.attendanceData, (_) => _updateStudentAttendanceRate());
  }

  // تحميل البيانات
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // تهيئة الخدمات
      _initializeServices();
      // جلب بيانات الحضور وتحديث نسبة الحضور للطالب
      await _attendanceController.loadAttendanceData();
      _updateStudentAttendanceRate();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    await loadData();
  }

  // تهيئة الخدمات
  void _initializeServices() {
    // الخدمات الرئيسية
    primaryServices.value = [
      ServiceModel(
        id: 'schedule',
        title: 'الجدول الدراسي',
        description: 'عرض الجدول الدراسي الأسبوعي',
        iconData: Icons.calendar_today,
        color: Colors.blue,
        route: '/schedule',
      ),
      ServiceModel(
        id: 'tasks',
        title: 'المهام والمذاكرة',
        description: 'إدارة المهام وجداول المذاكرة',
        iconData: Icons.task_alt,
        color: Colors.purple,
        route: '/tasks',
      ),
    ];

    // الخدمات الثانوية
    secondaryServices.value = [
      ServiceModel(
        id: 'library',
        title: 'المكتبة الإلكترونية',
        description: 'الوصول للكتب والمراجع',
        iconData: Icons.menu_book,
        color: Colors.amber,
        route: '/library',
      ),
      ServiceModel(
        id: 'exams',
        title: 'نماذج الاختبارات',
        description: 'تصفح نماذج الاختبارات السابقة',
        iconData: Icons.quiz,
        color: Colors.red,
        route: '/exams',
      ),
      ServiceModel(
        id: 'grades',
        title: 'الدرجات',
        description: 'عرض الدرجات والتقديرات',
        iconData: Icons.grade,
        color: Colors.green,
        route: '/grades',
      ),
      ServiceModel(
        id: 'attendance',
        title: 'الحضور والغياب',
        description: 'متابعة سجل الحضور',
        iconData: Icons.fact_check,
        color: Colors.teal,
        route: '/attendance',
      ),
    ];
  }

  // تحديث نسبة الحضور للطالب من AttendanceController
  void _updateStudentAttendanceRate() {
    final overallPercentage = _attendanceController.attendanceData.value.summary.overallPercentage;
    student.update((val) {
      val?.attendanceRate = overallPercentage;
    });
  }

  // التنقل إلى الخدمة المحددة
  void navigateToService(ServiceModel service) {
    if (Get.isDialogOpen ?? false) {
      Get.back(); // أغلق أي dialogs مفتوحة
    }

    if (service.route != null && service.route!.isNotEmpty) {
      Get.toNamed(service.route!);
    } else {
      Get.defaultDialog(
        title: 'الخدمة غير متاحة',
        middleText: 'هذه الخدمة قيد التطوير حالياً',
      );
    }
  }

  // التنقل إلى صفحة الجدول الدراسي
  void navigateToSchedule() {
    Get.toNamed('/schedule');
  }
}

// نموذج بيانات الطالب
class StudentModel {
  final String id;
  final String name;
  final String department;
  final String profileImage;
  double attendanceRate; // تغيير إلى double

  StudentModel({
    required this.id,
    required this.name,
    required this.department,
    required this.profileImage,
    required this.attendanceRate,
  });
}

// نموذج بيانات التنويهات
class NotificationModel {
  final String id;
  final String message;
  final String date;
  final bool isImportant;

  NotificationModel({
    required this.id,
    required this.message,
    required this.date,
    required this.isImportant,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      date: json['date'],
      isImportant: json['is_important'] ?? false,
    );
  }
}


