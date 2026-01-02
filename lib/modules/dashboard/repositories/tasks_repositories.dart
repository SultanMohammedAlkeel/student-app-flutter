// import 'package:get/get.dart';

// import '../../../data/providers/tasks_provider.dart';
// import '../models/study_tasks.dart';


// /// مستودع المهام الدراسية
// /// يعمل كوسيط بين المتحكم ومزود البيانات
// class StudyTaskRepository {
//   final StudyTaskProvider _provider = StudyTaskProvider();
  
//   /// الحصول على جميع المهام الدراسية
//   Future<List<StudyTask>> getAllTasks() async {
//     return await _provider.getAllTasks();
//   }
  
//   /// إضافة مهمة جديدة
//   Future<void> addTask(StudyTask task) async {
//     await _provider.addTask(task);
//   }
  
//   /// تحديث مهمة موجودة
//   Future<void> updateTask(StudyTask task) async {
//     await _provider.updateTask(task);
//   }
  
//   /// حذف مهمة
//   Future<void> deleteTask(String taskId) async {
//     await _provider.deleteTask(taskId);
//   }
  
//   /// تبديل حالة اكتمال المهمة
//   Future<void> toggleTaskCompletion(String taskId) async {
//     await _provider.toggleTaskCompletion(taskId);
//   }
  
//   /// الحصول على المهام حسب الحالة
//   Future<List<StudyTask>> getTasksByStatus(bool isCompleted) async {
//     final tasks = await getAllTasks();
//     return tasks.where((task) => task.isCompleted == isCompleted).toList();
//   }
  
//   /// الحصول على المهام المتأخرة
//   Future<List<StudyTask>> getOverdueTasks() async {
//     final tasks = await getAllTasks();
//     final now = DateTime.now();
//     return tasks.where((task) => !task.isCompleted && task.dueDate.isBefore(now)).toList();
//   }
  
//   /// الحصول على المهام القادمة
//   Future<List<StudyTask>> getUpcomingTasks() async {
//     final tasks = await getAllTasks();
//     final now = DateTime.now();
//     return tasks
//         .where((task) => !task.isCompleted && task.dueDate.isAfter(now))
//         .toList()
//       ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
//   }
  
//   /// الحصول على المهام حسب الأولوية
//   Future<List<StudyTask>> getTasksByPriority(String priority) async {
//     final tasks = await getAllTasks();
//     return tasks.where((task) => task.priority == priority).toList();
//   }
  
//   /// الحصول على المهام حسب المقرر
//   Future<List<StudyTask>> getTasksByCourse(String courseId) async {
//     final tasks = await getAllTasks();
//     return tasks.where((task) => task.courseId == courseId).toList();
//   }
  
//   /// البحث في المهام
//   Future<List<StudyTask>> searchTasks(String query) async {
//     if (query.isEmpty) {
//       return await getAllTasks();
//     }
    
//     final tasks = await getAllTasks();
//     final lowercaseQuery = query.toLowerCase();
    
//     return tasks.where((task) {
//       return task.title.toLowerCase().contains(lowercaseQuery) ||
//           task.description.toLowerCase().contains(lowercaseQuery) ||
//           (task.courseName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
//           task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
//     }).toList();
//   }
// }
