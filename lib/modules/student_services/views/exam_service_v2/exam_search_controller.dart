import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_controller.dart';
import 'utils/debouncer.dart';

class ExamSearchController extends GetxController {
  // متحكم النص لحقل البحث
  final TextEditingController searchTextController = TextEditingController();
  
  // استعلام البحث الحالي
  final RxString searchQuery = ''.obs;
  
  // حالة البحث التلقائي
  final RxBool autoSearch = true.obs;
  
  // حالة وجود فلاتر نشطة
  final RxBool hasActiveFilters = false.obs;
  
  // مؤقت للبحث بتأخير
  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));
  
  // مرجع لمتحكم الامتحانات
  final ExamController examController = Get.find<ExamController>();
  
  @override
  void onInit() {
    super.onInit();
    // مراقبة تغييرات الفلتر
    ever(examController.currentFilter, (_) {
      _updateHasActiveFilters();
    });
  }
  
  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
  
  // تعيين استعلام البحث وتحديث حقل النص
  void setSearchQuery(String query) {
    searchQuery.value = query;
    
    // تحديث حقل النص مع الحفاظ على موضع المؤشر
    searchTextController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    
    _updateHasActiveFilters();
  }
  
  // تعيين استعلام البحث بدون تغيير حالة حقل النص
  // هذا يحل مشكلة اختفاء الحرف وإخفاء لوحة المفاتيح
  void setSearchQueryWithoutStateChange(String query) {
    searchQuery.value = query;
    _updateHasActiveFilters();
  }
  
  // البحث
  void search() {
    final filter = examController.currentFilter.value.copyWith(
      searchQuery: searchQuery.value,
    );
    examController.applyFilter(filter);
  }
  
  // البحث مع تأخير
  void searchWithDebounce() {
    _debouncer.call(() {
      search();
    });
  }
  
  // مسح البحث
  void clearSearch() {
    setSearchQuery('');
    final filter = examController.currentFilter.value.copyWith(
      searchQuery: null,
    );
    examController.applyFilter(filter);
  }
  
  // تحديث حالة وجود فلاتر نشطة
  void _updateHasActiveFilters() {
    hasActiveFilters.value = searchQuery.value.isNotEmpty || 
                            examController.currentFilter.value.isActive;
  }
}
