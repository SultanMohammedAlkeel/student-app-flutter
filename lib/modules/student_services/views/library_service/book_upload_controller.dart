import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:student_app/core/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:student_app/modules/student_services/views/library_service/library_repository.dart';

import 'category_model.dart';

class BookUploadController extends GetxController {
  final LibraryRepository _repository = Get.find<LibraryRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // حالة التحميل
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // متحكمات حقول الإدخال
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // القيم المحددة
  final RxInt selectedCategoryId = 0.obs;
  final RxInt selectedCollegeId = 0.obs;
  final RxInt selectedDepartmentId = 0.obs;
  final RxString selectedLevel = ''.obs;
  final RxString selectedBookType = 'عام'.obs;

  // الملف المحدد
  final Rx<File?> selectedFile = Rx<File?>(null);

  // بيانات القوائم المنسدلة
  final RxList<Category> categories = <Category>[].obs;
  final RxList<dynamic> colleges = <dynamic>[].obs;
  final RxList<dynamic> departments = <dynamic>[].obs;
  final RxList<String> levels = <String>[
    'المستوى الأول',
    'المستوى الثاني',
    'المستوى الثالث',
    'المستوى الرابع',
    'المستوى الخامس',
  ].obs;

  // الوضع المظلم
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _loadDarkModeState();
    await loadCategories();
    await loadColleges();
  }

  @override
  void onClose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    codeController.dispose();
    super.onClose();
  }

  // تحميل حالة الوضع المظلم
  void _loadDarkModeState() {
    final darkMode = _storageService.read<bool>('dark_mode');
    if (darkMode != null) {
      isDarkMode.value = darkMode;
    }
  }

  // تحميل التصنيفات
 Future<void> loadCategories() async {
  try {
    final List<Category> loadedCategories = await _repository.getCategoriesOnly();
    categories.value = loadedCategories;
    print('Loaded categories: ${categories.length}');
  } catch (e) {
    print('Error loading categories: $e');
    // استخدام بيانات محلية في حالة الفشل
    final localCategories = await _storageService.read<List<dynamic>>('library_categories');
    if (localCategories != null) {
      categories.value = localCategories.map((item) => Category.fromJson(item)).toList();
    }
  }
}
  // تحميل الكليات
  Future<void> loadColleges() async {
    try {
      // يمكن استبدال هذا بدالة فعلية لجلب الكليات من السيرفر
      colleges.value = [
        {'id': 1, 'name': 'كلية الهندسة'},
        {'id': 2, 'name': 'كلية العلوم'},
        {'id': 3, 'name': 'كلية الطب'},
        {'id': 4, 'name': 'كلية الحاسوب وتقنية المعلومات'},
      ];
    } catch (e) {
      // استخدام بيانات محلية في حالة الفشل
    }
  }
// التحقق من صحة البيانات
bool validateData() {
  if (titleController.text.trim().isEmpty) {
    _showError('عنوان الكتاب مطلوب');
    return false;
  }

  if (authorController.text.trim().isEmpty) {
    _showError('اسم المؤلف مطلوب');
    return false;
  }

  if (descriptionController.text.trim().isEmpty) {
    _showError('وصف الكتاب مطلوب');
    return false;
  }

  if (selectedCategoryId.value == 0) {
    _showError('تصنيف الكتاب مطلوب');
    return false;
  }

  if (selectedFile.value == null) {
    _showError('ملف الكتاب مطلوب');
    return false;
  }

  return true;
}

// عرض رسالة خطأ مع تفاصيل أكثر
void _showError(String message) {
  Get.snackbar(
    'بيانات ناقصة',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red[800],
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 500),
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    icon: const Icon(Icons.error_outline, color: Colors.white),
  );
}

// عرض رسالة نجاح
void _showSuccess(String message) {
  Get.snackbar(
    'تم بنجاح',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green[800],
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 500),
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
  );
}
  // تحميل الأقسام
  // Future<void> loadDepartments() async {
  //   if (selectedCollegeId.value == 0) {
  //     departments.clear();
  //     return;
  //   }

  //   try {
  //     // يمكن استبدال هذا بدالة فعلية لجلب الأقسام من السيرفر حسب الكلية
  //     switch (selectedCollegeId.value) {
  //       case 1: // كلية الهندسة
  //         departments.value = [
  //           {'id': 1, 'name': 'الهندسة المدنية'},
  //           {'id': 2, 'name': 'الهندسة الكهربائية'},
  //           {'id': 3, 'name': 'الهندسة الميكانيكية'},
  //         ];
  //         break;
  //       case 2: // كلية العلوم
  //         departments.value = [
  //           {'id': 4, 'name': 'الرياضيات'},
  //           {'id': 5, 'name': 'الفيزياء'},
  //           {'id': 6, 'name': 'الكيمياء'},
  //         ];
  //         break;
  //       case 3: // كلية الطب
  //         departments.value = [
  //           {'id': 7, 'name': 'الطب البشري'},
  //           {'id': 8, 'name': 'طب الأسنان'},
  //           {'id': 9, 'name': 'الصيدلة'},
  //         ];
  //         break;
  //       case 4: // كلية الحاسوب
  //         departments.value = [
  //           {'id': 10, 'name': 'علوم الحاسوب'},
  //           {'id': 11, 'name': 'نظم المعلومات'},
  //           {'id': 12, 'name': 'هندسة البرمجيات'},
  //         ];
  //         break;
  //       default:
  //         departments.value = [];
  //     }
  //   } catch (e) {
  //     // استخدام بيانات محلية في حالة الفشل
  //   }
  // }

  // اختيار ملف
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt'
        ],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // التحقق من حجم الملف (الحد الأقصى: 20 ميجابايت)
        if (file.lengthSync() > 20 * 1024 * 1024) {
          Get.snackbar(
            'خطأ',
            'حجم الملف كبير جداً. الحد الأقصى هو 20 ميجابايت.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        selectedFile.value = file;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الملف. يرجى المحاولة مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // مسح الملف المحدد
  void clearSelectedFile() {
    selectedFile.value = null;
  }

  // تحديد نوع الملف
  String _getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.pdf':
        return 'PDF';
      case '.doc':
      case '.docx':
        return 'Microsoft Word';
      case '.xls':
      case '.xlsx':
        return 'Microsoft Excel';
      case '.ppt':
      case '.pptx':
        return 'PowerPoint';
      case '.txt':
        return 'Text Files';
      default:
        return 'Other';
    }
  }

  // التحقق من صحة البيانات

  // رفع الكتاب
  Future<void> uploadBook() async {
    if (!validateData()) {
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      // إنشاء FormData لرفع الملف
      final file = selectedFile.value!;
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'description': descriptionController.text.trim(),
        'category_id': selectedCategoryId.value,
        'college_id':
            selectedCollegeId.value == 0 ? null : selectedCollegeId.value,
        'department_id':
            selectedDepartmentId.value == 0 ? null : selectedDepartmentId.value,
        'level': selectedLevel.value.isEmpty ? null : selectedLevel.value,
        'type': selectedBookType.value,
        'code': codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // رفع الكتاب إلى السيرفر
      final response = await _repository.addBook(formData);

      // عرض رسالة نجاح
      Get.snackbar(
        'نجاح',
        'تم رفع الكتاب بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // العودة إلى الصفحة السابقة
      Get.back(result: true);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ أثناء رفع الكتاب. يرجى المحاولة مرة أخرى.';

      Get.snackbar(
        'خطأ',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
