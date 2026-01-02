// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:ui';
// import '../../../core/themes/colors.dart';
// import '../models/study_tasks.dart';
// import '../repositories/tasks_repositories.dart';

// class StudyTaskController extends GetxController {
//   final StudyTaskRepository _repository = Get.find<StudyTaskRepository>();
  
//   // قائمة المهام الدراسية
//   final RxList<StudyTask> tasks = <StudyTask>[].obs;
  
//   // المهام المصفاة حسب الفلتر الحالي
//   final RxList<StudyTask> filteredTasks = <StudyTask>[].obs;
  
//   // حالة تحميل البيانات
//   final RxBool isLoading = false.obs;
  
//   // فلتر الحالة الحالي
//   final Rx<TaskStatus?> statusFilter = Rx<TaskStatus?>(null);
  
//   // فلتر الأولوية الحالي
//   final Rx<TaskPriority?> priorityFilter = Rx<TaskPriority?>(null);
  
//   // نص البحث الحالي
//   final RxString searchQuery = ''.obs;
  
//   // حالة الوضع الداكن
//   final Rx<bool> isDarkMode = false.obs;
  
//   // المهمة المحددة حاليًا للتعديل
//   final Rx<StudyTask?> selectedTask = Rx<StudyTask?>(null);
  
//   // متغيرات لإضافة مهمة جديدة
//   final RxString newTaskTitle = ''.obs;
//   final RxString newTaskDescription = ''.obs;
//   final Rx<DateTime> newTaskDueDate = DateTime.now().add(const Duration(days: 1)).obs;
//   final Rx<TaskPriority> newTaskPriority = TaskPriority.medium.obs;
//   final RxString newTaskCourse = ''.obs;
//   final RxList<String> newTaskTags = <String>[].obs;
  
//   // قائمة المقررات الدراسية للاختيار منها
//   final RxList<String> availableCourses = <String>[
//     'هندسة البرمجيات المتقدمة',
//     'تطوير تطبيقات الويب',
//     'الذكاء الاصطناعي',
//     'أمن المعلومات',
//     'قواعد البيانات المتقدمة',
//     'شبكات الحاسب',
//     'تطوير تطبيقات الجوال',
//     'الحوسبة السحابية',
//   ].obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     loadTasks();
    
//     // مراقبة تغييرات الفلتر لتحديث المهام المصفاة
//     ever(statusFilter, (_) => _applyFilters());
//     ever(priorityFilter, (_) => _applyFilters());
//     ever(searchQuery, (_) => _applyFilters());
    
//     // التحقق من وضع السمة
//     isDarkMode.value = Get.isDarkMode;
//   }
  
//   // تحميل المهام من المستودع
//   Future<void> loadTasks() async {
//     isLoading.value = true;
//     try {
//       final loadedTasks = await _repository.getAllTasks();
//       tasks.value = loadedTasks;
//       _applyFilters();
//     } catch (e) {
//       print('خطأ في تحميل المهام: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء تحميل المهام',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
  
//   // تطبيق الفلاتر على المهام
//   void _applyFilters() {
//     List<StudyTask> result = List.from(tasks);
    
//     // تطبيق فلتر الحالة
//     if (statusFilter.value != null) {
//       result = result.where((task) => task.status == statusFilter.value).toList();
//     }
    
//     // تطبيق فلتر الأولوية
//     if (priorityFilter.value != null) {
//       result = result.where((task) => task.priority == priorityFilter.value).toList();
//     }
    
//     // تطبيق فلتر البحث
//     if (searchQuery.value.isNotEmpty) {
//       final query = searchQuery.value.toLowerCase();
//       result = result.where((task) {
//         return task.title.toLowerCase().contains(query) ||
//                task.description.toLowerCase().contains(query) ||
//                task.course.toLowerCase().contains(query) ||
//                task.tags.any((tag) => tag.toLowerCase().contains(query));
//       }).toList();
//     }
    
