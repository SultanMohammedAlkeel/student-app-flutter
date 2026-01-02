import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../library_search_controller.dart';

class LibrarySearchBar extends StatelessWidget {
  final LibrarySearchController searchController;
  final VoidCallback onSearch;
  final bool showFilterButton;
  final bool autoSearch;

  const LibrarySearchBar({
    Key? key,
    required this.searchController,
    required this.onSearch,
    this.showFilterButton = true,
    this.autoSearch = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color:
            Get.isDarkMode ? AppColors.darkDivider : AppColors.backgrounColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة البحث
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),

          // حقل البحث
          Expanded(
            child: TextField(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                fillColor: Get.isDarkMode
                    ? AppColors.darkDivider
                    : AppColors.backgrounColor,
                hintText: 'ابحث عن كتاب، مؤلف، أو تصنيف...',
                hintTextDirection: TextDirection.rtl,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) {
                // استخدام الدالة المعدلة التي لا تغير حالة البحث
                searchController.setSearchQueryWithoutStateChange(value);

                // إذا كان البحث التلقائي مفعلاً، نقوم بالبحث بعد كل تغيير
                if (autoSearch && value.isNotEmpty) {
                  onSearch();
                } else if (value.isEmpty) {
                  searchController.cancelSearch();
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  onSearch();
                }
              },
              // الاحتفاظ بالتركيز على حقل البحث
              autofocus: searchController.isSearching.value,
            ),
          ),

          // زر الفلتر
          if (showFilterButton)
            InkWell(
              onTap: _showFilterDialog,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: homeController.getPrimaryColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Get.isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.backgrounColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تصفية البحث',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // فلتر نوع الملف
              const Text(
                'نوع الملف:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFileTypeFilter(),
              const SizedBox(height: 16),

              // فلتر نوع الكتاب
              const Text(
                'نوع الكتاب:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildBookTypeFilter(),
              const SizedBox(height: 16),

              // فلتر التصنيف
              const Text(
                'التصنيف:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildCategoryFilter(),
              const SizedBox(height: 24),

              // أزرار التطبيق وإعادة التعيين
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      searchController.resetFilters();
                      Get.back();
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onSearch();
                      Get.back();
                    },
                    child: const Text('تطبيق'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeFilter() {
    HomeController homeController = Get.find<HomeController>();

    final fileTypes = [
      'PDF',
      'Microsoft Word',
      'Microsoft Excel',
      'PowerPoint',
      'Text Files',
      'Programming Files',
      'Executable Files',
      'Database Files',
    ];

    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fileTypes.map((type) {
            final isSelected = searchController.selectedFileType.value == type;
            return InkWell(
              onTap: () {
                if (isSelected) {
                  searchController.selectedFileType.value = '';
                } else {
                  searchController.selectedFileType.value = type;
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? homeController.getPrimaryColor()
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildBookTypeFilter() {
    final bookTypes = ['عام', 'خاص', 'مشترك', 'محدد'];
    HomeController homeController = Get.find<HomeController>();

    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bookTypes.map((type) {
            final isSelected = searchController.selectedBookType.value == type;
            return InkWell(
              onTap: () {
                if (isSelected) {
                  searchController.selectedBookType.value = '';
                } else {
                  searchController.selectedBookType.value = type;
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? homeController.getPrimaryColor()
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildCategoryFilter() {
    // هنا يمكن استخدام قائمة التصنيفات من المتحكم الرئيسي
    // لكن لأغراض التبسيط، سنستخدم قائمة ثابتة
    final categories = [
      {'id': 1, 'name': 'علوم الحاسوب'},
      {'id': 2, 'name': 'الهندسة'},
      {'id': 3, 'name': 'الطب'},
      {'id': 4, 'name': 'العلوم'},
      {'id': 5, 'name': 'الأدب'},
    ];
    HomeController homeController = Get.find<HomeController>();

    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final id = category['id'] as int;
            final name = category['name'] as String;
            final isSelected = searchController.selectedCategoryId.value == id;
            return InkWell(
              onTap: () {
                if (isSelected) {
                  searchController.selectedCategoryId.value = 0;
                } else {
                  searchController.selectedCategoryId.value = id;
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? homeController.getPrimaryColor()
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}
