import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/app/routes/app_pages.dart';
import 'package:student_app/core/services/auth_service.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkAuthStatus();
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/app_logo.png'),
      ),
    );
  }

  void _checkAuthStatus() {
    final isLoggedIn = Get.find<AuthService>().isLoggedInSync();
    Get.offAllNamed(isLoggedIn ? AppRoutes.home : AppRoutes.login);
  }
}