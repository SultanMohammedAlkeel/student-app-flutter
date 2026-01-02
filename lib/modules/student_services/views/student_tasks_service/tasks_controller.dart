import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'task_model.dart';

class TasksController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // حالة الوضع الداكن
  final isDarkMode = false.obs;
  
  // قائمة المهام
  final tasks = <Task>[].obs;
  
  // المهام المفلترة للعرض
  final filteredTasks = <Task>[].obs;
  
  // حالة التحميل
  final isLoading = false.obs;
  
  // الفلتر الحالي
  final currentFilter = 'الكل'.obs;
  
  // الترتيب الحالي
  final currentSort = 'التاريخ'.obs;
  
  // إحصائيات المهام
  final pendingTasksCount = 0.obs;
  final completedTasksCount = 0.obs;
  final cancelledTasksCount = 0.obs;
  final expiredTasksCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadTasks();
    updateTasksStatistics();
  }
  
  // تحميل المهام من التخزين المحلي
  void loadTasks() {
    isLoading.value = true;
    
    try {
      final storedTasks = _storageService.read<List>('tasks') ?? [];
      tasks.value = storedTasks.map((task) => Task.fromJson(task)).toList();
      applyFilters();
    } catch (e) {
      print('خطأ في تحميل المهام: $e');
      tasks.value = [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // حفظ المهام في التخزين المحلي
  void saveTasks() {
    try {
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      _storageService.write('tasks', tasksJson);
    } catch (e) {
      print('خطأ في حفظ المهام: $e');
    }
  }
  
  // إضافة مهمة جديدة
  void addTask(Task task) {
    tasks.add(task);
    saveTasks();
    applyFilters();
    updateTasksStatistics();
  }
  
  // تحديث مهمة موجودة
  void updateTask(String id, Task updatedTask) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      tasks[index] = updatedTask;
      saveTasks();
      applyFilters();
      updateTasksStatistics();
    }
  }
  
  // حذف مهمة
  void deleteTask(String id) {
    tasks.removeWhere((task) => task.id == id);
    saveTasks();
    applyFilters();
    updateTasksStatistics();
  }
  
  // تغيير حالة المهمة
  void toggleTaskStatus(String id, TaskStatus status) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = tasks[index];
      final updatedTask = task.copyWith(
        status: status,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
      tasks[index] = updatedTask;
      saveTasks();
      applyFilters();
      updateTasksStatistics();
    }
  }
  
  // تطبيق الفلاتر على المهام
  void applyFilters() {
    switch (currentFilter.value) {
      case 'الكل':
        filteredTasks.value = List.from(tasks);
        break;
      case 'اليوم':
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        filteredTasks.value = tasks.where((task) => 
          task.dueDate.isAfter(startOfDay) && 
          task.dueDate.isBefore(endOfDay)
        ).toList();
        break;
      case 'الأسبوع':
        final today = DateTime.now();
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final endOfWeek = startOfDay.add(const Duration(days: 7));
        filteredTasks.value = tasks.where((task) => 
          task.dueDate.isAfter(startOfDay) && 
          task.dueDate.isBefore(endOfWeek)
        ).toList();
        break;
      case 'أولوية عالية':
        filteredTasks.value = tasks.where((task) => 
          task.priority == TaskPriority.high
        ).toList();
        break;
      case 'مكتملة':
        filteredTasks.value = tasks.where((task) => 
          task.status == TaskStatus.completed
        ).toList();
        break;
      default:
        filteredTasks.value = List.from(tasks);
    }
    
    // تطبيق الترتيب
    applySorting();
  }
  
  // تطبيق الترتيب على المهام المفلترة
  void applySorting() {
    switch (currentSort.value) {
      case 'التاريخ':
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'الأولوية':
        filteredTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'العنوان':
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'تاريخ الإنشاء':
        filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      default:
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
  }
  
  // تغيير الفلتر الحالي
  void changeFilter(String filter) {
    currentFilter.value = filter;
    applyFilters();
  }
  
  // تغيير الترتيب الحالي
  void changeSort(String sort) {
    currentSort.value = sort;
    applySorting();
  }
  
  // تحديث إحصائيات المهام
  void updateTasksStatistics() {
    pendingTasksCount.value = tasks.where((task) => task.status == TaskStatus.pending).length;
    completedTasksCount.value = tasks.where((task) => task.status == TaskStatus.completed).length;
    cancelledTasksCount.value = tasks.where((task) => task.status == TaskStatus.cancelled).length;
    expiredTasksCount.value = tasks.where((task) => task.status == TaskStatus.expired).length;
  }
  
  // تحديث حالة المهام منتهية الصلاحية
  void updateExpiredTasks() {
    final now = DateTime.now();
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].status == TaskStatus.pending && tasks[i].dueDate.isBefore(now)) {
        tasks[i] = tasks[i].copyWith(status: TaskStatus.expired);
      }
    }
    saveTasks();
    applyFilters();
    updateTasksStatistics();
  }
  
  // تبديل وضع الظلام
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    _storageService.write('dark_mode', isDarkMode.value);
  }
  
  // تنسيق التاريخ بالعربية
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'اليوم، ${DateFormat.jm('ar').format(date)}';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'غداً، ${DateFormat.jm('ar').format(date)}';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'أمس، ${DateFormat.jm('ar').format(date)}';
    } else {
      return '${DateFormat.yMMMd('ar').format(date)}، ${DateFormat.jm('ar').format(date)}';
    }
  }
  
  // تحديث البيانات
  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    updateExpiredTasks();
    loadTasks();
    isLoading.value = false;
  }
}
