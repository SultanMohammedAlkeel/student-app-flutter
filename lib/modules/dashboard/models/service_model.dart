import 'package:flutter/material.dart';

/// نموذج بيانات الخدمة
class ServiceModel {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final Color secondaryColor;
  final String? lottieAsset;
  final int notificationsCount;
  final bool isAnimated;
  final String route;

  ServiceModel({
    required this.id,
    required this.title,
     this.description,
    required this.icon,
    required this.color,
    required this.secondaryColor,
    this.lottieAsset,
    this.notificationsCount = 0,
    this.isAnimated = false,
    required this.route,
  });

  // إنشاء قائمة الخدمات الافتراضية
  static List<ServiceModel> getDefaultServices() {
    return [
      ServiceModel(
        id: 'schedule',
        title: 'الجدول الدراسي',
        description: 'عرض وتنظيم جدول المحاضرات والمواعيد',
        icon: Icons.calendar_today_rounded,
        color: Colors.blue,
        secondaryColor: Colors.blue.shade300,
        lottieAsset: 'assets/animations/calendar.json',
        notificationsCount: 2,
        isAnimated: true,
        route: '/schedule',
      ),
      ServiceModel(
        id: 'library',
        title: 'المكتبة الإلكترونية',
        description: 'الوصول إلى الكتب والمراجع الإلكترونية',
        icon: Icons.menu_book_rounded,
        color: Colors.green,
        secondaryColor: Colors.green.shade300,
        lottieAsset: 'assets/animations/book.json',
        isAnimated: true,
        route: '/library',
      ),
      ServiceModel(
        id: 'grades',
        title: 'الدرجات',
        description: 'عرض نتائج الاختبارات والتقييمات',
        icon: Icons.grade_rounded,
        color: Colors.amber,
        secondaryColor: Colors.amber.shade300,
        notificationsCount: 1,
        route: '/grades',
      ),
      ServiceModel(
        id: 'exams',
        title: 'نماذج الاختبارات',
        description: 'الوصول إلى نماذج الاختبارات السابقة',
        icon: Icons.assignment_rounded,
        color: Colors.purple,
        secondaryColor: Colors.purple.shade300,
        route: '/exams',
      ),
      ServiceModel(
        id: 'study_tasks',
        title: 'المهام والمذاكرة',
        description: 'تنظيم المهام الدراسية وجدولة المذاكرة',
        icon: Icons.task_alt_rounded,
        color: Colors.red,
        secondaryColor: Colors.red.shade300,
        lottieAsset: 'assets/animations/tasks.json',
        isAnimated: true,
        route: '/study_tasks',
      ),
      ServiceModel(
        id: 'activities',
        title: 'الأنشطة والفعاليات',
        description: 'عرض الأنشطة والفعاليات الجامعية',
        icon: Icons.event_rounded,
        color: Colors.teal,
        secondaryColor: Colors.teal.shade300,
        notificationsCount: 3,
        route: '/activities',
      ),
      ServiceModel(
        id: 'university_info',
        title: 'معلومات الجامعة',
        description: 'استعراض معلومات الجامعة والكليات والمباني',
        icon: Icons.school_rounded,
        color: Colors.indigo,
        secondaryColor: Colors.indigo.shade300,
        lottieAsset: 'assets/animations/university.json',
        isAnimated: true,
        route: '/university_info',
      ),
      ServiceModel(
        id: 'more',
        title: 'خدمات إضافية',
        description: 'المزيد من الخدمات الطلابية',
        icon: Icons.more_horiz_rounded,
        color: Colors.grey,
        secondaryColor: Colors.grey.shade400,
        route: '/more_services',
      ),
    ];
  }
}
