// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:ui';
// import '../../../../core/themes/colors.dart';
// import '../../controllers/study_tasks_controller.dart';
// import '../../models/study_tasks.dart';
// import '../../utils/futuristic_animation_manager.dart';
// import '../widgets/futuristic_action_button.dart';
// import '../widgets/futuristic_circular_progress.dart';
// import '../widgets/futuristic_interactive_card.dart';


// class StudyTasksPage extends StatelessWidget {
//   final StudyTaskController controller = Get.find<StudyTaskController>();

//   StudyTasksPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Get.isDarkMode ? Colors.black : Colors.white,
//               Get.isDarkMode ? Colors.grey[900]! : Colors.blue[50]!,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Obx(() => controller.isLoading.value
//               ? _buildLoadingView()
//               : _buildTasksView()),
//         ),
//       ),
//       floatingActionButton: Obx(() => FuturisticActionButton(
//             label: 'مهمة جديدة',
//             icon: Icons.add,
//             onPressed: _showAddTaskDialog,
//             primaryColor: AppColors.scaffoldLight,
//             secondaryColor: _homeController.getPrimaryColor(),
//             isDarkMode: Get.isDarkMode,
//             isGlowing: true,
//           )),
//     );
//   }

//   Widget _buildLoadingView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 100,
//             height: 100,
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueAccent),
//               strokeWidth: 8,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'جاري تحميل المهام...',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Get.isDarkMode ? Colors.white : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasksView() {
//     return Column(
//       children: [
//         _buildHeader(),
//         _buildFilters(),
//         Expanded(
//           child: controller.filteredTasks.isEmpty
//               ? _buildEmptyView()
//               : _buildTasksList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'المهام والمذاكرة',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Get.isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                   color: Get.isDarkMode ? Colors.amber : Colors.blueGrey,
//                 ),
//                 onPressed: () => controller.isDarkMode.toggle(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'إدارة مهامك الدراسية وتتبع تقدمك',
//             style: TextStyle(
//               fontSize: 16,
//               color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildTaskSummary(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaskSummary() {
//     final totalTasks = controller.tasks.length;
//     final completedTasks = controller.tasks.where((task) => task.status == TaskStatus.completed).length;
//     final inProgressTasks = controller.tasks.where((task) => task.status == TaskStatus.inProgress).length;
//     final pendingTasks = controller.tasks.where((task) => task.status == TaskStatus.pending).length;
    
//     final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           FuturisticCircularProgress(
//             value: completionRate,
//             size: 120,
//             primaryColor: AppColors.greenAccent,
//             secondaryColor: AppColors.blueAccent,
//             isDarkMode: Get.isDarkMode,
//             label: 'الإنجاز',
//             sublabel: '${(completionRate * 100).toInt()}%',
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildStatusIndicator('قيد التنفيذ', inProgressTasks, AppColors.blueAccent),
//               const SizedBox(height: 12),
//               _buildStatusIndicator('قيد الانتظار', pendingTasks, AppColors.orangeAccent),
//               const SizedBox(height: 12),
//               _buildStatusIndicator('مكتملة', completedTasks, AppColors.greenAccent),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(String label, int count, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.5),
//                 blurRadius: 8,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '$label: $count',
//           style: TextStyle(
//             fontSize: 16,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFilters() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Get.isDarkMode
//                         ? Colors.grey[800]!.withOpacity(0.5)
//                         : Colors.white.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: AppColors.blueAccent.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: TextField(
//                     onChanged: controller.setSearchQuery,
//                     style: TextStyle(
//                       color: Get.isDarkMode ? Colors.white : Colors.black87,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'بحث في المهام...',
//                       hintStyle: TextStyle(
//                         color: Get.isDarkMode
//                             ? Colors.grey[400]
//                             : Colors.grey[600],
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: AppColors.blueAccent,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               _buildFilterButton(),
//             ],
//           ),
//           const SizedBox(height: 8),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildStatusFilterChip(null, 'الكل'),
//                 const SizedBox(width: 8),
//                 _buildStatusFilterChip(TaskStatus.pending, 'قيد الانتظار'),
//                 const SizedBox(width: 8),
//                 _buildStatusFilterChip(TaskStatus.inProgress, 'قيد التنفيذ'),
//                 const SizedBox(width: 8),
//                 _buildStatusFilterChip(TaskStatus.completed, 'مكتملة'),
//                 const SizedBox(width: 8),
//                 _buildStatusFilterChip(TaskStatus.cancelled, 'ملغاة'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterButton() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.blueAccent.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppColors.blueAccent.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: IconButton(
//         icon: Icon(
//           Icons.filter_list,
//           color: AppColors.blueAccent,
//         ),
//         onPressed: _showFilterDialog,
//       ),
//     );
//   }

