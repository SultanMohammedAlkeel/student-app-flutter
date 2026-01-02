import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'book_info_model.dart';
import 'book_model.dart';


class LibraryStorageService {
  final StorageService _storageService = Get.find<StorageService>();
  
  // حفظ قائمة الكتب محلياً
  Future<void> saveBooks(List<Book> books) async {
    await _storageService.write('library_books', books.map((e) => e.toJson()).toList());
  }
  
  // استرجاع قائمة الكتب من التخزين المحلي
  Future<List<Book>> getBooks() async {
    final booksData = await _storageService.read<List<dynamic>>('library_books');
    if (booksData != null) {
      return booksData.map((e) => Book.fromJson(e)).toList();
    }
    return [];
  }
  
  // حفظ قائمة التصنيفات محلياً
  Future<void> saveCategories(List<dynamic> categories) async {
    await _storageService.write('library_categories', categories);
  }
  
  // استرجاع قائمة التصنيفات من التخزين المحلي
  Future<List<dynamic>> getCategories() async {
    final categoriesData = await _storageService.read<List<dynamic>>('library_categories');
    return categoriesData ?? [];
  }
  
  // حفظ معلومات تفاعل المستخدم مع الكتب محلياً
  Future<void> saveBookInfos(List<BookInfo> bookInfos) async {
    await _storageService.write('library_book_infos', bookInfos.map((e) => e.toJson()).toList());
  }
  
  // استرجاع معلومات تفاعل المستخدم مع الكتب من التخزين المحلي
  Future<List<BookInfo>> getBookInfos() async {
    final bookInfosData = await _storageService.read<List<dynamic>>('library_book_infos');
    if (bookInfosData != null) {
      return bookInfosData.map((e) => BookInfo.fromJson(e)).toList();
    }
    return [];
  }
  
  // حفظ تاريخ آخر تحديث
  Future<void> saveLastUpdated(DateTime dateTime) async {
    await _storageService.write('library_last_updated', dateTime.toIso8601String());
  }
  
  // استرجاع تاريخ آخر تحديث
  Future<DateTime?> getLastUpdated() async {
    final lastUpdatedData = await _storageService.read<String>('library_last_updated');
    if (lastUpdatedData != null) {
      return DateTime.parse(lastUpdatedData);
    }
    return null;
  }
  
  // حفظ سجل البحث
  Future<void> saveSearchHistory(List<String> searchHistory) async {
    await _storageService.write('library_search_history', searchHistory);
  }
  
  // استرجاع سجل البحث
  Future<List<String>> getSearchHistory() async {
    final historyData = await _storageService.read<List<dynamic>>('library_search_history');
    if (historyData != null) {
      return historyData.map((e) => e.toString()).toList();
    }
    return [];
  }
  
  // حفظ الكتب المحفوظة
  Future<void> saveSavedBooks(List<int> bookIds) async {
    await _storageService.write('library_saved_books', bookIds);
  }
  
  // استرجاع الكتب المحفوظة
  Future<List<int>> getSavedBooks() async {
    final savedBooksData = await _storageService.read<List<dynamic>>('library_saved_books');
    if (savedBooksData != null) {
      return savedBooksData.map((e) => e as int).toList();
    }
    return [];
  }
  
  // مسح جميع بيانات المكتبة المخزنة محلياً
  Future<void> clearAllLibraryData() async {
    await _storageService.remove('library_books');
    await _storageService.remove('library_categories');
    await _storageService.remove('library_book_infos');
    await _storageService.remove('library_last_updated');
    await _storageService.remove('library_saved_books');
    // لا نمسح سجل البحث لأنه قد يكون مفيداً للمستخدم
  }
}
