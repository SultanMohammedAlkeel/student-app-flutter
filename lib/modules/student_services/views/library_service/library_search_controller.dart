import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'book_model.dart';

class LibrarySearchController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // حالة البحث
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  
  // نتائج البحث
  final RxList<Book> searchResults = <Book>[].obs;
  
  // فلاتر البحث
  final RxString selectedFileType = ''.obs;
  final RxString selectedBookType = ''.obs; // عام، خاص، مشترك، محدد
  final RxInt selectedCollegeId = 0.obs;
  final RxInt selectedDepartmentId = 0.obs;
  final RxString selectedLevel = ''.obs;
  final RxInt selectedCategoryId = 0.obs;
  
  // سجل البحث
  final RxList<String> searchHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }
  
  // تحميل سجل البحث
  void _loadSearchHistory() async {
    final history = await _storageService.read<List<dynamic>>('library_search_history');
    if (history != null) {
      searchHistory.value = history.map((e) => e.toString()).toList();
    }
  }
  
  // حفظ سجل البحث
  void _saveSearchHistory() async {
    await _storageService.write('library_search_history', searchHistory.toList());
  }
  
  // إضافة استعلام إلى سجل البحث
  void addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    // إزالة الاستعلام إذا كان موجوداً بالفعل
    searchHistory.remove(query);
    
    // إضافة الاستعلام في المقدمة
    searchHistory.insert(0, query);
    
    // الاحتفاظ بآخر 10 استعلامات فقط
    if (searchHistory.length > 10) {
      searchHistory.value = searchHistory.sublist(0, 10);
    }
    
    // حفظ سجل البحث
    _saveSearchHistory();
  }
  
  // مسح سجل البحث
  void clearSearchHistory() {
    searchHistory.clear();
    _saveSearchHistory();
  }
  
  // إزالة استعلام من سجل البحث
  void removeFromSearchHistory(String query) {
    searchHistory.remove(query);
    _saveSearchHistory();
  }
  
  // تعيين استعلام البحث بدون تغيير حالة البحث
  // هذه الدالة الجديدة تحل مشكلة اختفاء الحرف وإخفاء لوحة المفاتيح
  void setSearchQueryWithoutStateChange(String query) {
    searchQuery.value = query;
  }
  
  // تعيين استعلام البحث
  void setSearchQuery(String query) {
    searchQuery.value = query;
    if (query.trim().isNotEmpty) {
      isSearching.value = true;
    } else {
      isSearching.value = false;
      searchResults.clear();
    }
  }
  
  // إجراء البحث
  void search(List<Book> allBooks) {
    if (searchQuery.value.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    
    isSearching.value = true;
    
    // إضافة الاستعلام إلى سجل البحث
    addToSearchHistory(searchQuery.value);
    
    // البحث في الكتب
    final query = searchQuery.value.toLowerCase();
    final results = allBooks.where((book) {
      // البحث في العنوان والمؤلف والوصف
      final matchesQuery = book.title.toLowerCase().contains(query) ||
                          book.author.toLowerCase().contains(query) ||
                          book.description.toLowerCase().contains(query);
      
      // تطبيق الفلاتر
      final matchesFileType = selectedFileType.isEmpty || book.fileType == selectedFileType.value;
      final matchesBookType = selectedBookType.isEmpty || book.type == selectedBookType.value;
      final matchesCollege = selectedCollegeId.value == 0 || book.collegeId == selectedCollegeId.value;
      final matchesDepartment = selectedDepartmentId.value == 0 || book.departmentId == selectedDepartmentId.value;
      final matchesLevel = selectedLevel.isEmpty || book.level == selectedLevel.value;
      final matchesCategory = selectedCategoryId.value == 0 || book.categoryId == selectedCategoryId.value;
      
      return matchesQuery && 
             matchesFileType && 
             matchesBookType && 
             matchesCollege && 
             matchesDepartment && 
             matchesLevel && 
             matchesCategory;
    }).toList();
    
    searchResults.value = results;
  }
  
  // تطبيق الفلاتر فقط
  void applyFilters(List<Book> allBooks) {
    // إذا كان هناك استعلام بحث، استخدم دالة البحث
    if (searchQuery.value.trim().isNotEmpty) {
      search(allBooks);
      return;
    }
    
    // تطبيق الفلاتر فقط
    final results = allBooks.where((book) {
      final matchesFileType = selectedFileType.isEmpty || book.fileType == selectedFileType.value;
      final matchesBookType = selectedBookType.isEmpty || book.type == selectedBookType.value;
      final matchesCollege = selectedCollegeId.value == 0 || book.collegeId == selectedCollegeId.value;
      final matchesDepartment = selectedDepartmentId.value == 0 || book.departmentId == selectedDepartmentId.value;
      final matchesLevel = selectedLevel.isEmpty || book.level == selectedLevel.value;
      final matchesCategory = selectedCategoryId.value == 0 || book.categoryId == selectedCategoryId.value;
      
      return matchesFileType && 
             matchesBookType && 
             matchesCollege && 
             matchesDepartment && 
             matchesLevel && 
             matchesCategory;
    }).toList();
    
    searchResults.value = results;
    isSearching.value = true;
  }
  
  // إعادة تعيين الفلاتر
  void resetFilters() {
    selectedFileType.value = '';
    selectedBookType.value = '';
    selectedCollegeId.value = 0;
    selectedDepartmentId.value = 0;
    selectedLevel.value = '';
    selectedCategoryId.value = 0;
  }
  
  // إلغاء البحث
  void cancelSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
    resetFilters();
  }
}
