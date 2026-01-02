class University {
  final int id;
  final String name;
  final String? logoUrl;
  final String? contactInfo;
  final List<College> colleges;

  University({
    required this.id,
    required this.name,
    this.logoUrl,
    this.contactInfo,
    this.colleges = const [],
  });

  factory University.fromJson(Map<String, dynamic> json) {
    List<College> collegesList = [];
    if (json['colleges'] != null) {
      collegesList = List<College>.from(
          json['colleges'].map((x) => College.fromJson(x)));
    }

    return University(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      contactInfo: json['contact_info'],
      colleges: collegesList,
    );
  }
}

class College {
  final int id;
  final String name;
  final String? logoUrl;
  final int universityId;
  final String? contactInfo;
  final List<Department> departments;
  final List<Building> buildings;

  College({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.universityId,
    this.contactInfo,
    this.departments = const [],
    this.buildings = const [],
  });

  factory College.fromJson(Map<String, dynamic> json) {
    List<Department> departmentsList = [];
    if (json['departments'] != null) {
      departmentsList = List<Department>.from(
          json['departments'].map((x) => Department.fromJson(x)));
    }

    List<Building> buildingsList = [];
    if (json['buildings'] != null) {
      buildingsList = List<Building>.from(
          json['buildings'].map((x) => Building.fromJson(x)));
    }

    return College(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      universityId: json['university_id'],
      contactInfo: json['contact_info'],
      departments: departmentsList,
      buildings: buildingsList,
    );
  }
}

class Department {
  final int id;
  final String name;
  final int collegeId;
  final String? description;
  final List<Course> courses;

  Department({
    required this.id,
    required this.name,
    required this.collegeId,
    this.description,
    this.courses = const [],
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    List<Course> coursesList = [];
    if (json['courses'] != null) {
      coursesList = List<Course>.from(
          json['courses'].map((x) => Course.fromJson(x)));
    }

    return Department(
      id: json['id'],
      name: json['name'],
      collegeId: json['college_id'],
      description: json['description'],
      courses: coursesList,
    );
  }
}

class Building {
  final int id;
  final String name;
  final String? location;
  final String? description;

  Building({
    required this.id,
    required this.name,
    this.location,
    this.description,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
    );
  }
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
      id: json['id'],
      name: json['name'],
      type: json['type'],
      departmentId: json['department_id'],
      level: json['level'],
      term: json['term'],
      description: json['description'],
    );
  }
}
