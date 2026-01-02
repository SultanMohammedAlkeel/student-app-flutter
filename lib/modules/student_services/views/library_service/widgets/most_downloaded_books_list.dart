import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../book_model.dart';
import 'horizontal_book_card.dart';

class MostDownloadedBooksList extends StatelessWidget {
  final RxList<Book> books;
  final String emptyMessage;
  final double height;
  final bool isdarkMode;

  const MostDownloadedBooksList({
    Key? key,
    required this.books,
    required this.isdarkMode,
    this.emptyMessage = 'لا توجد كتب تم تحميلها حتى الآن',
    this.height = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (books.isEmpty) {
        return SizedBox(
          height: height,
          child: Center(
            child: Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        );
      }

      return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Stack(
              children: [
                HorizontalBookCard(book: book, isDarkMode: isdarkMode),
                if (index < 3)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRankColor(index),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    });
  }

  Color _getRankColor(int index) {
      final HomeController homeController = Get.find<HomeController>();

    switch (index) {
      case 0:
        return Colors.green; // أخضر للمركز الأول
      case 1:
        return Colors.teal; // أزرق مخضر للمركز الثاني
      case 2:
        return Colors.cyan; // سماوي للمركز الثالث
      default:
        return homeController.getPrimaryColor();
    }
  }
}
