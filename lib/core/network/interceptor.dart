import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = Get.find<StorageService>();
    final token = storage.getString('auth_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(response, ResponseInterceptorHandler handler) {
    // يمكنك معالجة الاستجابة هنا
    super.onResponse(response, handler);
  }

  @override
  void onError( err, ErrorInterceptorHandler handler) {
    // معالجة الأخطاء هنا
    super.onError(err, handler);
  }
}
