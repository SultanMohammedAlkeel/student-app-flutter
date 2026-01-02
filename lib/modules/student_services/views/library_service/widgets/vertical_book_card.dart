import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../book_model.dart';
import '../book_details_controller.dart';
import '../library_controller.dart';

class VerticalBookCard extends StatelessWidget {
  final Book book;
  final bool showStats;
  final double height;
  final double width;
  final bool isDarkMode;

  VerticalBookCard({
    Key? key,
    required this.book,
    required this.isDarkMode,
    this.showStats = true,
    this.height = 240,
    this.width = 180,
  }) : super(key: key);

  final LibraryController libraryController = Get.find<LibraryController>();
  final BookDetailsController bookDetailsController =
      Get.find<BookDetailsController>();

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      margin: const EdgeInsets.all(0.5),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    color: homeController.getPrimaryColor().withOpacity(0.1),
                  ),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Image.asset(
                        book.getFileIcon(),
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),

              // معلومات الكتاب
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // عنوان الكتاب
                      GestureDetector(
                        onTap: () => _navigateToDetails(),
                        child: Text(
                          book.title,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // المؤلف
                      Text(
                        book.author,
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // نوع الملف وحجمه
                      GestureDetector(
                        onTap: () => _navigateToDetails(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Neumorphic(
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                depth: 1,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(10)),
                                color: homeController
                                    .getPrimaryColor()
                                    .withOpacity(0.08),
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // إحصائيات الكتاب
                      if (showStats)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              book.getFormattedFileSize(),
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            // _buildStatItem(
                            //   Icons.favorite,
                            //   book.likesCount.toString(),
                            // ),
                            // _buildStatItem(
                            //   Icons.remove_red_eye,
                            //   book.opensCount.toString(),
                            // ),
                            // _buildStatItem(
                            //   Icons.download,
                            //   book.downloadCount.toString(),
                            // ),
                          ],
                        ),

                      // أزرار التفاعل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            Icons.remove_red_eye,
                            book.opensCount.toString(),
                          ),
                          const SizedBox(width: 5),
                          _buildStatItem(
                            Icons.download,
                            book.downloadCount.toString(),
                          ),
                          const SizedBox(width: 5),
                          _buildStatItem(
                            Icons.favorite,
                            book.likesCount.toString(),
                            color: book.isLiked.value ? Colors.red : null,
                          ),
                          const SizedBox(width: 5),
                          _buildStatItem(
                            Icons.bookmark,
                            book.saveCount.toString(),
                            color: book.isSaved.value
                                ? homeController.getPrimaryColor()
                                : null,
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
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, {Color? color}) {
    // تحويل النص إلى رقم
    int? number = int.tryParse(count);
    String formattedCount = count; // القيمة الافتراضية

    if (number != null) {
      if (number >= 1000) {
        // إذا كان العدد أكبر من أو يساوي 1000، نعرضه بالآلاف (k)
        double kValue = number / 1000;
        formattedCount =
            '${kValue.toStringAsFixed(kValue.truncateToDouble() == kValue ? 0 : 1)}k';
      } else if (number >= 100) {
        // إذا كان العدد أكبر من أو يساوي 100، نعرضه بالمئات (h)
        double hValue = number / 100;
        formattedCount =
            '${hValue.toStringAsFixed(hValue.truncateToDouble() == hValue ? 0 : 1)}h';
      }
      // إذا كان أقل من 100 نتركه كما هو
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
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
              formattedCount,
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

  Widget _buildActionButton(
      IconData icon, Color? color, VoidCallback onPressed) {
    return NeumorphicButton(
      onPressed: onPressed,
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
        depth: 1,
        intensity: 0.8,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        size: 18,
        color: color ?? (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
      ),
    );
  }

  void _navigateToDetails() {
    bookDetailsController.setSelectedBook(book);
    Get.toNamed('/library/book-details/${book.id}');
  }
}
