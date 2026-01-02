import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'book_model.dart';
import 'library_controller.dart';

class ViewMoreBooksView extends StatefulWidget {
  final String title;
  final List<Book> books;
  final bool isDarkMode;
  final String type; // 'most_viewed' أو 'most_downloaded'

  const ViewMoreBooksView({
    Key? key,
    required this.title,
    required this.books,
    required this.isDarkMode,
    required this.type,
  }) : super(key: key);

  @override
  State<ViewMoreBooksView> createState() => _ViewMoreBooksViewState();
}

class _ViewMoreBooksViewState extends State<ViewMoreBooksView> {
  HomeController homeController = Get.find<HomeController>();

  late List<Book> displayedBooks;
  String sortBy = 'default'; // default, title, author, date
  bool ascending = false;
  String? selectedCategory;
  String? selectedFileType;

  final LibraryController controller = Get.find<LibraryController>();

  @override
  void initState() {
    super.initState();
    displayedBooks = List.from(widget.books);
    _applySortingByType();
  }

  void _applySortingByType() {
    // تطبيق الترتيب الافتراضي حسب نوع القائمة
    if (widget.type == 'most_viewed') {
      displayedBooks.sort((a, b) => b.opensCount.compareTo(a.opensCount));
    } else if (widget.type == 'most_downloaded') {
      displayedBooks.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    }
  }

