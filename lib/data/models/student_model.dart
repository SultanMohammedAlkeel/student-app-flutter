// في ملف student_model.dart
class StudentModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? academicId;
  final String? department;
  // أضف باقي الحقول حسب احتياجاتك

  StudentModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.academicId,
    this.department,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      academicId: json['academic_id'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'academic_id': academicId,
      'department': department,
    };
  }
}