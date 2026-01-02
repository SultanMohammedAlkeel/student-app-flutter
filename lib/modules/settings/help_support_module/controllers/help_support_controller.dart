import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:student_app/core/network/api_service.dart';
import '../models/complaint_feedback_model.dart';
import '../data/user_guide_data.dart';
import '../data/faq_data.dart';

class HelpSupportController extends GetxController {
  final _apiService = Get.find<ApiService>();

  // Loading states
  final RxBool isSubmittingComplaint = false.obs;
  final RxBool isLoadingUserGuide = false.obs;
  final RxBool isLoadingFAQ = false.obs;

  // Form controllers for complaint/feedback
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedType = 'feedback'.obs; // 'complaint' or 'feedback'

  // User guide data
  final RxList<Map<String, dynamic>> userGuideData =
      <Map<String, dynamic>>[].obs;
  final RxInt selectedGuideSection = 0.obs;

  // FAQ data
  final RxList<Map<String, dynamic>> faqData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredFAQData =
      <Map<String, dynamic>>[].obs;
  final RxString selectedFAQCategory = 'الكل'.obs;
  final TextEditingController faqSearchController = TextEditingController();

  // Contact information
  final RxMap<String, dynamic> contactInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserGuideData();
    loadFAQData();
    loadContactInfo();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    faqSearchController.dispose();
    super.onClose();
  }

  /// Load user guide data from local storage
  void loadUserGuideData() {
    isLoadingUserGuide.value = true;
    try {
      userGuideData.value = UserGuideData.getUserGuideData();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل دليل الاستخدام',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoadingUserGuide.value = false;
    }
  }

  /// Load FAQ data from local storage
  void loadFAQData() {
    isLoadingFAQ.value = true;
    try {
      faqData.value = FAQData.getFAQData();
      filteredFAQData.value = faqData;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الأسئلة الشائعة',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoadingFAQ.value = false;
    }
  }

  /// Load contact information (static data)
  void loadContactInfo() {
    contactInfo.value = {
      'phones': [
        {'label': 'الدعم التقني', 'number': '+967-1-234567'},
        {'label': 'شؤون الطلاب', 'number': '+967-1-234568'},
        {'label': 'الطوارئ', 'number': '+967-1-234569'},
      ],
      'emails': [
        {'label': 'الدعم التقني', 'email': 'support@thamar.edu.ye'},
        {'label': 'شؤون الطلاب', 'email': 'students@thamar.edu.ye'},
        {'label': 'عام', 'email': 'info@thamar.edu.ye'},
      ],
      'social_media': [
        {
          'platform': 'واتساب',
          'icon': 'whatsapp',
          'url': 'https://wa.me/967123456789',
          'display': '+967 123 456 789'
        },
        {
          'platform': 'تلجرام',
          'icon': 'telegram',
          'url': 'https://t.me/thamar_university',
          'display': '@thamar_university'
        },
        {
          'platform': 'فيسبوك',
          'icon': 'facebook',
          'url': 'https://facebook.com/thamar.university',
          'display': 'جامعة ذمار'
        },
        {
          'platform': 'انستغرام',
          'icon': 'instagram',
          'url': 'https://instagram.com/thamar_university',
          'display': '@thamar_university'
        },
      ],
      'office_hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
      'address':
          'جامعة ذمار، كلية الحاسبات والمعلوماتية، قسم تكنولوجيا المعلومات',
    };
  }

  /// Submit complaint or feedback
  Future<void> submitComplaintFeedback() async {
    if (!_validateForm()) return;

    isSubmittingComplaint.value = true;

    try {
      final complaintFeedback = ComplaintFeedbackModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: selectedType.value,
      );

      final response = await _apiService.submitComplaintFeedback(
        type: complaintFeedback.type,
        title: complaintFeedback.title,
        description: complaintFeedback.description,
      );

      // التعديل هنا: الوصول إلى البيانات عبر response.data
      // تأكد أن response.data هو من نوع Map<String, dynamic> أو ما شابه
      if (response.data != null && response.data['success']) {
        Get.snackbar(
          'نجح الإرسال',
          response.data['message'], // الوصول إلى الرسالة عبر response.data
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 4),
        );
        _clearForm();
        Get.back(); // Close the form page
      } else {
        // التعامل مع حالة عدم وجود 'success' أو قيمتها false
        String errorMessage = 'فشل الإرسال';
        if (response.data != null && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        Get.snackbar(
          'فشل الإرسال',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    } on DioException catch (e) {
      // يمكنك هنا التعامل مع أخطاء الشبكة أو الخادم بشكل أكثر تفصيلاً
      String errorMessage = 'حدث خطأ في الاتصال بالخادم.';
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      Get.snackbar(
        'خطأ',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSubmittingComplaint.value = false;
    }
  }

  /// Validate complaint/feedback form
  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ في البيانات',
        'يرجى إدخال عنوان للرسالة',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return false;
    }

    if (titleController.text.trim().length < 5) {
      Get.snackbar(
        'خطأ في البيانات',
        'العنوان يجب أن يكون 5 أحرف على الأقل',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ في البيانات',
        'يرجى إدخال وصف للرسالة',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return false;
    }

    if (descriptionController.text.trim().length < 10) {
      Get.snackbar(
        'خطأ في البيانات',
        'الوصف يجب أن يكون 10 أحرف على الأقل',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return false;
    }

    return true;
  }

  /// Clear complaint/feedback form
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedType.value = 'feedback';
  }

  /// Set complaint/feedback type
  void setType(String type) {
    selectedType.value = type;
  }

  /// Select user guide section
  void selectGuideSection(int index) {
    selectedGuideSection.value = index;
    Get.forceAppUpdate();
  }

  /// Filter FAQ by category
  void filterFAQByCategory(String category) {
    selectedFAQCategory.value = category;
    if (category == 'الكل') {
      filteredFAQData.value = faqData;
    } else {
      filteredFAQData.value =
          faqData.where((item) => item['category'] == category).toList();
    }
  }

  /// Search in FAQ
  void searchFAQ(String query) {
    if (query.trim().isEmpty) {
      filterFAQByCategory(selectedFAQCategory.value);
      return;
    }

    final searchResults = FAQData.searchQuestions(query);
    filteredFAQData.value = FAQData.getFAQData()
        .where((category) => searchResults
            .any((result) => result['category'] == category['category']))
        .map((category) => {
              ...category,
              'questions': category['questions']
                  .where((question) => searchResults.any(
                      (result) => result['question'] == question['question']))
                  .toList(),
            })
        .where((category) => (category['questions'] as List).isNotEmpty)
        .toList();
  }

  /// Get FAQ categories
  List<String> getFAQCategories() {
    return ['الكل', ...FAQData.getCategories()];
  }

  /// Launch URL (for contact links)
  Future<void> launchURL(String url) async {
    try {
      // يجب إضافة url_launcher package واستخدامه هنا
      // await launch(url);
      Get.snackbar(
        'رابط',
        'سيتم فتح: $url',
        backgroundColor: Colors.blue.withOpacity(0.1),
        colorText: Colors.blue,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الرابط',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  /// Copy text to clipboard
  Future<void> copyToClipboard(String text) async {
    try {
      // يجب إضافة flutter/services واستخدام Clipboard.setData
      Get.snackbar(
        'تم النسخ',
        'تم نسخ النص إلى الحافظة',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'لا يمكن نسخ النص',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
