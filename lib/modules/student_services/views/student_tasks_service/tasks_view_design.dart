import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'task_model.dart';
import 'tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تهيئة بيانات اللغة العربية
    Intl.defaultLocale = 'ar';
      HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final cardColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
      final secondaryTextColor =
          isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);
      final primaryColor = homeController.getPrimaryColor();

      return Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // رأس الصفحة
                  _buildAppBar(
                      context, isDarkMode, textColor, primaryColor, cardColor),

                  // قسم الإحصائيات
                  _buildStatisticsSection(context, isDarkMode, textColor,
                      secondaryTextColor, primaryColor, cardColor),

                  // قسم تصفية المهام
                  _buildFilterSection(context, isDarkMode, textColor,
                      secondaryTextColor, primaryColor, cardColor),

                  // قائمة المهام
                  Expanded(
                    child: _buildTasksList(context, isDarkMode, textColor,
                        secondaryTextColor, primaryColor, cardColor),
                  ),
                ],
              ),
            ),

            // زر إضافة مهمة جديدة
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildAddTaskButton(
                  context, isDarkMode, primaryColor, cardColor),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, bool isDarkMode, Color textColor,
      Color primaryColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth:
                  isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
              intensity: AppConstants.darkDepth,
              color: cardColor,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),

          // عنوان الصفحة
          NeumorphicText(
            'المهام والمذاكرة',
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

          // زر الإعدادات
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth:
                  isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
              intensity: AppConstants.darkDepth,
              color: cardColor,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.settings,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () {
              // فتح إعدادات المهام
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
          intensity: AppConstants.darkDepth,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          color: cardColor,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات المهام',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                      isDarkMode,
                      textColor,
                      secondaryTextColor,
                      primaryColor,
                      cardColor,
                      'قيد الانتظار',
                      '5',
                      Colors.blue),
                  _buildStatItem(isDarkMode, textColor, secondaryTextColor,
                      primaryColor, cardColor, 'مكتملة', '12', Colors.green),
                  _buildStatItem(isDarkMode, textColor, secondaryTextColor,
                      primaryColor, cardColor, 'ملغاة', '3', Colors.grey),
                  _buildStatItem(isDarkMode, textColor, secondaryTextColor,
                      primaryColor, cardColor, 'منتهية', '2', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor,
      String title,
      String count,
      Color statColor) {
    return Column(
      children: [
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
            depth:
                isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
            intensity: AppConstants.darkDepth,
            color: cardColor,
          ),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(isDarkMode, textColor, primaryColor,
                      cardColor, 'الكل', true),
                  const SizedBox(width: 8),
                  _buildFilterChip(isDarkMode, textColor, primaryColor,
                      cardColor, 'اليوم', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(isDarkMode, textColor, primaryColor,
                      cardColor, 'الأسبوع', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(isDarkMode, textColor, primaryColor,
                      cardColor, 'أولوية عالية', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(isDarkMode, textColor, primaryColor,
                      cardColor, 'مكتملة', false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth:
                  isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
              intensity: AppConstants.darkDepth,
              color: cardColor,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.sort,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () {
              // فتح خيارات الترتيب
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(bool isDarkMode, Color textColor, Color primaryColor,
      Color cardColor, String label, bool isSelected) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        color: isSelected ? primaryColor.withOpacity(0.2) : cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primaryColor : textColor,
          fontFamily: 'Tajawal',
        ),
      ),
      onPressed: () {
        // تغيير الفلتر
      },
    );
  }

  Widget _buildTasksList(BuildContext context, bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color primaryColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 5, // عدد المهام للعرض
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTaskCard(context, isDarkMode, textColor,
                        secondaryTextColor, primaryColor, cardColor, index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor,
      int index) {
    // بيانات المهمة للعرض (ستكون ديناميكية في التنفيذ الفعلي)
    final bool isCompleted = index == 1;
    final TaskPriority priority = index == 0
        ? TaskPriority.high
        : (index == 2 ? TaskPriority.low : TaskPriority.medium);
    final String title = index == 0
        ? 'مراجعة محاضرة البرمجة'
        : (index == 1
            ? 'إكمال مشروع قواعد البيانات'
            : (index == 2
                ? 'قراءة الفصل الخامس'
                : (index == 3 ? 'حل تمارين الرياضيات' : 'تحضير عرض تقديمي')));
    final String dueDate = index == 0
        ? 'اليوم، 3:00 م'
        : (index == 1
            ? 'أمس، 11:59 م'
            : (index == 2
                ? 'غداً، 9:00 ص'
                : (index == 3 ? 'الخميس، 2:00 م' : 'الأحد، 10:00 ص')));

    Color priorityColor;
    switch (priority) {
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
    }

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              priorityColor.withOpacity(isDarkMode ? 0.15 : 0.1),
              priorityColor.withOpacity(isDarkMode ? 0.05 : 0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            // مربع تحديد المهمة
            NeumorphicCheckbox(
              style: NeumorphicCheckboxStyle(
                selectedDepth: isDarkMode
                    ? AppConstants.darkDepth
                    : AppConstants.lightDepth,
                unselectedDepth: isDarkMode
                    ? AppConstants.darkDepth
                    : AppConstants.lightDepth,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                selectedColor: primaryColor,
                //    unselectedColor: cardColor,
              ),
              value: isCompleted,
              onChanged: (value) {
                // تغيير حالة المهمة
              },
            ),
            const SizedBox(width: 16),
            // تفاصيل المهمة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // مؤشر الأولوية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priority == TaskPriority.high
                    ? 'عالية'
                    : (priority == TaskPriority.medium ? 'متوسطة' : 'منخفضة'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زر المزيد من الخيارات
            NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
                depth: isDarkMode
                    ? AppConstants.darkDepth
                    : AppConstants.lightDepth,
                intensity: AppConstants.darkDepth,
                color: cardColor,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: secondaryTextColor,
                size: 16,
              ),
              onPressed: () {
                // فتح قائمة خيارات المهمة
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, bool isDarkMode,
      Color primaryColor, Color cardColor) {
    return NeumorphicFloatingActionButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        color: primaryColor,
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
      onPressed: () {
        // فتح نموذج إضافة مهمة جديدة
        _showAddTaskModal(context, isDarkMode, primaryColor, cardColor);
      },
    );
  }

  void _showAddTaskModal(BuildContext context, bool isDarkMode,
      Color primaryColor, Color cardColor) {
    // سيتم تنفيذ هذا في مرحلة لاحقة
  }
}
