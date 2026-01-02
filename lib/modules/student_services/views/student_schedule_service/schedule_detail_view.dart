import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'schedule_controller.dart';
import 'schedule_view_design.dart';

class ScheduleDetailView extends GetView<ScheduleController> {
  // ignore: use_super_parameters
  const ScheduleDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تهيئة بيانات اللغة العربية
    Intl.defaultLocale = 'ar';

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor = ScheduleViewDesign.getBackgroundColor(isDarkMode);
      final cardColor = ScheduleViewDesign.getCardColor(isDarkMode);
      final textColor = ScheduleViewDesign.getTextColor(isDarkMode);
      final secondaryTextColor =
          ScheduleViewDesign.getSecondaryTextColor(isDarkMode);

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // رأس الصفحة
              _buildAppBar(isDarkMode, textColor, cardColor),

              // محتوى تفاصيل الجدول
              Expanded(
                child: controller.isLoading.value
                    ? ScheduleViewDesign.buildLoadingState(isDarkMode)
                    : controller.hasError.value
                        ? ScheduleViewDesign.buildErrorState(
                            controller.errorMessage.value,
                            isDarkMode,
                            () => controller.refreshSchedule(),
                          )
                        : _buildDetailContent(isDarkMode, textColor,
                            secondaryTextColor, cardColor),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(bool isDarkMode, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع
          ScheduleViewDesign.buildBackButton(isDarkMode, () => Get.back()),

          // عنوان الصفحة
          NeumorphicText(
            'تفاصيل الجدول الدراسي',
            textStyle: NeumorphicTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            style: NeumorphicStyle(
              color: isDarkMode
                  ? AppColors.lightBackground
                  : AppColors.darkBackground,
            ),
          ),

          // زر تحديث البيانات
          ScheduleViewDesign.buildRefreshButton(
            isDarkMode,
            () => controller.refreshSchedule(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الجدول
            _buildScheduleInfo(
                isDarkMode, textColor, secondaryTextColor, cardColor),
            const SizedBox(height: 24),

            // محاضرات اليوم
            _buildTodayLectures(
                isDarkMode, textColor, secondaryTextColor, cardColor),
            const SizedBox(height: 24),

            // محاضرات الغد
            _buildTomorrowLectures(
                isDarkMode, textColor, secondaryTextColor, cardColor),
            const SizedBox(height: 24),

            // حالة التخزين المحلي
            _buildStorageStatus(
                isDarkMode, textColor, secondaryTextColor, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: ScheduleViewDesign.getNeumorphicStyle(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleViewDesign.buildCardHeader('معلومات الجدول', isDarkMode),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: homeController.getPrimaryColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'المستوى: ',
                  style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                ),
                Text(
                  controller.schedule.value.level,
                  style: ScheduleViewDesign.getSubtitleStyle(isDarkMode),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: homeController.getPrimaryColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'الفصل الدراسي: ',
                  style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                ),
                Text(
                  controller.schedule.value.term,
                  style: ScheduleViewDesign.getSubtitleStyle(isDarkMode),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.update,
                  color: homeController.getPrimaryColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'آخر تحديث: ',
                  style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                ),
                Text(
                  DateFormat.yMMMd('ar')
                      .add_jm()
                      .format(controller.lastUpdated.value),
                  style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLectures(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    final todayLectures = controller.getTodayLectures();

    return Neumorphic(
      style: ScheduleViewDesign.getNeumorphicStyle(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleViewDesign.buildCardHeader('محاضرات اليوم', isDarkMode),
            const SizedBox(height: 16),
            todayLectures.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'لا توجد محاضرات اليوم',
                        style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayLectures.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lecture = todayLectures[index];
                      return _buildLectureItem(
                        lecture,
                        isDarkMode,
                        textColor,
                        secondaryTextColor,
                        ScheduleViewDesign.getPeriodColor(
                            lecture['periodIndex']),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTomorrowLectures(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    final tomorrowLectures = controller.getTomorrowLectures();

    return Neumorphic(
      style: ScheduleViewDesign.getNeumorphicStyle(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleViewDesign.buildCardHeader('محاضرات الغد', isDarkMode),
            const SizedBox(height: 16),
            tomorrowLectures.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'لا توجد محاضرات غداً',
                        style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tomorrowLectures.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lecture = tomorrowLectures[index];
                      return _buildLectureItem(
                        lecture,
                        isDarkMode,
                        textColor,
                        secondaryTextColor,
                        ScheduleViewDesign.getPeriodColor(
                            lecture['periodIndex']),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureItem(
    Map<String, dynamic> lecture,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color periodColor,
  ) {
    return Neumorphic(
      style: ScheduleViewDesign.getNeumorphicStyle(
        isDarkMode,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // وقت المحاضرة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: periodColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lecture['period'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: periodColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(width: 12),

            // تفاصيل المحاضرة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture['course'],
                    style: ScheduleViewDesign.getSubtitleStyle(isDarkMode),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: secondaryTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lecture['teacher'],
                        style: ScheduleViewDesign.getSmallStyle(isDarkMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        lecture['isLab'] ? Icons.computer : Icons.meeting_room,
                        color: secondaryTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lecture['hall'],
                        style: ScheduleViewDesign.getSmallStyle(isDarkMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // نوع القاعة (محاضرة أو معمل)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (lecture['isLab'] ? Colors.purple : Colors.blue)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lecture['isLab'] ? 'معمل' : 'محاضرة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: lecture['isLab'] ? Colors.purple : Colors.blue,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStatus(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: ScheduleViewDesign.getNeumorphicStyle(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleViewDesign.buildCardHeader('حالة التخزين', isDarkMode),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  controller.isUsingLocalData.value
                      ? Icons.offline_pin
                      : Icons.cloud_done,
                  color: controller.isUsingLocalData.value
                      ? Colors.orange
                      : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.isUsingLocalData.value
                            ? 'أنت تستخدم نسخة محفوظة من الجدول'
                            : 'أنت تستخدم أحدث نسخة من الجدول',
                        style: ScheduleViewDesign.getSubtitleStyle(isDarkMode),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.isUsingLocalData.value
                            ? 'اضغط على زر التحديث للحصول على أحدث البيانات'
                            : 'تم تحديث البيانات بنجاح',
                        style: ScheduleViewDesign.getSmallStyle(isDarkMode),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NeumorphicButton(
              style: ScheduleViewDesign.getButtonStyle(isDarkMode),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: homeController.getPrimaryColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تحديث الجدول الدراسي',
                      style: ScheduleViewDesign.getBodyStyle(isDarkMode),
                    ),
                  ],
                ),
              ),
              onPressed: () => controller.refreshSchedule(),
            ),
          ],
        ),
      ),
    );
  }
}
