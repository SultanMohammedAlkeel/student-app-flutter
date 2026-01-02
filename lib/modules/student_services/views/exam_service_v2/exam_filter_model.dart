class ExamFilter {
  String? searchQuery;
  String? type;
  int? departmentId;
  String? level;
  String? language;
  int? createdBy;
  String sortBy;
  bool ascending;
  
  ExamFilter({
    this.searchQuery,
    this.type,
    this.departmentId,
    this.level,
    this.language,
    this.createdBy,
    this.sortBy = 'created_at',
    this.ascending = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'search': searchQuery,
      'type': type,
      'department_id': departmentId,
      'level': level,
      'language': language,
      'created_by': createdBy,
      'sort_by': sortBy,
      'ascending': ascending.toString(),
    };
  }
  
  // تحقق مما إذا كان الفلتر نشطًا
  bool get isActive {
    return searchQuery != null && searchQuery!.isNotEmpty ||
           type != null ||
           departmentId != null ||
           level != null ||
           language != null ||
           createdBy != null ||
           sortBy != 'created_at' ||
           ascending != false;
  }
  
  // نسخة معدلة من الفلتر
  ExamFilter copyWith({
    String? searchQuery,
    String? type,
    int? departmentId,
    String? level,
    String? language,
    int? createdBy,
    String? sortBy,
    bool? ascending,
  }) {
    return ExamFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: type ?? this.type,
      departmentId: departmentId ?? this.departmentId,
      level: level ?? this.level,
      language: language ?? this.language,
      createdBy: createdBy ?? this.createdBy,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
  
  // إعادة تعيين الفلتر
  ExamFilter reset() {
    return ExamFilter(
      searchQuery: null,
      type: null,
      departmentId: null,
      level: null,
      language: null,
      createdBy: null,
      sortBy: 'created_at',
      ascending: false,
    );
  }
}
