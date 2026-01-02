import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../book_model.dart';
import '../book_details_controller.dart';
import '../library_controller.dart';

class HorizontalBookCard extends StatelessWidget {
  final Book book;
  final bool showStats;
  final double height;
  final double width;
  final bool isDarkMode;

  HorizontalBookCard({
    Key? key,
    required this.book,
    required this.isDarkMode,
    this.showStats = true,
    this.height = 140,
    this.width = 300,
  }) : super(key: key);

  final LibraryController libraryController = Get.find<LibraryController>();
  final BookDetailsController bookDetailsController =
      Get.find<BookDetailsController>();

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      margin: EdgeInsets.all(5),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isDarkMode ? -2 : 2,
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
          color:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          lightSource: LightSource.topLeft,
        ),
        child: SizedBox(
          height: height,
          width: width,
          child: Row(
            children: [
              // صورة الكتاب أو أيقونة نوع الملف
              GestureDetector(
                onTap: () => _navigateToDetails(),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    depth: 2,
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(
                      const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    color: homeController.getPrimaryColor().withOpacity(0.1),
                  ),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Image.asset(
                        book.getFileIcon(),
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ),
              // معلومات الكتاب
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // عنوان الكتاب
                      GestureDetector(
                        onTap: () => _navigateToDetails(),
                        child: NeumorphicText(
                          book.title,
                          style: NeumorphicStyle(
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // المؤلف
                      NeumorphicText(
                        book.author,
                        style: NeumorphicStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textStyle: NeumorphicTextStyle(
                          fontSize: 12,
                        ),
                      ),
                      // نوع الملف وحجمه
                      GestureDetector(
                        onTap: () => _navigateToDetails(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  depth: 1,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(10)),
                                  color: homeController
                                      .getPrimaryColor()
                                      .withOpacity(0.1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    book.fileType,
                                    style: TextStyle(
                                      color: homeController.getPrimaryColor(),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                book.getFormattedFileSize(),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // إحصائيات الكتاب
                      if (showStats)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  Icons.remove_red_eye,
                                  book.opensCount.toString(),
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  Icons.download,
                                  book.downloadCount.toString(),
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  Icons.favorite,
                                  book.likesCount.toString(),
                                  color: book.isLiked.value ? Colors.red : null,
                                ),
                                const SizedBox(width: 12),
                                _buildStatItem(
                                  Icons.bookmark,
                                  book.saveCount.toString(),
                                  color: book.isSaved.value
                                      ? homeController.getPrimaryColor()
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, {Color? color}) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 1,
        intensity: 0.6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  color ?? (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails() {
    bookDetailsController.setSelectedBook(book);
    Get.toNamed('/library/book-details/${book.id}');
  }
}
