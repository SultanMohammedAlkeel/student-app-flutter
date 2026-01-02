import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'task_model.dart';
import 'tasks_controller.dart';

class TaskFormView extends StatelessWidget {
  final Task? task;
  final TasksController controller = Get.find<TasksController>();

  TaskFormView({Key? key, this.task}) : super(key: key);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();

  final selectedPriority = TaskPriority.medium.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final isReminderSet = false.obs;
  final reminderTime = DateTime.now().add(const Duration(hours: 1)).obs;

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    // تهيئة البيانات إذا كانت مهمة موجودة للتعديل
    if (task != null) {
      titleController.text = task!.title;
      descriptionController.text = task!.description;
      categoryController.text = task!.category ?? '';
      selectedPriority.value = task!.priority;
      selectedDate.value = task!.dueDate;
      selectedTime.value = TimeOfDay.fromDateTime(task!.dueDate);
      isReminderSet.value = task!.isReminderSet;
      reminderTime.value =
          task!.reminderTime ?? DateTime.now().add(const Duration(hours: 1));
    }

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

            // نموذج المهمة
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان المهمة
                      _buildSectionTitle('عنوان المهمة', textColor),
                      const SizedBox(height: 8),
                      _buildTextField(titleController, 'أدخل عنوان المهمة',
                          isDarkMode, textColor, secondaryTextColor, cardColor),
                      const SizedBox(height: 16),

                      // وصف المهمة
                      _buildSectionTitle('وصف المهمة', textColor),
                      const SizedBox(height: 8),
                      _buildTextField(
                          descriptionController,
                          'أدخل وصف المهمة (اختياري)',
                          isDarkMode,
                          textColor,
                          secondaryTextColor,
                          cardColor,
                          maxLines: 3),
                      const SizedBox(height: 16),

