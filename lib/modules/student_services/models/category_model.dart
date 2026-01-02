// class CategoryModel {
//   final String id;
//   final String name;
//   final String description;
//   final String iconName;
//   final int booksCount;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.iconName,
//     required this.booksCount,
//   });

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'iconName': iconName,
//       'booksCount': booksCount,
//     };
//   }

//   // إنشاء نموذج من Map
//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       iconName: json['iconName'],
//       booksCount: json['booksCount'],
//     );
//   }
// }
