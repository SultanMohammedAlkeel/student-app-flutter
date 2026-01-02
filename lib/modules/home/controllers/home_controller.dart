import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Import Material for PageController
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:student_app/app/routes/app_pages.dart';
import 'package:student_app/core/services/api_url_service.dart';
import 'package:student_app/core/services/auth_service.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/core/network/api_service.dart';
import 'package:student_app/core/services/theme_service.dart';
import 'package:student_app/core/network/profile_service.dart';
import 'package:student_app/core/themes/app_theme.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isDarkMode = false.obs;
  final RxMap<String, dynamic> userData = RxMap();
  final RxMap<String, dynamic> studentData = RxMap();
  final Rx<Uint8List?> cachedImage = Rx<Uint8List?>(null);
  final ImagePicker _picker = ImagePicker();
  final StorageService _storage = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final ProfileService _profileService = Get.find<ProfileService>();
    final ApiUrlService _apiUrlService = Get.find<ApiUrlService>();

  // final baseUrl = 'http://192.168.1.9:8000/';
  final AppThemeService _appThemeService = Get.find<AppThemeService>( );

  // أضف PageController هنا
  late PageController pageController;

  Color getPrimaryColor() {
    return _appThemeService.primaryColor;
  }

  Color getSecondaryColor() {
    return _appThemeService.secondaryColor;
  }

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    // تهيئة PageController
    pageController = PageController(initialPage: currentIndex.value);
    // isDarkMode.value = ThemeService().theme == ThemeMode.dark;
    _loadCachedImage();
  }

  @override
  void onClose() {
    pageController.dispose(); // تخلص من PageController عند إغلاق المتحكم
    super.onClose();
  }

  Future<void> _loadCachedImage() async {
    try {
      // 1. التحقق من وجود صورة في التخزين الدائم
      final imagePath = await _storage.read<String>('profile_image_path');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          cachedImage.value = bytes;
          return;
        }
      }

      // 2. إذا لم توجد صورة محلية، جلبها من السيرفر
      if (userData['image_url'] != null) {
        await downloadAndCacheImage(userData['image_url']);
      }
    } catch (e) {
      print('Error loading cached image: $e');
    }
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

      // تحميل البيانات من التخزين المحلي أولاً
      final localUser = await _storage.read<Map<String, dynamic>>('user_data');
      final localStudent =
          await _storage.read<Map<String, dynamic>>('student_data');

      if (localUser != null) {
        userData.assignAll(localUser);
      }

      if (localStudent != null) {
        studentData.assignAll(localStudent);
      }

      // جلب البيانات المحدثة من السيرفر
      final result = await _profileService.getCurrentUser();
      if (result['success'] == true) {
        userData.assignAll(result['user']);
        studentData.assignAll(result['student']);

        // تحميل الصورة من السيرفر إذا لم تكن موجودة محلياً
        if (cachedImage.value == null && userData['image_url'] != null) {
          await downloadAndCacheImage(userData['image_url']);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> downloadAndCacheImage(String imageUrl) async {
  //   try {
  //     // استخدم Dio مباشرة مع الرابط الكامل
  //     final dio = Dio();
  //     final response = await dio.get(
  //       'http://192.168.1.9:8000/$imageUrl', // أضف الرابط الأساسي يدوياً
  //       options: Options(responseType: ResponseType.bytes ),
  //     );

  //     if (response.statusCode == 200) {
  //       await cacheImage(response.data);
  //     }
  //   } catch (e) {
  //     print('Error downloading image: $e');
  //   }
  // }
  Future<void> downloadAndCacheImage(String imageUrl) async {
    try {
      // استخدم الخدمة الجديدة للحصول على الرابط الكامل
      final fullImageUrl = _apiUrlService.getImageUrl(imageUrl);
      
      final dio = Dio();
      final response = await dio.get(
        fullImageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        await cacheImage(response.data);
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
  Future<void> cacheImage(Uint8List imageBytes) async {
    try {
      // 1. حفظ الصورة في التخزين الدائم للتطبيق
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/profile_image.jpg');
      await file.writeAsBytes(imageBytes);

      // 2. حفظ المسار في SharedPreferences
      await _storage.write('profile_image_path', file.path);

      // 3. تحديث حالة التطبيق
      cachedImage.value = imageBytes;
    } catch (e) {
      print('Error caching image: $e');
      rethrow;
    }
  }

  // تعديل دالة changePage لاستخدام PageController
  void changePage(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  Future<void> logout() async {
    await AuthService
        .clearAuthData(); // استدعاء دالة تسجيل الخروج الرئيسية من AuthService
    await AuthService
        .clearStudentData(); // استدعاء دالة تسجيل الخروج الرئيسية من AuthService
    // مسح أي بيانات إضافية مخزنة محليًا هنا إذا لم يتم مسحها بواسطة AuthService
    // _storage.remove('cached_profile_image');
    // _storage.remove('profile_image_path');
    // _storage.remove('user_data'); // تأكد من مسحها هنا أو في AuthService.clearAuthData()
    // _storage.remove('student_data'); // تأكد من مسحها هنا أو في AuthService.clearAuthData()

    // توجيه المستخدم إلى صفحة تسجيل الدخول ومسح جميع الصفحات السابقة
    Get.offAllNamed(AppRoutes.login);
    Get.reload();
  }

  Future<void> changeProfileImage() async {
    final result = await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر مصدر الصورة', style: Get.textTheme.headlineLarge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceButton(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  source: ImageSource.camera,
                ),
                _buildImageSourceButton(
                  icon: Icons.photo_library,
                  label: 'المعرض',
                  source: ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _handleImageSelection(result);
    }
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Get.back(result: source),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Get.theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Get.theme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        isImageUploading.value = true;

        // عرض مؤشر التحميل
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          barrierDismissible: false,
        );

        final bytes = await image.readAsBytes();
        final tempFile = await _createTempFile(bytes);

        final result = await _profileService.uploadProfileImage(file: tempFile);

        Get.back(); // إغلاق مؤشر التحميل

        if (result['success'] == true) {
          cachedImage.value = bytes;
          userData.assignAll(result['user']);
          await cacheImage(bytes);

          Get.snackbar(
            'نجح',
            result['message'],
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'خطأ',
            result['message'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // إغلاق مؤشر التحميل
      }
      Get.snackbar('خطأ', 'فشل في اختيار الصورة: ${e.toString()}');
    } finally {
      isImageUploading.value = false;
    }
  }

  Future<bool> uploadProfileImage(Uint8List imageBytes) async {
    try {
      final tempFile = await _createTempFile(imageBytes);
      final result = await _profileService.uploadProfileImage(file: tempFile);

      if (result['success'] == true) {
        await cacheImage(imageBytes); // حفظ محلي
        cachedImage.value = imageBytes; // تحديث القيمة المخزنة
        userData.assignAll(result['user']); // تحديث بيانات المستخدم
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _createTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String?> getProfileImage() async {
    return await _storage.read<String>('profile_image_url');
  }

  void showFullScreenImage(Uint8List imageBytes) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        body: Center(
          child: PhotoView(
            imageProvider: MemoryImage(imageBytes),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
      ),
    );
  }

  void getData() {
    _apiService.get('user-data').then((response) {
      if (response.statusCode == 200) {
        userData.assignAll(response.data);
        _loadCachedImage(); // تحميل الصورة بعد تحديث البيانات
      } else {
        Get.snackbar('خطأ', 'فشل في جلب البيانات');
      }
    }).catchError((error) {
      Get.snackbar('خطأ', 'حدث خطأ: $error');
    });
  }

  /// تحديث البيانات
  Future<void> refreshData() async {
    await loadUserData();
  }

  /// تحديث البيانات الأساسية
  Future<void> updateBasicInfo({
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final result = await _profileService.updateProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        userData.assignAll(result['user']);
        Get.snackbar(
          'نجح',
          result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث البيانات: ${e.toString()}');
    }
  }

  /// تحديث معلومات التواصل
  Future<void> updateContactInfo({
    String? email,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final result = await _profileService.updateContactInfo(
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      );

      if (result['success'] == true) {
        userData.assignAll(result['user']);
        Get.snackbar(
          'نجح',
          result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث معلومات التواصل: ${e.toString()}');
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final result = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      if (result['success'] == true) {
        Get.snackbar(
          'نجح',
          result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (result['requires_relogin'] == true) {
          // إعادة توجيه لصفحة تسجيل الدخول
          logout();
        }
      } else {
        Get.snackbar(
          'خطأ',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تغيير كلمة المرور: ${e.toString()}');
    }
  }
}
