import 'package:get/get.dart';
import 'package:student_app/modules/chats/controllers/chat_controller.dart';
import 'package:student_app/modules/chats/controllers/create_new_chat_controller.dart';
import 'package:student_app/modules/chats/repositories/chat_repository.dart';

class CreateNewChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewChatController>(
      () => CreateNewChatController(),
    );
    Get.lazyPut<ChatController>(
      () => ChatController(),
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepository(),
    );
  }
}
