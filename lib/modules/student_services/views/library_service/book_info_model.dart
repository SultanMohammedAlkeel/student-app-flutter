class BookInfo {
  final int id;
  final int bookId;
  final int userId;
  final int likes;
  final int downloads;
  final int opensCount;
  final int save;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookInfo({
    required this.id,
    required this.bookId,
    required this.userId,
    this.likes = 0,
    this.downloads = 0,
    this.opensCount = 0,
    this.save = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      id: json['id'],
      bookId: json['book_id'],
      userId: json['user_id'],
      likes: json['likes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      opensCount: json['opens_count'] ?? 0,
      save: json['save'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'likes': likes,
      'downloads': downloads,
      'opens_count': opensCount,
      'save': save,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // نسخة جديدة مع تحديث الإعجاب
  BookInfo copyWithToggleLike() {
    return BookInfo(
      id: id,
      bookId: bookId,
      userId: userId,
      likes: likes == 1 ? 0 : 1,
      downloads: downloads,
      opensCount: opensCount,
      save: save,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // نسخة جديدة مع تحديث الحفظ
  BookInfo copyWithToggleSave() {
    return BookInfo(
      id: id,
      bookId: bookId,
      userId: userId,
      likes: likes,
      downloads: downloads,
      opensCount: opensCount,
      save: save == 1 ? 0 : 1,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // نسخة جديدة مع زيادة عدد التحميلات
  BookInfo copyWithIncrementDownloads() {
    return BookInfo(
      id: id,
      bookId: bookId,
      userId: userId,
      likes: likes,
      downloads: downloads + 1,
      opensCount: opensCount,
      save: save,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // نسخة جديدة مع زيادة عدد المشاهدات
  BookInfo copyWithIncrementOpens() {
    return BookInfo(
      id: id,
      bookId: bookId,
      userId: userId,
      likes: likes,
      downloads: downloads,
      opensCount: opensCount + 1,
      save: save,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
