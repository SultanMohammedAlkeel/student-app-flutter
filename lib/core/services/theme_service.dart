
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class ThemeService extends GetxService {
//   final GetStorage _box = GetStorage();
//   final String _key = 'isDarkMode';

//   ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;

//   bool get isDarkMode => 
//       _loadTheme() ? ThemeMode.dark == ThemeMode.dark : ThemeMode.light == ThemeMode.light;

//   bool _loadTheme() => _box.read(_key) ?? false;

//   Future<void> saveTheme(bool isDarkMode) async {
//     await _box.write(_key, isDarkMode);
//     Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
//   }

//   Future<void> switchTheme() async {
//     await saveTheme(!_loadTheme());
//   }

//   Future<ThemeService> init() async {
//     return this;
//   }

//   void toggleTheme() {
//     bool currentTheme = _loadTheme();
//     saveTheme(!currentTheme);

//   }
// }