class ComplaintFeedbackModel {
  final int? id;
  final String title;
  final String description;
  final String type; // 'complaint' or 'feedback'
  final String? status; // 'new', 'read', 'archived'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComplaintFeedbackModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ComplaintFeedbackModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
    };
  }

  String get formattedType {
    return type == 'complaint' ? 'شكوى' : 'ملاحظة';
  }

  String get formattedStatus {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'read':
        return 'مقروء';
      case 'archived':
        return 'مؤرشف';
      default:
        return 'غير محدد';
    }
  }

  ComplaintFeedbackModel copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComplaintFeedbackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ComplaintFeedbackModel(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplaintFeedbackModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        type.hashCode ^
        status.hashCode;
  }
}

