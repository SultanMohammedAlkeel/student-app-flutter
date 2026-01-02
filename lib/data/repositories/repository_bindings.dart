import 'package:get/get.dart';
import 'auth_repository.dart';

class RepositoryBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRepository(), fenix: true);
    // يمكن إضافة مستودعات أخرى هنا
  }
}