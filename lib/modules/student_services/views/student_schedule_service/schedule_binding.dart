import 'package:get/get.dart';

import 'schedule_controller.dart';
import 'schedule_storage_service.dart';
import 'schedule_sync_service.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // تسجيل خدمات الجدول الدراسي
    Get.lazyPut<ScheduleStorageService>(() => ScheduleStorageService());
    Get.lazyPut<ScheduleSyncService>(() => ScheduleSyncService());
    
    // تسجيل متحكم الجدول الدراسي
    Get.lazyPut<ScheduleController>(() => ScheduleController());
  }
}