//     // ترتيب المهام حسب الأولوية ثم تاريخ الاستحقاق
//     result.sort((a, b) {
//       // ترتيب تنازلي حسب الأولوية
//       final priorityComparison = b.priority.index.compareTo(a.priority.index);
//       if (priorityComparison != 0) {
//         return priorityComparison;
//       }
      
//       // ترتيب تصاعدي حسب تاريخ الاستحقاق
//       return a.dueDate.compareTo(b.dueDate);
//     });
    
//     filteredTasks.value = result;
//   }
  
//   // إضافة مهمة جديدة
//   Future<bool> addTask() async {
//     if (newTaskTitle.value.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى إدخال عنوان المهمة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
    
//     final newTask = StudyTask(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: newTaskTitle.value,
//       description: newTaskDescription.value,
//       dueDate: newTaskDueDate.value,
//       priority: newTaskPriority.value,
//       status: TaskStatus.pending,
//       course: newTaskCourse.value,
//       tags: newTaskTags.toList(),
//       progress: 0.0,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
    
//     try {
//       await _repository.addTask(newTask);
//       tasks.add(newTask);
//       _applyFilters();
//       _resetNewTaskForm();
      
//       Get.snackbar(
//         'تم بنجاح',
//         'تمت إضافة المهمة بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
      
//       return true;
//     } catch (e) {
//       print('خطأ في إضافة المهمة: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء إضافة المهمة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
      
//       return false;
//     }
//   }
  
//   // تحديث مهمة موجودة
//   Future<bool> updateTask(StudyTask task) async {
//     try {
//       await _repository.updateTask(task);
//       final index = tasks.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         tasks[index] = task;
//         _applyFilters();
//       }
      
//       Get.snackbar(
//         'تم بنجاح',
//         'تم تحديث المهمة بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
      
//       return true;
//     } catch (e) {
//       print('خطأ في تحديث المهمة: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء تحديث المهمة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
      
//       return false;
//     }
//   }
  
//   // تحديث حالة المهمة
//   Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
//     try {
//       final index = tasks.indexWhere((t) => t.id == taskId);
//       if (index != -1) {
//         final updatedTask = tasks[index].copyWith(
//           status: newStatus,
//           updatedAt: DateTime.now(),
//           progress: newStatus == TaskStatus.completed ? 1.0 : tasks[index].progress,
//         );
        
//         await _repository.updateTask(updatedTask);
//         tasks[index] = updatedTask;
//         _applyFilters();
        
//         Get.snackbar(
//           'تم بنجاح',
//           'تم تحديث حالة المهمة بنجاح',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
        
//         return true;
//       }
      
//       return false;
//     } catch (e) {
//       print('خطأ في تحديث حالة المهمة: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء تحديث حالة المهمة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
      
//       return false;
//     }
//   }
  
//   // تحديث تقدم المهمة
//   Future<bool> updateTaskProgress(String taskId, double newProgress) async {
//     try {
//       final index = tasks.indexWhere((t) => t.id == taskId);
//       if (index != -1) {
//         final updatedTask = tasks[index].copyWith(
//           progress: newProgress,
//           updatedAt: DateTime.now(),
//           status: newProgress >= 1.0 ? TaskStatus.completed : 
//                  newProgress > 0.0 ? TaskStatus.inProgress : 
//                  tasks[index].status,
//         );
        
//         await _repository.updateTask(updatedTask);
//         tasks[index] = updatedTask;
//         _applyFilters();
        
//         return true;
//       }
      
//       return false;
//     } catch (e) {
//       print('خطأ في تحديث تقدم المهمة: $e');
//       return false;
//     }
//   }
  
//   // حذف مهمة
//   Future<bool> deleteTask(String taskId) async {
//     try {
//       await _repository.deleteTask(taskId);
//       tasks.removeWhere((task) => task.id == taskId);
//       _applyFilters();
      
