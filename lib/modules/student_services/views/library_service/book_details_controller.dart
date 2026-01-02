import 'package:get/get.dart';
import '../../../posts/views/widgets/media_preview.dart';
import 'book_model.dart';
import 'package:student_app/modules/posts/controllers/media_preview_controller.dart';
import 'package:student_app/modules/posts/models/post_model.dart';

class BookDetailsController extends GetxController {
  final Rx<Book?> selectedBook = Rx<Book?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // متحكم عرض الوسائط
  final MediaPreviewController mediaPreviewController = MediaPreviewController();
  
  // تعيين الكتاب المحدد
  void setSelectedBook(Book book) {
    selectedBook.value = book;
  }
  
  // تحويل الكتاب إلى منشور لاستخدامه مع MediaPreview
  Post convertBookToPost(Book book) {
    return Post(
      userImage: '',
      id: book.id,
      senderId: book.addedBy,
      userName: book.addedByName ?? 'مستخدم',
      content: book.description,
      fileUrl: book.fileUrl,
      fileType: _mapFileTypeToPostFileType(book.fileType),
      fileSize: book.fileSize,
      createdAt: book.createdAt.toIso8601String(),
      updatedAt: book.updatedAt.toIso8601String(),
      likesCount: book.likesCount,
      commentsCount: 0,
      viewsCount: book.opensCount,
      isLiked: book.isLiked.value,
      isSaved: book.isSaved.value, isDeleted: book.isActive, hasMedia: true,
    );
  }
  
  // تحويل نوع ملف الكتاب إلى نوع ملف المنشور
  String _mapFileTypeToPostFileType(String bookFileType) {
    switch (bookFileType) {
      case 'PDF':
        return 'pdf';
      case 'Microsoft Word':
        return 'doc';
      case 'Microsoft Excel':
        return 'xls';
      case 'PowerPoint':
        return 'ppt';
      case 'Text Files':
        return 'txt';
      case 'Programming Files':
        return 'code';
      case 'Executable Files':
        return 'exe';
      case 'Database Files':
        return 'db';
      default:
        return 'file';
    }
  }
  
  // فتح الكتاب باستخدام MediaPreview
  Future<void> openBookWithMediaPreview(Book book) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // تحويل الكتاب إلى منشور
      final post = convertBookToPost(book);
      
      // تعيين المنشور في متحكم عرض الوسائط
      mediaPreviewController.setPost(post);
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'فشل في فتح الكتاب. يرجى المحاولة مرة أخرى.';
    }
  }
  
  // تحميل الكتاب باستخدام MediaPreview
  Future<void> downloadBookWithMediaPreview(Book book) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // تحويل الكتاب إلى منشور
      final post = convertBookToPost(book);
      
      // تحميل الملف
      await MediaPreview.downloadFile(post);
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'فشل في تحميل الكتاب. يرجى المحاولة مرة أخرى.';
    }
  }
  
  @override
  void onClose() {
    mediaPreviewController.dispose();
    super.onClose();
  }
}