//   Widget _buildStatusFilterChip(TaskStatus? status, String label) {
//     final isSelected = controller.statusFilter.value == status;
    
//     return GestureDetector(
//       onTap: () => controller.setStatusFilter(status),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.blueAccent
//               : Get.isDarkMode
//                   ? Colors.grey[800]!.withOpacity(0.5)
//                   : Colors.white.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected
//                 ? AppColors.blueAccent
//                 : AppColors.blueAccent.withOpacity(0.3),
//             width: 1,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: AppColors.blueAccent.withOpacity(0.3),
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.white
//                 : Get.isDarkMode
//                     ? Colors.white
//                     : Colors.black87,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyView() {
//     return FuturisticAnimationManager.staggeredFadeIn(
//       children: [
//         Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.task_alt,
//                 size: 100,
//                 color: AppColors.blueAccent.withOpacity(0.5),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'لا توجد مهام',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Get.isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 controller.searchQuery.value.isNotEmpty ||
//                         controller.statusFilter.value != null ||
//                         controller.priorityFilter.value != null
//                     ? 'لا توجد مهام تطابق معايير البحث والتصفية'
//                     : 'أضف مهامك الدراسية لتتبع تقدمك',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               if (controller.searchQuery.value.isNotEmpty ||
//                   controller.statusFilter.value != null ||
//                   controller.priorityFilter.value != null)
//                 ElevatedButton.icon(
//                   onPressed: controller.resetFilters,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('إعادة تعيين الفلاتر'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.blueAccent,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       initialDelay: const Duration(milliseconds: 300),
//       itemDelay: const Duration(milliseconds: 100),
//     );
//   }

//   Widget _buildTasksList() {
//     return FuturisticAnimationManager.staggeredFadeInGrid(
//       children: List.generate(
//         controller.filteredTasks.length,
//         (index) => _buildTaskCard(controller.filteredTasks[index]),
//       ),
//       crossAxisCount: 1,
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       childAspectRatio: 2.5,
//       initialDelay: const Duration(milliseconds: 300),
//       itemDelay: const Duration(milliseconds: 50),
//     );
//   }

//   Widget _buildTaskCard(StudyTask task) {
//     final priorityColor = controller.getPriorityColor(task.priority);
//     final statusColor = controller.getStatusColor(task.status);
    
