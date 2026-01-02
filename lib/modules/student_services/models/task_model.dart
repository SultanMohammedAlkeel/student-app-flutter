// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

// class TaskModel {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dueDate;
//   final TimeOfDay dueTime;
//   final String priority;
//   final String category;
//   final bool isCompleted;
//   final DateTime createdAt;
//   final DateTime? completedAt;

//   TaskModel({
//     String? id,
//     required this.title,
//     this.description = '',
//     required this.dueDate,
//     required this.dueTime,
//     required this.priority,
//     required this.category,
//     this.isCompleted = false,
//     DateTime? createdAt,
//     this.completedAt,
//   }) : 
//     id = id ?? const Uuid().v4(),
//     createdAt = createdAt ?? DateTime.now();

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'dueDate': dueDate.toIso8601String(),
//       'dueTime': {
//         'hour': dueTime.hour,
//         'minute': dueTime.minute,
//       },
//       'priority': priority,
//       'category': category,
//       'isCompleted': isCompleted,
//       'createdAt': createdAt.toIso8601String(),
//       'completedAt': completedAt?.toIso8601String(),
//     };
//   }

//   // إنشاء نموذج من Map
//   factory TaskModel.fromJson(Map<String, dynamic> json) {
//     return TaskModel(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'] ?? '',
//       dueDate: DateTime.parse(json['dueDate']),
//       dueTime: TimeOfDay(
//         hour: json['dueTime']['hour'],
//         minute: json['dueTime']['minute'],
//       ),
//       priority: json['priority'],
//       category: json['category'],
//       isCompleted: json['isCompleted'] ?? false,
//       createdAt: DateTime.parse(json['createdAt']),
//       completedAt: json['completedAt'] != null 
//           ? DateTime.parse(json['completedAt']) 
//           : null,
//     );
//   }

//   // نسخ النموذج مع تعديل بعض الخصائص
//   TaskModel copyWith({
//     String? title,
//     String? description,
//     DateTime? dueDate,
//     TimeOfDay? dueTime,
//     String? priority,
//     String? category,
//     bool? isCompleted,
//     DateTime? completedAt,
//   }) {
//     return TaskModel(
//       id: this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       dueDate: dueDate ?? this.dueDate,
//       dueTime: dueTime ?? this.dueTime,
//       priority: priority ?? this.priority,
//       category: category ?? this.category,
//       isCompleted: isCompleted ?? this.isCompleted,
//       createdAt: this.createdAt,
//       completedAt: completedAt ?? this.completedAt,
//     );
//   }

//   // تحديد ما إذا كانت المهمة متأخرة
//   bool get isOverdue {
//     final now = DateTime.now();
//     final dueDateTime = DateTime(
//       dueDate.year,
//       dueDate.month,
//       dueDate.day,
//       dueTime.hour,
//       dueTime.minute,
//     );
//     return !isCompleted && now.isAfter(dueDateTime);
//   }

//   // تحديد ما إذا كانت المهمة قريبة من الموعد النهائي
//   bool get isUpcoming {
//     final now = DateTime.now();
//     final dueDateTime = DateTime(
//       dueDate.year,
//       dueDate.month,
//       dueDate.day,
//       dueTime.hour,
//       dueTime.minute,
//     );
//     final difference = dueDateTime.difference(now);
//     return !isCompleted && !isOverdue && difference.inHours <= 24;
//   }

//   // الحصول على لون المهمة حسب الأولوية
//   Color get priorityColor {
//     switch (priority) {
//       case 'عالية':
//         return Colors.red;
//       case 'متوسطة':
//         return Colors.orange;
//       case 'منخفضة':
//         return Colors.green;
//       default:
//         return Colors.blue;
//     }
//   }

//   // الحصول على أيقونة المهمة حسب الفئة
//   IconData get categoryIcon {
//     switch (category) {
//       case 'مذاكرة':
//         return Icons.book;
//       case 'امتحان':
//         return Icons.assignment;
//       case 'مشروع':
//         return Icons.work;
//       case 'تسليم واجب':
//         return Icons.assignment_turned_in;
//       default:
//         return Icons.task_alt;
//     }
//   }
// }
