// import 'package:flutter/material.dart';

// class ExamModel {
//   final String id;
//   final String title;
//   final String courseId;
//   final String courseName;
//   final String courseCode;
//   final String type; // نهائي، نصفي، قصير، تجريبي
//   final DateTime date;
//   final TimeOfDay startTime;
//   final int durationMinutes;
//   final String location;
//   final int totalQuestions;
//   final int totalMarks;
//   final bool isAvailable;
//   final String? description;
//   final String? instructorName;
//   final List<String>? topics;
//   final String? fileUrl;

//   ExamModel({
//     required this.id,
//     required this.title,
//     required this.courseId,
//     required this.courseName,
//     required this.courseCode,
//     required this.type,
//     required this.date,
//     required this.startTime,
//     required this.durationMinutes,
//     required this.location,
//     required this.totalQuestions,
//     required this.totalMarks,
//     required this.isAvailable,
//     this.description,
//     this.instructorName,
//     this.topics,
//     this.fileUrl,
//   });

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'courseId': courseId,
//       'courseName': courseName,
//       'courseCode': courseCode,
//       'type': type,
//       'date': date.toIso8601String(),
//       'startTime': {
//         'hour': startTime.hour,
//         'minute': startTime.minute,
//       },
//       'durationMinutes': durationMinutes,
//       'location': location,
//       'totalQuestions': totalQuestions,
//       'totalMarks': totalMarks,
//       'isAvailable': isAvailable,
//       'description': description,
//       'instructorName': instructorName,
//       'topics': topics,
//       'fileUrl': fileUrl,
//     };
//   }

//   // إنشاء نموذج من Map
//   factory ExamModel.fromJson(Map<String, dynamic> json) {
//     List<String>? topicsList;
    
//     if (json['topics'] != null) {
//       topicsList = List<String>.from(json['topics']);
//     }
    
//     return ExamModel(
//       id: json['id'],
//       title: json['title'],
//       courseId: json['courseId'],
//       courseName: json['courseName'],
//       courseCode: json['courseCode'],
//       type: json['type'],
//       date: DateTime.parse(json['date']),
//       startTime: TimeOfDay(
//         hour: json['startTime']['hour'],
//         minute: json['startTime']['minute'],
//       ),
//       durationMinutes: json['durationMinutes'],
//       location: json['location'],
//       totalQuestions: json['totalQuestions'],
//       totalMarks: json['totalMarks'],
//       isAvailable: json['isAvailable'],
//       description: json['description'],
//       instructorName: json['instructorName'],
//       topics: topicsList,
//       fileUrl: json['fileUrl'],
//     );
//   }
  
//   // حساب وقت الانتهاء
//   TimeOfDay get endTime {
//     final int totalMinutes = startTime.hour * 60 + startTime.minute + durationMinutes;
//     final int endHour = totalMinutes ~/ 60 % 24;
//     final int endMinute = totalMinutes % 60;
    
//     return TimeOfDay(hour: endHour, minute: endMinute);
//   }
  
//   // الحصول على لون الامتحان حسب النوع
//   Color get typeColor {
//     switch (type) {
//       case 'نهائي':
//         return Colors.red;
//       case 'نصفي':
//         return Colors.orange;
//       case 'قصير':
//         return Colors.blue;
//       case 'تجريبي':
//         return Colors.green;
//       default:
//         return Colors.purple;
//     }
//   }
  
//   // الحصول على أيقونة الامتحان حسب النوع
//   IconData get typeIcon {
//     switch (type) {
//       case 'نهائي':
//         return Icons.assignment;
//       case 'نصفي':
//         return Icons.assignment_turned_in;
//       case 'قصير':
//         return Icons.quiz;
//       case 'تجريبي':
//         return Icons.school;
//       default:
//         return Icons.description;
//     }
//   }
  
//   // التحقق مما إذا كان الامتحان قادمًا
//   bool get isUpcoming {
//     final now = DateTime.now();
//     return date.isAfter(now);
//   }
  
//   // التحقق مما إذا كان الامتحان قد انتهى
//   bool get isPast {
//     final now = DateTime.now();
//     return date.isBefore(now);
//   }
  
//   // الحصول على مدة الامتحان كنص
//   String get formattedDuration {
//     final hours = durationMinutes ~/ 60;
//     final minutes = durationMinutes % 60;
    
//     if (hours > 0) {
//       return '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
//     } else {
//       return '$minutes دقيقة';
//     }
//   }
// }