//     return FuturisticInteractiveCard(
//       accentColor: priorityColor,
//       isDarkMode: Get.isDarkMode,
//       isExpandable: true,
//       onTap: () => controller.selectTask(task),
//       expandedTitle: 'تفاصيل المهمة',
//       expandedContent: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (task.description.isNotEmpty) ...[
//               Text(
//                 'الوصف:',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Get.isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 task.description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//             if (task.tags.isNotEmpty) ...[
//               Text(
//                 'الوسوم:',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Get.isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: task.tags.map((tag) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: priorityColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: priorityColor.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       tag,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Get.isDarkMode ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
//             ],
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildActionButton(
//                   icon: Icons.edit,
//                   label: 'تعديل',
//                   color: AppColors.blueAccent,
//                   onTap: () => _showEditTaskDialog(task),
//                 ),
//                 _buildActionButton(
//                   icon: task.status == TaskStatus.completed
//                       ? Icons.replay
//                       : Icons.check_circle,
//                   label: task.status == TaskStatus.completed
//                       ? 'إعادة فتح'
//                       : 'إكمال',
//                   color: task.status == TaskStatus.completed
//                       ? AppColors.orangeAccent
//                       : AppColors.greenAccent,
//                   onTap: () => controller.updateTaskStatus(
//                     task.id,
//                     task.status == TaskStatus.completed
//                         ? TaskStatus.inProgress
//                         : TaskStatus.completed,
//                   ),
//                 ),
//                 _buildActionButton(
//                   icon: Icons.delete,
//                   label: 'حذف',
//                   color: AppColors.redAccent,
//                   onTap: () => _showDeleteConfirmation(task),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: priorityColor.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     controller.getPriorityIcon(task.priority),
//                     color: priorityColor,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         task.title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Get.isDarkMode ? Colors.white : Colors.black87,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         task.course,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: statusColor.withOpacity(0.5),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         controller.getStatusIcon(task.status),
//                         color: statusColor,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         controller.getStatusText(task.status),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Get.isDarkMode ? Colors.white : Colors.black87,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                   size: 16,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   'تاريخ الاستحقاق: ${_formatDate(task.dueDate)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                   ),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.priority_high,
//                   color: priorityColor,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   'الأولوية: ${controller.getPriorityText(task.priority)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: priorityColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: LinearProgressIndicator(
//                 value: task.progress,
//                 backgroundColor: Get.isDarkMode
//                     ? Colors.grey[800]
//                     : Colors.grey[300],
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   task.status == TaskStatus.completed
//                       ? AppColors.greenAccent
//                       : priorityColor,
//                 ),
//                 minHeight: 8,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'التقدم: ${(task.progress * 100).toInt()}%',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                   ),
//                 ),
//                 if (task.status != TaskStatus.completed)
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => _updateProgress(task, 0.25),
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: AppColors.blueAccent.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.exposure_plus_1,
//                             color: AppColors.blueAccent,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _updateProgress(task, -0.25),
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: AppColors.redAccent.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.exposure_minus_1,
//                             color: AppColors.redAccent,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: color.withOpacity(0.5),
//                 width: 1,
//               ),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Get.isDarkMode ? Colors.white : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddTaskDialog() {
//     controller.newTaskTitle.value = '';
//     controller.newTaskDescription.value = '';
//     controller.newTaskDueDate.value = DateTime.now().add(const Duration(days: 1));
//     controller.newTaskPriority.value = TaskPriority.medium;
//     controller.newTaskCourse.value = '';
//     controller.newTaskTags.clear();
    
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: FuturisticInteractiveCard(
//           accentColor: AppColors.blueAccent,
//           isDarkMode: Get.isDarkMode,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.add_task,
//                       color: AppColors.blueAccent,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'إضافة مهمة جديدة',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Get.isDarkMode ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   label: 'عنوان المهمة',
//                   hint: 'أدخل عنوان المهمة',
//                   onChanged: (value) => controller.newTaskTitle.value = value,
//                   icon: Icons.title,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   label: 'وصف المهمة',
//                   hint: 'أدخل وصف المهمة (اختياري)',
//                   onChanged: (value) => controller.newTaskDescription.value = value,
//                   icon: Icons.description,
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDropdownField(
//                   label: 'المقرر الدراسي',
//                   hint: 'اختر المقرر الدراسي',
//                   value: controller.newTaskCourse.value.isEmpty ? null : controller.newTaskCourse.value,
//                   items: controller.availableCourses,
//                   onChanged: (value) => controller.newTaskCourse.value = value ?? '',
//                   icon: Icons.book,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDateField(
//                   label: 'تاريخ الاستحقاق',
//                   value: controller.newTaskDueDate.value,
//                   onChanged: (date) {
//                     if (date != null) {
//                       controller.newTaskDueDate.value = date;
//                     }
//                   },
//                   icon: Icons.calendar_today,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPrioritySelector(),
//                 const SizedBox(height: 16),
//                 _buildTagsField(),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: Text(
//                         'إلغاء',
//                         style: TextStyle(
//                           color: Get.isDarkMode ? Colors.white70 : Colors.black54,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: () async {
//                         final success = await controller.addTask();
//                         if (success) {
//                           Get.back();
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.blueAccent,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('إضافة'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showEditTaskDialog(StudyTask task) {
//     controller.newTaskTitle.value = task.title;
//     controller.newTaskDescription.value = task.description;
//     controller.newTaskDueDate.value = task.dueDate;
//     controller.newTaskPriority.value = task.priority;
//     controller.newTaskCourse.value = task.course;
//     controller.newTaskTags.value = List.from(task.tags);
    
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: FuturisticInteractiveCard(
//           accentColor: AppColors.blueAccent,
//           isDarkMode: Get.isDarkMode,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.edit,
//                       color: AppColors.blueAccent,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'تعديل المهمة',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Get.isDarkMode ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   label: 'عنوان المهمة',
//                   hint: 'أدخل عنوان المهمة',
//                   initialValue: task.title,
//                   onChanged: (value) => controller.newTaskTitle.value = value,
//                   icon: Icons.title,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   label: 'وصف المهمة',
//                   hint: 'أدخل وصف المهمة (اختياري)',
//                   initialValue: task.description,
//                   onChanged: (value) => controller.newTaskDescription.value = value,
//                   icon: Icons.description,
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDropdownField(
//                   label: 'المقرر الدراسي',
//                   hint: 'اختر المقرر الدراسي',
//                   value: task.course.isEmpty ? null : task.course,
//                   items: controller.availableCourses,
//                   onChanged: (value) => controller.newTaskCourse.value = value ?? '',
//                   icon: Icons.book,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDateField(
//                   label: 'تاريخ الاستحقاق',
//                   value: task.dueDate,
//                   onChanged: (date) {
//                     if (date != null) {
//                       controller.newTaskDueDate.value = date;
//                     }
//                   },
//                   icon: Icons.calendar_today,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPrioritySelector(),
//                 const SizedBox(height: 16),
//                 _buildTagsField(),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: Text(
//                         'إلغاء',
//                         style: TextStyle(
//                           color: Get.isDarkMode ? Colors.white70 : Colors.black54,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: () async {
//                         final updatedTask = task.copyWith(
//                           title: controller.newTaskTitle.value,
//                           description: controller.newTaskDescription.value,
//                           dueDate: controller.newTaskDueDate.value,
//                           priority: controller.newTaskPriority.value,
//                           course: controller.newTaskCourse.value,
//                           tags: controller.newTaskTags.toList(),
//                           updatedAt: DateTime.now(),
//                         );
                        
//                         final success = await controller.updateTask(updatedTask);
//                         if (success) {
//                           Get.back();
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.blueAccent,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('حفظ التغييرات'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFilterDialog() {
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: FuturisticInteractiveCard(
//           accentColor: AppColors.blueAccent,
//           isDarkMode: Get.isDarkMode,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.filter_list,
//                       color: AppColors.blueAccent,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'تصفية المهام',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Get.isDarkMode ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'الحالة',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Get.isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _buildFilterChip(null, 'الكل', controller.statusFilter.value == null),
//                     _buildFilterChip(TaskStatus.pending, 'قيد الانتظار', controller.statusFilter.value == TaskStatus.pending),
//                     _buildFilterChip(TaskStatus.inProgress, 'قيد التنفيذ', controller.statusFilter.value == TaskStatus.inProgress),
//                     _buildFilterChip(TaskStatus.completed, 'مكتملة', controller.statusFilter.value == TaskStatus.completed),
//                     _buildFilterChip(TaskStatus.cancelled, 'ملغاة', controller.statusFilter.value == TaskStatus.cancelled),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'الأولوية',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Get.isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _buildFilterChip(null, 'الكل', controller.priorityFilter.value == null, isStatus: false),
//                     _buildFilterChip(TaskPriority.high, 'عالية', controller.priorityFilter.value == TaskPriority.high, isStatus: false),
//                     _buildFilterChip(TaskPriority.medium, 'متوسطة', controller.priorityFilter.value == TaskPriority.medium, isStatus: false),
//                     _buildFilterChip(TaskPriority.low, 'منخفضة', controller.priorityFilter.value == TaskPriority.low, isStatus: false),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         controller.resetFilters();
//                         Get.back();
//                       },
//                       child: const Text('إعادة تعيين'),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: () => Get.back(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.blueAccent,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('تطبيق'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(dynamic value, String label, bool isSelected, {bool isStatus = true}) {
//     return GestureDetector(
//       onTap: () {
//         if (isStatus) {
//           controller.setStatusFilter(value as TaskStatus?);
//         } else {
//           controller.setPriorityFilter(value as TaskPriority?);
//         }
//         Get.back();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.blueAccent
//               : Get.isDarkMode
//                   ? Colors.grey[800]!.withOpacity(0.5)
//                   : Colors.white.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected
//                 ? AppColors.blueAccent
//                 : AppColors.blueAccent.withOpacity(0.3),
//             width: 1,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: AppColors.blueAccent.withOpacity(0.3),
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.white
//                 : Get.isDarkMode
//                     ? Colors.white
//                     : Colors.black87,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(StudyTask task) {
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: FuturisticInteractiveCard(
//           accentColor: AppColors.redAccent,
//           isDarkMode: Get.isDarkMode,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.warning_amber_rounded,
//                   color: AppColors.redAccent,
//                   size: 48,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'تأكيد الحذف',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Get.isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: Text(
//                         'إلغاء',
//                         style: TextStyle(
//                           color: Get.isDarkMode ? Colors.white70 : Colors.black54,
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         final success = await controller.deleteTask(task.id);
//                         if (success) {
//                           Get.back();
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.redAccent,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('حذف'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required String hint,
//     required Function(String) onChanged,
//     required IconData icon,
//     String? initialValue,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Get.isDarkMode
//                 ? Colors.grey[800]!.withOpacity(0.5)
//                 : Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: AppColors.blueAccent.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: TextFormField(
//             initialValue: initialValue,
//             onChanged: onChanged,
//             maxLines: maxLines,
//             style: TextStyle(
//               color: Get.isDarkMode ? Colors.white : Colors.black87,
//             ),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: Get.isDarkMode
//                     ? Colors.grey[400]
//                     : Colors.grey[600],
//               ),
//               prefixIcon: Icon(
//                 icon,
//                 color: AppColors.blueAccent,
//               ),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField({
//     required String label,
//     required String hint,
//     required String? value,
//     required List<String> items,
//     required Function(String?) onChanged,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Get.isDarkMode
//                 ? Colors.grey[800]!.withOpacity(0.5)
//                 : Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: AppColors.blueAccent.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: value,
//             onChanged: onChanged,
//             style: TextStyle(
//               color: Get.isDarkMode ? Colors.white : Colors.black87,
//             ),
//             dropdownColor: Get.isDarkMode
//                 ? Colors.grey[800]
//                 : Colors.white,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: Get.isDarkMode
//                     ? Colors.grey[400]
//                     : Colors.grey[600],
//               ),
//               prefixIcon: Icon(
//                 icon,
//                 color: AppColors.blueAccent,
//               ),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//             ),
//             items: items.map((item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Text(item),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField({
//     required String label,
//     required DateTime value,
//     required Function(DateTime?) onChanged,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () async {
//             final pickedDate = await showDatePicker(
//               context: Get.context!,
//               initialDate: value,
//               firstDate: DateTime.now(),
//               lastDate: DateTime.now().add(const Duration(days: 365)),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: ColorScheme.light(
//                       primary: AppColors.blueAccent,
//                       onPrimary: Colors.white,
//                       onSurface: Get.isDarkMode ? Colors.white : Colors.black87,
//                     ),
//                     dialogBackgroundColor: Get.isDarkMode
//                         ? Colors.grey[900]
//                         : Colors.white,
//                   ),
//                   child: child!,
//                 );
//               },
//             );
            
//             if (pickedDate != null) {
//               onChanged(pickedDate);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//             decoration: BoxDecoration(
//               color: Get.isDarkMode
//                   ? Colors.grey[800]!.withOpacity(0.5)
//                   : Colors.white.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.blueAccent.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: AppColors.blueAccent,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   _formatDate(value),
//                   style: TextStyle(
//                     color: Get.isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPrioritySelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'الأولوية',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Obx(() => Row(
//           children: [
//             _buildPriorityOption(
//               label: 'منخفضة',
//               value: TaskPriority.low,
//               color: AppColors.blueAccent,
//               isSelected: controller.newTaskPriority.value == TaskPriority.low,
//             ),
//             const SizedBox(width: 8),
//             _buildPriorityOption(
//               label: 'متوسطة',
//               value: TaskPriority.medium,
//               color: AppColors.orangeAccent,
//               isSelected: controller.newTaskPriority.value == TaskPriority.medium,
//             ),
//             const SizedBox(width: 8),
//             _buildPriorityOption(
//               label: 'عالية',
//               value: TaskPriority.high,
//               color: AppColors.redAccent,
//               isSelected: controller.newTaskPriority.value == TaskPriority.high,
//             ),
//           ],
//         )),
//       ],
//     );
//   }

//   Widget _buildPriorityOption({
//     required String label,
//     required TaskPriority value,
//     required Color color,
//     required bool isSelected,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => controller.newTaskPriority.value = value,
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? color.withOpacity(0.2)
//                 : Get.isDarkMode
//                     ? Colors.grey[800]!.withOpacity(0.5)
//                     : Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected ? color : color.withOpacity(0.3),
//               width: isSelected ? 2 : 1,
//             ),
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: color.withOpacity(0.3),
//                       blurRadius: 8,
//                       spreadRadius: 1,
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 controller.getPriorityIcon(value),
//                 color: isSelected ? color : color.withOpacity(0.5),
//                 size: 16,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected
//                       ? color
//                       : Get.isDarkMode
//                           ? Colors.white
//                           : Colors.black87,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTagsField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'الوسوم',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Get.isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Get.isDarkMode
//                       ? Colors.grey[800]!.withOpacity(0.5)
//                       : Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.blueAccent.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: TextFormField(
//                   controller: TextEditingController(),
//                   style: TextStyle(
//                     color: Get.isDarkMode ? Colors.white : Colors.black87,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'أضف وسمًا',
//                     hintStyle: TextStyle(
//                       color: Get.isDarkMode
//                           ? Colors.grey[400]
//                           : Colors.grey[600],
//                     ),
//                     prefixIcon: const Icon(
//                       Icons.tag,
//                       color: AppColors.blueAccent,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                   onFieldSubmitted: (value) {
//                     if (value.isNotEmpty) {
//                       controller.addTag(value);
//                       // Clear the text field
//                       Get.find<TextEditingController>().clear();
//                     }
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               decoration: BoxDecoration(
//                 color: AppColors.blueAccent.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.blueAccent.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.add,
//                   color: AppColors.blueAccent,
//                 ),
//                 onPressed: () {
//                   final textController = Get.find<TextEditingController>();
//                   if (textController.text.isNotEmpty) {
//                     controller.addTag(textController.text);
//                     textController.clear();
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Obx(() => Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: controller.newTaskTags.map((tag) {
//             return Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 6,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.blueAccent.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: AppColors.blueAccent.withOpacity(0.5),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     tag,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Get.isDarkMode ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   GestureDetector(
//                     onTap: () => controller.removeTag(tag),
//                     child: const Icon(
//                       Icons.close,
//                       color: AppColors.blueAccent,
//                       size: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         )),
//       ],
//     );
//   }

//   void _updateProgress(StudyTask task, double delta) {
//     double newProgress = task.progress + delta;
//     newProgress = newProgress.clamp(0.0, 1.0);
//     controller.updateTaskProgress(task.id, newProgress);
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final tomorrow = DateTime(now.year, now.month, now.day + 1);
//     final dateOnly = DateTime(date.year, date.month, date.day);
    
//     if (dateOnly.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
//       return 'اليوم';
//     } else if (dateOnly.isAtSameMomentAs(DateTime(tomorrow.year, tomorrow.month, tomorrow.day))) {
//       return 'غدًا';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
