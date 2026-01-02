import 'package:dio/dio.dart';
import 'package:student_app/core/network/api_service.dart';

import 'book_info_model.dart';
import 'book_model.dart';
import 'category_model.dart';

class LibraryRepository {
  final _dio = ApiService().dio;

  // الحصول على قائمة الكتب
  Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('/library/books');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('فشل في الحصول على الكتب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الحصول على الكتب: $e');
    }
  }

  // الحصول على قائمة التصنيفات
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/library/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('فشل في الحصول على التصنيفات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الحصول على التصنيفات: $e');
    }
  }

  // الحصول على قائمة التصنيفات
 Future<List<Category>> getCategoriesOnly() async {
  try {
    final response = await _dio.get('/library/categories-list');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Failed to load categories: ${e.message}');
  }
}
  // الحصول على معلومات تفاعل المستخدم مع الكتب
  Future<List<BookInfo>> getBookInfos() async {
    try {
      final response = await _dio.get('/library/book-infos');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookInfo.fromJson(json)).toList();
      } else {
        throw Exception(
            'فشل في الحصول على معلومات الكتب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الحصول على معلومات الكتب: $e');
    }
  }

// إضافة كتاب جديد
  Future<Book> addBook(FormData formData) async {
    try {
      final response = await _dio.post(
        '/library/books/addBook',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        return Book.fromJson(data);
      } else if (response.statusCode == 422) {
        // خطأ في التحقق من البيانات
        final errors = response.data['errors'];
        final errorMessages = errors.values.map((e) => e.join(', ')).join('\n');
        throw Exception('فشل في التحقق من البيانات: $errorMessages');
      } else {
        throw Exception('فشل في إضافة الكتاب: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        final errorMessages = errors.values.map((e) => e.join(', ')).join('\n');
        throw Exception('فشل في التحقق من البيانات: $errorMessages');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة الاتصال بالخادم');
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      } else {
        throw Exception('فشل في إضافة الكتاب: ${e.message}');
      }
    } catch (e) {
      throw Exception('فشل في إضافة الكتاب: $e');
    }
  }

  // البحث في الكتب
  Future<List<Book>> searchBooks(
      String query, Map<String, dynamic> filters) async {
    try {
      final response =
          await _dio.get('/library/books/search', queryParameters: {
        'query': query,
        ...filters,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('فشل في البحث عن الكتب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في البحث عن الكتب: $e');
    }
  }

  // الحصول على الكتب الأكثر مشاهدة
  Future<List<Book>> getMostViewedBooks() async {
    try {
      final response = await _dio.get('/library/books/most-viewed');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(
            'فشل في الحصول على الكتب الأكثر مشاهدة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الحصول على الكتب الأكثر مشاهدة: $e');
    }
  }

  // الحصول على الكتب الأكثر تحميلاً
  Future<List<Book>> getMostDownloadedBooks() async {
    try {
      final response = await _dio.get('/library/books/most-downloaded');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(
            'فشل في الحصول على الكتب الأكثر تحميلاً: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الحصول على الكتب الأكثر تحميلاً: $e');
    }
  }

  // الإعجاب بكتاب
  Future<void> toggleLikeBook(int bookId) async {
    try {
      final response = await _dio.post('/library/books/$bookId/like');

      if (response.statusCode != 200) {
        throw Exception('فشل في تحديث حالة الإعجاب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في تحديث حالة الإعجاب: $e');
    }
  }

  // حفظ كتاب
  Future<void> toggleSaveBook(int bookId) async {
    try {
      final response = await _dio.post('/library/books/$bookId/save');

      if (response.statusCode != 200) {
        throw Exception('فشل في تحديث حالة الحفظ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في تحديث حالة الحفظ: $e');
    }
  }

  // تحميل كتاب
  Future<void> downloadBook(int bookId) async {
    try {
      final response = await _dio.post('/library/books/$bookId/download');

      if (response.statusCode != 200) {
        throw Exception('فشل في تسجيل تحميل الكتاب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في تسجيل تحميل الكتاب: $e');
    }
  }

  // فتح كتاب
  Future<void> openBook(int bookId) async {
    try {
      final response = await _dio.post('/library/books/$bookId/view');

      if (response.statusCode != 200) {
        throw Exception('فشل في تسجيل مشاهدة الكتاب: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في تسجيل مشاهدة الكتاب: $e');
    }
  }

}
