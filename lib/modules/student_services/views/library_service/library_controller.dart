import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';

import 'book_info_model.dart';
import 'book_model.dart';
import 'category_model.dart';
import 'library_repository.dart';

class LibraryController extends GetxController {
  final LibraryRepository _repository = Get.find<LibraryRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // حالة التحميل
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // بيانات المكتبة
  final RxList<Book> books = <Book>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<BookInfo> bookInfos = <BookInfo>[].obs;
  
  // الكتب المميزة
  final RxList<Book> mostViewedBooks = <Book>[].obs;
  final RxList<Book> mostDownloadedBooks = <Book>[].obs;
  final RxList<Book> mostLikedBooks = <Book>[].obs;
  final RxList<Book> savedBooks = <Book>[].obs;
  
  // التصنيف المحدد حالياً
  final Rx<Category?> selectedCategory = Rx<Category?>(null);
  
  // الوضع المظلم
  final RxBool isDarkMode = false.obs;
  
  // آخر تحديث
  final Rx<DateTime> lastUpdated = DateTime.now().obs;
  final RxBool isUsingLocalData = false.obs;
    final RxBool showFloatingButton = true.obs;


  @override
  void onInit() {
    super.onInit();
    loadLibraryData();
    
    // تحميل حالة الوضع المظلم
    _loadDarkModeState();
  }
  
  // تحميل بيانات المكتبة
  Future<void> loadLibraryData() async {
    isLoading.value = true;
    hasError.value = false;
    
    try {
      // محاولة تحميل البيانات من السيرفر
      await _loadDataFromServer();
    } catch (e) {
      // في حالة الفشل، تحميل البيانات المخزنة محلياً
      await _loadDataFromLocalStorage();
      isUsingLocalData.value = true;
      
      // إذا لم تكن هناك بيانات محلية أيضاً
      if (books.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'فشل في تحميل بيانات المكتبة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
      }
    } finally {
      isLoading.value = false;
    }
    
    // تحديث القوائم المميزة
    _updateFeaturedLists();
  }
  
  // تحميل البيانات من السيرفر
  Future<void> _loadDataFromServer() async {
    final booksData = await _repository.getBooks();
    final categoriesData = await _repository.getCategories();
    final bookInfosData = await _repository.getBookInfos();
    
    books.value = booksData;
    categories.value = categoriesData;
    bookInfos.value = bookInfosData;
    
    // تحديث حالة التفاعل للكتب
    _updateBooksInteractionState();
    
    // حفظ البيانات محلياً
    await _saveDataToLocalStorage();
    
    lastUpdated.value = DateTime.now();
    isUsingLocalData.value = false;
  }
  
  // تحميل البيانات من التخزين المحلي
  Future<void> _loadDataFromLocalStorage() async {
    final booksData = await _storageService.read<List<dynamic>>('library_books');
    final categoriesData = await _storageService.read<List<dynamic>>('library_categories');
    final bookInfosData = await _storageService.read<List<dynamic>>('library_book_infos');
    final lastUpdatedData = await _storageService.read<String>('library_last_updated');
    
    if (booksData != null) {
      books.value = booksData.map((e) => Book.fromJson(e)).toList();
    }
    
    if (categoriesData != null) {
      categories.value = categoriesData.map((e) => Category.fromJson(e)).toList();
    }
    
    if (bookInfosData != null) {
      bookInfos.value = bookInfosData.map((e) => BookInfo.fromJson(e)).toList();
    }
    
    if (lastUpdatedData != null) {
      lastUpdated.value = DateTime.parse(lastUpdatedData);
    }
    
    // تحديث حالة التفاعل للكتب
    _updateBooksInteractionState();
  }
   // تحويل الكتاب إلى منشور لاستخدامه مع MediaPreview
  dynamic convertBookToPost(Book book) {
    return {
      'id': book.id,
      'title': book.title,
      'content': book.description,
      'author': book.author,
      'file_url': book.fileUrl,
      'file_type': book.fileType,
      'created_at': book.createdAt,
      'likes_count': book.likesCount,
      'comments_count': 0,
      'is_liked': book.isLiked,
      'is_saved': book.isSaved,
      'user': {
        'id': book.addedBy,
        'name': book.addedByName ?? 'مستخدم',
        'avatar': null,
      },
    };
  }
  // حفظ البيانات في التخزين المحلي
  Future<void> _saveDataToLocalStorage() async {
    await _storageService.write('library_books', books.map((e) => e.toJson()).toList());
    await _storageService.write('library_categories', categories.map((e) => e.toJson()).toList());
    await _storageService.write('library_book_infos', bookInfos.map((e) => e.toJson()).toList());
    await _storageService.write('library_last_updated', DateTime.now().toIso8601String());
  }
  
