class Schedule {
  final int id;
  final int departmentId;
  final int academicYearId;
  final String level;
  final String term;
  final List<List<List<ScheduleCell>>> schedule;
  final DateTime lastUpdated;

  Schedule({
    required this.id,
    required this.departmentId,
    required this.academicYearId,
    required this.level,
    required this.term,
    required this.schedule,
    required this.lastUpdated,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // تحويل بيانات الجدول من JSON إلى مصفوفة ثلاثية الأبعاد
    List<List<List<ScheduleCell>>> scheduleData = [];
    
    final scheduleJson = json['schedule'];
    if (scheduleJson is List) {
      for (var i = 0; i < scheduleJson.length; i++) {
        List<List<ScheduleCell>> day = [];
        if (scheduleJson[i] is List) {
          for (var j = 0; j < scheduleJson[i].length; j++) {
            List<ScheduleCell> period = [];
            if (scheduleJson[i][j] is Map) {
              period.add(ScheduleCell.fromJson(scheduleJson[i][j]));
            }
            day.add(period);
          }
        }
        scheduleData.add(day);
      }
    }

    return Schedule(
      id: json['id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      academicYearId: json['academic_year_id'] ?? 0,
      level: json['level'] ?? '',
      term: json['term'] ?? '',
      schedule: scheduleData,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    List<List<Map<String, dynamic>>> scheduleJson = [];
    
    for (var day in schedule) {
      List<Map<String, dynamic>> dayJson = [];
      for (var period in day) {
        if (period.isNotEmpty) {
          dayJson.add(period.first.toJson());
        } else {
          dayJson.add({
            'course': '',
            'hall': '',
            'teacher': '',
          });
        }
      }
      scheduleJson.add(dayJson);
    }

    return {
      'id': id,
      'department_id': departmentId,
      'academic_year_id': academicYearId,
      'level': level,
      'term': term,
      'schedule': scheduleJson,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // إنشاء جدول فارغ
  factory Schedule.empty() {
    List<List<List<ScheduleCell>>> emptySchedule = [];
    
    // 6 أيام في الأسبوع
    for (var i = 0; i < 6; i++) {
      List<List<ScheduleCell>> day = [];
      // 3 فترات في اليوم
      for (var j = 0; j < 3; j++) {
        day.add([ScheduleCell.empty()]);
      }
      emptySchedule.add(day);
    }

    return Schedule(
      id: 0,
      departmentId: 0,
      academicYearId: 0,
      level: '',
      term: '',
      schedule: emptySchedule,
      lastUpdated: DateTime.now(),
    );
  }
}

class ScheduleCell {
  final String course;
  final String hall;
  final String teacher;

  ScheduleCell({
    required this.course,
    required this.hall,
    required this.teacher,
  });

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      course: json['course']?.toString() ?? '',
      hall: json['hall']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'hall': hall,
      'teacher': teacher,
    };
  }

  // إنشاء خلية فارغة
  factory ScheduleCell.empty() {
    return ScheduleCell(
      course: '',
      hall: '',
      teacher: '',
    );
  }

  // التحقق مما إذا كانت الخلية فارغة
  bool get isEmpty => course.isEmpty && hall.isEmpty && teacher.isEmpty;
}

class Course {
  final int id;
  final String name;
  final String? type;
  final int departmentId;
  final String? level;
  final String? term;
  final String? description;

  Course({
    required this.id,
    required this.name,
    this.type,
    required this.departmentId,
    this.level,
    this.term,
    this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      departmentId: json['department_id'] ?? 0,
      level: json['level'],
      term: json['term'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'department_id': departmentId,
      'level': level,
      'term': term,
      'description': description,
    };
  }
}

class Hall {
  final int id;
  final String name;
  final String? type;
  final int buildingId;
  final int capacity;
  final String? description;

  Hall({
    required this.id,
    required this.name,
    this.type,
    required this.buildingId,
    required this.capacity,
    this.description,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      buildingId: json['building_id'] ?? 0,
      capacity: json['capacity'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'building_id': buildingId,
      'capacity': capacity,
      'description': description,
    };
  }
}

class Teacher {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int departmentId;

  Teacher({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.departmentId,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      departmentId: json['department_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department_id': departmentId,
    };
  }
}

class Department {
  final int id;
  final String name;
  final int collegeId;
  final String? description;

  Department({
    required this.id,
    required this.name,
    required this.collegeId,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      collegeId: json['college_id'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'college_id': collegeId,
      'description': description,
    };
  }
}
