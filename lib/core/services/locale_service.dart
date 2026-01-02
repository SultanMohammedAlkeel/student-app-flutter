import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:student_app/core/services/storage_service.dart';

class LocaleService extends GetxService {
  final RxString currentLocale = 'ar'.obs;
  final StorageService storageService = Get.find<StorageService>();
  @override
  void onInit() {
    super.onInit();
    initLocale();
  }
  
  // تهيئة اللغة
  Future<void> initLocale() async {
    // تهيئة بيانات التاريخ للغة العربية
    await initializeDateFormatting('ar', null);
    
    // تهيئة بيانات التاريخ للغة الإنجليزية (احتياطي)
    await initializeDateFormatting('en', null);
    
    // استرجاع اللغة المحفوظة
    final savedLocale = storageService.getLocale();
    currentLocale.value = savedLocale;
    
    // تعيين اللغة في التطبيق
    await updateLocale(savedLocale);
  }
  
  // تحديث اللغة
  Future<void> updateLocale(String localeCode) async {
    Locale locale;
    
    switch (localeCode) {
      case 'ar':
        locale = const Locale('ar', 'SA');
        break;
      case 'en':
        locale = const Locale('en', 'US');
        break;
      default:
        locale = const Locale('ar', 'SA');
    }
    
    // تحديث اللغة في GetX
    Get.updateLocale(locale);
    
    // حفظ اللغة في التخزين المحلي
    await storageService.saveLocale(localeCode);
    
    currentLocale.value = localeCode;
  }
  
  // تنسيق التاريخ حسب اللغة الحالية
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(currentLocale.value).format(date);
  }
  
  // تنسيق الوقت حسب اللغة الحالية
  String formatTime(DateTime time) {
    return DateFormat.jm(currentLocale.value).format(time);
  }
  
  // تنسيق اليوم حسب اللغة الحالية
  String formatDay(DateTime date) {
    return DateFormat.EEEE(currentLocale.value).format(date);
  }
  
  // الحصول على اسم اليوم من رقم اليوم في الأسبوع
  String getDayName(int weekday) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: now.weekday - weekday));
    return formatDay(date);
  }
  
  // تبديل اللغة
  Future<void> toggleLocale() async {
    final newLocale = currentLocale.value == 'ar' ? 'en' : 'ar';
    await updateLocale(newLocale);
  }
}
