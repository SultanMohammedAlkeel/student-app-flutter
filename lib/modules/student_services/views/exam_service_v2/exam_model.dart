import 'dart:convert';

import 'exam_taking_controller.dart';

class Exam {
  final int? id;
  final String code;
  final String name;
  final String description;
  final String language;
  final String type;
  final int departmentId;
  final String? departmentName;
  final String level;
  final int createdBy;
  final String? creatorName;
  final String examData;
  final DateTime? createdAt;
  final int? questionsCount;
  final int? takenCount;
  
  Exam({
    this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.language,
    required this.type,
    required this.departmentId,
    this.departmentName,
    required this.level,
    required this.createdBy,
    this.creatorName,
    required this.examData,
    this.createdAt,
    this.questionsCount,
    this.takenCount=0,
  });
  
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'] ?? '',
      language: json['language'],
      type: json['type'],
      departmentId: json['department_id'],
      departmentName: json['department'] != null 
          ? json['department']['name'] ?? json['department_name']
          : json['department_name'],
      level: json['level'],
      createdBy: json['created_by'],
      creatorName: json['creator_name'],
      examData: json['exam_data'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      questionsCount: json['questions_count'] ?? 
          (json['exam_data'] != null 
              ? (jsonDecode(json['exam_data']) as List).length 
              : 0),
      takenCount: json['taken_count'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'language': language,
      'type': type,
      'department_id': departmentId,
      'department_name': departmentName,
      'level': level,
      'created_by': createdBy,
      'creator_name': creatorName,
      'exam_data': examData,
      'created_at': createdAt?.toIso8601String(),
      'questions_count': questionsCount,
      'taken_count': takenCount,
    };
  }
  
  // استخراج الأسئلة من بيانات الامتحان
  List<ExamQuestion> getQuestions() {
    try {
      final List<dynamic> questionsJson = jsonDecode(examData);
      return questionsJson.map((q) => ExamQuestion.fromJson(q)).toList();
    } catch (e) {
      print('Error parsing exam data: $e');
      return [];
    }
  }
  
  // الحصول على عدد الأسئلة (إذا لم يكن متوفراً في الحقل)
  int get calculatedQuestionsCount {
    return questionsCount ?? getQuestions().length;
  }
  
  // نسخة معدلة من الامتحان
  Exam copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? language,
    String? type,
    int? departmentId,
    String? departmentName,
    String? level,
    int? createdBy,
    String? creatorName,
    String? examData,
    DateTime? createdAt,
    int? questionsCount,
    int? takenCount,
  }) {
    return Exam(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      type: type ?? this.type,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      level: level ?? this.level,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      examData: examData ?? this.examData,
      createdAt: createdAt ?? this.createdAt,
      questionsCount: questionsCount ?? this.questionsCount,
      takenCount: takenCount ?? this.takenCount,
    );
  }
  
  @override
  String toString() {
    return 'Exam{id: $id, name: $name, code: $code, questions: $questionsCount, taken: $takenCount}';
  }
}