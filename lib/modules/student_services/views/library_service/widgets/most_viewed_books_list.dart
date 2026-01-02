import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../book_model.dart';
import 'horizontal_book_card.dart';

class MostViewedBooksList extends StatelessWidget {
  final RxList<Book> books;
  final String emptyMessage;
  final double height;
  final bool isdarkMode;
  MostViewedBooksList({
    Key? key,
    required this.books,
    this.emptyMessage = 'لا توجد كتب مشاهدة حتى الآن',
    this.height = 160,
    required this.isdarkMode,
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
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
      final HomeController _homeController = Get.find<HomeController>();

    switch (index) {
      case 0:
        return Colors.amber; // ذهبي للمركز الأول
      case 1:
        return Colors.blueGrey; // فضي للمركز الثاني
      case 2:
        return Colors.brown; // برونزي للمركز الثالث
      default:
        return _homeController.getPrimaryColor();
    }
  }
}
