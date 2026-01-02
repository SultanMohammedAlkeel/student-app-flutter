import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/modules/posts/models/post_model.dart';

import 'book_info_model.dart';
import 'book_model.dart';
import 'library_repository.dart';

class LibrarySyncService {
  final LibraryRepository _repository = Get.find<LibraryRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // مزامنة بيانات المكتبة مع السيرفر
  Future<Map<String, dynamic>> syncLibraryData() async {
    try {
      // الحصول على البيانات من السيرفر
      final books = await _repository.getBooks();
      final categories = await _repository.getCategories();
      final bookInfos = await _repository.getBookInfos();
      
      // حفظ البيانات محلياً
      await _storageService.write('library_books', books.map((e) => (e).toJson()).toList());
      await _storageService.write('library_categories', categories.map((e) => (e).toJson()).toList());
      await _storageService.write('library_book_infos', bookInfos.map((e) => (e as BookInfo?)?.toJson()).toList());
      await _storageService.write('library_last_updated', DateTime.now().toIso8601String());
      
      return {
        'success': true,
        'books': books,
        'categories': categories,
        'bookInfos': bookInfos,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // تحويل كتاب إلى منشور لاستخدامه مع MediaPreview
  Post convertBookToPost(Book book) {
    return Post(
      
      id: book.id,
      senderId: book.addedBy,
      userName: book.addedByName ?? 'مستخدم',
      userImage: '', // Add userImage parameter
      content: book.description,
      fileUrl: book.fileUrl,
      fileType: _mapFileTypeToPostFileType(book.fileType),
      fileSize: book.fileSize,
      createdAt: book.createdAt.toIso8601String(),
      updatedAt: book.updatedAt.toIso8601String(),
      likesCount: book.likesCount,
      commentsCount: 0,
      viewsCount: book.opensCount,
      isLiked: book.isLiked.value,
      isSaved: book.isSaved.value, isDeleted: book.isActive, hasMedia: true,
    );
  }
  
  // تحويل نوع ملف الكتاب إلى نوع ملف المنشور
  String _mapFileTypeToPostFileType(String bookFileType) {
    switch (bookFileType) {
      case 'PDF':
        return 'pdf';
      case 'Microsoft Word':
        return 'doc';
      case 'Microsoft Excel':
        return 'xls';
      case 'PowerPoint':
        return 'ppt';
      case 'Text Files':
        return 'txt';
      case 'Programming Files':
        return 'code';
      case 'Executable Files':
        return 'exe';
      case 'Database Files':
        return 'db';
      default:
        return 'file';
    }
  }
  
  // مزامنة تفاعلات المستخدم مع السيرفر
  Future<bool> syncUserInteractions() async {
    try {
      // يمكن تنفيذ منطق لمزامنة التفاعلات المحلية مع السيرفر
      // مثل الإعجابات والحفظ والتحميلات التي تمت بدون اتصال بالإنترنت
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // التحقق من وجود تحديثات جديدة
  Future<bool> checkForUpdates() async {
    try {
      final lastUpdatedString = await _storageService.read<String>('library_last_updated');
      if (lastUpdatedString == null) {
        return true; // لم يتم التحديث من قبل
      }
      
      final lastUpdated = DateTime.parse(lastUpdatedString);
      final now = DateTime.now();
      final difference = now.difference(lastUpdated);
      
      // التحقق من وجود تحديثات كل يوم
      if (difference.inHours > 24) {
        return true;
      }
      
      return false;
    } catch (e) {
      return true; // في حالة الخطأ، نفترض وجود تحديثات
    }
  }
  
  // تحميل ملف من كتاب
  Future<String?> downloadBookFile(Book book) async {
    try {
      // تسجيل التحميل في السيرفر
      await _repository.downloadBook(book.id);
      
      // هنا يمكن إضافة منطق لتحميل الملف وحفظه محلياً
      // ثم إرجاع مسار الملف المحلي
      
      return book.fileUrl; // نرجع رابط الملف مباشرة في هذه الحالة
    } catch (e) {
      return null;
    }
  }
  
  // فتح ملف من كتاب
  Future<bool> openBookFile(Book book) async {
    try {
      // تسجيل المشاهدة في السيرفر
      await _repository.openBook(book.id);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