  // تحديث حالة التفاعل للكتب
  void _updateBooksInteractionState() {
    for (final book in books) {
      final bookInfo = bookInfos.firstWhereOrNull((info) => info.bookId == book.id);
      
      if (bookInfo != null) {
        book.isLiked.value = bookInfo.likes == 1;
        book.isSaved.value = bookInfo.save == 1;
        book.isDownloaded.value = bookInfo.downloads > 0;
        book.isOpened.value = bookInfo.opensCount > 0;
      }
    }
  }
  
  // تحديث القوائم المميزة
  void _updateFeaturedLists() {
    // الكتب الأكثر مشاهدة
    mostViewedBooks.value = List.from(books)
      ..sort((a, b) => b.opensCount.compareTo(a.opensCount));
    if (mostViewedBooks.length > 10) {
      mostViewedBooks.value = mostViewedBooks.sublist(0, 10);
    }
    
    // الكتب الأكثر تحميلاً
    mostDownloadedBooks.value = List.from(books)
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    if (mostDownloadedBooks.length > 10) {
      mostDownloadedBooks.value = mostDownloadedBooks.sublist(0, 10);
    }
    
    // الكتب الأكثر إعجاباً
    mostLikedBooks.value = List.from(books)
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    if (mostLikedBooks.length > 10) {
      mostLikedBooks.value = mostLikedBooks.sublist(0, 10);
    }
    
    // الكتب المحفوظة
    savedBooks.value = books.where((book) => book.isSaved.value).toList();
  }
  
  // تحديث بيانات المكتبة
  Future<void> refreshLibraryData() async {
    await loadLibraryData();
  }
  
  // اختيار تصنيف
  void selectCategory(Category? category) {
    selectedCategory.value = category;
  }
  
  // الحصول على الكتب حسب التصنيف
  List<Book> getBooksByCategory(int? categoryId) {
    if (categoryId == null) {
      return books;
    }
    
    return books.where((book) => book.categoryId == categoryId).toList();
  }
  
