import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'task_form_view.dart';
import 'task_model.dart';
import 'task_statistics_view.dart';
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

          // زر الإحصائيات
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
              Icons.bar_chart,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () {
              // الانتقال إلى صفحة الإحصائيات
              Get.to(() => TaskStatisticsView());
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
                      '${controller.pendingTasksCount}',
                      Colors.blue),
                  _buildStatItem(
                      isDarkMode,
                      textColor,
                      secondaryTextColor,
                      primaryColor,
                      cardColor,
                      'مكتملة',
                      '${controller.completedTasksCount}',
                      Colors.green),
                  _buildStatItem(
                      isDarkMode,
                      textColor,
                      secondaryTextColor,
                      primaryColor,
                      cardColor,
                      'ملغاة',
                      '${controller.cancelledTasksCount}',
                      Colors.grey),
                  _buildStatItem(
                      isDarkMode,
                      textColor,
                      secondaryTextColor,
                      primaryColor,
                      cardColor,
                      'منتهية',
                      '${controller.expiredTasksCount}',
                      Colors.red),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                padding: const EdgeInsets.symmetric(vertical: 2),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                        isDarkMode,
                        textColor,
                        primaryColor,
                        cardColor,
                        'الكل',
                        controller.currentFilter.value == 'الكل'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        isDarkMode,
                        textColor,
                        primaryColor,
                        cardColor,
                        'اليوم',
                        controller.currentFilter.value == 'اليوم'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        isDarkMode,
                        textColor,
                        primaryColor,
                        cardColor,
                        'الأسبوع',
                        controller.currentFilter.value == 'الأسبوع'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        isDarkMode,
                        textColor,
                        primaryColor,
                        cardColor,
                        'أولوية عالية',
                        controller.currentFilter.value == 'أولوية عالية'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        isDarkMode,
                        textColor,
                        primaryColor,
                        cardColor,
                        'مكتملة',
                        controller.currentFilter.value == 'مكتملة'),
                  ],
                ),
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
              _showSortOptions(
                  context, isDarkMode, textColor, primaryColor, cardColor);
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
        controller.changeFilter(label);
      },
    );
  }

  Widget _buildTasksList(BuildContext context, bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color primaryColor, Color cardColor) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.filteredTasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: secondaryTextColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد مهام',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط على زر + لإضافة مهمة جديدة',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: controller.filteredTasks.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTaskCard(
                            context,
                            isDarkMode,
                            textColor,
                            secondaryTextColor,
                            primaryColor,
                            cardColor,
                            controller.filteredTasks[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTaskCard(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor,
      Task task) {
    final isCompleted = task.status == TaskStatus.completed;
    final Color priorityColor = task.getPriorityColor();

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
            NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                depth: isDarkMode
                    ? AppConstants.darkDepth
                    : AppConstants.lightDepth,
                color: isCompleted ? primaryColor : cardColor,
              ),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                controller.toggleTaskStatus(task.id,
                    !isCompleted ? TaskStatus.completed : TaskStatus.pending);
              },
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                size: 18,
                color: isCompleted ? Colors.white : secondaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            // تفاصيل المهمة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
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
                        controller.formatDate(task.dueDate),
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
                task.getPriorityText(),
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
                _showTaskOptions(context, isDarkMode, textColor, primaryColor,
                    cardColor, task);
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
        Get.to(() => TaskFormView());
      },
    );
  }

  void _showTaskOptions(BuildContext context, bool isDarkMode, Color textColor,
      Color primaryColor, Color cardColor, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
          intensity: AppConstants.darkDepth,
          boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
          color: cardColor,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // عنوان المهمة
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // خيارات المهمة
              _buildTaskOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                Icons.edit,
                'تعديل المهمة',
                () {
                  Navigator.pop(context);
                  Get.to(() => TaskFormView(task: task));
                },
              ),
              const SizedBox(height: 12),
              _buildTaskOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                task.status == TaskStatus.completed
                    ? Icons.refresh
                    : Icons.check_circle,
                task.status == TaskStatus.completed
                    ? 'إعادة فتح المهمة'
                    : 'تحديد كمكتملة',
                () {
                  Navigator.pop(context);
                  controller.toggleTaskStatus(
                      task.id,
                      task.status == TaskStatus.completed
                          ? TaskStatus.pending
                          : TaskStatus.completed);
                },
              ),
              const SizedBox(height: 12),
              _buildTaskOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                Icons.cancel,
                'إلغاء المهمة',
                () {
                  Navigator.pop(context);
                  controller.toggleTaskStatus(task.id, TaskStatus.cancelled);
                },
              ),
              const SizedBox(height: 12),
              _buildTaskOptionButton(
                isDarkMode,
                textColor,
                Colors.red,
                cardColor,
                Icons.delete,
                'حذف المهمة',
                () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, isDarkMode, textColor,
                      primaryColor, cardColor, task);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskOptionButton(
      bool isDarkMode,
      Color textColor,
      Color iconColor,
      Color cardColor,
      IconData icon,
      String label,
      VoidCallback onTap) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
      onPressed: onTap,
    );
  }

  void _showSortOptions(BuildContext context, bool isDarkMode, Color textColor,
      Color primaryColor, Color cardColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
          intensity: AppConstants.darkDepth,
          boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
          color: cardColor,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // عنوان
              Text(
                'ترتيب المهام',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // خيارات الترتيب
              _buildSortOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                'التاريخ',
                controller.currentSort.value == 'التاريخ',
                () {
                  Navigator.pop(context);
                  controller.changeSort('التاريخ');
                },
              ),
              const SizedBox(height: 12),
              _buildSortOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                'الأولوية',
                controller.currentSort.value == 'الأولوية',
                () {
                  Navigator.pop(context);
                  controller.changeSort('الأولوية');
                },
              ),
              const SizedBox(height: 12),
              _buildSortOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                'العنوان',
                controller.currentSort.value == 'العنوان',
                () {
                  Navigator.pop(context);
                  controller.changeSort('العنوان');
                },
              ),
              const SizedBox(height: 12),
              _buildSortOptionButton(
                isDarkMode,
                textColor,
                primaryColor,
                cardColor,
                'تاريخ الإنشاء',
                controller.currentSort.value == 'تاريخ الإنشاء',
                () {
                  Navigator.pop(context);
                  controller.changeSort('تاريخ الإنشاء');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptionButton(
      bool isDarkMode,
      Color textColor,
      Color primaryColor,
      Color cardColor,
      String label,
      bool isSelected,
      VoidCallback onTap) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: isSelected ? primaryColor.withOpacity(0.2) : cardColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected ? primaryColor : textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : textColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
      onPressed: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool isDarkMode,
      Color textColor, Color primaryColor, Color cardColor, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'حذف المهمة',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه المهمة؟',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Tajawal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.deleteTask(task.id);
              Navigator.of(context).pop();
            },
            child: const Text(
              'حذف',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
