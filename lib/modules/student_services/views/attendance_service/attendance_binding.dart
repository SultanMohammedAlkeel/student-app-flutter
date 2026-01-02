// ملف التهيئة والربط لخدمة سجلات الحضور والغياب

import 'package:get/get.dart';
import 'attendance_controller.dart';
import 'attendance_storage_service.dart';
import 'attendance_sync_service.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل خدمات التخزين والمزامنة
    Get.lazyPut<AttendanceStorageService>(() => AttendanceStorageService());
    Get.lazyPut<AttendanceSyncService>(() => AttendanceSyncService());
    
    // تسجيل المتحكم
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}

// ملف التهيئة الأولية للخدمة
class AttendanceInitializer {
  static Future<void> initialize() async {
    // تسجيل الخدمات في GetX
    Get.put<AttendanceStorageService>(AttendanceStorageService());
    Get.put<AttendanceSyncService>(AttendanceSyncService());
    
    print('تم تهيئة خدمة سجلات الحضور والغياب بنجاح');
  }
}

