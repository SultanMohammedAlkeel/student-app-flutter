import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final Rx<AuthStatus> status = AuthStatus.unauthenticated.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final AuthRepository _authRepo = Get.find();
  // ignore: unused_field
  final StorageService _storage = Get.find();

  @override
  void onInit() {
    _checkAuthStatus();
    super.onInit();
  }

  Future<void> _checkAuthStatus() async {
    status.value = AuthStatus.loading;
    user.value = await _authRepo.getCurrentUser();
    status.value = user.value != null 
        ? AuthStatus.authenticated 
        : AuthStatus.unauthenticated;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    user.value = null;
    status.value = AuthStatus.unauthenticated;
    Get.offAllNamed(AppRoutes.login);
  }
}

enum AuthStatus { authenticated, unauthenticated, loading }