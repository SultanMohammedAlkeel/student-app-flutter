import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'schedule_controller.dart';
import 'schedule_view.dart';
import 'schedule_view_design.dart';

class ScheduleServiceCard extends GetView<ScheduleController> {
  const ScheduleServiceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final hasUpdates = true;
      HomeController homeController = Get.find<HomeController>();

      return Neumorphic(
        style: ScheduleViewDesign.getNeumorphicStyle(isDarkMode),
        child: InkWell(
          onTap: () => Get.to(() => const ScheduleView()),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // أيقونة الخدمة
                    NeumorphicIcon(
                      Icons.calendar_today,
                      size: 32,
                      style: NeumorphicStyle(
                        color: homeController.getPrimaryColor(),
                        depth: isDarkMode
                            ? AppConstants.darkDepth
                            : AppConstants.lightDepth,
                      ),
                    ),

                    // مؤشر التحديثات
                    if (hasUpdates)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sync,
                              color: Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'تحديث',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // عنوان الخدمة
                Text(
                  'الجدول الدراسي',
                  style: ScheduleViewDesign.getTitleStyle(isDarkMode),
                ),
                const SizedBox(height: 8),

                // وصف الخدمة
                Text(
                  'عرض الجدول الدراسي الأسبوعي ومحاضرات اليوم والغد',
                  style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // محاضرات اليوم
                _buildTodayLecturesSummary(isDarkMode),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTodayLecturesSummary(bool isDarkMode) {
    final todayLectures = controller.getTodayLectures();

    if (todayLectures.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'لا توجد محاضرات اليوم',
            style: ScheduleViewDesign.getSmallStyle(isDarkMode),
          ),
        ),
      );
    }
    HomeController homeController = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'محاضرات اليوم:',
          style: ScheduleViewDesign.getSubtitleStyle(isDarkMode),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var i = 0; i < todayLectures.length && i < 2; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i < 1 ? 8 : 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ScheduleViewDesign.getPeriodColor(
                                  todayLectures[i]['periodIndex'])
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          todayLectures[i]['period'],
                          style: TextStyle(
                            fontSize: 10,
                            color: ScheduleViewDesign.getPeriodColor(
                                todayLectures[i]['periodIndex']),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          todayLectures[i]['course'],
                          style: ScheduleViewDesign.getSmallStyle(isDarkMode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (todayLectures.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... والمزيد',
                    style:
                        ScheduleViewDesign.getSmallStyle(isDarkMode).copyWith(
                      color: homeController.getPrimaryColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