  void _applySorting() {
    switch (sortBy) {
      case 'title':
        displayedBooks.sort((a, b) => ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'author':
        displayedBooks.sort((a, b) => ascending
            ? a.author.compareTo(b.author)
            : b.author.compareTo(a.author));
        break;
      case 'date':
        displayedBooks.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'default':
        _applySortingByType();
        break;
    }
  }

  void _applyFilters() {
    displayedBooks = widget.books.where((book) {
      bool matchesCategory =
          selectedCategory == null || book.categoryName == selectedCategory;
      bool matchesFileType =
          selectedFileType == null || book.fileType == selectedFileType;
      return matchesCategory && matchesFileType;
    }).toList();

    _applySorting();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(widget.isDarkMode);
    final cardColor = _getCardColor(widget.isDarkMode);
    final textColor = _getTextColor(widget.isDarkMode);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(textColor, cardColor),
            _buildFilterBar(textColor, cardColor),
            Expanded(
              child: displayedBooks.isEmpty
                  ? _buildEmptyState()
                  : _buildBooksList(textColor, cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color textColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.circle(),
              depth: 3,
              intensity: 1,
              color: cardColor,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: homeController.getPrimaryColor(),
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: NeumorphicText(
              widget.title,
              style: NeumorphicStyle(
                depth: 3,
                intensity: 1,
                color: textColor,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(Color textColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                depth: 3,
                intensity: 1,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                color: cardColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ترتيب حسب: ${_getSortByText()}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: homeController.getPrimaryColor(),
                    size: 18,
                  ),
                ],
              ),
              onPressed: _showSortOptions,
            ),
          ),
          const SizedBox(width: 12),
          NeumorphicButton(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.circle(),
              depth: 3,
              intensity: 1,
              color: cardColor,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.filter_list,
              color: homeController.getPrimaryColor(),
              size: 20,
            ),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(Color textColor, Color cardColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: displayedBooks.length,
      itemBuilder: (context, index) {
        final book = displayedBooks[index];
        return _buildBookCard(book, textColor, cardColor);
      },
    );
  }

  Widget _buildBookCard(Book book, Color textColor, Color cardColor) {
    return GestureDetector(
      onTap: () => _showBookDetails(book),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: 3,
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          color: cardColor,
          lightSource: LightSource.topLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة الكتاب أو أيقونة نوع الملف
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: homeController.getSecondaryColor().withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(
                    _getFileIcon(book.fileType),
                    size: 48,
                    color: homeController.getPrimaryColor(),
                  ),
                ),
              ),
            ),
            // معلومات الكتاب
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          widget.type == 'most_viewed'
                              ? Icons.visibility
                              : Icons.download,
                          size: 14,
                          color: homeController.getPrimaryColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.type == 'most_viewed'
                              ? '${book.opensCount} مشاهدة'
                              : '${book.downloadCount} تحميل',
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: widget.isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد كتب متطابقة مع الفلاتر المحددة',
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    final textColor = _getTextColor(widget.isDarkMode);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(widget.isDarkMode),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ترتيب حسب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('default', 'الافتراضي', textColor),
            _buildSortOption('title', 'العنوان', textColor),
            _buildSortOption('author', 'المؤلف', textColor),
            _buildSortOption('date', 'تاريخ الإضافة', textColor),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ترتيب تصاعدي',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Switch(
                  value: ascending,
                  onChanged: (value) {
                    setState(() {
                      ascending = value;
                      _applySorting();
                    });
                    Get.back();
                  },
                  activeColor: homeController.getPrimaryColor(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, Color textColor) {
    return InkWell(
      onTap: () {
        setState(() {
          sortBy = value;
          _applySorting();
        });
        Get.back();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            if (sortBy == value)
              Icon(
                Icons.check_circle,
                color: homeController.getPrimaryColor(),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    final textColor = _getTextColor(widget.isDarkMode);

    // استخراج التصنيفات وأنواع الملفات الفريدة
    final categories = widget.books
        .map((book) => book.categoryName)
        .where((category) => category != null)
        .toSet()
        .toList();

    final fileTypes =
        widget.books.map((book) => book.fileType).toSet().toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardColor(widget.isDarkMode),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // تصفية حسب التصنيف
            Text(
              'التصنيف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(
                    'الكل',
                    selectedCategory == null,
                    () {
                      setState(() {
                        selectedCategory = null;
                        _applyFilters();
                      });
                    },
                  ),
                  ...categories.map((category) => _buildFilterChip(
                        category!,
                        selectedCategory == category,
                        () {
                          setState(() {
                            selectedCategory = category;
                            _applyFilters();
                          });
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // تصفية حسب نوع الملف
            Text(
              'نوع الملف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(
                    'الكل',
                    selectedFileType == null,
                    () {
                      setState(() {
                        selectedFileType = null;
                        _applyFilters();
                      });
                    },
                  ),
                  ...fileTypes.map((fileType) => _buildFilterChip(
                        fileType,
                        selectedFileType == fileType,
                        () {
                          setState(() {
                            selectedFileType = fileType;
                            _applyFilters();
                          });
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // زر إعادة تعيين الفلاتر
            Center(
              child: NeumorphicButton(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  depth: 3,
                  intensity: 1,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  color: homeController.getPrimaryColor(),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: const Text(
                  'إعادة تعيين الفلاتر',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                    selectedFileType = null;
                    _applyFilters();
                  });
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () {
          onTap();
          Get.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? homeController.getPrimaryColor()
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? homeController.getPrimaryColor() : Colors.grey,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? Colors.white : _getTextColor(widget.isDarkMode),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showBookDetails(Book book) {
    // تحويل الكتاب إلى منشور لاستخدامه مع MediaPreview
    final post = controller.convertBookToPost(book);

    // فتح MediaPreview لعرض الكتاب
    Get.toNamed('/media_preview', arguments: {
      'post': post,
      'onLike': () => controller.toggleLikeBook(book),
      'onSave': () => controller.toggleSaveBook(book),
      'onDownload': () => controller.downloadBook(book),
      'onOpen': () => controller.openBook(book),
    });
  }

  String _getSortByText() {
    switch (sortBy) {
      case 'title':
        return 'العنوان';
      case 'author':
        return 'المؤلف';
      case 'date':
        return 'تاريخ الإضافة';
      case 'default':
      default:
        return 'الافتراضي';
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Microsoft Word':
        return Icons.description;
      case 'Microsoft Excel':
        return Icons.table_chart;
      case 'PowerPoint':
        return Icons.slideshow;
      case 'Text Files':
        return Icons.text_snippet;
      case 'Programming Files':
        return Icons.code;
      case 'Executable Files':
        return Icons.settings;
      case 'Database Files':
        return Icons.storage;
      default:
        return Icons.insert_drive_file;
    }
  }

  // دوال مساعدة
  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : const Color(0xFF333333);
  }
}
