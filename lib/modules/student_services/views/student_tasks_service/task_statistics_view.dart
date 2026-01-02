import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'task_model.dart';
import 'tasks_controller.dart';

class TaskStatisticsView extends GetView<TasksController> {
  const TaskStatisticsView({Key? key}) : super(key: key);

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
        body: SafeArea(
          child: Column(
            children: [
              // رأس الصفحة
              _buildAppBar(
                  context, isDarkMode, textColor, primaryColor, cardColor),

              // محتوى الإحصائيات
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // مخطط حالة المهام
                        _buildTaskStatusChart(context, isDarkMode, textColor,
                            secondaryTextColor, primaryColor, cardColor),
                        const SizedBox(height: 24),

                        // مخطط أولويات المهام
                        _buildTaskPriorityChart(context, isDarkMode, textColor,
                            secondaryTextColor, primaryColor, cardColor),
                        const SizedBox(height: 24),

                        // سجل المهام التاريخي
                        _buildTaskHistory(context, isDarkMode, textColor,
                            secondaryTextColor, primaryColor, cardColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            'إحصائيات المهام',
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
              Icons.refresh,
              color: primaryColor,
              size: 18,
            ),
            onPressed: () {
              controller.refreshData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusChart(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    // حساب النسب المئوية
    final total = controller.pendingTasksCount.value +
        controller.completedTasksCount.value +
        controller.cancelledTasksCount.value +
        controller.expiredTasksCount.value;

    final pendingPercentage = total > 0
        ? (controller.pendingTasksCount.value / total * 100).toStringAsFixed(1)
        : '0';
    final completedPercentage = total > 0
        ? (controller.completedTasksCount.value / total * 100)
            .toStringAsFixed(1)
        : '0';
    final cancelledPercentage = total > 0
        ? (controller.cancelledTasksCount.value / total * 100)
            .toStringAsFixed(1)
        : '0';
    final expiredPercentage = total > 0
        ? (controller.expiredTasksCount.value / total * 100).toStringAsFixed(1)
        : '0';

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة المهام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: total > 0
                  ? PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value:
                                controller.pendingTasksCount.value.toDouble(),
                            title: '$pendingPercentage%',
                            color: Colors.blue,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            value:
                                controller.completedTasksCount.value.toDouble(),
                            title: '$completedPercentage%',
                            color: Colors.green,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            value:
                                controller.cancelledTasksCount.value.toDouble(),
                            title: '$cancelledPercentage%',
                            color: Colors.grey,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          PieChartSectionData(
                            value:
                                controller.expiredTasksCount.value.toDouble(),
                            title: '$expiredPercentage%',
                            color: Colors.red,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        'لا توجد بيانات كافية',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(textColor, Colors.blue, 'قيد الانتظار',
                    controller.pendingTasksCount.value.toString()),
                _buildLegendItem(textColor, Colors.green, 'مكتملة',
                    controller.completedTasksCount.value.toString()),
                _buildLegendItem(textColor, Colors.grey, 'ملغاة',
                    controller.cancelledTasksCount.value.toString()),
                _buildLegendItem(textColor, Colors.red, 'منتهية',
                    controller.expiredTasksCount.value.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPriorityChart(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    // حساب عدد المهام حسب الأولوية
    final highPriorityCount = controller.tasks
        .where((task) => task.priority == TaskPriority.high)
        .length;
    final mediumPriorityCount = controller.tasks
        .where((task) => task.priority == TaskPriority.medium)
        .length;
    final lowPriorityCount = controller.tasks
        .where((task) => task.priority == TaskPriority.low)
        .length;

    final total = highPriorityCount + mediumPriorityCount + lowPriorityCount;

    final highPercentage =
        total > 0 ? (highPriorityCount / total * 100).toStringAsFixed(1) : '0';
    final mediumPercentage = total > 0
        ? (mediumPriorityCount / total * 100).toStringAsFixed(1)
        : '0';
    final lowPercentage =
        total > 0 ? (lowPriorityCount / total * 100).toStringAsFixed(1) : '0';

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أولويات المهام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: cardColor,
              height: 200,
              child: total > 0
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: total > 0 ? (total * 1.2) : 10,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String priority;
                              switch (groupIndex) {
                                case 0:
                                  priority = 'عالية';
                                  break;
                                case 1:
                                  priority = 'متوسطة';
                                  break;
                                case 2:
                                  priority = 'منخفضة';
                                  break;
                                default:
                                  priority = '';
                              }
                              return BarTooltipItem(
                                '$priority: ${rod.toY.toInt()}',
                                TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'عالية';
                                    break;
                                  case 1:
                                    text = 'متوسطة';
                                    break;
                                  case 2:
                                    text = 'منخفضة';
                                    break;
                                  default:
                                    text = '';
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: highPriorityCount.toDouble(),
                                color: Colors.red,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: mediumPriorityCount.toDouble(),
                                color: Colors.orange,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: lowPriorityCount.toDouble(),
                                color: Colors.green,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        'لا توجد بيانات كافية',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(textColor, Colors.red, 'عالية',
                    '$highPriorityCount ($highPercentage%)'),
                _buildLegendItem(textColor, Colors.orange, 'متوسطة',
                    '$mediumPriorityCount ($mediumPercentage%)'),
                _buildLegendItem(textColor, Colors.green, 'منخفضة',
                    '$lowPriorityCount ($lowPercentage%)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHistory(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    // ترتيب المهام حسب تاريخ الإنشاء (الأحدث أولاً)
    final sortedTasks = List<Task>.from(controller.tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سجل المهام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            sortedTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'لا توجد مهام في السجل',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        sortedTasks.length > 10 ? 10 : sortedTasks.length,
                    itemBuilder: (context, index) {
                      final task = sortedTasks[index];
                      return _buildHistoryItem(
                        context,
                        isDarkMode,
                        textColor,
                        secondaryTextColor,
                        primaryColor,
                        cardColor,
                        task,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardColor,
    Task task,
  ) {
    final statusColor = task.getStatusColor();
    final priorityColor = task.getPriorityColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // مؤشر الحالة
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
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
                    decoration: task.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'تاريخ الإنشاء: ${DateFormat.yMMMd('ar').format(task.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.getPriorityText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // حالة المهمة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.getStatusText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      Color textColor, Color color, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
