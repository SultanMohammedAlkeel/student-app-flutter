import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_app/core/widgets/neumorphic_container.dart';
import 'package:student_app/core/widgets/custom_app_bar.dart';
import 'package:student_app/core/widgets/loading_widget.dart';
import 'package:student_app/core/widgets/error_widget.dart';
import 'package:student_app/core/widgets/empty_state_widget.dart';
import 'package:student_app/core/themes/colors.dart' hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'attendance_controller.dart';
import 'attendance_model.dart';

class AttendanceView extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  AttendanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'سجلات الحضور والغياب',
        actions: [
          Obx(() => IconButton(
                onPressed: controller.refreshAttendanceData,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Get.isDarkMode
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: Get.isDarkMode
                            ? AppColors.darkNeuLightShadow
                            : AppColors.neuLightShadow,
                      ),
              )),
          // PopupMenuButton<String>(
          //   onSelected: (value) {
          //     switch (value) {
          //       case 'clear_cache':
          //         _showClearCacheDialog(context);
          //         break;
          //       case 'toggle_theme':
          //         controller.toggleDarkMode();
          //         break;
          //     }
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 'clear_cache',
          //       child: Row(
          //         children: [
          //           Icon(Icons.clear_all, size: 20.sp),
          //           SizedBox(width: 8.w),
          //           Text('مسح البيانات المحلية'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 'toggle_theme',
          //       child: Row(
          //         children: [
          //           Obx(() => Icon(
          //                 Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          //                 size: 20.sp,
          //               )),
          //           SizedBox(width: 8.w),
          //           Obx(() => Text(
          //                 Get.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          //               )),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.attendanceData.value.coursesAttendance.isEmpty) {
          return const LoadingWidget();
        }

        if (controller.hasError.value &&
            controller.attendanceData.value.coursesAttendance.isEmpty) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadAttendanceData,
          );
        }

        if (controller.attendanceData.value.coursesAttendance.isEmpty) {
          return EmptyStateWidget(
            animationPath: 'assets/animations/empty_posts.json',
            title: 'لا توجد سجلات حضور',
            subtitle: 'لم يتم العثور على أي سجلات حضور لك حتى الآن',
            actionText: 'تحديث',
            onAction: controller.refreshAttendanceData,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAttendanceData,
          color: Get.isDarkMode
              ? homeController.getPrimaryColor()
              : homeController.getSecondaryColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الطالب
                _buildStudentInfoCard(),
                SizedBox(height: 16.h),

                // الإحصائيات العامة
                _buildSummaryCard(),
                SizedBox(height: 16.h),

                // مؤشر البيانات المحلية
                if (controller.isUsingLocalData.value)
                  _buildLocalDataIndicator(),

                // قائمة المقررات
                _buildCoursesSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStudentInfoCard() {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final studentInfo = controller.attendanceData.value.studentInfo;

      return NeumorphicContainer(
        backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Get.isDarkMode
                      ? homeController.getPrimaryColor()
                      : AppColors.lightPrimary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'معلومات الطالب',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Get.isDarkMode
                        ? AppColors.lightBackground
                        : AppColors.lightOnSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('الاسم', studentInfo.name),
            _buildInfoRow('رقم البطاقة', studentInfo.card),
            _buildInfoRow('المستوى', studentInfo.level),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Get.isDarkMode
                  ? AppColors.lightBackground
                  : AppColors.darkBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Get.isDarkMode
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final summary = controller.attendanceData.value.summary;

      return NeumorphicContainer(
        backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Get.isDarkMode
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'الإحصائيات العامة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Get.isDarkMode
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                    child: _buildStatItem('المقررات',
                        summary.totalCourses.toString(), Icons.book)),
                Expanded(
                    child: _buildStatItem('المحاضرات',
                        summary.totalLectures.toString(), Icons.school)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                    child: _buildStatItem(
                        'الحضور',
                        summary.totalAttended.toString(),
                        Icons.check_circle,
                        Colors.green)),
                Expanded(
                    child: _buildStatItem(
                        'الغياب',
                        summary.totalAbsent.toString(),
                        Icons.cancel,
                        Colors.red)),
              ],
            ),
            SizedBox(height: 16.h),
            _buildOverallPercentage(summary.overallPercentage),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      [Color? color]) {
    return NeumorphicContainer(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ??
                (Get.isDarkMode
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary),
            size: 20.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Get.isDarkMode
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Get.isDarkMode
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallPercentage(double percentage) {
    final color = controller.getAttendanceStatusColor(percentage);
    final status = controller.getAttendanceStatusText(percentage);

    return NeumorphicContainer(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(
            controller.getAttendanceStatusIcon(percentage),
            color: color,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نسبة الحضور الإجمالية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Get.isDarkMode
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '($status)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60.w,
            height: 60.h,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 6,
              backgroundColor: Get.isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalDataIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.offline_pin,
            color: Colors.orange,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'يتم عرض البيانات المحفوظة محلياً',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Obx(() {
      final courses = controller.attendanceData.value.coursesAttendance;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books,
                color: Get.isDarkMode
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'المقررات الدراسية',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Get.isDarkMode
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${courses.length} مقرر',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Get.isDarkMode
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(course);
            },
          ),
        ],
      );
    });
  }

  Widget _buildCourseCard(CourseAttendance course) {
    final color =
        controller.getAttendanceStatusColor(course.attendancePercentage);
    final status =
        controller.getAttendanceStatusText(course.attendancePercentage);

    return NeumorphicContainer(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
      onTap: () => controller.navigateToCourseDetails(course),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Get.isDarkMode
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      course.courseCode,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Get.isDarkMode
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (course.teacherName.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'د. ${course.teacherName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Get.isDarkMode
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: CircularProgressIndicator(
                      value: course.attendancePercentage / 100,
                      strokeWidth: 4,
                      backgroundColor: Get.isDarkMode
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${course.attendancePercentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCourseStatChip(
                  '${course.totalLectures} محاضرة', Icons.school, null),
              SizedBox(width: 8.w),
              _buildCourseStatChip('${course.attendedLectures} حضور',
                  Icons.check_circle, Colors.green),
              SizedBox(width: 8.w),
              _buildCourseStatChip(
                  '${course.absentLectures} غياب', Icons.cancel, Colors.red),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              status,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStatChip(String text, IconData icon, Color? color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ??
                (Get.isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.lightSurface))
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color ??
                (Get.isDarkMode
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant),
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color ??
                  (Get.isDarkMode
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        title: Text(
          'مسح البيانات المحلية',
          style: AppTextStyles.titleLarge.copyWith(
            color: Get.isDarkMode
                ? AppColors.darkOnSurface
                : AppColors.lightOnSurface,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد مسح جميع البيانات المحفوظة محلياً؟ سيتم إعادة تحميل البيانات من الخادم.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Get.isDarkMode
                ? AppColors.darkOnSurface
                : AppColors.lightOnSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: Get.isDarkMode
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearLocalData();
            },
            child: Text(
              'مسح',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
