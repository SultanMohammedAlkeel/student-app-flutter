// import 'package:flutter/material.dart';

// class LectureModel {
//   final String id;
//   final String courseName;
//   final String courseCode;
//   final String instructorName;
//   final String location;
//   final int dayOfWeek; // 0 = السبت، 1 = الأحد، ... 6 = الجمعة
//   final TimeOfDay startTime;
//   final TimeOfDay endTime;
//   final String type; // محاضرة، معمل، تمارين
//   final String? notes;

//   LectureModel({
//     required this.id,
//     required this.courseName,
//     required this.courseCode,
//     required this.instructorName,
//     required this.location,
//     required this.dayOfWeek,
//     required this.startTime,
//     required this.endTime,
//     required this.type,
//     this.notes,
//   });

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'courseName': courseName,
//       'courseCode': courseCode,
//       'instructorName': instructorName,
//       'location': location,
//       'dayOfWeek': dayOfWeek,
//       'startTime': {
//         'hour': startTime.hour,
//         'minute': startTime.minute,
//       },
//       'endTime': {
//         'hour': endTime.hour,
//         'minute': endTime.minute,
//       },
//       'type': type,
//       'notes': notes,
//     };
//   }

//   // إنشاء نموذج من Map
//   factory LectureModel.fromJson(Map<String, dynamic> json) {
//     return LectureModel(
//       id: json['id'],
//       courseName: json['courseName'],
//       courseCode: json['courseCode'],
//       instructorName: json['instructorName'],
//       location: json['location'],
//       dayOfWeek: json['dayOfWeek'],
//       startTime: TimeOfDay(
//         hour: json['startTime']['hour'],
//         minute: json['startTime']['minute'],
//       ),
//       endTime: TimeOfDay(
//         hour: json['endTime']['hour'],
//         minute: json['endTime']['minute'],
//       ),
//       type: json['type'],
//       notes: json['notes'],
//     );
//   }

//   // الحصول على لون المحاضرة حسب النوع
//   Color get typeColor {
//     switch (type) {
//       case 'محاضرة':
//         return Colors.blue;
//       case 'معمل':
//         return Colors.green;
//       case 'تمارين':
//         return Colors.orange;
//       default:
//         return Colors.purple;
//     }
//   }

//   // الحصول على أيقونة المحاضرة حسب النوع
//   IconData get typeIcon {
//     switch (type) {
//       case 'محاضرة':
//         return Icons.menu_book;
//       case 'معمل':
//         return Icons.science;
//       case 'تمارين':
//         return Icons.calculate;
//       default:
//         return Icons.school;
//     }
//   }

//   // حساب مدة المحاضرة بالدقائق
//   int get durationInMinutes {
//     final startMinutes = startTime.hour * 60 + startTime.minute;
//     final endMinutes = endTime.hour * 60 + endTime.minute;
//     return endMinutes - startMinutes;
//   }

//   // تنسيق مدة المحاضرة (ساعات ودقائق)
//   String get formattedDuration {
//     final duration = durationInMinutes;
//     final hours = duration ~/ 60;
//     final minutes = duration % 60;
    
//     if (hours > 0) {
//       return '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
//     } else {
//       return '$minutes دقيقة';
//     }
//   }
// }
