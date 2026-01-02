import 'package:flutter/material.dart';

class AttendanceRecord {
  final int attendanceId;
  final String lectureDate;
  final int lectureNumber;
  final String period;
  final String status;
  final String statusCode;
  final String? teacherName;

  AttendanceRecord({
    required this.attendanceId,
    required this.lectureDate,
    required this.lectureNumber,
    required this.period,
    required this.status,
    required this.statusCode,
    this.teacherName,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      attendanceId: json['attendance_id'] ?? 0,
      lectureDate: json['lecture_date'] ?? '',
      lectureNumber: json['lecture_number'] ?? 0,
      period: json['period'] ?? '',
      status: json['status'] ?? '',
      statusCode: json['status_code'] ?? '0',
      teacherName: json['teacher_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'lecture_date': lectureDate,
      'lecture_number': lectureNumber,
      'period': period,
      'status': status,
      'status_code': statusCode,
      'teacher_name': teacherName,
    };
  }

  bool get isPresent => statusCode == '1';
  bool get isAbsent => statusCode == '0';
}

class CourseAttendance {
  final int courseId;
  final String courseName;
  final String courseCode;
  final String teacherName;
  final int totalLectures;
  final int attendedLectures;
  final int absentLectures;
  final double attendancePercentage;
  final List<AttendanceRecord> lectures;

  CourseAttendance({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.teacherName,
    required this.totalLectures,
    required this.attendedLectures,
    required this.absentLectures,
    required this.attendancePercentage,
    required this.lectures,
  });

  factory CourseAttendance.fromJson(Map<String, dynamic> json) {
    return CourseAttendance(
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      totalLectures: json['total_lectures'] ?? 0,
      attendedLectures: json['attended_lectures'] ?? 0,
      absentLectures: json['absent_lectures'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0.0).toDouble(),
      lectures: (json['lectures'] as List<dynamic>?)
              ?.map((lecture) => AttendanceRecord.fromJson(lecture))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'course_code': courseCode,
      'teacher_name': teacherName,
      'total_lectures': totalLectures,
      'attended_lectures': attendedLectures,
      'absent_lectures': absentLectures,
      'attendance_percentage': attendancePercentage,
      'lectures': lectures.map((lecture) => lecture.toJson()).toList(),
    };
  }

  String get attendanceStatus {
    if (attendancePercentage >= 90) return 'ممتاز';
    if (attendancePercentage >= 80) return 'جيد جداً';
    if (attendancePercentage >= 70) return 'جيد';
    if (attendancePercentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Color get statusColor {
    if (attendancePercentage >= 90) return Colors.green;
    if (attendancePercentage >= 80) return Colors.lightGreen;
    if (attendancePercentage >= 70) return Colors.orange;
    if (attendancePercentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}

class StudentInfo {
  final int id;
  final String name;
  final String card;
  final String level;
  final int departmentId;

  StudentInfo({
    required this.id,
    required this.name,
    required this.card,
    required this.level,
    required this.departmentId,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      card: json['card'] ?? '',
      level: json['level'] ?? '',
      departmentId: json['department_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'card': card,
      'level': level,
      'department_id': departmentId,
    };
  }
}

class AttendanceSummary {
  final int totalCourses;
  final int totalLectures;
  final int totalAttended;
  final int totalAbsent;
  final double overallPercentage;

  AttendanceSummary({
    required this.totalCourses,
    required this.totalLectures,
    required this.totalAttended,
    required this.totalAbsent,
    required this.overallPercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalCourses: json['total_courses'] ?? 0,
      totalLectures: json['total_lectures'] ?? 0,
      totalAttended: json['total_attended'] ?? 0,
      totalAbsent: json['total_absent'] ?? 0,
      overallPercentage: (json['overall_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_courses': totalCourses,
      'total_lectures': totalLectures,
      'total_attended': totalAttended,
      'total_absent': totalAbsent,
      'overall_percentage': overallPercentage,
    };
  }
}

class AttendanceData {
  final StudentInfo studentInfo;
  final List<CourseAttendance> coursesAttendance;
  final AttendanceSummary summary;
  final DateTime lastUpdated;

  AttendanceData({
    required this.studentInfo,
    required this.coursesAttendance,
    required this.summary,
    required this.lastUpdated,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      studentInfo: StudentInfo.fromJson(json['student_info'] ?? {}),
      coursesAttendance: (json['courses_attendance'] as List<dynamic>?)
              ?.map((course) => CourseAttendance.fromJson(course))
              .toList() ??
          [],
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_info': studentInfo.toJson(),
      'courses_attendance': coursesAttendance.map((course) => course.toJson()).toList(),
      'summary': summary.toJson(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  static AttendanceData empty() {
    return AttendanceData(
      studentInfo: StudentInfo(
        id: 0,
        name: '',
        card: '',
        level: '',
        departmentId: 0,
      ),
      coursesAttendance: [],
      summary: AttendanceSummary(
        totalCourses: 0,
        totalLectures: 0,
        totalAttended: 0,
        totalAbsent: 0,
        overallPercentage: 0.0,
      ),
      lastUpdated: DateTime.now(),
    );
  }
}

class CourseAttendanceDetails {
  final CourseInfo courseInfo;
  final AttendanceSummary attendanceSummary;
  final List<AttendanceRecord> lectures;

  CourseAttendanceDetails({
    required this.courseInfo,
    required this.attendanceSummary,
    required this.lectures,
  });

  factory CourseAttendanceDetails.fromJson(Map<String, dynamic> json) {
    return CourseAttendanceDetails(
      courseInfo: CourseInfo.fromJson(json['course_info'] ?? {}),
      attendanceSummary: AttendanceSummary.fromJson(json['attendance_summary'] ?? {}),
      lectures: (json['lectures'] as List<dynamic>?)
              ?.map((lecture) => AttendanceRecord.fromJson(lecture))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_info': courseInfo.toJson(),
      'attendance_summary': attendanceSummary.toJson(),
      'lectures': lectures.map((lecture) => lecture.toJson()).toList(),
    };
  }
}

class CourseInfo {
  final int id;
  final String name;
  final String code;
  final String level;

  CourseInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.level,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      level: json['level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'level': level,
    };
  }
}

