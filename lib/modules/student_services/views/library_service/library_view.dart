import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import '../../../posts/views/widgets/media_preview.dart';
import 'book_details_controller.dart';
import 'book_model.dart';
import 'book_upload_view.dart';
import 'category_model.dart';
import 'library_controller.dart';
import 'library_search_controller.dart';
import 'widgets/library_search_bar.dart';
import 'widgets/horizontal_book_card.dart';
import 'widgets/vertical_book_card.dart';
import 'widgets/category_card.dart';
import 'widgets/most_viewed_books_list.dart';
import 'widgets/most_downloaded_books_list.dart';
import 'view_more_books_view.dart';

class LibraryView extends StatelessWidget {
  final LibraryController controller = Get.find<LibraryController>();
  final LibrarySearchController searchController =
      Get.put(LibrarySearchController());
  final BookDetailsController bookController = Get.put(BookDetailsController());

  LibraryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor = _getBackgroundColor(isDarkMode);
      final cardColor = _getCardColor(isDarkMode);
      final textColor = _getTextColor(isDarkMode);

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // المحتوى الرئيسي
              NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // الرأس
                    SliverToBoxAdapter(
                      child: _buildHeader(
                          isDarkMode, textColor, cardColor, context),
                    ),

                    // شريط البحث
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: LibrarySearchBar(
                          searchController: searchController,
                          onSearch: () =>
                              searchController.search(controller.books),
                          autoSearch: true,
                        ),
                      ),
                    ),

                    // محتوى البحث أو المحتوى الرئيسي
                    if (searchController.isSearching.value)
                      _buildSearchResults(
                          isDarkMode, textColor, cardColor, context)
                    else
                      ..._buildMainContent(
                          isDarkMode, textColor, cardColor, context),
                  ],
                ),
              ),

              // زر الإضافة العائم
              Obx(() => AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    right: 20,
                    bottom: controller.showFloatingButton.value ? 20 : -80,
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: const NeumorphicBoxShape.circle(),
                        depth: 4,
                        intensity: 1,
                        color: homeController.getPrimaryColor(),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => _navigateToBookUpload(context),
                    ),
                  )),
            ],
          ),
        ),
      );
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null) {
        if (notification.scrollDelta! > 0) {
          // التمرير للأسفل - إخفاء الزر
          if (controller.showFloatingButton.value) {
            controller.showFloatingButton.value = false;
          }
        } else if (notification.scrollDelta! < 0) {
          // التمرير للأعلى - إظهار الزر
          if (!controller.showFloatingButton.value) {
            controller.showFloatingButton.value = true;
          }
        }
      }
    } else if (notification is ScrollEndNotification) {
      // عند التوقف عن التمرير في أعلى الصفحة، نظهر الزر
      if (notification.metrics.pixels == 0 &&
          !controller.showFloatingButton.value) {
        controller.showFloatingButton.value = true;
      }
    }
    return false;
  }

  void _navigateToBookUpload(BuildContext context) async {
    final result = await Get.to(() => BookUploadView());
    if (result == true) {
      // تم إضافة كتاب جديد، تحديث البيانات
      controller.refreshLibraryData();
    }
  }

  Widget _buildHeader(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NeumorphicText(
            'المكتبة الإلكترونية',
            style: NeumorphicStyle(
              depth: 3,
              intensity: 1,
              color: textColor,
            ),
            textStyle: NeumorphicTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          // NeumorphicButton(
          //   style: NeumorphicStyle(
          //     shape: NeumorphicShape.flat,
          //     boxShape: const NeumorphicBoxShape.circle(),
          //     depth: 3,
          //     intensity: 1,
          //     color: cardColor,
          //   ),
          //   padding: const EdgeInsets.all(12),
          //   child: Icon(
          //     isDarkMode ? Icons.light_mode : Icons.dark_mode,
          //     color: isDarkMode ? Colors.amber : Colors.blueGrey,
          //     size: 20,
          //   ),
          //   onPressed: () => controller.toggleDarkMode(),
          // ),
        ],
      ),
    );
  }

  List<Widget> _buildMainContent(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return [
      // الكتب الأكثر مشاهدة
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأكثر مشاهدة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => ViewMoreBooksView(
                      title: 'الكتب الأكثر مشاهدة',
                      books: controller.mostViewedBooks,
                      isDarkMode: isDarkMode,
                      type: 'most_viewed',
                    )),
                child: Text(
                  'عرض المزيد',
                  style: TextStyle(
                    color: homeController.getPrimaryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 160,
          child: controller.mostViewedBooks.isEmpty
              ? _buildEmptyState('لا توجد كتب مشاهدة حتى الآن', isDarkMode)
              : MostViewedBooksList(
                  books: controller.mostViewedBooks,
                  isdarkMode: isDarkMode,
                ),
        ),
      ),

      // الكتب الأكثر تحميلاً
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأكثر تحميلاً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => ViewMoreBooksView(
                      title: 'الكتب الأكثر تحميلاً',
                      books: controller.mostDownloadedBooks,
                      isDarkMode: isDarkMode,
                      type: 'most_downloaded',
                    )),
                child: Text(
                  'عرض المزيد',
                  style: TextStyle(
                    color: homeController.getPrimaryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 160,
          child: controller.mostDownloadedBooks.isEmpty
              ? _buildEmptyState('لا توجد كتب تم تحميلها حتى الآن', isDarkMode)
              : MostDownloadedBooksList(
                  books: controller.mostDownloadedBooks,
                  isdarkMode: isDarkMode,
                ),
        ),
      ),
      // التصنيفات
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التصنيفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CategoryCard(
                  category: category,
                  isDarkMode: Get.isDarkMode,
                  isSelected:
                      controller.selectedCategory.value?.id == category.id,
                  onTap: () => controller.selectCategory(
                      controller.selectedCategory.value?.id == category.id
                          ? null
                          : category),
                ),
              );
            },
          ),
        ),
      ),

      // الكتب حسب التصنيف المحدد
      if (controller.selectedCategory.value != null) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'كتب ${controller.selectedCategory.value!.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final books = controller
                    .getBooksByCategory(controller.selectedCategory.value!.id);
                if (books.isEmpty) {
                  return _buildEmptyState(
                      'لا توجد كتب في هذا التصنيف', isDarkMode);
                }
                final book = books[index];
                return VerticalBookCard(
                  book: book,
                  isDarkMode: isDarkMode,
                );
              },
              childCount: controller
                  .getBooksByCategory(controller.selectedCategory.value!.id)
                  .length,
            ),
          ),
        ),
      ],

      // جميع الكتب
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جميع الكتب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: controller.books.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyState('لا توجد كتب متاحة حالياً', isDarkMode),
              )
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = controller.books[index];
                    return VerticalBookCard(
                      book: book,
                      isDarkMode: isDarkMode,
                    );
                  },
                  childCount: controller.books.length,
                ),
              ),
      ),

      // مساحة إضافية في الأسفل
      const SliverToBoxAdapter(
        child: SizedBox(height: 80),
      ),
    ];
  }

  Widget _buildSearchResults(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return searchController.searchResults.isEmpty
        ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: _buildEmptyState('لا توجد نتائج للبحث', isDarkMode),
            ),
          )
        : SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = searchController.searchResults[index];
                  return VerticalBookCard(
                    book: book,
                    isDarkMode: isDarkMode,
                  );
                },
                childCount: searchController.searchResults.length,
              ),
            ),
          );
  }

  Widget _buildEmptyState(String message, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showBookDetails(Book book) {
    // تحويل الكتاب إلى منشور لاستخدامه مع MediaPreview
    final post = controller.convertBookToPost(book);

    // فتح MediaPreview لعرض الكتاب
    Get.to(() => MediaPreview(
          post: post,

          // onLike: () => controller.toggleLikeBook(book),
          // onSave: () => controller.toggleSaveBook(book),
          // onDownload: () => controller.downloadBook(book),
          // onOpen: () => controller.openBook(book),
        ));
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
