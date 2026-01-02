// class BookModel {
//   final String id;
//   final String title;
//   final String author;
//   final String description;
//   final String coverImageUrl;
//   final String categoryId;
//   final String publisher;
//   final int pageCount;
//   final DateTime publishDate;
//   final String language;
//   final String fileUrl;
//   final bool isAvailable;
//   final double rating;
//   final int downloadCount;

//   BookModel({
//     required this.id,
//     required this.title,
//     required this.author,
//     required this.description,
//     required this.coverImageUrl,
//     required this.categoryId,
//     required this.publisher,
//     required this.pageCount,
//     required this.publishDate,
//     required this.language,
//     required this.fileUrl,
//     required this.isAvailable,
//     required this.rating,
//     required this.downloadCount,
//   });

//   // تحويل النموذج إلى Map
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'author': author,
//       'description': description,
//       'coverImageUrl': coverImageUrl,
//       'categoryId': categoryId,
//       'publisher': publisher,
//       'pageCount': pageCount,
//       'publishDate': publishDate.toIso8601String(),
//       'language': language,
//       'fileUrl': fileUrl,
//       'isAvailable': isAvailable,
//       'rating': rating,
//       'downloadCount': downloadCount,
//     };
//   }

//   // إنشاء نموذج من Map
//   factory BookModel.fromJson(Map<String, dynamic> json) {
//     return BookModel(
//       id: json['id'],
//       title: json['title'],
//       author: json['author'],
//       description: json['description'],
//       coverImageUrl: json['coverImageUrl'],
//       categoryId: json['categoryId'],
//       publisher: json['publisher'],
//       pageCount: json['pageCount'],
//       publishDate: DateTime.parse(json['publishDate']),
//       language: json['language'],
//       fileUrl: json['fileUrl'],
//       isAvailable: json['isAvailable'],
//       rating: json['rating'].toDouble(),
//       downloadCount: json['downloadCount'],
//     );
//   }
  
//   // الحصول على تقييم النجوم كنص
//   String get ratingText {
//     return '$rating/5.0';
//   }
  
//   // الحصول على حجم الملف كنص
//   String get fileSizeText {
//     // افتراضي لأن حجم الملف غير متوفر في البيانات
//     return 'غير معروف';
//   }
// }
