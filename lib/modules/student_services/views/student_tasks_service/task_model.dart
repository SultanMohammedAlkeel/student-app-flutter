import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskStatus {
  pending,
  completed,
  cancelled,
  expired,
}

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;
  DateTime createdAt;
  DateTime? completedAt;
  bool isReminderSet;
  DateTime? reminderTime;
  String? category;
  Color? color;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    this.completedAt,
    this.isReminderSet = false,
    this.reminderTime,
    this.category,
    this.color,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // تحويل Task إلى Map لتخزينه محلياً
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'isReminderSet': isReminderSet,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'category': category,
      'color': color?.value,
    };
  }

  // إنشاء Task من Map مخزن محلياً
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      priority: TaskPriority.values[json['priority']],
      status: TaskStatus.values[json['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      isReminderSet: json['isReminderSet'] ?? false,
      reminderTime: json['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['reminderTime'])
          : null,
      category: json['category'],
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  // نسخة معدلة من Task
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? completedAt,
    bool? isReminderSet,
    DateTime? reminderTime,
    String? category,
    Color? color,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isReminderSet: isReminderSet ?? this.isReminderSet,
      reminderTime: reminderTime ?? this.reminderTime,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  // التحقق مما إذا كانت المهمة منتهية الصلاحية
  bool get isExpired {
    return dueDate.isBefore(DateTime.now()) && status == TaskStatus.pending;
  }

  // الحصول على اللون بناءً على الأولوية
  Color getPriorityColor() {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  // الحصول على اللون بناءً على الحالة
  Color getStatusColor() {
    switch (status) {
      case TaskStatus.pending:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.grey;
      case TaskStatus.expired:
        return Colors.red;
    }
  }

  // الحصول على نص الأولوية
  String getPriorityText() {
    switch (priority) {
      case TaskPriority.low:
        return 'منخفضة';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.high:
        return 'عالية';
    }
  }

  // الحصول على نص الحالة
  String getStatusText() {
    switch (status) {
      case TaskStatus.pending:
        return 'قيد الانتظار';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.cancelled:
        return 'ملغاة';
      case TaskStatus.expired:
        return 'منتهية';
    }
  }
}
