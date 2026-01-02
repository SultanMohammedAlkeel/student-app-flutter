// import 'package:student_app/modules/student_services/models/course_grade_model.dart';

// class GradesResult {
//   final List<CourseGradeModel> courses;
//   final double gpa;
//   final int passedCourses;
//   final int remainingCourses;
//   final int creditHours;

//   GradesResult({
//     required this.courses,
//     required this.gpa,
//     required this.passedCourses,
//     required this.remainingCourses,
//     required this.creditHours,
//   });

//   factory GradesResult.fromJson(Map<String, dynamic> json) {
//     final List<dynamic> coursesJson = json['courses'];
    
//     return GradesResult(
//       courses: coursesJson.map((course) => CourseGradeModel.fromJson(course)).toList(),
//       gpa: json['gpa'].toDouble(),
//       passedCourses: json['passed_courses'],
//       remainingCourses: json['remaining_courses'],
//       creditHours: json['credit_hours'],
//     );
//   }
// }
