import 'package:get/get.dart';
import 'package:student_app/core/services/storage_service.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/repositories/chat_repository.dart';
import 'package:student_app/modules/chats/models/chat_model.dart'; // Assuming ChatModel can represent a user

class BlockedUsersController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  RxList<ChatModel> blockedUsers = <ChatModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    isLoading(true);
    try {
      final List<int> blockedIds = _storageService.getBlockedUserIds();
      // In a real application, you would fetch user details from your backend
      // based on these IDs. For now, we'll simulate it or use existing chat data.
      // Assuming ChatRepository.getChats() returns all chats, we can filter them.
      final allChats = await _chatRepository.getChats();
      blockedUsers.assignAll(
          allChats.where((chat) => blockedIds.contains(chat.id)).toList());
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المستخدمين المحظورين: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      isLoading(true);
      await _chatRepository.unblockUser(userId);
      await _storageService.removeBlockedUserId(userId);
      blockedUsers.removeWhere((user) => user.id == userId);
      // تحديث قائمة الدردشات في ChatController
      Get.find<ChatController>().loadChats();
      Get.snackbar(
        'تم إلغاء الحظر',
        'تم إلغاء حظر المستخدم بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إلغاء حظر المستخدم: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }
}
