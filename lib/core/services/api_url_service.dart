import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUrlService extends GetxService {
  static const String _apiUrlKey = 'api_base_url';
  static const String _defaultApiUrl = 'http://192.168.1.9:8000/'; // القيمة الافتراضية

  late SharedPreferences _prefs;
  final RxString _currentApiUrl = ''.obs;

  String get currentApiUrl => _currentApiUrl.value.isNotEmpty 
      ? _currentApiUrl.value 
      : _defaultApiUrl;

  String get apiBaseUrl => currentApiUrl.endsWith('/') 
      ? currentApiUrl 
      : '$currentApiUrl/';

  String get apiUrl => '${apiBaseUrl}api/';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeService();
  }

  Future<void> _initializeService() async {
    _prefs = await SharedPreferences.getInstance();
    _currentApiUrl.value = _prefs.getString(_apiUrlKey) ?? _defaultApiUrl;
  }

  Future<void> setApiUrl(String url) async {
    // تنظيف الرابط وإضافة البروتوكول إذا لم يكن موجوداً
    String cleanUrl = _cleanUrl(url);
    
    await _prefs.setString(_apiUrlKey, cleanUrl);
    _currentApiUrl.value = cleanUrl;
  }

  String _cleanUrl(String url) {
    // إزالة المسافات
    url = url.trim();
    
    // إضافة البروتوكول إذا لم يكن موجوداً
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    
    // إزالة الشرطة المائلة في النهاية إذا كانت موجودة
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    return url;
  }

  String getDefaultApiUrl() {
    return _defaultApiUrl;
  }

  Future<void> resetToDefault() async {
    await setApiUrl(_defaultApiUrl);
  }

  bool isDefaultUrl() {
    return currentApiUrl == _defaultApiUrl;
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }
    
    return '${apiBaseUrl}$imagePath';
  }

  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(_cleanUrl(url));
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
}


