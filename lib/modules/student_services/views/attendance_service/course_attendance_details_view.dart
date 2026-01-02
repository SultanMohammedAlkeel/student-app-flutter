import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/widgets/neumorphic_container.dart';
import 'package:student_app/core/widgets/custom_app_bar.dart';
import 'package:student_app/core/widgets/loading_widget.dart';
import 'package:student_app/core/widgets/error_widget.dart';
import 'package:student_app/core/widgets/empty_state_widget.dart';
import 'package:student_app/core/themes/colors.dart' hide AppTextStyles;
import 'package:student_app/core/widgets/app_text_styles.dart';
import 'attendance_controller.dart';
import 'attendance_model.dart';

class CourseAttendanceDetailsView extends StatelessWidget {
  final AttendanceController controller = Get.find<AttendanceController>();
  final int courseId = Get.arguments['courseId'] ?? 0;
  final String courseName = Get.arguments['courseName'] ?? '';
  final String courseCode = Get.arguments['courseCode'] ?? '';

  CourseAttendanceDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحميل تفاصيل المقرر عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCourseDetails(courseId);
    });

    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'تفاصيل الحضور',
        subtitle: courseCode,
        actions: [
          Obx(() => IconButton(
                onPressed: () => controller.loadCourseDetails(courseId),
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Get.isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: Get.isDarkMode
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedCourseDetails.value.lectures.isEmpty) {
          return const LoadingWidget();
        }

        if (controller.hasError.value &&
            controller.selectedCourseDetails.value.lectures.isEmpty) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadCourseDetails(courseId),
          );
        }

        final courseDetails = controller.selectedCourseDetails.value;

        if (courseDetails.lectures.isEmpty) {
          return EmptyStateWidget(
            animationPath: 'assets/animations/empty_lectures.json',
            title: 'لا توجد محاضرات',
            subtitle: 'لم يتم العثور على أي محاضرات لهذا المقرر حتى الآن',
            actionText: 'تحديث',
            onAction: () => controller.loadCourseDetails(courseId),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCourseDetails(courseId),
          color:
              Get.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المقرر
                _buildCourseInfoCard(courseDetails.courseInfo),
                SizedBox(height: 16.h),

                // // إحصائيات الحضور
                // _buildAttendanceSummaryCard(courseDetails.attendanceSummary),
                // SizedBox(height: 16.h),

                // مؤشر البيانات المحلية
                if (controller.isUsingLocalData.value)
                  _buildLocalDataIndicator(),

                // قائمة المحاضرات
                _buildLecturesSection(courseDetails.lectures),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCourseInfoCard(CourseInfo courseInfo) {
    return NeumorphicContainer(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.book,
                color: Get.isDarkMode
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'معلومات المقرر',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Get.isDarkMode
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('اسم المقرر', courseInfo.name),
          _buildInfoRow('رمز المقرر', courseInfo.code),
          _buildInfoRow('المستوى', courseInfo.level),
        ],
      ),
    );
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
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
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

  // Widget _buildAttendanceSummaryCard(AttendanceSummary summary) {
  //   final percentage = summary.overallPercentage;
  //   final color = controller.getAttendanceStatusColor(percentage);
  //   final status = controller.getAttendanceStatusText(percentage);

  //   return NeumorphicContainer(
  //     padding: EdgeInsets.all(16.w),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.analytics,
  //               color: Get.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
  //               size: 24.sp,
  //             ),
  //             SizedBox(width: 8.w),
  //             Text(
  //               'إحصائيات الحضور',
  //               style: AppTextStyles.headlineSmall.copyWith(
  //                 color: Get.isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 16.h),

  //         // نسبة الحضور الرئيسية
  //         NeumorphicContainer(
  //           padding: EdgeInsets.all(16.w),
  //           child: Row(
  //             children: [
  //               SizedBox(
  //                 width: 80.w,
  //                 height: 80.h,
  //                 child: Stack(
  //                   children: [
  //                     CircularProgressIndicator(
  //                       value: percentage / 100,
  //                       strokeWidth: 8,
  //                       backgroundColor: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
  //                       valueColor: AlwaysStoppedAnimation<Color>(color),
  //                     ),
  //                     Center(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             '${percentage.toStringAsFixed(0)}%',
  //                             style: AppTextStyles.titleLarge.copyWith(
  //                               color: color,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           Text(
  //                             status,
  //                             style: AppTextStyles.bodySmall.copyWith(
  //                               color: color,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(width: 16.w),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _buildStatRow('إجمالي المحاضرات', summary.totalLectures.toString(), Icons.school),
  //                     SizedBox(height: 8.h),
  //                     _buildStatRow('الحضور', summary.totalAttended.toString(), Icons.check_circle, Colors.green),
  //                     SizedBox(height: 8.h),
  //                     _buildStatRow('الغياب', summary.totalAbsent.toString(), Icons.cancel, Colors.red),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatRow(String label, String value, IconData icon,
      [Color? color]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: color ??
              (Get.isDarkMode
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant),
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Get.isDarkMode
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ??
                (Get.isDarkMode
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  Widget _buildLecturesSection(List<AttendanceRecord> lectures) {
    // تجميع المحاضرات حسب الشهر
    final groupedLectures = <String, List<AttendanceRecord>>{};

    for (final lecture in lectures) {
      final date = DateTime.parse(lecture.lectureDate);
      final monthKey = DateFormat('MMMM yyyy', 'ar').format(date);

      if (!groupedLectures.containsKey(monthKey)) {
        groupedLectures[monthKey] = [];
      }
      groupedLectures[monthKey]!.add(lecture);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_note,
              color: Get.isDarkMode
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'سجل المحاضرات',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Get.isDarkMode
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${lectures.length} محاضرة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Get.isDarkMode
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // عرض المحاضرات مجمعة حسب الشهر
        ...groupedLectures.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان الشهر
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  entry.key,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Get.isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // محاضرات الشهر
              ...entry.value.map((lecture) => _buildLectureCard(lecture)),

              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLectureCard(AttendanceRecord lecture) {
    final date = DateTime.parse(lecture.lectureDate);
    final formattedDate = DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
    final isPresent = lecture.isPresent;
    final statusColor = isPresent ? Colors.green : Colors.red;

    return NeumorphicContainer(
      backgroundColor: AppColors.getBackgroundColor(Get.isDarkMode),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // أيقونة الحالة
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              isPresent ? Icons.check_circle : Icons.cancel,
              color: statusColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // تفاصيل المحاضرة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'المحاضرة ${lecture.lectureNumber}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Get.isDarkMode
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        lecture.status,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  formattedDate,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Get.isDarkMode
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: Get.isDarkMode
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      lecture.period,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: Get.isDarkMode
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                    ),
                    if (lecture.teacherName != null &&
                        lecture.teacherName!.isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.person,
                        size: 14.sp,
                        color: Get.isDarkMode
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'د. ${lecture.teacherName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.sp,
                          color: Get.isDarkMode
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
