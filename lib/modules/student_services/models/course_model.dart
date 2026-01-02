// class CourseModel {
//   final String id;
//   final String code;
//   final String name;
//   final String? description;
//   final String type;
//   final String departmentId;
//   final String? level;
//   final String? term;

//   CourseModel({
//     required this.id,
//     required this.code,
//     required this.name,
//     this.description,
//     required this.type,
//     required this.departmentId,
//     this.level,
//     this.term,
//   });

//   factory CourseModel.fromJson(Map<String, dynamic> json) {
//     return CourseModel(
//       id: json['id'],
//       code: json['code'] ?? '',
//       name: json['name'],
//       description: json['description'],
//       type: json['type'],
//       departmentId: json['department_id'],
//       level: json['level'],
//       term: json['term'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'code': code,
//       'name': name,
//       'description': description,
//       'type': type,
//       'department_id': departmentId,
//       'level': level,
//       'term': term,
//     };
//   }
// }
