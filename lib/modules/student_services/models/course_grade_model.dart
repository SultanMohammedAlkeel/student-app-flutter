// class CourseGradeModel {
//   final String id;
//   final String courseCode;
//   final String courseName;
//   final String semester;
//   final int creditHours;
//   final double percentage;
//   final String letterGrade;
//   final double gradePoints;
//   final bool isCompleted;
//   final Map<String, double>? assessmentBreakdown;

//   CourseGradeModel({
//     required this.id,
//     required this.courseCode,
//     required this.courseName,
//     required this.semester,
//     required this.creditHours,
//     required this.percentage,
//     required this.letterGrade,
//     required this.gradePoints,
//     required this.isCompleted,
//     this.assessmentBreakdown,
//   });

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'courseCode': courseCode,
//       'courseName': courseName,
//       'semester': semester,
//       'creditHours': creditHours,
//       'percentage': percentage,
//       'letterGrade': letterGrade,
//       'gradePoints': gradePoints,
//       'isCompleted': isCompleted,
//       'assessmentBreakdown': assessmentBreakdown,
//     };
//   }

//   // إنشاء نموذج من Map
//   factory CourseGradeModel.fromJson(Map<String, dynamic> json) {
//     Map<String, double>? breakdown;
    
//     if (json['assessmentBreakdown'] != null) {
//       breakdown = Map<String, double>.from(json['assessmentBreakdown']);
//     }
    
//     return CourseGradeModel(
//       id: json['id'],
//       courseCode: json['courseCode'],
//       courseName: json['courseName'],
//       semester: json['semester'],
//       creditHours: json['creditHours'],
//       percentage: json['percentage'].toDouble(),
//       letterGrade: json['letterGrade'],
//       gradePoints: json['gradePoints'].toDouble(),
//       isCompleted: json['isCompleted'],
//       assessmentBreakdown: breakdown,
//     );
//   }
  
//   // الحصول على تقدير الدرجة باللغة العربية
//   String get gradeInArabic {
//     switch (letterGrade) {
//       case 'A+':
//         return 'ممتاز مرتفع';
//       case 'A':
//         return 'ممتاز';
//       case 'B+':
//         return 'جيد جداً مرتفع';
//       case 'B':
//         return 'جيد جداً';
//       case 'C+':
//         return 'جيد مرتفع';
//       case 'C':
//         return 'جيد';
//       case 'D+':
//         return 'مقبول مرتفع';
//       case 'D':
//         return 'مقبول';
//       case 'F':
//         return 'راسب';
//       default:
//         return 'غير محدد';
//     }
//   }
// }
