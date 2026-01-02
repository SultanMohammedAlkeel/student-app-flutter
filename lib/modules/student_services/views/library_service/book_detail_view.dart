import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/posts/views/widgets/media_preview.dart';
import 'book_model.dart';
import 'book_details_controller.dart';
import 'library_controller.dart';

class BookDetailView extends StatelessWidget {
  final BookDetailsController controller = Get.find<BookDetailsController>();
  final LibraryController libraryController = Get.find<LibraryController>();

  BookDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الكتاب'),
        backgroundColor: homeController.getPrimaryColor(),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final book = controller.selectedBook.value;

        if (book == null) {
          return const Center(child: Text('لم يتم العثور على الكتاب'));
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('العودة'),
                ),
              ],
            ),
          );
        }
        return Container(
          color: AppColors.lightBackground,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الكتاب أو أيقونة نوع الملف
                Container(
                  width: double.infinity,
                  height: 200,
                  color: homeController.getPrimaryColor().withOpacity(0.1),
                  child: Center(
                    child: Image.asset(
                      book.getFileIcon(),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                // معلومات الكتاب
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان الكتاب
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // المؤلف
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // نوع الملف وحجمه
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.grey),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: homeController
                                  .getPrimaryColor()
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              book.fileType,
                              style: TextStyle(
                                color: homeController.getPrimaryColor(),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            book.getFormattedFileSize(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // التصنيف
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            book.categoryName ?? 'غير مصنف',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // الكلية والقسم (إذا كانت متاحة)
                      if (book.collegeName != null)
                        Row(
                          children: [
                            const Icon(Icons.school, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '${book.collegeName}${book.departmentName != null ? ' - ${book.departmentName}' : ''}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      if (book.collegeName != null) const SizedBox(height: 8),

                      // المستوى (إذا كان متاحاً)
                      if (book.level != null)
                        Row(
                          children: [
                            const Icon(Icons.layers, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              book.level!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      if (book.level != null) const SizedBox(height: 8),

                      // تاريخ الإضافة
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'تمت الإضافة في ${_formatDate(book.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // إحصائيات الكتاب
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.remove_red_eye, 'المشاهدات',
                                book.opensCount.toString()),
                            _buildStatItem(Icons.download, 'التحميلات',
                                book.downloadCount.toString()),
                            _buildStatItem(Icons.favorite, 'الإعجابات',
                                book.likesCount.toString()),
                            _buildStatItem(Icons.bookmark, 'الحفظ',
                                book.saveCount.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // الوصف
                      const Text(
                        'الوصف',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.description.isEmpty
                            ? 'لا يوجد وصف متاح'
                            : book.description,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // معاينة الملف
                      const Text(
                        'معاينة الملف',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMediaPreview(book),
                      const SizedBox(height: 32),

                      // أزرار التفاعل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            Icons.favorite,
                            book.isLiked.value ? Colors.red : Colors.grey,
                            'إعجاب',
                            () => libraryController.toggleLikeBook(book),
                          ),
                          _buildActionButton(
                            Icons.bookmark,
                            book.isSaved.value
                                ? homeController.getPrimaryColor()
                                : Colors.grey,
                            'حفظ',
                            () => libraryController.toggleSaveBook(book),
                          ),
                          _buildActionButton(
                            Icons.download,
                            Colors.green,
                            'تحميل',
                            () => _downloadBook(book),
                          ),
                          _buildActionButton(
                            Icons.visibility,
                            Colors.blue,
                            'فتح',
                            () => _openBook(book),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String count) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(Book book) {
    // تحويل الكتاب إلى منشور لاستخدامه مع MediaPreview
    final post = controller.convertBookToPost(book);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: MediaPreview(
        post: post,
        showControls: true,
        autoPlay: false,
      ),
    );
  }

  void _downloadBook(Book book) async {
    try {
      // تسجيل التحميل
      await libraryController.downloadBook(book);

      // تحميل الكتاب باستخدام MediaPreview
      await controller.downloadBookWithMediaPreview(book);

      Get.snackbar(
        'تم التحميل بنجاح',
        'تم تحميل الكتاب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الكتاب. يرجى المحاولة مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _openBook(Book book) async {
    try {
      // تسجيل الفتح
      await libraryController.openBook(book);

      // فتح الكتاب باستخدام MediaPreview
      await controller.openBookWithMediaPreview(book);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في فتح الكتاب. يرجى المحاولة مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'اليوم';
    } else if (difference.inDays < 2) {
      return 'الأمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} أشهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنوات';
    }
  }
}