  // الإعجاب بكتاب
  Future<void> toggleLikeBook(Book book) async {
    try {
      // تحديث حالة الإعجاب محلياً
      book.isLiked.value = !book.isLiked.value;
      
      // تحديث في السيرفر
      await _repository.toggleLikeBook(book.id);
      
      // تحديث BookInfo
      final bookInfo = bookInfos.firstWhereOrNull((info) => info.bookId == book.id);
      if (bookInfo != null) {
        final index = bookInfos.indexOf(bookInfo);
        bookInfos[index] = bookInfo.copyWithToggleLike();
      } else {
        // إنشاء معلومات جديدة إذا لم تكن موجودة
        final newBookInfo = BookInfo(
          id: 0, // سيتم تحديثه من السيرفر
          bookId: book.id,
          userId: 0, // سيتم تحديثه من السيرفر
          likes: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bookInfos.add(newBookInfo);
      }
      
      // حفظ البيانات محلياً
      await _saveDataToLocalStorage();
      
      // تحديث القوائم المميزة
      _updateFeaturedLists();
    } catch (e) {
      // إعادة الحالة في حالة الفشل
      book.isLiked.value = !book.isLiked.value;
      throw Exception('فشل في تحديث حالة الإعجاب. يرجى المحاولة مرة أخرى.');
    }
  }
  
  // حفظ كتاب
  Future<void> toggleSaveBook(Book book) async {
    try {
      // تحديث حالة الحفظ محلياً
      book.isSaved.value = !book.isSaved.value;
      
      // تحديث في السيرفر
      await _repository.toggleSaveBook(book.id);
      
      // تحديث BookInfo
      final bookInfo = bookInfos.firstWhereOrNull((info) => info.bookId == book.id);
      if (bookInfo != null) {
        final index = bookInfos.indexOf(bookInfo);
        bookInfos[index] = bookInfo.copyWithToggleSave();
      } else {
        // إنشاء معلومات جديدة إذا لم تكن موجودة
        final newBookInfo = BookInfo(
          id: 0, // سيتم تحديثه من السيرفر
          bookId: book.id,
          userId: 0, // سيتم تحديثه من السيرفر
          save: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bookInfos.add(newBookInfo);
      }
      
      // حفظ البيانات محلياً
      await _saveDataToLocalStorage();
      
      // تحديث القوائم المميزة
      _updateFeaturedLists();
    } catch (e) {
      // إعادة الحالة في حالة الفشل
      book.isSaved.value = !book.isSaved.value;
      throw Exception('فشل في تحديث حالة الحفظ. يرجى المحاولة مرة أخرى.');
    }
  }
  
  // تحميل كتاب
  Future<void> downloadBook(Book book) async {
    try {
      // تحديث حالة التحميل محلياً
      book.isDownloaded.value = true;
      
      // تحديث في السيرفر
      await _repository.downloadBook(book.id);
      
      // تحديث BookInfo
      final bookInfo = bookInfos.firstWhereOrNull((info) => info.bookId == book.id);
      if (bookInfo != null) {
        final index = bookInfos.indexOf(bookInfo);
        bookInfos[index] = bookInfo.copyWithIncrementDownloads();
      } else {
        // إنشاء معلومات جديدة إذا لم تكن موجودة
        final newBookInfo = BookInfo(
          id: 0, // سيتم تحديثه من السيرفر
          bookId: book.id,
          userId: 0, // سيتم تحديثه من السيرفر
          downloads: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bookInfos.add(newBookInfo);
      }
      
      // حفظ البيانات محلياً
      await _saveDataToLocalStorage();
      
      // تحديث القوائم المميزة
      _updateFeaturedLists();
    } catch (e) {
      throw Exception('فشل في تحميل الكتاب. يرجى المحاولة مرة أخرى.');
    }
  }
  
  // فتح كتاب
  Future<void> openBook(Book book) async {
    try {
      // تحديث حالة الفتح محلياً
      book.isOpened.value = true;
      
      // تحديث في السيرفر
      await _repository.openBook(book.id);
      
      // تحديث BookInfo
      final bookInfo = bookInfos.firstWhereOrNull((info) => info.bookId == book.id);
      if (bookInfo != null) {
        final index = bookInfos.indexOf(bookInfo);
        bookInfos[index] = bookInfo.copyWithIncrementOpens();
      } else {
        // إنشاء معلومات جديدة إذا لم تكن موجودة
        final newBookInfo = BookInfo(
          id: 0, // سيتم تحديثه من السيرفر
          bookId: book.id,
          userId: 0, // سيتم تحديثه من السيرفر
          opensCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bookInfos.add(newBookInfo);
      }
      
      // حفظ البيانات محلياً
      await _saveDataToLocalStorage();
      
      // تحديث القوائم المميزة
      _updateFeaturedLists();
    } catch (e) {
      throw Exception('فشل في فتح الكتاب. يرجى المحاولة مرة أخرى.');
    }
  }
  
  // تحميل حالة الوضع المظلم
  void _loadDarkModeState() {
    final darkMode = _storageService.read<bool>('dark_mode');
    if (darkMode != null) {
      isDarkMode.value = darkMode;
    }
  }
  
  // تبديل الوضع المظلم
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    _storageService.write('dark_mode', isDarkMode.value);
  }
}
