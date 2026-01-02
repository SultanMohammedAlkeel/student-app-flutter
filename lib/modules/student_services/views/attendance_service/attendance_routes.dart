// إضافة مسارات التنقل لخدمة سجلات الحضور والغياب

import 'package:get/get.dart';
import 'attendance_view.dart';
import 'course_attendance_details_view.dart';

class AttendanceRoutes {
  static const String attendance = '/attendance';
  static const String courseDetails = '/attendance/course-details';

  static List<GetPage> routes = [
    GetPage(
      name: attendance,
      page: () => AttendanceView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: courseDetails,
      page: () => CourseAttendanceDetailsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

