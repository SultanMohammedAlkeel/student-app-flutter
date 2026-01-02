// import 'package:get/get.dart';
// import '../../modules/dashboard/models/study_tasks.dart';
// import '../../../core/services/storage_service.dart';
// import '../../../core/constants/app_constants.dart';

// /// مزود بيانات المهام الدراسية
// /// يتعامل مع تخزين واسترجاع ومزامنة المهام مع الخادم
// class StudyTaskProvider {
//   final StorageService _storageService = Get.find<StorageService>();
//   // final SyncService _syncService = Get.find<SyncService>();
  
//   /// الحصول على جميع المهام الدراسية
//   Future<List<StudyTask>> getAllTasks() async {
//     // محاولة مزامنة البيانات مع الخادم إذا كان ذلك ممكنًا
//     if (_syncService.needsSync()) {
//       await _syncService.syncData();
//     }
    
//     final tasksJson = _storageService.read<List<dynamic>>(AppConstants.studyTasksKey);
//     if (tasksJson == null) {
//       return [];
//     }
    
//     return tasksJson.map((json) => StudyTask.fromJson(json)).toList();
//   }
  
//   /// إضافة مهمة جديدة
//   Future<void> addTask(StudyTask task) async {
//     final tasks = await _getLocalTasks();
//     tasks.add(task);
//     await _saveTasks(tasks);
    
//     // مزامنة البيانات مع الخادم
//     await _syncService.syncData();
//   }
  
//   /// تحديث مهمة موجودة
//   Future<void> updateTask(StudyTask task) async {
//     final tasks = await _getLocalTasks();
//     final index = tasks.indexWhere((t) => t.id == task.id);
    
//     if (index != -1) {
//       tasks[index] = task;
//       await _saveTasks(tasks);
      
//       // مزامنة البيانات مع الخادم
//       await _syncService.syncData();
//     }
//   }
  
//   /// حذف مهمة
//   Future<void> deleteTask(String taskId) async {
//     final tasks = await _getLocalTasks();
//     tasks.removeWhere((task) => task.id == taskId);
//     await _saveTasks(tasks);
    
//     // مزامنة البيانات مع الخادم
//     await _syncService.syncData();
//   }
  
//   /// تبديل حالة اكتمال المهمة
//   Future<void> toggleTaskCompletion(String taskId) async {
//     final tasks = await _getLocalTasks();
//     final index = tasks.indexWhere((t) => t.id == taskId);
    
//     if (index != -1) {
//       final task = tasks[index];
//       tasks[index] = task.copyWith(
//         isCompleted: !task.isCompleted,
//         updatedAt: DateTime.now(),
//       );
//       await _saveTasks(tasks);
      
//       // مزامنة البيانات مع الخادم
//       await _syncService.syncData();
//     }
//   }
  
//   /// الحصول على المهام المخزنة محليًا
//   Future<List<StudyTask>> _getLocalTasks() async {
//     final tasksJson = _storageService.read<List<dynamic>>(AppConstants.studyTasksKey);
//     if (tasksJson == null) {
//       return [];
//     }
    
//     return tasksJson.map((json) => StudyTask.fromJson(json)).toList();
//   }
  
//   /// حفظ المهام في التخزين المحلي
//   Future<void> _saveTasks(List<StudyTask> tasks) async {
//     final tasksJson = tasks.map((task) => task.toJson()).toList();
//     await _storageService.write(AppConstants.studyTasksKey, tasksJson);
//   }
// }
