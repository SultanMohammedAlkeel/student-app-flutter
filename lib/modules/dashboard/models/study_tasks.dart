import 'package:flutter/material.dart';

/// نموذج المهمة الدراسية
class StudyTask {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final String? courseId;
  final String? courseName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.courseId,
    this.courseName,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء نموذج من JSON
  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
      courseId: json['courseId'],
      courseName: json['courseName'],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'courseId': courseId,
      'courseName': courseName,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء نسخة معدلة من المهمة
  StudyTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    String? courseId,
    String? courseName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// الحصول على لون الأولوية
  Color getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'عالي':
      case 'high':
        return Colors.red;
      case 'متوسط':
      case 'medium':
        return Colors.orange;
      case 'منخفض':
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  /// التحقق من تأخر المهمة
  bool isOverdue() {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  /// الحصول على حالة المهمة كنص
  String getStatusText() {
    if (isCompleted) {
      return 'مكتملة';
    } else if (isOverdue()) {
      return 'متأخرة';
    } else {
      return 'قيد التنفيذ';
    }
  }

  /// الحصول على أيقونة حالة المهمة
  IconData getStatusIcon() {
    if (isCompleted) {
      return Icons.check_circle;
    } else if (isOverdue()) {
      return Icons.warning;
    } else {
      return Icons.access_time;
    }
  }

  /// الحصول على لون حالة المهمة
  Color getStatusColor() {
    if (isCompleted) {
      return Colors.green;
    } else if (isOverdue()) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
