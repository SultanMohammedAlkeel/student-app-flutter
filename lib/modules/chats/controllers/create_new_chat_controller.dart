import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/views/pages/chat_page.dart';

class CreateNewChatController extends GetxController {
  final ChatController chatController = Get.find<ChatController>();

  final RxList<Map<String, dynamic>> availableUsers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedUserType = 'الكل'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> userTypes = ['الكل', 'مشرف', 'معلم', 'طالب'];

  @override
  void onInit() {
    super.onInit();
    _loadAvailableUsers();
    debounce(searchQuery, (_) => _applySearchFilter(),
        time: const Duration(milliseconds: 300));
    ever(selectedUserType, (_) => _filterUsersByType(selectedUserType.value));
  }

  /// تحميل المستخدمين المتاحين من الخادم
  Future<void> _loadAvailableUsers() async {
    try {
      isLoading(true);
      print('تحميل المستخدمين المتاحين...');

      final users = await chatController.repository.getAvailableUsers();

      availableUsers.assignAll(users);
      filteredUsers.assignAll(users);
      isLoading(false);

      print('تم تحميل ${users.length} مستخدم متاح');
    } catch (e) {
      print('خطأ في تحميل المستخدمين المتاحين: $e');

      isLoading(false);

      Get.snackbar(
        'خطأ',
        'فشل في تحميل المستخدمين المتاحين',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// تصفية المستخدمين حسب النوع
  Future<void> _filterUsersByType(String type) async {
    try {
      selectedUserType.value = type;
      isLoading(true);

      print('تصفية المستخدمين حسب النوع: $type');

      final users = await chatController.repository
          .getAvailableUsers(type: type == 'الكل' ? null : type);

      availableUsers.assignAll(users);
      filteredUsers.assignAll(users);
      isLoading(false);

      _applySearchFilter();

      print('تم تصفية ${users.length} مستخدم حسب النوع: $type');
    } catch (e) {
      print('خطأ في تصفية المستخدمين: $e');

      isLoading(false);

      Get.snackbar(
        'خطأ',
        'فشل في تصفية المستخدمين',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// تطبيق تصفية البحث
  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      filteredUsers.assignAll(availableUsers);
    } else {
      filteredUsers.assignAll(availableUsers.where((user) {
        final name = _getSafeString(user['name']).toLowerCase();
        final email = _getSafeString(user['email']).toLowerCase();
        final userType = _getSafeString(user['user']).toLowerCase();
        final query = searchQuery.toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            userType.contains(query);
      }).toList());
    }
  }

  /// إضافة مستخدم إلى قائمة الاتصالات (نفس منطق ContactController)
  Future<void> addUserToContacts(Map<String, dynamic> user) async {
    try {
      print('إضافة مستخدم إلى قائمة الاتصالات: ${user['name']}');

      // إظهار مؤشر التحميل
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // إضافة المستخدم إلى قائمة الاتصالات عبر API (نفس منطق ContactController)
      final success = await chatController.repository
          .addContact(user['id'], _getSafeString(user['user']));

      // إخفاء مؤشر التحميل
      Get.back();

      if (success) {
        print('تم إضافة المستخدم بنجاح إلى قائمة الاتصالات');

        // إعادة تحميل قائمة المحادثات من الخادم
        await chatController.loadChats();

        // البحث عن الـ chatId للمحادثة الجديدة
        final newChat = chatController.chats.firstWhereOrNull(
          (chat) => chat.name == user['name'], // Assuming 'name' is unique
        );

        if (newChat != null) {
          // إظهار رسالة نجاح
          Get.snackbar(
            'تم بنجاح',
            'تم إضافة ${_getSafeString(user['name'])} إلى قائمة الدردشات',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle, color: Colors.green),
          );

          // العودة إلى صفحة الدردشات مع إشارة التحديث ثم التوجيه إلى صفحة المراسلة
          Get.back(result: {'updated': true, 'addedUser': user});
          Get.to(() =>
              ChatDetailPage(chatId: newChat.id, isdarkMode: Get.isDarkMode));
        } else {
          print('لم يتم العثور على المحادثة الجديدة بعد الإضافة.');
          Get.snackbar(
            'خطأ',
            'تم إضافة المستخدم ولكن لم يتم العثور على المحادثة. يرجى المحاولة مرة أخرى.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.warning, color: Colors.orange),
          );
        }
      } else {
        print('فشل في إضافة المستخدم إلى قائمة الاتصالات');

        Get.snackbar(
          'خطأ',
          'فشل في إضافة المستخدم. قد يكون موجوداً بالفعل.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e) {
      print('خطأ في إضافة المستخدم: $e');

      // إخفاء مؤشر التحميل إذا كان مفتوحاً
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'خطأ',
        'حدث خطأ في إضافة المستخدم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  /// الحصول على سلسلة نصية آمنة
  String _getSafeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// الحصول على لون نوع المستخدم
  Color getUserTypeColor(String userType) {
    switch (userType) {
      case 'مشرف':
        return Colors.purple;
      case 'معلم':
        return Colors.blue;
      case 'طالب':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على أيقونة نوع المستخدم
  IconData getUserTypeIcon(String userType) {
    switch (userType) {
      case 'مشرف':
        return Icons.admin_panel_settings;
      case 'معلم':
        return Icons.school;
      case 'طالب':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Future<void> refreshUsers() async {
    await _loadAvailableUsers();
  }

  /// الحصول على سلسلة نصية آمنة
  String getSafeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
