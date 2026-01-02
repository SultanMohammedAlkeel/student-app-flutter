import 'package:get/get.dart';
import 'package:student_app/modules/chats/controllers/blocked_users_controller.dart';

class BlockedUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockedUsersController>(() => BlockedUsersController());
  }
}
