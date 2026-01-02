import 'package:get/get.dart';

import 'book_details_controller.dart';
import 'library_controller.dart';
import 'library_repository.dart';
import 'library_search_controller.dart';
import 'library_storage_service.dart';
import 'library_sync_service.dart';
import 'book_upload_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    // المستودع
    Get.lazyPut<LibraryRepository>(() => LibraryRepository());
    
    // الخدمات
    Get.lazyPut<LibraryStorageService>(() => LibraryStorageService());
    Get.lazyPut<LibrarySyncService>(() => LibrarySyncService());
    
    // المتحكمات
    Get.lazyPut<LibraryController>(() => LibraryController());
    Get.lazyPut<LibrarySearchController>(() => LibrarySearchController());
    Get.lazyPut<BookDetailsController>(() => BookDetailsController());
    Get.lazyPut<BookUploadController>(() => BookUploadController());
  }
}
