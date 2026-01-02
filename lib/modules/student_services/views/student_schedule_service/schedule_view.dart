import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'schedule_controller.dart';
import 'next_day_lectures_card.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'ar';

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor = _getBackgroundColor(isDarkMode);
      final cardColor = _getCardColor(isDarkMode);
      final textColor = _getTextColor(isDarkMode);
      final secondaryTextColor = _getSecondaryTextColor(isDarkMode);

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDarkMode, textColor, cardColor, context),
              Expanded(
                child: controller.isLoading.value
                    ? _buildLoadingState(isDarkMode)
                    : controller.hasError.value
                        ? _buildErrorState(
                            controller.errorMessage.value,
                            isDarkMode,
                            () => controller.refreshSchedule(),
                            context,
                          )
                        : _buildScheduleContent(isDarkMode, textColor,
                            secondaryTextColor, cardColor, context),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    final responsivePadding = _getResponsivePadding(context);

    return Container(
      padding: responsivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(isDarkMode, () => Get.back()),
          NeumorphicText(
            'الجدول الدراسي',
            textStyle: NeumorphicTextStyle(
              fontSize: _getResponsiveFontSize(context, 22),
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            style: NeumorphicStyle(
              color: isDarkMode
                  ? AppColors.lightBackground
                  : AppColors.darkBackground,
              depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
            ),
          ),
          _buildRefreshButton(
            isDarkMode,
            () => controller.refreshSchedule(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor, BuildContext context) {
    if (controller.schedule.value.schedule.isEmpty) {
      return _buildEmptyState(
        'لا يوجد جدول دراسي متاح حالياً',
        isDarkMode,
      );
    }

    final responsivePadding = _getResponsivePadding(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleInfo(
                isDarkMode, textColor, secondaryTextColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildTodayLectures(
                isDarkMode, textColor, secondaryTextColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            // استخدام المكون الجديد لعرض محاضرات الغد
            NextDayLecturesCard(controller: controller),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildWeeklySchedule(
                isDarkMode, textColor, secondaryTextColor, cardColor, context),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('معلومات الجدول', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 12)),
            Row(
              children: [
                Icon(Icons.school,
                    color: homeController.getPrimaryColor(),
                    size: _getResponsiveIconSize(context, 20)),
                SizedBox(width: _getResponsiveSpacing(context, 8)),
                Text('المستوى: ', style: _getBodyStyle(isDarkMode, context)),
                Text(controller.schedule.value.level,
                    style: _getSubtitleStyle(isDarkMode, context)),
              ],
            ),
            SizedBox(height: _getResponsiveSpacing(context, 8)),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: homeController.getPrimaryColor(),
                    size: _getResponsiveIconSize(context, 20)),
                SizedBox(width: _getResponsiveSpacing(context, 8)),
                Text('الفصل الدراسي: ',
                    style: _getBodyStyle(isDarkMode, context)),
                Text(controller.schedule.value.term,
                    style: _getSubtitleStyle(isDarkMode, context)),
              ],
            ),
            SizedBox(height: _getResponsiveSpacing(context, 8)),
            Row(
              children: [
                Icon(Icons.update,
                    color: homeController.getPrimaryColor(),
                    size: _getResponsiveIconSize(context, 20)),
                SizedBox(width: _getResponsiveSpacing(context, 8)),
                Text('آخر تحديث: ', style: _getBodyStyle(isDarkMode, context)),
                Text(
                    DateFormat.yMMMd('ar')
                        .add_jm()
                        .format(controller.lastUpdated.value),
                    style: _getBodyStyle(isDarkMode, context)),
              ],
            ),
            if (controller.isUsingLocalData.value) ...[
              SizedBox(height: _getResponsiveSpacing(context, 12)),
              Row(
                children: [
                  Icon(Icons.offline_pin,
                      color: Colors.orange,
                      size: _getResponsiveIconSize(context, 20)),
                  SizedBox(width: _getResponsiveSpacing(context, 8)),
                  Expanded(
                    child: Text(
                      'أنت تستخدم نسخة محفوظة من الجدول. اضغط على زر التحديث للحصول على أحدث البيانات.',
                      style: _getSmallStyle(isDarkMode, context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLectures(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor, BuildContext context) {
    final todayLectures = controller.getTodayLectures();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('محاضرات اليوم', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 12)),
            todayLectures.isEmpty
                ? Center(
                    child: Padding(
                      padding: _getResponsivePadding(context),
                      child: Text(
                        'لا توجد محاضرات اليوم',
                        style: _getBodyStyle(isDarkMode, context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayLectures.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: _getResponsiveSpacing(context, 10)),
                    itemBuilder: (context, index) {
                      final lecture = todayLectures[index];
                      return _buildLectureItem(
                        lecture,
                        isDarkMode,
                        textColor,
                        secondaryTextColor,
                        _getPeriodColor(lecture['periodIndex']),
                        context,
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
    BuildContext context,
  ) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // وقت المحاضرة
            Container(
              width: _getResponsiveWidth(context, 70),
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveSpacing(context, 6),
                vertical: _getResponsiveSpacing(context, 4),
              ),
              decoration: BoxDecoration(
                color: periodColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lecture['period'],
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.bold,
                  color: periodColor,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: _getResponsiveSpacing(context, 8)),

            // تفاصيل المحاضرة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture['course'],
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 13),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontFamily: 'Tajawal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _getResponsiveSpacing(context, 4)),
                  Row(
                    children: [
                      Icon(Icons.person,
                          color: secondaryTextColor,
                          size: _getResponsiveIconSize(context, 14)),
                      SizedBox(width: _getResponsiveSpacing(context, 4)),
                      Expanded(
                        child: Text(
                          lecture['teacher'],
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 11),
                            color: secondaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _getResponsiveSpacing(context, 4)),
                  Row(
                    children: [
                      Icon(
                        lecture['isLab'] ? Icons.computer : Icons.meeting_room,
                        color: secondaryTextColor,
                        size: _getResponsiveIconSize(context, 14),
                      ),
                      SizedBox(width: _getResponsiveSpacing(context, 4)),
                      Expanded(
                        child: Text(
                          lecture['hall'],
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 11),
                            color: secondaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: _getResponsiveSpacing(context, 8)),

            // نوع القاعة
            Container(
              width: _getResponsiveWidth(context, 60),
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveSpacing(context, 6),
                vertical: _getResponsiveSpacing(context, 4),
              ),
              decoration: BoxDecoration(
                color: (lecture['isLab'] ? Colors.purple : Colors.blue)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lecture['isLab'] ? 'معمل' : 'محاضرة',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.bold,
                  color: lecture['isLab'] ? Colors.purple : Colors.blue,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySchedule(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader('الجدول الأسبوعي', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 12)),
            // تحسين عرض الجدول الأسبوعي
            _buildImprovedScheduleTable(
                isDarkMode, textColor, secondaryTextColor, context),
          ],
        ),
      ),
    );
  }

  // تحسين عرض الجدول الأسبوعي
  Widget _buildImprovedScheduleTable(bool isDarkMode, Color textColor,
      Color secondaryTextColor, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      width: double.infinity,
      child: Column(
        children: [
          // عرض أيام الأسبوع كتبويب أفقي
          _buildDaysTabs(isDarkMode, textColor, context),
          SizedBox(height: _getResponsiveSpacing(context, 16)),
          // عرض محاضرات اليوم المحدد
          _buildSelectedDaySchedule(
              isDarkMode, textColor, secondaryTextColor, context),
        ],
      ),
    );
  }

  Widget _buildDaysTabs(
      bool isDarkMode, Color textColor, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() => SingleChildScrollView(
          padding: EdgeInsets.all(3),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
              controller.days.length,
              (index) => Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 4)),
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: isDarkMode ? -1 : 1,
                    intensity: 0.8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    color: controller.selectedDayIndex.value == index
                        ? homeController.getPrimaryColor().withOpacity(0.2)
                        : isDarkMode
                            ? _getDayColor(index)
                                .withOpacity(isDarkMode ? 0.3 : 0.2)
                            : (isDarkMode
                                ? AppColors.darkBackground
                                : AppColors.lightBackground),
                    lightSource: LightSource.topLeft,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 16),
                    vertical: _getResponsiveSpacing(context, 12),
                  ),
                  child: Text(
                    controller.days[index],
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      fontWeight:
                          isDarkMode ? FontWeight.bold : FontWeight.normal,
                      color: isDarkMode ? _getDayColor(index) : textColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  onPressed: () => controller.selectedDayIndex.value = index,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSelectedDaySchedule(bool isDarkMode, Color textColor,
      Color secondaryTextColor, BuildContext context) {
    return Obx(() {
      final dayIndex = controller.selectedDayIndex.value;
      final daySchedule = controller.getScheduleForDay(dayIndex);

      if (daySchedule.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(_getResponsiveSpacing(context, 24)),
            child: Text(
              'لا توجد محاضرات في هذا اليوم',
              style: _getBodyStyle(isDarkMode, context),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.periods.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: _getResponsiveSpacing(context, 10)),
        itemBuilder: (context, periodIndex) {
          final lecture = daySchedule.firstWhere(
            (lecture) => lecture['periodIndex'] == periodIndex,
            orElse: () => {'isEmpty': true},
          );

          if (lecture['isEmpty'] == true) {
            return _buildEmptyPeriodItem(
              periodIndex,
              isDarkMode,
              textColor,
              secondaryTextColor,
              context,
            );
          }

          return _buildPeriodLectureItem(
            lecture,
            periodIndex,
            isDarkMode,
            textColor,
            secondaryTextColor,
            context,
          );
        },
      );
    });
  }

  Widget _buildEmptyPeriodItem(int periodIndex, bool isDarkMode,
      Color textColor, Color secondaryTextColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 1,
        intensity: 0.5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
        child: Row(
          children: [
            Container(
              width: _getResponsiveWidth(context, 70),
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveSpacing(context, 6),
                vertical: _getResponsiveSpacing(context, 4),
              ),
              decoration: BoxDecoration(
                color: _getPeriodColor(periodIndex)
                    .withOpacity(isDarkMode ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.periods[periodIndex],
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.bold,
                  color: _getPeriodColor(periodIndex).withOpacity(0.7),
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: _getResponsiveSpacing(context, 16)),
            Expanded(
              child: Text(
                'لا توجد محاضرة',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 13),
                  color: secondaryTextColor,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodLectureItem(
    Map<String, dynamic> lecture,
    int periodIndex,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    BuildContext context,
  ) {
    final periodColor = _getPeriodColor(periodIndex);
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // وقت المحاضرة
                Container(
                  width: _getResponsiveWidth(context, 70),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 6),
                    vertical: _getResponsiveSpacing(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: periodColor.withOpacity(isDarkMode ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.periods[periodIndex],
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 11),
                      fontWeight: FontWeight.bold,
                      color: periodColor,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 12)),

                // تفاصيل المحاضرة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture['course'],
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: _getResponsiveSpacing(context, 8)),
                      Row(
                        children: [
                          Icon(Icons.person,
                              color: homeController.getPrimaryColor(),
                              size: _getResponsiveIconSize(context, 16)),
                          SizedBox(width: _getResponsiveSpacing(context, 4)),
                          Expanded(
                            child: Text(
                              lecture['teacher'],
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 12),
                                color: secondaryTextColor,
                                fontFamily: 'Tajawal',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // نوع القاعة
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 8),
                    vertical: _getResponsiveSpacing(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: (lecture['isLab'] ? Colors.purple : Colors.blue)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lecture['isLab'] ? 'معمل' : 'محاضرة',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 11),
                      fontWeight: FontWeight.bold,
                      color: lecture['isLab'] ? Colors.purple : Colors.blue,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: _getResponsiveSpacing(context, 8)),
            Row(
              children: [
                Icon(
                  lecture['isLab'] ? Icons.computer : Icons.meeting_room,
                  color: homeController.getPrimaryColor(),
                  size: _getResponsiveIconSize(context, 16),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 4)),
                Expanded(
                  child: Text(
                    lecture['hall'],
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: secondaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة للتصميم المتجاوب
  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : const Color(0xFF333333);
  }

  Color _getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);
  }

  Color _getPeriodColor(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return Colors.blue.withOpacity(0.7);
      case 1:
        return Colors.green.withOpacity(0.7);
      case 2:
        return Colors.orange.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  Color _getDayColor(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return Colors.purple.withOpacity(0.7);
      case 1:
        return Colors.indigo.withOpacity(0.7);
      case 2:
        return Colors.blue.withOpacity(0.7);
      case 3:
        return Colors.teal.withOpacity(0.7);
      case 4:
        return Colors.amber.withOpacity(0.7);
      case 5:
        return Colors.deepOrange.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  double _getResponsiveFontSize(BuildContext context, double size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return size * 0.8; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return size * 0.9; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return size; // للشاشات المتوسطة
    } else {
      return size * 1.1; // للشاشات الكبيرة
    }
  }

  double _getResponsiveIconSize(BuildContext context, double size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return size * 0.8; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return size * 0.9; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return size; // للشاشات المتوسطة
    } else {
      return size * 1.1; // للشاشات الكبيرة
    }
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return const EdgeInsets.all(8); // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(12); // للشاشات الصغيرة
    } else {
      return const EdgeInsets.all(16); // للشاشات المتوسطة والكبيرة
    }
  }

  double _getResponsiveSpacing(BuildContext context, double value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return value * 0.7; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return value * 0.85; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return value; // للشاشات المتوسطة
    } else {
      return value * 1.2; // للشاشات الكبيرة
    }
  }

  double _getResponsiveWidth(BuildContext context, double value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return value * 0.8; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return value * 0.9; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return value; // للشاشات المتوسطة
    } else {
      return value * 1.2; // للشاشات الكبيرة
    }
  }

  Widget _buildCardHeader(String title, bool isDarkMode, BuildContext context,
      {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: _getTitleStyle(isDarkMode, context),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  TextStyle _getTitleStyle(bool isDarkMode, BuildContext context) {
    return TextStyle(
      fontSize: _getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.bold,
      color: _getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  TextStyle _getSubtitleStyle(bool isDarkMode, BuildContext context) {
    return TextStyle(
      fontSize: _getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      color: _getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  TextStyle _getBodyStyle(bool isDarkMode, BuildContext context) {
    return TextStyle(
      fontSize: _getResponsiveFontSize(context, 14),
      color: _getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  TextStyle _getSmallStyle(bool isDarkMode, BuildContext context) {
    return TextStyle(
      fontSize: _getResponsiveFontSize(context, 12),
      color: _getSecondaryTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  Widget _buildBackButton(bool isDarkMode, VoidCallback onPressed) {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color: _getCardColor(isDarkMode),
        lightSource: LightSource.topLeft,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: homeController.getPrimaryColor(),
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildRefreshButton(bool isDarkMode, VoidCallback onPressed) {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
        intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color: _getCardColor(isDarkMode),
        lightSource: LightSource.topLeft,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.refresh,
        color: homeController.getPrimaryColor(),
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    HomeController homeController = Get.find<HomeController>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicProgress(
            height: 10.0,
            percent: 0.8,
            style: ProgressStyle(
              accent: homeController.getPrimaryColor(),
              variant: homeController.getPrimaryColor().withOpacity(0.5),
              depth: 2, // تعديل العمق إلى 3 كما طلب المستخدم
              lightSource: LightSource.topLeft,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الجدول الدراسي...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getTextColor(isDarkMode),
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode, VoidCallback onRetry,
      BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          SizedBox(height: _getResponsiveSpacing(context, 16)),
          Text(
            message,
            style: _getSubtitleStyle(isDarkMode, context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _getResponsiveSpacing(context, 24)),
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              depth: 2, // زيادة العمق إلى 3 كما طلب المستخدم
              intensity: 0.8, // تعديل الكثافة إلى 1 كما طلب المستخدم
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              color: _getCardColor(isDarkMode),
              lightSource: LightSource.topLeft,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsiveSpacing(context, 24),
              vertical: _getResponsiveSpacing(context, 12),
            ),
            child: Text(
              'إعادة المحاولة',
              style: _getBodyStyle(isDarkMode, context),
            ),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: _getSecondaryTextColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getTextColor(isDarkMode),
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