//       Get.snackbar(
//         'تم بنجاح',
//         'تم حذف المهمة بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
      
//       return true;
//     } catch (e) {
//       print('خطأ في حذف المهمة: $e');
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ أثناء حذف المهمة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
      
//       return false;
//     }
//   }
  
//   // تعيين فلتر الحالة
//   void setStatusFilter(TaskStatus? status) {
//     statusFilter.value = status;
//   }
  
//   // تعيين فلتر الأولوية
//   void setPriorityFilter(TaskPriority? priority) {
//     priorityFilter.value = priority;
//   }
  
//   // تعيين نص البحث
//   void setSearchQuery(String query) {
//     searchQuery.value = query;
//   }
  
//   // إعادة تعيين جميع الفلاتر
//   void resetFilters() {
//     statusFilter.value = null;
//     priorityFilter.value = null;
//     searchQuery.value = '';
//   }
  
//   // تحديد مهمة للتعديل
//   void selectTask(StudyTask task) {
//     selectedTask.value = task;
//   }
  
//   // إعادة تعيين نموذج المهمة الجديدة
//   void _resetNewTaskForm() {
//     newTaskTitle.value = '';
//     newTaskDescription.value = '';
//     newTaskDueDate.value = DateTime.now().add(const Duration(days: 1));
//     newTaskPriority.value = TaskPriority.medium;
//     newTaskCourse.value = '';
//     newTaskTags.clear();
//   }
  
//   // إضافة وسم جديد للمهمة
//   void addTag(String tag) {
//     if (tag.isNotEmpty && !newTaskTags.contains(tag)) {
//       newTaskTags.add(tag);
//     }
//   }
  
//   // إزالة وسم من المهمة
//   void removeTag(String tag) {
//     newTaskTags.remove(tag);
//   }
  
//   // الحصول على لون الأولوية
//   Color getPriorityColor(TaskPriority priority) {
//     switch (priority) {
//       case TaskPriority.high:
//         return AppColors.redAccent;
//       case TaskPriority.medium:
//         return AppColors.orangeAccent;
//       case TaskPriority.low:
//         return AppColors.blueAccent;
//     }
//   }
  
//   // الحصول على لون الحالة
//   Color getStatusColor(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return AppColors.greyAccent;
//       case TaskStatus.inProgress:
//         return AppColors.blueAccent;
//       case TaskStatus.completed:
//         return AppColors.greenAccent;
//       case TaskStatus.cancelled:
//         return AppColors.redAccent;
//     }
//   }
  
//   // الحصول على نص الأولوية
//   String getPriorityText(TaskPriority priority) {
//     switch (priority) {
//       case TaskPriority.high:
//         return 'عالية';
//       case TaskPriority.medium:
//         return 'متوسطة';
//       case TaskPriority.low:
//         return 'منخفضة';
//     }
//   }
  
//   // الحصول على نص الحالة
//   String getStatusText(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return 'قيد الانتظار';
//       case TaskStatus.inProgress:
//         return 'قيد التنفيذ';
//       case TaskStatus.completed:
//         return 'مكتملة';
//       case TaskStatus.cancelled:
//         return 'ملغاة';
//     }
//   }
  
//   // الحصول على أيقونة الأولوية
//   IconData getPriorityIcon(TaskPriority priority) {
//     switch (priority) {
//       case TaskPriority.high:
//         return Icons.priority_high;
//       case TaskPriority.medium:
//         return Icons.low_priority;
//       case TaskPriority.low:
//         return Icons.arrow_downward;
//     }
//   }
  
//   // الحصول على أيقونة الحالة
//   IconData getStatusIcon(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.pending:
//         return Icons.hourglass_empty;
//       case TaskStatus.inProgress:
//         return Icons.sync;
//       case TaskStatus.completed:
//         return Icons.check_circle;
//       case TaskStatus.cancelled:
//         return Icons.cancel;
//     }
//   }
// }
