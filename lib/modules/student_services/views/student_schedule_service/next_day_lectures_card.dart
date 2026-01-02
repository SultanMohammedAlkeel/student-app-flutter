import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'schedule_controller.dart';

class NextDayLecturesCard extends StatelessWidget {
  final ScheduleController controller;

  const NextDayLecturesCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
          HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final textColor = isDarkMode
          ? const Color.fromARGB(255, 255, 255, 255)
          : const Color.fromARGB(255, 0, 5, 11);
      final secondaryTextColor =
          isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);
      final cardColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

      final tomorrowLectures = controller.getTomorrowLectures();
      final tomorrowDate = DateTime.now().add(Duration(days: 1));
      final tomorrowDateFormatted =
          DateFormat.yMMMEd('ar').format(tomorrowDate);

      return Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: 2, // عمق 3 كما طلب المستخدم
          intensity: 0.8, // كثافة 1 كما طلب المستخدم
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          color: cardColor,
          lightSource: LightSource.topLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان البطاقة مع التاريخ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.next_plan,
                        color: homeController.getPrimaryColor(),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'محاضرات الغد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tomorrowDateFormatted,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // محتوى البطاقة
              tomorrowLectures.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 48,
                              color: secondaryTextColor.withOpacity(0.7),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد محاضرات مجدولة غداً',
                              style: TextStyle(
                                fontSize: 16,
                                color: secondaryTextColor,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                        );
                      },
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLectureItem(
    Map<String, dynamic> lecture,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final periodColor = _getPeriodColor(lecture['periodIndex']);
    final isLab = lecture['isLab'] ?? false;
      HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? -2 : 2, // عمق 3 كما طلب المستخدم
        intensity: 0.8, // كثافة 1 كما طلب المستخدم
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // الصف الأول: الوقت والمادة ونوع القاعة
            Row(
              children: [
                // وقت المحاضرة
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),

                // اسم المادة
                Expanded(
                  child: Text(
                    lecture['course'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontFamily: 'Tajawal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // نوع القاعة
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        (isLab ? Colors.purple : Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLab ? 'معمل' : 'محاضرة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isLab ? Colors.purple : Colors.blue,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),

            // الصف الثاني: المدرس والقاعة
            Row(
              children: [
                // المدرس
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, color: homeController.getPrimaryColor(), size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lecture['teacher'],
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // القاعة
                Row(
                  children: [
                    Icon(
                      isLab ? Icons.computer : Icons.meeting_room,
                      color: homeController.getPrimaryColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lecture['hall'],
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