                      // تاريخ ووقت المهمة
                      _buildSectionTitle('تاريخ ووقت المهمة', textColor),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // اختيار التاريخ
                          Expanded(
                            child: _buildDateSelector(
                                context,
                                isDarkMode,
                                textColor,
                                secondaryTextColor,
                                primaryColor,
                                cardColor),
                          ),
                          const SizedBox(width: 16),
                          // اختيار الوقت
                          Expanded(
                            child: _buildTimeSelector(
                                context,
                                isDarkMode,
                                textColor,
                                secondaryTextColor,
                                primaryColor,
                                cardColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // أولوية المهمة
                      _buildSectionTitle('أولوية المهمة', textColor),
                      const SizedBox(height: 8),
                      _buildPrioritySelector(isDarkMode, textColor,
                          secondaryTextColor, primaryColor, cardColor),
                      const SizedBox(height: 16),

                      // تصنيف المهمة
                      _buildSectionTitle('تصنيف المهمة', textColor),
                      const SizedBox(height: 8),
                      _buildTextField(
                          categoryController,
                          'أدخل تصنيف المهمة (اختياري)',
                          isDarkMode,
                          textColor,
                          secondaryTextColor,
                          cardColor),
                      const SizedBox(height: 16),

                      // إعدادات التذكير
                      _buildSectionTitle('التذكير', textColor),
                      const SizedBox(height: 8),
                      _buildReminderSettings(context, isDarkMode, textColor,
                          secondaryTextColor, primaryColor, cardColor),
                      const SizedBox(height: 32),

                      // زر الحفظ
                      _buildSaveButton(context, isDarkMode, textColor,
                          primaryColor, cardColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            task != null ? 'تعديل مهمة' : 'مهمة جديدة',
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

          // زر الحذف (يظهر فقط عند التعديل)
          task != null
              ? NeumorphicButton(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: isDarkMode
                        ? AppConstants.darkDepth
                        : AppConstants.lightDepth,
                    intensity: AppConstants.darkDepth,
                    color: cardColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 18,
                  ),
                  onPressed: () {
                    // تأكيد الحذف
                    _showDeleteConfirmation(context, isDarkMode, textColor,
                        primaryColor, cardColor);
                  },
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      {int maxLines = 1}) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            backgroundColor: cardColor,
            color: textColor,
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            fillColor: cardColor,
            hintText: hint,
            hintStyle: TextStyle(
              color: secondaryTextColor,
              fontFamily: 'Tajawal',
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      child: InkWell(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate.value,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: cardColor,
                    onSurface: textColor,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            selectedDate.value = pickedDate;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Text(
                      DateFormat.yMMMd('ar').format(selectedDate.value),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Tajawal',
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      child: InkWell(
        onTap: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: selectedTime.value,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: cardColor,
                    onSurface: textColor,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            selectedTime.value = pickedTime;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Text(
                      selectedTime.value.format(context),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Tajawal',
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color primaryColor, Color cardColor) {
    return Row(
      children: [
        Expanded(
          child: _buildPriorityOption(isDarkMode, textColor, cardColor,
              'منخفضة', Colors.green, TaskPriority.low),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPriorityOption(isDarkMode, textColor, cardColor,
              'متوسطة', Colors.orange, TaskPriority.medium),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPriorityOption(isDarkMode, textColor, cardColor, 'عالية',
              Colors.red, TaskPriority.high),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(bool isDarkMode, Color textColor, Color cardColor,
      String label, Color priorityColor, TaskPriority priority) {
    return Obx(() {
      final isSelected = selectedPriority.value == priority;

      return NeumorphicButton(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
          intensity: AppConstants.darkDepth,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          color: isSelected ? priorityColor.withOpacity(0.2) : cardColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? priorityColor : textColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        onPressed: () {
          selectedPriority.value = priority;
        },
      );
    });
  }

  Widget _buildReminderSettings(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفعيل التذكير',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Obx(() => NeumorphicSwitch(
                      style: NeumorphicSwitchStyle(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: secondaryTextColor.withOpacity(0.2),
                      ),
                      value: isReminderSet.value,
                      onChanged: (value) {
                        isReminderSet.value = value;
                      },
                    )),
              ],
            ),
            Obx(() {
              if (!isReminderSet.value) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedDateTime = await _showDateTimePicker(
                          context,
                          reminderTime.value,
                          isDarkMode,
                          textColor,
                          primaryColor,
                          cardColor);

                      if (pickedDateTime != null) {
                        reminderTime.value = pickedDateTime;
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'وقت التذكير: ${DateFormat.yMMMd('ar').add_jm().format(reminderTime.value)}',
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDarkMode,
      Color textColor, Color primaryColor, Color cardColor) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
        intensity: AppConstants.darkDepth,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: primaryColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          task != null ? 'حفظ التغييرات' : 'إضافة المهمة',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      onPressed: () {
        _saveTask();
      },
    );
  }

  Future<DateTime?> _showDateTimePicker(
      BuildContext context,
      DateTime initialDateTime,
      bool isDarkMode,
      Color textColor,
      Color primaryColor,
      Color cardColor) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void _saveTask() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال عنوان المهمة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // إنشاء كائن DateTime من التاريخ والوقت المحددين
    final dueDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    if (task == null) {
      // إضافة مهمة جديدة
      final newTask = Task(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: dueDateTime,
        priority: selectedPriority.value,
        isReminderSet: isReminderSet.value,
        reminderTime: isReminderSet.value ? reminderTime.value : null,
        category: categoryController.text.trim().isNotEmpty
            ? categoryController.text.trim()
            : null,
      );

      controller.addTask(newTask);
    } else {
      // تحديث مهمة موجودة
      final updatedTask = task!.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: dueDateTime,
        priority: selectedPriority.value,
        isReminderSet: isReminderSet.value,
        reminderTime: isReminderSet.value ? reminderTime.value : null,
        category: categoryController.text.trim().isNotEmpty
            ? categoryController.text.trim()
            : null,
      );

      controller.updateTask(task!.id, updatedTask);
    }

    Get.back();
  }

  void _showDeleteConfirmation(BuildContext context, bool isDarkMode,
      Color textColor, Color primaryColor, Color cardColor) {
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
              controller.deleteTask(task!.id);
              Navigator.of(context).pop();
              Get.back();
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
