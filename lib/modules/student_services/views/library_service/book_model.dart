import 'package:get/get.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final int categoryId;
  final String? categoryName;
  final int? collegeId;
  final String? collegeName;
  final int? departmentId;
  final String? departmentName;
  final String? level;
  final String type; // عام، خاص، مشترك، محدد
  final int addedBy;
  final String? addedByName;
  final int likesCount;
  final int downloadCount;
  final int opensCount;
  final int saveCount;
  final bool isActive;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // متغيرات تفاعلية للمستخدم الحالي
  final RxBool isLiked = false.obs;
  final RxBool isSaved = false.obs;
  final RxBool isDownloaded = false.obs;
  final RxBool isOpened = false.obs;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.categoryId,
    this.categoryName,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
    this.level,
    required this.type,
    required this.addedBy,
    this.addedByName,
    required this.likesCount,
    required this.downloadCount,
    required this.opensCount,
    required this.saveCount,
    required this.isActive,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'] ?? '',
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      collegeId: json['college_id'],
      collegeName: json['college_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      level: json['level'],
      type: json['type'],
      addedBy: json['added_by'],
      addedByName: json['added_by_name'],
      likesCount: json['likes_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      opensCount: json['opens_count'] ?? 0,
      saveCount: json['save_count'] ?? 0,
      isActive: json['is_active'] == 1,
      code: json['code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'category_id': categoryId,
      'category_name': categoryName,
      'college_id': collegeId,
      'college_name': collegeName,
      'department_id': departmentId,
      'department_name': departmentName,
      'level': level,
      'type': type,
      'added_by': addedBy,
      'added_by_name': addedByName,
      'likes_count': likesCount,
      'download_count': downloadCount,
      'opens_count': opensCount,
      'save_count': saveCount,
      'is_active': isActive ? 1 : 0,
      'code': code,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // تحويل حجم الملف إلى صيغة مقروءة
  String getFormattedFileSize() {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = fileSize.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  // الحصول على أيقونة مناسبة لنوع الملف
  String getFileIcon() {
    switch (fileType) {
      case 'PDF':
        return 'assets/icons/pdf.png';
      case 'Microsoft Word':
        return 'assets/icons/word.png';
      case 'Microsoft Excel':
        return 'assets/icons/excel.png';
      case 'PowerPoint':
        return 'assets/icons/powerpoint.png';
      case 'Text Files':
        return 'assets/icons/text.png';
      case 'Programming Files':
        return 'assets/icons/code.png';
      case 'Executable Files':
        return 'assets/icons/exe.png';
      case 'Database Files':
        return 'assets/icons/database.png';
      default:
        return 'assets/icons/file.png';
    }
  }
}
